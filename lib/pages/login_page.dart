import 'package:flutter/cupertino.dart';
import 'package:flutter_app_mensuales/components/Animation/FadeAnimation.dart';
import 'package:flutter_app_mensuales/models/login.dart';
import 'package:flutter_app_mensuales/models/path.dart';
import 'package:flutter_app_mensuales/whatsapp_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app_mensuales/components/Widgets/FormCard.dart';
import 'package:flutter_app_mensuales/components/Widgets/SocialIcons.dart';
import 'package:flutter_app_mensuales/components/CustomIcons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
/*
import 'Widgets/FormCard.dart';
import 'Widgets/SocialIcons.dart';
import 'CustomIcons.dart';*/

class LoginPage1 extends StatefulWidget {
  @override
  _LoginPage1 createState() => _LoginPage1();
}

class _LoginPage1 extends State<LoginPage1> {
  bool _isSelected = false;
  bool _isLoading = false;

  final txtUsuario = TextEditingController();
  final txtpassword = TextEditingController();

  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  signIn(String usuario, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var data = json.encode({'username': usuario, 'password': pass});

    var jsonResponse = null;

    var uri =
        "http://31.220.62.119/compras/servicios/public/index.php/App/login";
    var response = await http.post(Uri.encodeFull(uri),
        body: data, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });

        sharedPreferences.setString("token", null);

        if (jsonResponse["type"].toString() == "error") {
          /*  Fluttertoast.showToast(
              msg:jsonResponse["message"].toString(),
              backgroundColor: Colors.red,
              toastLength: Toast.LENGTH_SHORT
          );*/

          Fluttertoast.showToast(
              msg: jsonResponse["message"].toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);

          /* showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text(jsonResponse["type"].toString()),
                  content: Text(jsonResponse["message"].toString()) ,
                );
              }
          );*/
        } else {
          sharedPreferences.setString(
              "token", jsonResponse['access_token'].toString());

          sharedPreferences.setString("data", jsonResponse['data'].toString());

          sharedPreferences.setString(
              "usuario", jsonResponse['data']["us_usuario"].toString());

          /*  Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => WhatsAppHome()),
              (Route<dynamic> route) => false);*/

          print(jsonResponse['data']["grupos"].toString());
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16.0,
        height: 16.0,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2.0, color: Colors.black)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              )
            : Container(),
      );

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.pink.withOpacity(.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Image.asset('assets/login_fondo_07.png'),
              ),
              Expanded(
                child: Container(),
              ),
              Image.asset("assets/image_02.png")
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 80.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(360),
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil.getInstance().setHeight(500),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 12.0, right: 12.0, top: 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("FoundSoft",
                              style: TextStyle(
                                  color: Colors.pink,
                                  fontSize: ScreenUtil.getInstance().setSp(45),
                                  fontFamily: "Poppins-Bold",
                                  letterSpacing: .6)),
                          Text("version 1.0",
                              style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: ScreenUtil.getInstance().setSp(13),
                                  fontFamily: "Poppins-Bold",
                                  letterSpacing: .6)),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(20),
                          ),
                          Text("Tu usuario",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            validator: (value) =>
                                value.isEmpty ? 'Email can\'t be empty' : null,
                            controller: txtUsuario,
                            decoration: InputDecoration(
                                hintText: "Nombre de usuario",
                                icon: new Icon(
                                  Icons.account_circle,
                                  color: Colors.pink,
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0)),
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(30),
                          ),
                          Text("Tu contraseña",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextField(
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            controller: txtpassword,
                            decoration: InputDecoration(
                                hintText: "Contraseña",
                                icon: new Icon(
                                  Icons.lock,
                                  color: Colors.pink,
                                ),
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0)),
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(35),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                "Olvido su contraseña?",
                                style: TextStyle(
                                    color: Colors.pink,
                                    fontFamily: "Poppins-Medium",
                                    fontSize:
                                        ScreenUtil.getInstance().setSp(22)),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          width: ScreenUtil.getInstance().setWidth(400),
                          height: ScreenUtil.getInstance().setHeight(80),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFF17ead9),
                                Color(0xFF6078ea)
                              ]),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF6078ea).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.pink,
                            borderRadius: BorderRadius.circular(6.0),
                            child: _isLoading
                                ? Center(
                                    child: new CircularProgressIndicator(
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.white54)))
                                : InkWell(
                                    onTap: () async {
                                    },
                                    child: RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        signIn(
                                            txtUsuario.text, txtpassword.text);
                                      },
                                      elevation: 0.0,
                                      color: Colors.pink,
                                      child: Text("CONECTAR",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Poppins-Bold",
                                              fontSize: 16,
                                              letterSpacing: 1.0)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(40),
                  ),

                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(30),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Crear nueva cuenta ? ",
                        style: TextStyle(fontFamily: "Poppins-Medium"),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text("registrarse",
                            style: TextStyle(
                                color: Colors.pink,
                                fontFamily: "Poppins-Bold")),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Todos los derechos reservados.",
                          style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: ScreenUtil.getInstance().setSp(13),
                              fontFamily: "Poppins-Bold",
                              letterSpacing: .6)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage2 extends State<LoginPage> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              "assets/logo.png",
              height: 50,
              width: 50,
            ),
            Center(
              child: Text(
                "Create a password",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Column(
              children: <Widget>[
                CustomInputField(
                  hasIcon: true,
                  hint: "Password",
                  label: "New Password (min 8 chars)",
                  icon: Icon(
                    Icons.visibility,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 21,
                ),
                CustomInputField(
                  hasIcon: false,
                  hint: "Confirmation",
                  label: "Confirm Password",
                ),
              ],
            ),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Enable Touch ID at login",
                      style: Theme.of(context).textTheme.subtitle1),
                  CupertinoSwitch(
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                    },
                    value: switchValue,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return WhatsAppHome();
                      },
                    ),
                  );
                },
                child: Text(
                  "NEXT",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label, hint;
  final bool hasIcon;
  final Icon icon;
  const CustomInputField({
    Key key,
    this.label,
    this.hint,
    this.hasIcon,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(
          height: 5.0,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                ),
              ),
              hasIcon
                  ? IconButton(
                      icon: icon,
                      onPressed: () {},
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginRequestData {
  String email = '';
  String password = '';
}

class FormValidator {
  static FormValidator _instance;

  factory FormValidator() => _instance ??= new FormValidator._();

  FormValidator._();

  String validatePassword(String value) {
    String patttern = r'(^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.isEmpty) {
      return "Password es requerido";
    } else if (value.length <= 2) {
      return "Mínimo de 3 caracteres";
      /*/} else if (!regExp.hasMatch(value)) {
      return "Contraseña al menos una letra mayúscula, una letra minúscula y un número";*/
    }
    return null;
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^&lt;&gt;()[\]\\.,;:\s@\"]+(\.[^&lt;&gt;()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.isEmpty) {
      return "Email o usuario is requerido";
      /* } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";*/
    } else {
      return null;
    }
  }
}

class _LoginPage extends State<LoginPage> {
  GlobalKey<FormState> _key = new GlobalKey();

  LoginRequestData _loginData = LoginRequestData();
  bool _validate = false;
  bool _obscureText = true;
  bool _isSelected = false;
  bool _isLoading = false;

  final txtUsuario = TextEditingController();
  final txtpassword = TextEditingController();

  void _radio() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  signIn1() async {
    Fluttertoast.showToast(
        msg: _loginData.email.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  signIn(String usuario, String pass) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      var data = json.encode({'username': usuario, 'password': pass});

      var jsonResponse = null;

      //var uri ="http://31.220.62.119/compras/servicios/public/index.php/App/login";
      var uri = Global().getAccountUrl("App/login");

      var response = await http.post(Uri.encodeFull(uri),
          body: data, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          setState(() {
            _isLoading = false;
          });

          sharedPreferences.setString("token", null);

          if (jsonResponse["type"].toString() == "error") {
            Fluttertoast.showToast(
                msg: jsonResponse["message"].toString(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            sharedPreferences.setString(
                "token", jsonResponse['access_token'].toString());

            sharedPreferences.setString(
                "data", jsonResponse['data'].toString());

            sharedPreferences.setString(
                "usuario", jsonResponse['data']["us_usuario"].toString());

            sharedPreferences.setString(
                "email", jsonResponse['data']["us_email"].toString());

            sharedPreferences.setString(
                "clave", jsonResponse['data']["us_clave"].toString());

            var listGrupos = json.decode(jsonResponse["grupos"]);
            var totalGrupos = int.parse(listGrupos.length.toString());

            if (totalGrupos <= 1) {
              sharedPreferences.setString(
                  "grupo_id", listGrupos[0]["cr_idcobro"].toString());
              sharedPreferences.setString(
                  "grupo_nombre", listGrupos[0]["cr_nombre"].toString());

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => WhatsAppHome()),
                  (Route<dynamic> route) => false);
            } else {
              for (var row in listGrupos) {
                print(row["cr_nombre"]);
              }
            }
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _sendToServer() {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
      print("Email ${_loginData.email}");
      print("Password ${_loginData.password}");

      //signIn(txtUsuario.text, txtpassword.text);

      signIn(_loginData.email, _loginData.password);
    } else {
      // validation error
      setState(() {
        _validate = true;
        _isLoading = false;
      });
    }
  }

  Widget _getFormUI() {
    return new Column(
      children: <Widget>[
        FadeAnimation(
            1.8,
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(143, 148, 251, .2),
                        blurRadius: 3.0,
                        offset: Offset(0, 10))
                  ]),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey[100]))),
                    child: TextFormField(
                      controller: txtUsuario,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Email o usuario',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0)),
                      ),
                      validator: FormValidator().validateEmail,
                      onSaved: (String value) {
                        _loginData.email = value;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: TextFormField(
                        autofocus: false,
                        controller: txtpassword,
                        obscureText: _obscureText,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          fillColor: Colors.pink,
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              semanticLabel: _obscureText
                                  ? 'show password'
                                  : 'hide password',
                            ),
                          ),
                        ),
                        validator: FormValidator().validatePassword,
                        onSaved: (String value) {
                          _loginData.password = value;
                        }),
                  )
                ],
              ),
            )),
        SizedBox(
          height: 30,
        ),
        FadeAnimation(
          2,
          Container(
            width: 230,
            height: 50,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF17ead9), Color(0xFF6078ea)]),
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: [
                  BoxShadow(
                      color: Color(0xFF6078ea).withOpacity(.3),
                      offset: Offset(0.0, 8.0),
                      blurRadius: 8.0)
                ]),
            child: Material(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(6.0),
              child: _isLoading
                  ? Center(
                      child: new CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Colors.white54
                          )
                      )
                   )
                  : InkWell(
                      onTap: () async {},
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });

                          _sendToServer();
                        },
                        elevation: 0.0,
                        color: Colors.pink,
                        child: Text("CONECTAR",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppins-Bold",
                                fontSize: 16,
                                letterSpacing: 1.0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        FadeAnimation(
            1.8,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: () {},
                  child: Text("¿ Olvido su contraseña ?",
                      style: TextStyle(color: Colors.pink)),
                )
              ],
            )),
        /*  FadeAnimation(
                            1.5,
                            Text(
                              "¿ Olvido su contraseña ?",
                              style: TextStyle(color: Colors.teal),
                            )),*/
        SizedBox(
          height: ScreenUtil.getInstance().setHeight(30),
        ),
        FadeAnimation(
            1.8,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Crear nueva cuenta ? ",
                  style: TextStyle(fontFamily: "Poppins-Medium"),
                ),
                InkWell(
                  onTap: () {
                    signIn1();
                  },
                  child: Text("registrarse",
                      style: TextStyle(
                          color: Colors.pink, fontFamily: "Poppins-Bold")),
                )
              ],
            )),
        FadeAnimation(
            2.0,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Todos los derechos reservados.",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: ScreenUtil.getInstance().setSp(13),
                        fontFamily: "Poppins-Bold",
                        letterSpacing: .6)),
              ],
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(fit: StackFit.expand, children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
             /* Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Image.asset('assets/login_fondo_07.png'),
              ),*/
              Expanded(
                child: Container(),
              ),
              Image.asset("assets/image_02.png")
            ],
          ),
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 42.0.h,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/silueta.png'),
                            fit: BoxFit.fill)
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 30,
                          width: 80,
                          height: 35.0.h,
                          child: FadeAnimation(
                              1,
                              Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/light-1.png'))),
                              )),
                        ),
                        Positioned(
                          left: 140,
                          width: 80,
                          height: 20.0.h,
                          child: FadeAnimation(
                              1.3,
                              Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/light-2.png'))),
                              )),
                        ),
                        Positioned(
                          right: 40,
                          top: 40,
                          width: 80,
                          height: 10.0.h,
                          child: FadeAnimation(
                              1.5,
                              Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/clock.png'))),
                              )),
                        ),
                        Positioned(
                          child: FadeAnimation(
                              1.6,
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Center(
                                  child: Text(
                                    "Entrada",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(30.0),
                      child: new Form(
                        key: _key,
                        //autovalidate: _validate,
                        child: _getFormUI(),
                      ))
                ],
              ),
            ),
          )
        ]));
  }
}
