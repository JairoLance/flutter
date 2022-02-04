import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_mensuales/models/prestamos_model.dart';
import 'package:flutter_app_mensuales/pages/util/ink_well_custom.dart';
import 'package:flutter_app_mensuales/pages/util/MessageScreen.dart';
import 'package:flutter_app_mensuales/pages/util/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intent/extra.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:intent/action.dart' as android_action;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../../whatsapp_home.dart';

ProgressDialog pr;

class PageAbonosDetalles extends StatefulWidget {
  PageAbonosDetalles(
      this.EstadoAtrasoColor,
      this._cedula_index,
      this._nombres_index,
      this._idcompra_index,
      this._secuencia_index,
      this._valor_prestamo,
      this._ti_porcentaje,
      this._object);

  final _cedula_index;
  final _nombres_index;
  final _idcompra_index;
  final _secuencia_index;
  final _valor_prestamo;
  final _ti_porcentaje;
  final PrestamosModel _object;

  Color EstadoAtrasoColor;

  @override
  _PageAbonosDetallesState createState() => _PageAbonosDetallesState();
}

class _PageAbonosDetallesState extends State<PageAbonosDetalles> {
  final GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController valor_abono = new TextEditingController();

  String yourReview;
  double ratingScore;

  String _session_grupo;

  /*
  * Instanciamos la permisos handler para poder
  * Habilitar las llamadas en este equipo
  * */
  final PermissionHandler _permissionHandler = PermissionHandler();

  @override
  void initState() {
    _loadvariable();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadvariable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _session_grupo = (prefs.getString("grupo_id")) ?? "";
    });
  }

  _permission_call_phone() async {
    var result =
        await _permissionHandler.requestPermissions([PermissionGroup.phone]);
    if (result[PermissionGroup.phone] == PermissionStatus.granted) {
      Fluttertoast.showToast(
        msg: "Llamada en procesos",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  _permission_call_message() async {
    var result =
        await _permissionHandler.requestPermissions([PermissionGroup.sms]);
    if (result[PermissionGroup.sms] == PermissionStatus.granted) {
      Fluttertoast.showToast(
        msg: "Mensaje en procesos",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  _callPhone(String phone) async {
    phone = 'tel:+' + phone;
    if (await canLaunch(phone)) {
      await launch(phone);
    } else {
      throw 'No realizarse la llamada.';
    }
  }

  _send_email() {
    //https://pub.dev/packages/intent#-readme-tab-
    /*android_intent.Intent()
      ..setPackage("com.google.android.gm")
      ..setAction(Action.ACTION_SEND);
    ..setType("message/rfc822");
    ..putExtra(Extra.EXTRA_EMAIL, ["john.doe@exampleemail.com"]);
    ..putExtra(Extra.EXTRA_CC, ["jane.doe@exampleemail.com"]);
    ..putExtra(Extra.EXTRA_SUBJECT, "Foo bar");
    ..putExtra(Extra.EXTRA_TEXT, "Lorem ipsum");
    ..startActivity().catchError((e) => print(e));*/
  }

  void _Toasted(type, msn) {
    Fluttertoast.showToast(
        msg: msn,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: (type == "error") ? Colors.red : Colors.white,
        textColor: (type == "error") ? Colors.white : Colors.blueGrey,
        fontSize: 16.0);
  }

  _onPressedGuardarAbonos() async {
    /*Validacion 1*/
    if (valor_abono.text.isEmpty) {
      _Toasted("error", "No se aceptan valores vacios.");
    } else if (int.parse(valor_abono.text.trim()) <= 0) {
      _Toasted("error", "Ingrese un valor mayor a 0");
    } else {
      _ShowDialogProgress();

      var body = json.encode({
        "cobro": _session_grupo.toString(),
        "co_idcompras": widget._idcompra_index.toString(),
        "valor": int.parse(valor_abono.text.trim()),
        "ab_descuento": 3,
        "atraso_total_hoy":widget._object.atraso_total_hoy.toString(),
        "total_saldo":widget._object.total_saldo.toString()
      });

      var jsonr = await GuardarAbonos(body);

      Future.delayed(Duration(seconds: 1)).then((value) {
        pr.hide().whenComplete(() {
          _Toasted(jsonr["type"], jsonr["message"]);
          if (jsonr["type"] == "error") {
          } else {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (BuildContext context) => WhatsAppHome()));
          }
        });
      });
    }
  }

  void _ShowDialogProgress() {
    pr = new ProgressDialog(context);
    pr = ProgressDialog(context,
        type: ProgressDialogType.Download, isDismissible: true, showLogs: true);
    pr.update(
      progress: 50.0,
      message: "Procesando...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
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

  _call_phone(String Telefono) async {
    _permission_call_phone();
    android_intent.Intent()
      ..setAction(android_action.Action.ACTION_CALL)
      ..setData(Uri(scheme: "tel", path: Telefono))
      ..startActivity().catchError((e) => print(e));
  }

  // Function to validate the number
  bool isNumber(String value) {
    if (value == null) {
      return true;
    }
    final n = num.tryParse(value);
    return n != null;
  }

  Widget getTextField(
      String inputBoxName, TextEditingController inputBoxController) {
    var loginBtn = new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new TextFormField(
        style: textStyleValorAbono,
        keyboardType: TextInputType.number,
        onChanged: (String newVal) {
          if (!isNumber(newVal)) {
            inputBoxController.clear();
          }
        },
        controller: inputBoxController,
        decoration: new InputDecoration(
          hintText: inputBoxName,
        ),
      ),
    );

    return loginBtn;
  }

  openAlertBox(String nombre) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          nombre,
                          style: TextStyle(fontSize: 15.0),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.attach_money,
                              color: Colors.teal,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Nota".toUpperCase(),
                          style: textGreyBold,
                        ),
                        Text(
                          "Ingrese el valor del abono , recuerde que el valor ingresado debe ser un numero entero.",
                          style: textStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Tu obligacion mensual es \$" +
                              widget._object.obligacion_mensual.toString(),
                          style: textStyleSubtitle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Tu deuda hasta fecha es \$" +
                              widget._object.total_saldo.toString(),
                          style: textStyleSubtitle,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: new Padding(
                      padding: EdgeInsets.only(
                          left: 12.0, right: 12.0, bottom: 20.0),
                      child: new Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: new TextFormField(
                          style: textStyleValorAbono,
                          keyboardType: TextInputType.number,
                          onChanged: (String newVal) {
                            if (!isNumber(newVal)) {
                              valor_abono.clear();
                            }
                          },
                          controller: valor_abono,
                          decoration: new InputDecoration(
                            hintText: '\$ 0.0',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new Center(
                child: new RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: dangerButtonColor,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              new Center(
                child: new RaisedButton(
                  onPressed: () {
                    _onPressedGuardarAbonos();
                  },
                  color: ButtonColorPrincipal,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Aceptar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.add,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  _showDialogAddAbono(String nombre) async {
    await Future.delayed(Duration(milliseconds: 5));

    showDialog(
        builder: (context) => new AlertDialog(
          title: new Text(nombre),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                getTextField("Valor del abono", valor_abono),
                new GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: new Container(
                    margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
                  openAlertBox(valor_abono.toString());
                }),
          ],
        ), context: context,
        barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pago de abonos y detalles',
          style: TextStyle(color: whiteColor, fontSize: 18.0),
        ),
        backgroundColor: HeaderColorPrincipal,
        elevation: 0.0,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 1, bottom: 5),
        child: ButtonTheme(
          minWidth: screenSize.width,
          height: 45.0,
          child: RaisedButton(
            onPressed: () {
              //_showDialogAddAbono(widget._nombres_index.toString());
              openAlertBox(widget._nombres_index.toString());
            },
            color: ButtonColorPrincipal,
            child: Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Aplicar el abono',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    Icons.attach_money,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: InkWellCustom(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            color: greyColor,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      )),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Image.asset(
                            'assets/avatar_mujer.jpg',
                            width: 40.0,
                            height: 40.0,
                          ),
                          /*CachedNetworkImage(
                            imageUrl:Image.asset(
                              'assets/avatar_hombre.jpg',
                              width: 20.9,
                              height: 19.9,
                            ).toString(),
                            //imageUrl: Image.network('assets/avatar_hombre.jpg').toString(),
                            fit: BoxFit.cover,
                            width: 40.0,
                            height: 40.0,
                          ),*/
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget._nombres_index.toString(),
                              style: textBoldBlack,
                            ),
                            Text(
                              widget._object.fecha.toString(),
                              style: textGrey,
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: 25.0,
                                    padding: EdgeInsets.all(5.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: ButtonColorPrincipal),
                                    child: Text(
                                      'Editar cliente',
                                      style: textBoldWhite,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    height: 25.0,
                                    padding: EdgeInsets.all(5.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: ButtonColorPrincipal),
                                    child: Text(
                                      'Descuento',
                                      style: textBoldWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "\$ " + widget._valor_prestamo.toString(),
                              style: textBoldBlack,
                            ),
                            Text(
                              widget._object.porcentaje.toString() + "%",
                              style: textGrey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    color: whiteColor,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "CODIGO DEL PRESTAMO".toUpperCase(),
                                style: textGreyBold,
                              ),
                              Text(
                                "COD - " + widget._idcompra_index.toString(),
                                style: textStyle,
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "DIRECCION DE RESIDENCIA".toUpperCase(),
                                style: textGreyBold,
                              ),
                              Text(
                                widget._object.direccion
                                    .toString()
                                    .toLowerCase(),
                                style: textStyle,
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "CONTACTAR".toUpperCase(),
                                style: textGreyBold,
                              ),
                              Text(
                                "Telefono : " +
                                    widget._object.telefono
                                        .toString()
                                        .toLowerCase() +
                                    " - Movil : " +
                                    widget._object.movil
                                        .toString()
                                        .toLowerCase(),
                                style: textStyle,
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "nota".toUpperCase(),
                                style: textGreyBold,
                              ),
                              Text(
                                "Mes adelantado " +
                                    (widget._object.mes_adelantado.toString() ==
                                            "1"
                                        ? "si"
                                        : "no") +
                                    " | " +
                                    ("Interes fijo " +
                                        (widget._object.interes_fijo
                                                    .toString() ==
                                                "1"
                                            ? "si"
                                            : "no")),
                                style: textStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                Container(
                  margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  padding: EdgeInsets.all(10),
                  color: whiteColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Detalles de la factura (pago en efectivo)"
                            .toUpperCase(),
                        style: textGreyBold,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Debe pagar",
                              style: textStyle,
                            ),
                            new Text(
                              "\$" + widget._object.obligacion.toString(),
                              style: textBoldBlack,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Pagos",
                              style: textStyle,
                            ),
                            new Text(
                              "\$ " +
                                  widget._object.acu_abono_interes.toString(),
                              style: textBoldBlack,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Descuento",
                              style: textStyleMinus,
                            ),
                            new Text(
                              "- \$0",
                              style: textBoldBlack,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: screenSize.width - 50.0,
                        height: 1.0,
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0, bottom: 10.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Total Saldo",
                              style: heading18Black,
                            ),
                            new Text(
                              "\$" + widget._object.total_saldo.toString(),
                              style: heading18Black,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Detalles del prestamo".toUpperCase(),
                        style: textGreyBold,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Obligacion mensual",
                              style: textStyle,
                            ),
                            new Text(
                              "\$" + widget._object.obligacion_mensual == null
                                  ? "0"
                                  : widget._object.obligacion_mensual
                                      .toString(),
                              style: textBoldBlack,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Mes generados",
                              style: textStyle,
                            ),
                            new Text(
                              widget._object.meses_obligacion == null
                                  ? "0"
                                  : widget._object.meses_obligacion.toString(),
                              style: textBoldBlack,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Mes pagado",
                              style: textStyle,
                            ),
                            new Text(
                              widget._object.mes_abonos == null
                                  ? "0"
                                  : widget._object.mes_abonos.toString(),
                              style: textBoldBlack,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                              "Dias",
                              style: textStyle,
                            ),
                            new Text(
                              widget._object.dias_abonos == null
                                  ? "0"
                                  : widget._object.dias_abonos
                                      .toString()
                                      .substring(0, 1)
                              //  .substring(0, 1)
                              ,
                              style: textBoldBlack,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: whiteColor,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          _call_phone(widget._object.movil.toString());
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: ButtonColorPrincipal,
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.call,
                                color: whiteColor,
                              ),
                              Text('LLamar',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: whiteColor,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _callPhone(widget._object.movil.toString());
                          /* Navigator.of(context)
                              .push(new MaterialPageRoute<Null>(
                                  builder: (BuildContext context) {
                                    return ChatScreen();
                                  },
                                  fullscreenDialog: true));*/
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: ButtonColorPrincipal,
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.mail,
                                color: whiteColor,
                              ),
                              Text('Mensaje',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: whiteColor,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print('ok');
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: greyColor2,
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.delete,
                                color: whiteColor,
                              ),
                              Text('Cancelar',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: whiteColor,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
