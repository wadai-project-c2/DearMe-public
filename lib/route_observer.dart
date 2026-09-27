import 'package:flutter/widgets.dart';

/// ホーム画面など、他のルートに覆われても破棄されない画面が
/// `RouteAware`でその一時的な非表示を検知するための共有インスタンス。
final routeObserver = RouteObserver<ModalRoute<dynamic>>();
