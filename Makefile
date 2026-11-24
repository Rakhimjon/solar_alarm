.PHONY: all get clean clean_all runner watch format analyze test e2e maestro-install apk bundle ios icon help

help:
	@echo "Available commands:"
	@echo "  make get        - Run flutter pub get"
	@echo "  make clean      - Clean build cache"
	@echo "  make clean_all  - Full clean and rebuild"
	@echo "  make runner     - Generate code (bloc, freezed, json)"
	@echo "  make watch      - Watch & auto-generate code"
	@echo "  make icon       - Generate Android & iOS launcher icons"
	@echo "  make format     - Format all dart files"
	@echo "  make analyze    - Run flutter analyze"
	@echo "  make test       - Run unit tests"
	@echo "  make e2e        - Run Maestro E2E test suite"
	@echo "  make run        - Run flutter app"
	@echo "  make apk        - Build release APK"
	@echo "  make bundle     - Build release AppBundle"

icon:
	dart run flutter_launcher_icons

get:
	flutter pub get

clean:
	flutter clean

clean_all:
	flutter clean
	rm -rf pubspec.lock .dart_tool/
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs

runner:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

format:
	dart format lib test

analyze:
	flutter analyze

test:
	flutter test

maestro-install:
	curl -FsSL "https://get.maestro.mobile.dev" | bash

e2e:
	maestro test .maestro/suite.yaml

run:
	flutter run

apk:
	flutter build apk --release

bundle:
	flutter build appbundle --release

ios:
	flutter build ios --release --no-codesign
