import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/auth_http_client.dart';

/// Google Drive から app_data.json を取得するデータソース。
/// フォルダ ID は設定で選択済みであること。
class DrivePortfolioDatasource {
  DrivePortfolioDatasource({
    required GoogleSignIn googleSignIn,
    String? appDataFileName,
  })  : _googleSignIn = googleSignIn,
        _appDataFileName = appDataFileName ?? AppConstants.appDataFileName;

  final GoogleSignIn _googleSignIn;
  final String _appDataFileName;

  /// 指定フォルダ内の app_data.json の内容を取得する。
  /// 未サインイン・ファイル未存在時は [AppException] を投げる。
  Future<String> getAppDataJson(String folderId) async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw const DataFetchException(
        'サインインしてください',
      );
    }

    final client = AuthHttpClient(() => account.authHeaders);
    final driveApi = drive.DriveApi(client);

    try {
      final fileList = await driveApi.files.list(
        q: "'$folderId' in parents and name = '$_appDataFileName' and trashed = false",
        pageSize: 1,
        $fields: 'files(id, name)',
      );

      final files = fileList.files;
      if (files == null || files.isEmpty) {
        throw DataNotFoundException(
          '指定フォルダに $_appDataFileName が見つかりません',
        );
      }

      final fileId = files.first.id;
      if (fileId == null || fileId.isEmpty) {
        throw const DataFetchException('ファイル ID を取得できませんでした');
      }

      final result = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (result is! drive.Media) {
        throw const ParseException('ファイル内容の取得に失敗しました');
      }
      final media = result;
      final bytes = await media.stream.toList();
      final combined = bytes.expand((e) => e).toList();
      return utf8.decode(combined);
    } finally {
      client.close();
    }
  }

  /// 指定親フォルダ直下のフォルダ一覧を取得する（ピッカー用）。
  /// [parentId] に 'root' を渡すとルート直下のフォルダを返す。
  Future<List<DriveFolderItem>> listFolders(String parentId) async {
    final account = _googleSignIn.currentUser;
    if (account == null) {
      throw const DataFetchException('サインインしてください');
    }

    final client = AuthHttpClient(() => account.authHeaders);
    final driveApi = drive.DriveApi(client);

    try {
      const folderMimeType = "application/vnd.google-apps.folder";
      final fileList = await driveApi.files.list(
        q: "'$parentId' in parents and mimeType = '$folderMimeType' and trashed = false",
        orderBy: 'name',
        pageSize: 100,
        $fields: 'files(id, name)',
      );

      final files = fileList.files ?? <drive.File>[];
      return files
          .where((f) => f.id != null && f.name != null)
          .map((f) => DriveFolderItem(id: f.id!, name: f.name!))
          .toList();
    } finally {
      client.close();
    }
  }
}

/// フォルダピッカー用の 1 件分。
class DriveFolderItem {
  const DriveFolderItem({required this.id, required this.name});
  final String id;
  final String name;
}
