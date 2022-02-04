import 'package:flutter/services.dart';
import 'package:flutter_app_mensuales/pages/login_page.dart';
import 'package:flutter_app_mensuales/pages/splash_page.dart';
import 'package:flutter_app_mensuales/whatsapp_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
//import 'package:global_configuration/global_configuration.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.pink, // navigation bar color
      statusBarColor: Colors.purple, // status bar color
      systemNavigationBarDividerColor: Colors.pink,
      statusBarBrightness: Brightness.dark));
  //await GlobalConfiguration().loadFromAsset("app_settings");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  SharedPreferences sharedPreferences;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      //return LayoutBuilder
      builder: (context, constraints) {
        return OrientationBuilder(
          //return OrientationBuilder
          builder: (context, orientation) {
            //initialize SizerUtil()
            SizerUtil().init(constraints, orientation);
            return MaterialApp(
                title: 'WhatSapp Clientes',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  // This is the theme of your application.
                  //
                  // Try running your application with "flutter run". You'll see the
                  // application has a blue toolbar. Then, without quitting the app, try
                  // changing the primarySwatch below to Colors.green and then invoke
                  // "hot reload" (press "r" in the console where you ran "flutter run",
                  // or simply save your changes to "hot reload" in a Flutter IDE).
                  // Notice that the counter didn't reset back to zero; the application
                  // is not restarted.
                  primaryColor: new Color(0xff075E54),
                  accentColor: new Color(0xff25d366),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                // home: WhatsAppHome(),
                home: SplashPage());
          },
        );
      },
    );
  }
}
