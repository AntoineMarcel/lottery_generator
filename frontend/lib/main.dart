import 'package:flutter/material.dart';
import 'package:frontend/home.dart';

void main() async {
  bool _isConnected = false;

  runApp(MaterialApp(
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        listTileTheme: ListTileThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        )),
    themeMode: ThemeMode.dark,
    debugShowCheckedModeBanner: false,
    title: 'Token Lottery',
    home: MyHomePage(isConnected: _isConnected),
  ));
}
