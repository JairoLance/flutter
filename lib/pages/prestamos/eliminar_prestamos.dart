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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

class EliminarPrestamos extends StatefulWidget {
  EliminarPrestamos(this._id, this._nombre,this._valor);

  final _id;
  final _nombre;
  final _valor;

  @override
  EliminarPrestamosState createState() {
    return new EliminarPrestamosState();
  }
}

class _ClienteData {
  String cedula = "";
  String nombres = "";
  String direccion = "";
  String telefono = "";
  String movil = "";
  String seq = "";
}

class EliminarPrestamosState extends State<EliminarPrestamos> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String _mySelectionTiempo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    print("cerro");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ELIMINAR PRESTAMOS',
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
      body: new Container(
          child: new Form(
        key: this._formKey,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      new Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          new Container(
                            margin: new EdgeInsets.only(top: 40.0),
                            alignment: AlignmentDirectional(0.0, 0.0),
                            height: 140.0,
                            width: 140.0,
                            decoration: new BoxDecoration(
                                //borderRadius: new BorderRadius.circular(50.0),
                                color: Colors.transparent),
                            child: new Icon(
                              Icons.delete_forever,
                              size: 140.0,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "¿ Eliminar este prestamo ?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                            fontWeight: FontWeight.w500, fontSize: 22
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Tenga en cuenta que al eliminar este prestamo, automaticamente se eliminaran los abonos.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal, fontSize: 14
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      new Text(
                        widget._nombre.toString(),
                        style: new TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      new Text(
                        widget._valor.toString(),
                        style: new TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            new RaisedButton(
                              padding: const EdgeInsets.all(8.0),
                              textColor: Colors.white,
                              color: Colors.redAccent,
                              onPressed: () {
                                Navigator.pop(context, '');
                              },
                              child: new Text("Cancelar"),
                            ),
                            new RaisedButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                var body = json.encode({
                                  "cobro": (prefs.getString("grupo_id")) ?? "",
                                  "compra": widget._id.toString()
                                });

                                final response =
                                    await EliminarPrestamosModel(body);
                                if (response["type"] == 'error') {
                                  Fluttertoast.showToast(
                                      msg: response["content"].toString(),
                                      backgroundColor: Colors.redAccent,
                                      toastLength: Toast.LENGTH_SHORT);
                                } else {
                                  Navigator.of(context)
                                      .push(new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new WhatsAppHome(),
                                  ));
                                  // Navigator.pop(context, 'refresh_list_prestamos');
                                  // Fluttertoast.showToast(msg:response["content"].toString(),backgroundColor: Colors.teal,toastLength: Toast.LENGTH_SHORT);
                                }
                              },
                              textColor: Colors.teal,
                              color: Colors.tealAccent,
                              padding: const EdgeInsets.all(8.0),
                              child: new Text(
                                "Eliminar",
                              ),
                            ),
                          ])
                    ],
                  ),
                )
              ],
            ),
            /* Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    new Container(
                      margin: new EdgeInsets.only(top: 40.0),
                      alignment: AlignmentDirectional(0.0, 0.0),
                      height: 140.0,
                      width: 140.0,
                      decoration: new BoxDecoration(
                          //borderRadius: new BorderRadius.circular(50.0),
                          color: Colors.transparent),
                      child: new Icon(
                        Icons.delete_forever,
                        size: 140.0,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 6.0, left: 25, right:25),
                      child: new Text(
                        "¿ Eliminar este prestamo ?",
                        style: new TextStyle(fontSize: 20, color: Colors.teal),
                      ),
                    )
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 50, bottom: 5.0),
                      child: new Text(
                        widget._nombre.toString(),
                        style: new TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    )
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0.0, left: 50, bottom: 70.0),
                      child: new Text(
                        "*********",
                        style: new TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    )
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new RaisedButton(
                      padding: const EdgeInsets.all(8.0),
                      textColor: Colors.white,
                      color: Colors.redAccent,
                      onPressed: () {
                        Navigator.pop(context, '');
                      },
                      child: new Text("Cancelar"),
                    ),
                    new RaisedButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        var body = json.encode({
                          "cobro": (prefs.getString("grupo_id")) ?? "",
                          "compra": widget._id.toString()
                        });

                        final response = await EliminarPrestamosModel(body);
                        if (response["type"] == 'error') {
                          Fluttertoast.showToast(
                              msg: response["content"].toString(),
                              backgroundColor: Colors.redAccent,
                              toastLength: Toast.LENGTH_SHORT);
                        } else {
                          Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new WhatsAppHome(),
                          ));
                          // Navigator.pop(context, 'refresh_list_prestamos');
                          // Fluttertoast.showToast(msg:response["content"].toString(),backgroundColor: Colors.teal,toastLength: Toast.LENGTH_SHORT);
                        }
                      },
                      textColor: Colors.teal,
                      color: Colors.tealAccent,
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        "Eliminar",
                      ),
                    ),
                  ],
                )
              ],
            ),*/
          ],
        ),
      )),
    );
  }
}
