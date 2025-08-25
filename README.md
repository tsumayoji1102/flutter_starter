# flutter_starter

これを使えば、ある程度揃った状態で Flutter 開発を始められる。

- `lib/src`より、いきなり実装を書いていける。
- `lib/l10n`より、多言語化設定を初期から設定できる。
- Makefile によく使うコマンドをまとめている。
- fvm 導入済み。
- flavor 設定済み。`.vscode/launch.json`より確認して欲しい。
  - ios はすでに dart-defines を設定している。

## 必要な設定

- fvm の環境構築。
- dart_defines に dev.json, prod.json を追加する必要がある。(.gitignore に追加されているので注意)
- bundle id が flutter_starter（キャメルになってる箇所もあるので確認必要）に設定されているので、全てを書き換える必要あり。
  - 環境設定からできれば一番いいがまだやってない。
