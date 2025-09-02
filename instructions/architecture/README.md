# Flutter App Architecture: Domain Model Instructions for AI

## 概要

このガイドは、FlutterアプリケーションにおけるDomain-Driven Design (DDD) とレイヤードアーキテクチャを実装する際のAI向けInstructionsです。
主にAndrea Bizzottoが提案するRiverpodアーキテクチャをベースとしています。
また、`./detail/README.md` では、各層の詳細な実装ガイドラインが提供されていますのでそちらも参照してください。

## アーキテクチャの全体構成

### 4層構造
1. **Data Layer（データ層）** - 外部データソースとの通信を担当
2. **Domain Layer（ドメイン層）** - エンティティとビジネスロジックを定義
3. **Application Layer（アプリケーション層）** - サービスクラスとビジネスワークフローを管理
4. **Presentation Layer（プレゼンテーション層）** - ウィジェットとコントローラー

### 依存関係の流れ
```
Presentation Layer → Application Layer → Domain Layer ← Data Layer
```

データの流れは一方向で、Data LayerからPresentation Layerへと流れます。

## Domain Layerの詳細仕様

### 1. Domain Model（ドメインモデル）の定義

Domain Modelは以下の要素を含む概念モデルです：
- **データ**: エンティティとそれらの関係性として表現
- **振る舞い**: エンティティを操作するビジネスロジック

### 2. エンティティの例（eCommerceアプリケーション）

```dart
// ProductIDは重要なドメイン概念なので独自の型を定義
typedef ProductID = String;

class Product {
  Product({
    required this.id,
    required this.imageUrl, 
    required this.title,
    required this.price,
    required this.availableQuantity,
  });
  
  final ProductID id;
  final String imageUrl;
  final String title;
  final double price;
  final int availableQuantity;
  
  // シリアライゼーション用メソッド
  factory Product.fromMap(Map<String, dynamic> map, ProductID id) {
    // 実装省略
  }
  
  Map<String, dynamic> toMap() {
    // 実装省略
  }
}
```

### 3. モデルクラスの要件

Domain Layerのモデルクラスは以下の要件を満たす必要があります：

#### 必須要件
- **不変性**: 全てのプロパティは `final` で定義
- **シリアライゼーション**: `fromMap()` / `toMap()` または `fromJson()` / `toJson()` メソッドの実装
- **等価性**: `==` 演算子と `hashCode` メソッドの実装
- **依存関係の排除**: Repository、Service、その他のドメイン外オブジェクトへの依存を持たない

#### 推奨実装
```dart
class Cart {
  const Cart([this.items = const {}]);
  
  /// ショッピングカート内のアイテム
  /// - key: product ID
  /// - value: 数量
  final Map<ProductID, int> items;
  
  factory Cart.fromMap(Map<String, dynamic> map) { /* 実装 */ }
  Map<String, dynamic> toMap() { /* 実装 */ }
  
  @override
  bool operator ==(Object other) => /* 実装 */;
  
  @override
  int get hashCode => /* 実装 */;
}
```

### 4. ビジネスロジックの実装

モデルクラス内でのビジネスロジック実装には Extension を使用します：

```dart
/// ショッピングカート操作用のヘルパーExtension
extension MutableCart on Cart {
  Cart addItem({required ProductID productId, required int quantity}) {
    final copy = Map<ProductID, int>.from(items);
    copy[productId] = quantity + (copy[productId] ?? 0);
    return Cart(copy);
  }
  
  Cart removeItemById(ProductID productId) {
    final copy = Map<ProductID, int>.from(items);
    copy.remove(productId);
    return Cart(copy);
  }
}
```

### 5. 不変性の実装原則

状態管理ソリューションとの連携のため、モデルの変更は以下のパターンで実行：

1. 既存オブジェクトのコピーを作成
2. 必要な変更を適用
3. 新しい不変オブジェクトを返却

## テスト戦略

### 単体テストの実装例

```dart
void main() {
  group('add item', () {
    test('empty cart - add item', () {
      final cart = const Cart()
          .addItem(productId: '1', quantity: 1);
      expect(cart.items, {'1': 1});
    });
    
    test('empty cart - add same item twice', () {
      final cart = const Cart()
          .addItem(productId: '1', quantity: 1)
          .addItem(productId: '1', quantity: 1);
      expect(cart.items, {'1': 2});
    });
  });
}
```

### テストのメリット
- **依存関係なし**: モックや複雑なセットアップが不要
- **高速実行**: 純粋な関数型テストのため高速
- **高価値**: ビジネスロジックのバグを事前に検出

## 設計ガイドライン

### 1. ドメインモデル設計の手順

1. **ドメインの探索**: 必要な概念と振る舞いを特定
2. **エンティティの表現**: 概念をエンティティとその関係性として表現
3. **Dartクラスの実装**: 対応するモデルクラスを実装
4. **ビジネスロジックの実装**: 振る舞いを動作するコードに変換
5. **単体テストの追加**: 振る舞いが正しく実装されているかを検証

### 2. UI設計との連携

- UIに表示するデータと用途を考慮
- ユーザーのインタラクションパターンを反映
- 他の層との接続は後で考慮（Application Layerの責務）

### 3. データソースからの独立性

Domain Layerでは以下を考慮しない：
- データの取得元（API、データベース、ローカルストレージ）
- データの配布方法
- 他システムとの連携方法

これらはData LayerとApplication Layerで処理します。

## プロジェクト構造

### Feature-First アプローチ（推奨）

```
lib/
  src/
    features/
      authentication/
        domain/
        application/
        data/
        presentation/
      products/
        domain/
        application/
        data/
        presentation/
      cart/
        domain/
        application/
        data/
        presentation/
```

### Layer-First アプローチ

```
lib/
  src/
    domain/
      authentication/
      products/
      cart/
    application/
    data/
    presentation/
```

## 関連技術とツール

### シリアライゼーション
- **手動実装**: `fromMap()` / `toMap()` メソッド
- **コード生成**: Freezed パッケージを使用
- **JSON処理**: dart:convert と組み合わせて使用

### 状態管理との連携
- **Riverpod**: Provider経由でモデルにアクセス
- **immutable**: 不変オブジェクトによる状態伝播
- **AsyncValue**: 非同期状態の管理

## 実装時の注意点

### やるべきこと
- ✅ 不変なデータクラスの実装
- ✅ ビジネスロジックのカプセル化
- ✅ 包括的な単体テストの作成
- ✅ 明確な型定義（typedefs）の使用
- ✅ Extension を使用したロジックの分離

### やってはいけないこと
- ❌ Repository や Service への直接依存
- ❌ 可変なプロパティの使用
- ❌ UI層への直接的な結合
- ❌ 外部APIの詳細への依存
- ❌ 複雑な初期化処理の実装

## まとめ

Domain Layerは以下の責務を持ちます：
- **エンティティの定義**: アプリケーション固有のモデルクラス
- **ビジネスロジックの実装**: エンティティ操作の振る舞い
- **データの抽象化**: 実装詳細からの独立性

このアーキテクチャにより、テスト可能で保守しやすく、スケーラブルなFlutterアプリケーションを構築することができます。

---

*このガイドは [Code with Andrea](https://codewithandrea.com) の Flutter App Architecture シリーズを基に作成されています。*