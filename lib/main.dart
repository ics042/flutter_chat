import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_chat/ui/chat/chat_page.dart';
import 'package:flutter_chat/ui/auth/login_page.dart';

void main() {
  runApp(ChatApp());
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.red,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.red[300],
);

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "chat",
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
      routes: {
        '/chat': (BuildContext context) => ChatPage()
      },
      home: LoginPage(),
    );
  }
}
