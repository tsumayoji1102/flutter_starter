help:
	@echo "Usage:"
	@echo "  make build_runner         - Run build_runner to generate code"
	@echo "  make format               - Format Dart code and apply fixes"
	@echo "  make build_runner_watch   - Watch for changes and run build_runner"
	@echo "  make l10n                 - Generate localization files"
	@echo "  make ios_cache_clear      - Clear iOS cache"
	@echo "  make cache_clear          - Clear Flutter and iOS caches"
	@echo "  make cache_repair         - Repair Flutter pub cache"
	@echo "  make help                 - Show this help message"

.DEFAULT_GOAL := setup


build_runner:
	flutter pub run build_runner build --delete-conflicting-outputs

format:
	dart fix --apply

build_runner_watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

l10n:
	flutter gen-l10n

ios-cache_clear:
	flutter clean
	rm -rf ~/Library/Developer/Xcode/DerivedData
	rm -rf ~/Library/Caches/com.apple.dt.Xcode

cache_clear:
	cd ios
	rm Podfile.lock
	pod install
	cd ..
	flutter clean
	flutter pub get

cache_repair:
	flutter pub cache repair