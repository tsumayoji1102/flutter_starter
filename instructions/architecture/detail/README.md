# Flutter Architecture - 関連記事概要
## 1. Flutter App Architecture with Riverpod: An Introduction

**URL**: https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/

### 概要
Riverpodを使用したスケーラブルで保守しやすいFlutterアプリアーキテクチャの包括的な紹介。

### 主要内容
- **4層アーキテクチャ**の詳細説明
  - Data Layer: データソースとの通信
  - Domain Layer: モデルクラスの定義
  - Application Layer: ビジネスワークフロー
  - Presentation Layer: UIとコントローラー

### 各層の役割

#### Presentation Layer（プレゼンテーション層）
- **Widgets**: 画面に表示するデータの表現
- **Controllers**: 非同期データ変更と状態管理を行う
- AsyncNotifier サブクラスとして実装
- UIの主要な役割：アプリケーションデータの表示とユーザー操作の受付

#### Domain Layer（ドメイン層）
- データ層から取得したデータを表現するアプリケーション固有のモデルクラスを定義
- ビジネスロジックとエンティティの関係性を管理

#### Application Layer（アプリケーション層）
- 複数のリポジトリに依存するサービスクラス
- ビジネスワークフローの管理

#### Data Layer（データ層）
- 外部データソース（API、データベース）との通信
- Repository パターンの実装

### Riverpodの活用
- **依存性注入システム**として機能
- **リアクティブキャッシング**とデータバインディング
- Provider、FutureProvider、StreamProviderの使用
- AsyncValueによる状態管理

## 2. Flutter Project Structure: Feature-first or Layer-first?

**URL**: https://codewithandrea.com/articles/flutter-project-structure/

### 概要
中・大規模Flutterアプリにおけるプロジェクト構造の選択肢と、それぞれのトレードオフ。

### Feature-First アプローチ

```
lib/
  src/
    features/
      authentication/
        presentation/
        application/
        domain/
        data/
      products/
        presentation/
        application/  
        domain/
        data/
```

#### メリット
- 機能要件に基づいた構造
- チームメンバーが独立して機能を開発可能
- 機能の追加・削除が容易

#### デメリット
- 複数機能で共有されるモデルやリポジトリの配置が困難
- 初期設定が複雑

### Layer-First アプローチ

```
lib/
  src/
    presentation/
      feature1/
      feature2/
    application/
      feature1/
      feature2/
    domain/
      feature1/
      feature2/
    data/
      feature1/
      feature2/
```

#### メリット
- アーキテクチャの層が明確
- 依存関係の方向が分かりやすい

#### デメリット
- 機能横断的な変更時に複数フォルダを変更する必要
- スケールしづらい

### 推奨アプローチ
1. **ドメイン層から開始**してモデルクラスを特定
2. **関連するモデルごとにフォルダを作成**
3. **必要に応じてサブフォルダを作成**
4. **UIコードが多い場合は、presentation内でサブ機能に分割**

## 3. Flutter App Architecture: The Repository Pattern

**URL**: https://codewithandrea.com/articles/flutter-repository-pattern/

### 概要
Flutterにおけるリポジトリパターンの詳細な説明と実装戦略。

### リポジトリパターンの役割
- **データソースの抽象化**: 複数のデータソース（API、ローカルDB）を統一インターフェースで提供
- **ドメインモデルの分離**: データ実装の詳細からドメインエンティティを保護
- **テスタビリティの向上**: モックしやすいインターフェース提供

### 実装例（天気アプリ）

```dart
abstract class WeatherRepository {
  Future<Weather> getWeather(String city);
}

class HttpWeatherRepository implements WeatherRepository {
  HttpWeatherRepository({required this.api});
  final WeatherApi api;
  
  @override
  Future<Weather> getWeather(String city) async {
    final weatherData = await api.getWeather(city);
    return Weather.fromJson(weatherData);
  }
}
```

### 使用すべき場面
- **複雑なデータ層**を持つアプリケーション
- **複数のエンドポイント**が非構造化データ（JSON）を返す場合
- **サードパーティAPI**の変更から保護したい場合
- **オフライン機能**が必要な場合

### メリット
- API変更時の影響範囲を限定
- テストとモックが容易
- データソースの切り替えが可能
- キャッシュ戦略の実装場所が明確

## 4. Flutter App Architecture: The Application Layer

**URL**: https://codewithandrea.com/articles/flutter-app-architecture-application-layer/

### 概要
アプリケーション層の実装方法と、ショッピングカート機能の実例による詳細解説。

### Application Layer の責務
- **複数のリポジトリに依存**するビジネスロジック
- **ワークフローの管理**
- **データの変換と組み合わせ**

### サービスクラスの実装例

```dart
class CartService {
  CartService({
    required this.authRepository,
    required this.cartRepository,
    required this.productsRepository,
  });
  
  final AuthRepository authRepository;
  final CartRepository cartRepository;
  final ProductsRepository productsRepository;
  
  Future<void> addToCart(ProductID productId) async {
    final user = authRepository.currentUser;
    if (user == null) throw UserNotSignedInException();
    
    final product = await productsRepository.fetchProduct(productId);
    if (product.availableQuantity == 0) {
      throw ProductOutOfStockException();
    }
    
    final cart = await cartRepository.fetchCart(user.uid);
    final updatedCart = cart.addItem(
      productId: productId, 
      quantity: 1
    );
    await cartRepository.setCart(user.uid, updatedCart);
  }
}
```

### いつサービスクラスを作成するか
- **複数のリポジトリ**に依存する処理がある場合
- **複雑なビジネスワークフロー**がある場合
- **単純な転送処理だけなら不要**（コントローラーから直接リポジトリを呼ぶ）

### Riverpod での実装

```dart
@riverpod
CartService cartService(CartServiceRef ref) {
  return CartService(
    authRepository: ref.watch(authRepositoryProvider),
    cartRepository: ref.watch(cartRepositoryProvider),
    productsRepository: ref.watch(productsRepositoryProvider),
  );
}
```

## 5. Flutter App Architecture: The Presentation Layer  

**URL**: https://codewithandrea.com/articles/flutter-presentation-layer/

### 概要
プレゼンテーション層のコントローラークラス実装方法と、認証フローの実例。

### Presentation Layer の構成要素

#### Widgets
- **データの視覚的表現**
- **ConsumerWidget** を継承してRiverpodと連携
- **状態は持たず**、コントローラーから取得

#### Controllers
- **AsyncNotifier** のサブクラスとして実装
- **非同期データ変更**の管理
- **ウィジェット状態**の管理
- **MVVMパターンのViewModel**や **flutter_bloc の Cubit** と同等

### コントローラーの実装例

```dart
@riverpod
class SignInScreenController extends _$SignInScreenController {
  @override
  FutureOr<void> build() {
    // 初期状態
  }
  
  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInAnonymously();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
```

### Widget での使用方法

```dart
class SignInScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<void> state = ref.watch(signInScreenControllerProvider);
    
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: state.isLoading 
            ? const CircularProgressIndicator()
            : const Text('Sign in anonymously'),
          onPressed: state.isLoading 
            ? null
            : () => ref.read(signInScreenControllerProvider.notifier)
                .signInAnonymously(),
        ),
      ),
    );
  }
}
```

### AsyncValue の活用
- **Loading状態**: `AsyncLoading`
- **成功状態**: `AsyncData`
- **エラー状態**: `AsyncError`
- **状態分岐**: `.when()` メソッドでUI分岐

### ベストプラクティス
- **薄いUI層**: 複雑なロジックはコントローラーに分離
- **明確な責任分離**: UIとビジネスロジックの分離
- **テスタビリティ**: コントローラーの単体テスト容易性
- **リアクティブUI**: 状態変更に対する自動的なUI更新

---

## 全体的な設計指針

### 分離の原則
各層は明確な責任を持ち、適切な抽象化レベルを維持する。

### 依存性注入
Riverpodを使用して依存関係を管理し、テストしやすい構造を保つ。

### 単方向データフロー
データはData LayerからPresentation Layerへの一方向に流れる。

### テスタビリティ
各層が独立してテスト可能な設計を心がける。

### スケーラビリティ
チームでの開発と機能追加に対応できる柔軟な構造を維持する。

---

*これらの記事は Andrea Bizzotto の [Code with Andrea](https://codewithandrea.com) で公開されており、Flutter開発におけるベストプラクティスを提供しています。*