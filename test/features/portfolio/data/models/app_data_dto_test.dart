import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_app/features/portfolio/data/models/app_data_dto.dart';

void main() {
  group('AppDataDto', () {
    test('fromJson parses fixture app_data.json', () {
      final file = File('test/fixtures/app_data.json');
      expect(file.existsSync(), isTrue);

      final jsonString = file.readAsStringSync();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final dto = AppDataDto.fromJson(json);

      expect(dto.holdings.length, 3);
      expect(dto.holdings[0].symbol, 'AAPL');
      expect(dto.holdings[0].quantity, 10.0);
      expect(dto.holdings[0].valueUsd, 2000.0);
      expect(dto.holdings[0].valueJpy, 300000.0);
      expect(dto.holdings[0].ratio, 50.0);

      expect(dto.sectors.length, 3);
      expect(dto.sectors[0].symbol, 'AAPL');
      expect(dto.sectors[0].sector, 'Information Technology');

      expect(dto.sectorAllocation.length, 2);
      expect(
        dto.sectorAllocation['Information Technology']?.ratio,
        75,
      );
      expect(dto.sectorAllocation['Communication Services']?.ratio, 25);

      expect(dto.regionExposure['North America'], 100);
      expect(dto.regionExposure['Europe'], 0);

      expect(dto.themeExposure, isEmpty);
      expect(dto.riskTolerance, isEmpty);
    });

    test('toJson then fromJson round-trip', () {
      final file = File('test/fixtures/app_data.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final dto = AppDataDto.fromJson(json);
      final encoded = dto.toJson();
      final decoded = AppDataDto.fromJson(encoded);

      expect(decoded.holdings.length, dto.holdings.length);
      expect(decoded.holdings[0].symbol, dto.holdings[0].symbol);
      expect(decoded.sectorAllocation.length, dto.sectorAllocation.length);
    });
  });
}
