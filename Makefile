# format は Dart 3+ の dart が必要。システムの dart が 2.x の場合は
# IDE のフォーマット機能（Flutter SDK 使用）を利用するか、PATH を調整すること。
.PHONY: fix
fix:
	flutter analyze .
	dart format .
