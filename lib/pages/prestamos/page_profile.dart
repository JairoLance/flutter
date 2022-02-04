import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_mensuales/models/profile_model.dart';
import 'package:flutter_app_mensuales/pages/util/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_page.dart';

ProgressDialog pr;

class PageProfile extends StatefulWidget {
  @override
  _PageProfileState createState() => _PageProfileState();
}

class _PageProfileState extends State<PageProfile> {
  final GlobalKey<FormState> _keyValidationForm = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _textEditConName = TextEditingController();
  TextEditingController _textEditConEmail = TextEditingController();
  TextEditingController _textEditConPassword = TextEditingController();
  TextEditingController _textEditConConfirmPassword = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  SharedPreferences sharedPreferences;

  String _session_usuario;
  String _session_grupo;
  String _session_email;
  String _session_clave;


  @override
  void initState() {
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
    _loadvariable() ?? "";



    super.initState();
  }

  _loadvariable() async {
    // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _session_grupo = (prefs.getString("grupo_id")) ?? "";
      _session_usuario = (prefs.getString("usuario")) ?? "";
      _session_email = (prefs.getString("email")) ?? "";
      _session_clave = (prefs.getString("clave")) ?? "";

      _textEditConName.text = _session_usuario.toString();
      _textEditConEmail.text = _session_email.toString();
      _textEditConPassword.text = _session_clave.toString();
    });
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cuenta actualizada !",
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.teal,
                  fontFamily: "Poppins-Bold",
                  letterSpacing: .5,
                  fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[

                Text(
                    'Actualizastes tu cuenta es necesario que ingreses de nuevo al sistema, para reflejar los cambios !.'),
              ],
            ),
          ),
          actions: <Widget>[
            new RaisedButton(
              color: Colors.teal,
              child: Text('Si'),
              textColor: Colors.white,
              onPressed: () async {
                sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.clear();
                sharedPreferences.commit();

                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()),
                        (Route<dynamic> route) => false);
              },
            ),
            new RaisedButton(
              color: Colors.redAccent,
              child: Text('No'),
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _ShowDialogProgress() {
    pr = new ProgressDialog(context);
    pr = ProgressDialog(context,
        type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    pr.update(
      progress: 50.0,
      message: "Actualizando...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          )),
      maxProgress: 100.0,

      //https://pub.dev/packages/progress_dialog
      progressTextStyle: TextStyle(
          color: Colors.red, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    pr.show();
  }

  Future<void> _onTappedButtonRegister() async {
    var body = json.encode({
      "cobro": _session_grupo.toString(),
      "us_usuario": _session_usuario.toString(),
      "us_clave": _textEditConPassword.text.toString(),
      "us_email": _textEditConEmail.text.toString()
    });
    _ShowDialogProgress();

    final response = await GuardarProfile(body);

    Future.delayed(Duration(seconds: 1)).then((value) {
      pr.hide().whenComplete(() {
        if (response["type"] == 'error') {
          Fluttertoast.showToast(
              msg: response["data"].toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 15.0);
        } else {
          _neverSatisfied();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mi cuenta',
          style: TextStyle(color: whiteColor, fontSize: 18.0),
        ),
        actions: <Widget>[

          new IconButton(icon: new Icon(Icons.save),
            onPressed: () async {
              if (_keyValidationForm.currentState.validate()) {
                _onTappedButtonRegister();
              }
            },
          ),
          new IconButton(icon: new Icon(Icons.menu),
            onPressed: (){},
          ),
        ],
        backgroundColor: HeaderColorPrincipal,
        elevation: 0.0,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.only(top: 22.0),
            child: Column(
              children: <Widget>[
                new Container(
                  child: Image.asset("assets/images/personal_profile2.png",height: 200.0,)
                ),
                SizedBox(height: 7),
                /*Text('Enable Your Location', style: heading35Black,
                ),*/
                Container(
                  padding: new EdgeInsets.only(left: 40.0, right: 40.0),
                  child: new Text( 'Actualize los datos de su cuenta para mejorar la confiabilidad del sistema !',
                    style: textGrey,
                    textAlign: TextAlign.center,
                  ),
                ),

                //getWidgetImageLogo(),
                getWidgetRegistrationCard(),
              ],
            )),
      ),
    );
  }

  Widget getWidgetImageLogo() {
    return Container(
        alignment: Alignment.center,
        child:
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 12),
          child: Image.asset(
            "assets/images/personal_profile2.png",
            height: 200,
            width: 200,
          ),
        ));
  }

  Widget getWidgetRegistrationCard() {
    final FocusNode _passwordEmail = FocusNode();
    final FocusNode _passwordFocus = FocusNode();
    final FocusNode _passwordConfirmFocus = FocusNode();

    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Card(
        color: Colors.white,
        /* shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),*/
        elevation: 0.0, //10.0,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _keyValidationForm,
            child: Column(
              children: <Widget>[


                Container(
                  child: TextFormField(
                    controller: _textEditConName,
                    readOnly: true,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: _validateUserName,
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_passwordEmail);
                    },
                    decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        //prefixIcon: Icon(Icons.email),
                        icon: Icon(Icons.perm_identity)),
                  ),
                ), //text field : user name
                Container(
                  child: TextFormField(
                    controller: _textEditConEmail,
                    focusNode: _passwordEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                    decoration: InputDecoration(
                        labelText: 'Email',
                        //prefixIcon: Icon(Icons.email),
                        icon: Icon(Icons.email)),
                  ),
                ), //text field: email
                Container(
                  child: TextFormField(
                    controller: _textEditConPassword,
                    focusNode: _passwordFocus,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: _validatePassword,
                    onFieldSubmitted: (String value) {
                      FocusScope.of(context)
                          .requestFocus(_passwordConfirmFocus);
                    },
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                        labelText: 'Cambiar contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        icon: Icon(Icons.vpn_key)),
                  ),
                ), //text field: password
                /* Container(
                  child: TextFormField(
                      controller: _textEditConConfirmPassword,
                      focusNode: _passwordConfirmFocus,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      obscureText: !isConfirmPasswordVisible,
                      decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible;
                              });
                            },
                          ),
                          icon: Icon(Icons.vpn_key))),
                ),*/
                /*Container(
                  margin: EdgeInsets.only(top: 32.0),
                  width: double.infinity,
                  child: RaisedButton(
                    color: Colors.teal,
                    textColor: Colors.white,
                    elevation: 5.0,
                    padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Text(
                      'Actualizar informacion',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    onPressed: () async {
                      if (_keyValidationForm.currentState.validate()) {
                        _onTappedButtonRegister();
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                  ),
                ), //button: login*/
                /*
                Container(
                    margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Already Register? ',
                        ),
                        InkWell(
                          splashColor: Colors.blueGrey.withOpacity(0.5),
                          onTap: () {
                            _onTappedTextlogin();
                          },
                          child: Text(
                            ' Login',
                            style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ))*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _validateUserName(String value) {
    return value.trim().isEmpty ? "El nombre no puede estar vacío" : null;
  }

  String _validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Invalido Email';
    } else {
      return null;
    }
  }

  String _validatePassword(String value) {
    return value.length < 4 ? 'Se requieren 4 caracteres como mínimo' : null;
  }

  String _validateConfirmPassword(String value) {
    return value.length < 4 ? 'Se requieren 4 caracteres como mínimo' : null;
  }




  void _onTappedTextlogin() {}
}
