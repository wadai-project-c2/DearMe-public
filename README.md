# DEARME — コンペ公開デモ

写真から思い出を登録し、AI加工したプレゼントをアバターの部屋へ飾るFlutterアプリです。運営の共有AWSに接続します。開発PCでバックエンドを起動する必要はありません。

## 最初にお読みください

- **全利用者合計で画像加工は1日50回まで。日本時間0時に切り替わります。** 個人ごとに50回ではありません。
- OpenAIへの加工依頼前に1回分を確保します。加工開始後の失敗・再試行も消費し、払い戻しません。
- 同じIPからの画像加工は5分25リクエストを基準にWAFが制限します。厳密な25回保証ではなく、同じWi-Fiの利用者も枠を共有する場合があります。
- 同時処理は最大5件。混雑時は時間を空けてください。自動連打・大量送信はしないでください。
- 写真とタイトル等は **AWS経由でOpenAIへ送信**されます。個人情報・機密情報・第三者が写った写真は、送信の可否を確認してください。メモや部屋配置は端末内に保存されます。
- `dart_define.demo.json`のアプリトークンは、運営の承認により意図的に公開しています。秘密ではなく、利用者の本人確認にはなりません。第三者が枠を消費する可能性があります。
- **コンペ終了後、運営が手動でトークン・専用OpenAIキーを失効し、共有画像加工サービスを停止します。自動停止ではありません。** 公開ファイルを残しても加工は利用できなくなります。可用性・永続提供は保証しません。
- AWSアクセスキーやOpenAI APIキーは本リポジトリに含めていません。利用者にこれらの入力は不要です。

## 必要な環境

- Git、Flutter **3.44.6**（Dartは同梱）。Flutterの指定バージョンは[.fvmrc](.fvmrc)でも管理しています。
- iOS：macOS、Xcode、iOS Simulator。実機では自分のApple署名設定が必要です。
- Android：Android Studio、Android SDK、エミュレーターまたは実機。
- 本デモはiOS/Android向けです。Web・デスクトップでの動作は保証しません。

## クローンして起動

### 1. リポジトリを取得する（共通）

```sh
git clone https://github.com/wadai-project-c2/DearMe-public.git
cd DearMe-public
```

以降のコマンドは、リポジトリのルート（`DearMe-public`フォルダ内）で実行してください。すでに取得済みの場合は、既存のフォルダに移動すれば大丈夫です。

次の**2-Aか2-Bのどちらか一方**を選んでください。両方を実行する必要はありません。迷った場合は、プロジェクトの指定バージョンを使える**2-A（FVM）を推奨**します。

### 2-A. FVMを使う場合（推奨）

FVMは、プロジェクトごとにFlutterのバージョンを揃えるためのツールです。未導入の場合は、先に[FVMの公式インストール手順](https://fvm.app/documentation/getting-started/installation)に従って導入してください。以下の`fvm install`は、FVM本体ではなく、[.fvmrc](.fvmrc)に指定されたFlutterをインストールするコマンドです。

```sh
fvm install
fvm flutter --version
fvm flutter doctor
fvm flutter pub get
fvm flutter devices
fvm flutter run --dart-define-from-file=dart_define.demo.json
```

上から順に実行し、`fvm flutter --version`で**3.44.6**が表示されることを確認してください。`fvm flutter doctor`で対象OSの開発環境に問題が出た場合は、案内に従って解消してから先に進んでください。

**この方法では、起動・解析・テストなどにも`fvm flutter`を使います。** 通常の`flutter`はPCのPATHなどの設定によって別のFlutterを使う場合があり、`.fvmrc`があるだけでは自動的に切り替わりません。詳しくは[FVMの実行方法](https://fvm.app/documentation/guides/running-flutter)を参照してください。

### 2-B. Flutterを直接インストールして使う場合（FVMなし）

この方法ではFVMは不要です。まず、PCの`flutter`コマンドが使うバージョンを確認してください。

```sh
flutter --version
```

**3.44.6**と表示されることを確認してから、次を実行してください。異なるバージョンの場合は、指定バージョンを用意するか、2-AのFVMを使ってください。

```sh
flutter doctor
flutter pub get
flutter devices
flutter run --dart-define-from-file=dart_define.demo.json
```

`flutter doctor`で対象OSの開発環境に問題が出た場合は、案内に従って解消してから先に進んでください。

### 3. 端末の選択・接続設定の確認（共通）

複数端末がある場合は、`devices`の出力で端末IDを確認し、選んだ方式の`run`コマンドに`-d <device-id>`を追加します。`<device-id>`は実際の端末IDに置き換えてください。

トークンのコピーや追加取得は不要です。**`--dart-define-from-file=dart_define.demo.json`を省くと共有AWSには接続されません。** 設定はビルド時に読み込むため、変更後は再ビルドしてください。

iPhone実機ではXcodeで`ios/Runner.xcworkspace`を開き、Signing & Capabilitiesから自分のTeamと必要に応じて一意のBundle Identifierを設定してください。共有デモ用のApple証明書は付属しません。

## 使い方

1. 初回案内に沿ってプロフィール・アバターを設定します。
2. クリエイト画面から写真登録を開き、写真とタイトルを選び「送信して加工を開始」を押します。
3. 加工中に思い出のメモ等を入力し、記録します。写真とタイトル以外のメモ等は画像加工APIへ送信しません。
4. 加工済みの思い出をプレゼントとしてアバターへ渡し、部屋に配置します。
5. 部屋編集でプレゼントや家具の位置・向きを調整します。角度は45度刻みで調整できます。
6. サウンド設定でBGM・効果音を切り替えられます。

元写真・加工画像・メモ・部屋の配置は端末内保存です。クラウド同期はなく、アプリの削除などで失われる場合があります。大切な元写真は別途保管してください。

## 困ったとき

| 状況 | 対処 |
| --- | --- |
| `fvm`コマンドが見つからない | FVM本体のインストールとPATH設定を確認してください。`fvm install`はFVM本体の導入コマンドではありません |
| `flutter`のバージョンが3.44.6ではない | 2-AのFVMを使うか、直接使うFlutterを指定バージョンに揃えてください |
| 全体の上限50回に達した | 次の日本時間0時以降に再試行。端末の再インストールでは枠は増えません |
| 混雑・短時間の制限 | 数分待って再試行。WAFの拒否は一般的な加工失敗として表示される場合もあります |
| 401・サービス終了後の失敗 | トークン失効の可能性があります。運営の案内を確認してください |
| 通信・503エラー | 通信状態を確認して時間を空ける。日次制限の確認ができない場合も安全のため停止します |
| 写真を送れない | JPEG/PNG/WebP、送信データ4 MiB以下が対象です |
| 加工失敗 | 再試行は追加の1回を消費する場合があります。連打しないでください |

### 共有サービス停止後にUIだけを確認する

次のモックモードを使用できます。実際のAI加工はしません。環境構築時に選んだ方式のコマンドを実行してください。

**FVMを使う場合**

```sh
fvm flutter run --dart-define=DEARME_MOCK_IMAGE_PROCESSING=true
```

**Flutterを直接使う場合（FVMなし）**

```sh
flutter run --dart-define=DEARME_MOCK_IMAGE_PROCESSING=true
```

## 開発・構成

解析・テストも、環境構築時に選んだ方式で実行してください。

**FVMを使う場合**

```sh
fvm flutter analyze
fvm flutter test
```

**Flutterを直接使う場合（FVMなし）**

```sh
flutter analyze
flutter test
```

- `lib/`：Flutterアプリ、ローカルDB、3D部屋表示
- 公開版にはサーバー実装・AWS配備スクリプトを含めません。稼働中の共有AWSを利用するため、PCでのサーバー起動やAWS構築は不要です。
- [AWS設計](docs/AWS_ARCHITECTURE.md)
- [コンペ終了後の停止手順](docs/SHUTDOWN.md)

このリポジトリは公開用の新規スナップショットであり、開発リポジトリの過去履歴・個人環境設定は含めません。素材・フォントの同梱ライセンスはそれぞれの条件に従ってください。リポジトリの公開は、すべての素材に無制限の再配布権を付与するものではありません。
