# flutter_starter

これを使えば、ある程度揃った状態で Flutter 開発を始められる。

- `lib`より、いきなり実装を書いていける。
- Makefile によく使うコマンドをまとめている。
- `lib/l10n`より、多言語化設定を初期から設定できる。
  - `$ make l10n`実行で、arb に追加した要素を生成できる。
- fvm 導入済み。
- flavor 設定済み。`.vscode/launch.json`より確認して欲しい。
  - ios はすでに dart-defines を設定している。
- ライブラリは最新の状態で入れておきたいので、`flutter_flavorizr`, `intl`以外は外部のものを入れていない。
- `instructions`ディレクトリ内に AI 用の指示をまとめており、現状 Copilot, Cursor ではこちらを参照するように設定している。
  - AI 用の指示がしたい場合は、こちらに追記していったり、README.md を適宜追加して参照するようにして欲しい。

## 参考にしている構成

- Flutter Project Structure: Feature-first or Layer-first?
  - https://codewithandrea.com/articles/flutter-project-structure/

## 推奨環境

- エディタ: VSCode, Cursor（.vscode に設定を追加しているため、他エディタでは別設定が必要）
- `main.dart`, `app.dart`, `flavors.dart`は flutter_flavorizr によって生成されるため、配置を変えないほうが良い（少なくとも flutter_flavorizr の設定を変更しうる限り）。

## 必要な設定

- [ ] fvm の環境構築。
- [ ] `dart_defines` に dev.json, prod.json を追加されているが、.gitignore に追加すること
- [ ] `flutter_flavorizr`の設定。
  - [ ] まず、このライブラリが最新であるかを確認。最新でなければアップデート。
  - [ ] `flavorizr.yaml`に必要な情報をいれて、`$ make flavorizr`を実行。
