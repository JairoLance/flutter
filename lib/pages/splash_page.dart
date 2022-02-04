import 'dart:async';
import 'package:flutter_app_mensuales/pages/login_page.dart';
import 'package:flutter_app_mensuales/whatsapp_home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  static String splash = "splash";

  @override
  SplashPageState createState() {
    return new SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin{

  AnimationController _iconAnimationController;
  CurvedAnimation _iconAnimation;
  SharedPreferences sharedPreferences;

  void handleTimeout() {
    checkLoginStatus();
    /*
    Navigator.of(context).pushReplacement(
        // ignore: strong_mode_invalid_cast_new_expr
        //new MaterialPageRoute(builder: (BuildContext context) => new WhatsAppHome()));

        new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));*/
  }

  startTimeout() async {
    var duration = const Duration(seconds: 4);
    return new Timer(duration, handleTimeout);
  }

  bool _visible = true;
  @override
  void initState(){
      super.initState();
      //Timer(Duration(seconds: 5),()=> print(''));

      _iconAnimationController = new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 3000));

      _iconAnimation = new CurvedAnimation(
          parent: _iconAnimationController, curve: Curves.easeIn);
      _iconAnimation.addListener(() => this.setState(() {}));

      _iconAnimationController.forward();

      startTimeout();

  }


  /*Verificamos que ruta debe de acceder segun sea la validacion correspondiente*/
  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => LoginPage()), (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => WhatsAppHome()), (Route<dynamic> route) => false);
    }
  }



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body : Stack(
        fit:StackFit.expand,
        children: <Widget>[
          Container(
            decoration : BoxDecoration(color: Colors.white)
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Image.asset('assets/images/pressta_splash.png'),
                      ),
                     /* Padding(
                        padding: EdgeInsets.only(top:20.0),
                      ),*/
                      /*Text(
                          "Pressta",
                             textAlign: TextAlign.center, style: TextStyle(
                             color:Colors.purple,
                             fontSize: 24.0,
                             fontWeight: FontWeight.bold
                           ),
                      )*/
                    ],
                  ),

                ),
              ),

              Expanded(flex:1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.purple)
                    ),
                    Padding(
                      padding: EdgeInsets.only(top:20.0),
                    ),
                    Text(
                        "Procesando... ",
                        textAlign: TextAlign.center,
                        style : TextStyle(
                                  color : Colors.purple,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                        )
                    )
                  ],
                ),
              )

            ]
          )
        ],
      ),
    );
  }
}


