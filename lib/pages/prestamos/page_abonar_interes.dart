import 'dart:async';
import 'dart:convert';
import 'package:flutter_app_mensuales/components/CircleIconButton.dart';
import 'package:flutter_app_mensuales/models/cliente_models.dart';
import 'package:flutter_app_mensuales/models/path.dart';
import 'package:flutter_app_mensuales/models/prestamos_model.dart';
import 'package:flutter_app_mensuales/pages/prestamos_screen.dart';
import 'package:flutter_app_mensuales/pages/terceros/gestion_clientes.dart';
import 'package:flutter_app_mensuales/whatsapp_home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:validators/validators.dart' as validator;
import 'package:dropdown_formfield/dropdown_formfield.dart';

class PagarInteresPage extends StatefulWidget {
  PagarInteresPage(this._id, this._nombre);

  final _id;
  final _nombre;

  @override
  _PagarInteresPageState createState() {
    return new _PagarInteresPageState();
  }
}

class Model {
  String firstName;
  String lastName;
  String email;
  String password;

  Model({this.firstName, this.lastName, this.email, this.password});
}

class Result extends StatelessWidget {
  Model model;

  Result({this.model});

  List<String> _type = <String>[
    'License/Registered',
    'UN-Registered',
  ];

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(title: Text('Successful')),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(model.firstName, style: TextStyle(fontSize: 22)),
            Text(model.lastName, style: TextStyle(fontSize: 22)),
            Text(model.email, style: TextStyle(fontSize: 22)),
            Text(model.password, style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    ));
  }
}

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final Function validator;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;

  MyTextFormField({
    this.hintText,
    this.validator,
    this.onSaved,
    this.isPassword = false,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        obscureText: isPassword ? true : false,
        validator: validator,
        onSaved: onSaved,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}

class _PagarInteresPageState extends State<PagarInteresPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Model model = Model();

  String _dropdownError;
  String _selectedItem;

  String _myActivity;
  String _myActivityResult;

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;

    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'ABONAR INTERESES',
              ),
              Visibility(
                visible: true,
                child: Text(
                  widget._nombre.toString(),
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        hintText: 'First Name',
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Enter your first name';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          model.firstName = value;
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        hintText: 'Last Name',
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Enter your last name';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          model.lastName = value;
                        },
                      ),
                    )
                  ],
                ),
              ),
              MyTextFormField(
                hintText: 'Email',
                isEmail: true,
                validator: (String value) {
                  if (!validator.isEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (String value) {
                  model.email = value;
                },
              ),
              MyTextFormField(
                hintText: 'Password',
                isPassword: true,
                validator: (String value) {
                  if (value.length < 7) {
                    return 'Password should be minimum 7 characters';
                  }

                  _formKey.currentState.save();

                  return null;
                },
                onSaved: (String value) {
                  model.password = value;
                },
              ),
              MyTextFormField(
                hintText: 'Confirm Password',
                isPassword: true,
                validator: (String value) {
                  if (value.length < 7) {
                    return 'Password should be minimum 7 characters';
                  } else if (model.password != null &&
                      value != model.password) {
                    print(value);
                    print(model.password);
                    return 'Password not matched';
                  }

                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: new InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Selecionar',
                    contentPadding: EdgeInsets.all(0.0),
                    border: InputBorder.none,
                    filled: true,
                    //fillColor: Colors.grey[200],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(0.0),
                    child: DropDownFormField(
                      filled: false,
                      titleText: 'Tipos de pagos',
                      hintText: 'Por favor seleccione una opcion',
                      value: _myActivity,
                      onSaved: (value) {
                        setState(() {
                          _myActivity = value;
                        });
                      },
                      onChanged: (value) {
                        setState(() {
                          _myActivity = value;
                        });
                      },
                      dataSource: [
                        {
                          "display": "Running",
                          "value": "Running",
                        },
                        {
                          "display": "Climbing",
                          "value": "Climbing",
                        },
                        {
                          "display": "Walking",
                          "value": "Walking",
                        },
                        {
                          "display": "Swimming",
                          "value": "Swimming",
                        },
                        {
                          "display": "Soccer Practice",
                          "value": "Soccer Practice",
                        },
                        {
                          "display": "Baseball Practice",
                          "value": "Baseball Practice",
                        },
                        {
                          "display": "Football Practice",
                          "value": "Football Practice",
                        },
                      ],
                      textField: 'display',
                      valueField: 'value',
                    ),
                  ),

                ),

              ),
              RaisedButton(
                color: Colors.blueAccent,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Result(model: this.model)));
                  }
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
