import 'dart:convert';
import 'dart:io';

import 'package:flutter_app_mensuales/components/fab_bottom_app_bar.dart';
import 'package:flutter_app_mensuales/components/fab_with_icons.dart';
import 'package:flutter_app_mensuales/components/layout.dart';
import 'package:flutter_app_mensuales/models/par_condicion.dart';
import 'package:flutter_app_mensuales/models/path.dart';
import 'package:flutter_app_mensuales/models/prestamos_model.dart';

//import 'package:badge/badge.dart';
import 'package:badges/badges.dart';
import 'package:flutter_app_mensuales/models/reportes_model.dart';
import 'package:flutter_app_mensuales/pages/abonos/crear_abonos.dart';
import 'package:flutter_app_mensuales/pages/abonos_page.dart';
import 'package:flutter_app_mensuales/pages/prestamos/crear_prestamos.dart';
import 'package:flutter_app_mensuales/pages/prestamos/eliminar_prestamos.dart';
import 'package:flutter_app_mensuales/pages/prestamos/page_abonar_interes.dart';
import 'package:flutter_app_mensuales/pages/requestDetail.dart';
import 'package:flutter_app_mensuales/pages/terceros/gestion_clientes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter_app_mensuales/models/cliente_models.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'abonos/page_abonos_capital.dart';
import 'abonos/page_abonos_detalles.dart';
import 'login_page.dart';

ProgressDialog pr;

class PrestamosScreen extends StatefulWidget {
  final Function func;

  const PrestamosScreen({Key key, this.func}) : super(key: key);

  @override
  PrestamosScreenState createState() {
    return new PrestamosScreenState();
  }
}

class PrestamosScreenState extends State<PrestamosScreen> {
  SharedPreferences sharedPreferences;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  double total_valor = 0;
  double total_saldo = 0;
  double total_obligacion_mensual = 0;
  int selectedItemModelPrestamos = null;

  final teFirstName = TextEditingController();
  final teLastFirstName = TextEditingController();
  final teDOB = TextEditingController();

  List<PrestamosModel> prestamoModel = new List();

  bool _progressBarActive = true;
  var subscription;

  String _session_grupo;
  String _session_email;

  PrestamosScreenState();

  int _itemCount = 10;

  /// You need to use a FutureBuilder.
  /// Add your async function in the future argument otherwise the
  /// build method gets called before the data are obtained.
  ///
  Future<List<PrestamosModel>> getData() async {
    //  var uri = "http://estudiopracticando.com/servicios/public/Compras/listComprasActivas";
    //http://31.220.60.70
    //var uri = "http://192.168.179.2/vue-globalnet/servicios/public/Compras/listComprasActivas";
    /* var uri =
        "http://31.220.62.119/compras/servicios/public/index.php/Compras/listComprasActivas";
    var response = await http
        .get(Uri.encodeFull(uri), headers: {"Accept": "application/json"});
    var jsondata = json.decode(response.body);
    */

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _session_grupo = (prefs.getString("grupo_id")) ?? "";
      _session_email = (prefs.getString("email")) ?? "";
    });

    var data = json.encode({'grupo_id': _session_grupo.toString()});
    var uri = Global().getAccountUrl("Compras/listComprasActivas");
    var response = await http.post(Uri.encodeFull(uri),
        body: data, headers: {"Accept": "application/json"});
    var jsondata = json.decode(response.body);

    prestamoModel.clear();
    prestamoModel.length = 0;

    total_valor = 0;
    total_saldo = 0;
    total_obligacion_mensual = 0;

    //this._showDialog(jsondata.toString());

    print(jsondata["list"]);

    print(jsondata["list"].length);

    PrestamosModel cm;

    if (jsondata["list"].length > 0) {
      for (var row in jsondata["list"]) {
        cm = new PrestamosModel(
            row["co_idcompras"],
            row["co_secuencia"],
            row["co_fecha"],
            row["co_cobro"],
            row["co_cliente"],
            row["co_fiador"],
            row["co_valor"],
            row["co_saldo"],
            row["co_tiempo"],
            row["co_estado"],
            row["te_nombres"],
            row["te_direccion_domicilio"],
            row["te_telefono_fijo"],
            row["te_movil"],
            row["atraso"],
            row["fecha_mes_pago"],
            row["mes_pago"],
            row["obligacion"],
            row["obligacion_mensual"],
            row["acu_abono_interes"],
            row["ti_porcentaje"],
            row["dias_abonos"],
            row["mes_abonos"],
            row["meses_obligacion"],
            row["total_saldo"],
            row["te_email"],
            row["co_mes_adelantado"],
            row["co_interes_fijo"],
            row["acu_abono_capital"],
            row["atraso_total_hoy"]);

        total_valor += double.parse(row["co_valor"].toString());
        total_saldo += double.parse(row["co_saldo"].toString());
        //data.obligacion
        total_obligacion_mensual += double.parse(row["obligacion"].toString());

        //new Future<dynamic>.delayed(new Duration(seconds: 5)).then((_) {

        setState(() {
          _progressBarActive = false;
          prestamoModel.add(cm);
          _itemCount = prestamoModel.length;
        });
      }
    } else {
      setState(() {
        _progressBarActive = false;
        _itemCount = 0;
      });
    }
  }

  String _value = '';
  void _onClick(String value) => setState(() => _value = value);

  @override
  void initState() {
    //var connectivityResult = new Connectivity().checkConnectivity();
    //initConnectivity();
    this.getData();
  }

  Future<void> _OpcionesDetalles() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Opciones",
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.teal,
                  fontFamily: "Poppins-Bold",
                  letterSpacing: .5,
                  fontWeight: FontWeight.normal)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 15.0, 8.0),
                        child: Text("¿Que deseas hacer?",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'El prestamo seleccionado es de '),
                                TextSpan(
                                    text: prestamoModel[
                                            selectedItemModelPrestamos]
                                        .nombres
                                        .toString(),
                                    style: TextStyle(color: Colors.blueGrey)),
                                TextSpan(text: '!.'),
                              ],
                            ),
                          ),
                        ]),
                  ],
                ),
                Center(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 15.0, 15.0, 1.0),
                              child: Container(
                                width: 200,
                                color: Colors.transparent,
                                child: OutlineButton.icon(
                                  color: Colors.teal,
                                  textColor: Colors.teal,
                                  icon:
                                      Icon(Icons.mode_edit), //`Icon` to display
                                  label: Text(
                                      'Editar prestamo   '), //`Text` to display
                                  onPressed: () {
                                    //Code to execute when Floating Action Button is clicked
                                    //...
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 5.0, 15.0, 1.0),
                              child: Container(
                                  width: 200,
                                  color: Colors.transparent,
                                  child: OutlineButton.icon(
                                    color: Colors.teal,
                                    textColor: Colors.teal,
                                    icon:
                                        Icon(Icons.person), //`Icon` to display
                                    label: Text(
                                        "Editar cliente         "), //`Text` to display
                                    onPressed: () {
                                      var model = prestamoModel[
                                          selectedItemModelPrestamos];

                                      this.setState(() {
                                        ClienteModel _cliente_model =
                                            new ClienteModel(
                                                cedula: model.cliente,
                                                nombres: model.nombres,
                                                telefono: model.telefono == null
                                                    ? ""
                                                    : model.telefono,
                                                direccion:
                                                    model.direccion == null
                                                        ? ""
                                                        : model.direccion,
                                                movil: model.movil == null
                                                    ? ""
                                                    : model.movil,
                                                email: model.email == null
                                                    ? ""
                                                    : model.movil);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GestionClientes(
                                                    _cliente_model,
                                                    model.cliente.toString(),
                                                    "Editar"),
                                          ),
                                        );
                                      });
                                    },
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 5.0, 15.0, 15.0),
                              child: Container(
                                  width: 200,
                                  color: Colors.transparent,
                                  child: OutlineButton.icon(
                                    color: Colors.teal,
                                    textColor: Colors.teal,
                                    icon: Icon(Icons
                                        .delete_outline), //`Icon` to display
                                    label: Text(
                                        "Eliminar prestamo"), //`Text` to display
                                    onPressed: () {
                                      _navigateAndDisplaySelectionEliminarPrestamos(
                                          context);
                                    },
                                  )),
                            ),
                          ],
                        ),
                      ]),
                )
              ],
            ),
          ),
          actions: <Widget>[
            new OutlineButton(
              child: Text('Cancelar'),
              color: Colors.red,
              textColor: Colors.redAccent,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  Future<void> _onTappedButtonRegister() async {
    var body = json.encode({
      "cobro": _session_grupo.toString(),
      "compra": prestamoModel[selectedItemModelPrestamos].id.toString(),
      "email_cliente":
          prestamoModel[selectedItemModelPrestamos].email.toString(),
      "email_usuario": _session_email.toString(),
    });

    var email1_ = prestamoModel[selectedItemModelPrestamos].email.toString();
    var email2_ = _session_email.toString();
    if (_validateEmail(email1_) != null) {
      Fluttertoast.showToast(
          msg: "Email del cliente es invalido",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
    } else if (_validateEmail(email2_) != null) {
      Fluttertoast.showToast(
          msg: "Email del usuario es invalido",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0);
    } else {
      _ShowDialogProgress();
      print(body);
      final response = await EnviarEmailEstadoCuenta(body);
      Future.delayed(Duration(seconds: 1)).then((value) {
        pr.hide().whenComplete(() {
          if (response["type"] == 'error') {
            Fluttertoast.showToast(
                msg: response["message"].toString(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 15.0);
          } else {
            Fluttertoast.showToast(
                msg: response["message"].toString(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.teal,
                textColor: Colors.white,
                fontSize: 15.0);
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
      message: "Enviando estado de cuenta...",
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

  String _lastSelected = 'TAB: 0';

  /*
  * OPCIONES EN EL TAB
  * SI ES ABONAR , ELIMINAR , OPCIONES
  */
  void _selectedTab(int index) {
    print("Selecccion " + index.toString());
    setState(() {
      _lastSelected = 'TAB: $index';
    });

    const List<Key> keys = [
      Key("Network"),
      Key("NetworkDialog"),
      Key("Flare"),
      Key("FlareDialog"),
      Key("Asset"),
      Key("AssetDialog")
    ];

    switch (index) {
      case 0:
        if ((selectedItemModelPrestamos) != null) {
          _navigateAndDisplaySelectionPagePagarCapital(context);
        }
        break;

      case 1:
        if ((selectedItemModelPrestamos) != null) {
          _navigateAndDisplaySelectionPagePagarInteres(context);
        }
        break;

      case 2:
        if ((selectedItemModelPrestamos) != null) {
          //_OpcionesDetalles();
          _onTappedButtonRegister();
        }
        break;
    }
  }

  openAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "Rate",
                        style: TextStyle(fontSize: 24.0),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.star_border,
                            color: Colors.teal,
                            size: 30.0,
                          ),
                          Icon(
                            Icons.star_border,
                            color: Colors.teal,
                            size: 30.0,
                          ),
                          Icon(
                            Icons.star_border,
                            color: Colors.teal,
                            size: 30.0,
                          ),
                          Icon(
                            Icons.star_border,
                            color: Colors.teal,
                            size: 30.0,
                          ),
                          Icon(
                            Icons.star_border,
                            color: Colors.teal,
                            size: 30.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Add Review",
                        border: InputBorder.none,
                      ),
                      maxLines: 8,
                    ),
                  ),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32.0),
                            bottomRight: Radius.circular(32.0)),
                      ),
                      child: Text(
                        "Rate Product",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  dialogInfo() {
    return AlertDialog(
      title: Text("Information"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Text('Delete successful'),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  _showDialogEliminarPrestamos(String tab) async {
    await Future.delayed(Duration(milliseconds: 5));

    showDialog(
        builder: (context) => new AlertDialog(
          title: new Text("¿ Desea eliminar este prestamo ?"),
          content: new Text(
              prestamoModel[selectedItemModelPrestamos].nombres.toString(),
              style: new TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              )),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Si'),
                onPressed: () async {
                  var body = json.encode({
                    "cobro": _session_grupo.toString(),
                    "compra":
                        prestamoModel[selectedItemModelPrestamos].id.toString()
                  });

                  final response = await EliminarPrestamosModel(body);
                  if (response["type"] == 'error') {
                    Fluttertoast.showToast(
                        msg: response["content"].toString(),
                        backgroundColor: Colors.redAccent,
                        toastLength: Toast.LENGTH_SHORT);
                  } else {
                    setState(() {
                      prestamoModel.removeAt(selectedItemModelPrestamos);
                    });

                    Navigator.of(context).pop();
                    // Fluttertoast.showToast(msg:response["content"].toString(),backgroundColor: Colors.teal,toastLength: Toast.LENGTH_SHORT);
                  }
                }),
            new FlatButton(
                child: new Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ), context: context,
        barrierDismissible: false);
  }

  _showDialogEliminarPrestamos1(String tab) async {
    await Future.delayed(Duration(milliseconds: 5));

    showDialog(
        builder: (context) => new AlertDialog(
          title: new Text(tab +
              ' Prestamos .' +
              prestamoModel[selectedItemModelPrestamos].nombres.toString()),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                getTextField("Enter first name", teFirstName),
                getTextField("Enter last name", teLastFirstName),
                getTextField("DD-MM-YYYY", teDOB),
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
                  Navigator.of(context).pop();
                }),
          ],
        ), context: context,
        barrierDismissible: false);
  }

  Widget getList() {
    ListView myList = new ListView.builder(
      itemCount: _itemCount <= 0 ? 1 : _itemCount,
      itemBuilder: (context, i) {
        return _itemCount <= 0
            ? new Column(key: new Key("0"), children: <Widget>[
                new ListTile(
                  contentPadding: new EdgeInsets.only(
                      left: 18.0, top: 15.0, right: 0.0, bottom: 20.0),
                  leading: new CircleAvatar(
                    backgroundColor: Colors.black12,
                    child: new Icon(Icons.add, color: Colors.grey),
                  ),
                  title: Text(
                    "CREAR PRESTAMO",
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    _navigateAndDisplaySelection(context, "");
                  },
                )
              ])
            : new Column(
                key: new Key(prestamoModel[i].toString()),
                children: <Widget>[
                  new Ink(
                    color:
                        (selectedItemModelPrestamos == int.parse(i.toString()))
                            ? const Color(0XFFF1F2F6)
                            : Colors.white,
                    child: new ListTile(
                      leading: _leftSectionValues(prestamoModel, i.toString()),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _middleSection(prestamoModel, i.toString()),
                          _rightSectionValues(prestamoModel, i.toString())
                        ],
                      ),
                      onLongPress: () {
                        setState(() {
                          selectedItemModelPrestamos = int.parse(i.toString());
                        });
                      },
                      onTap: () {
                        if (selectedItemModelPrestamos != null) {
                          if (prestamoModel[i].id.toString() ==
                              prestamoModel[selectedItemModelPrestamos]
                                  .id
                                  .toString()) {
                            setState(() {
                              selectedItemModelPrestamos = null;
                              try {
                                widget.func(
                                    prestamoModel[selectedItemModelPrestamos],
                                    selectedItemModelPrestamos);
                              } catch (e) {
                                widget.func(null, null);
                              }
                            });
                          } else {
                            setState(() {
                              selectedItemModelPrestamos =
                                  int.parse(i.toString());
                              widget.func(
                                  prestamoModel[selectedItemModelPrestamos],
                                  selectedItemModelPrestamos);
                            });
                          }
                        } else {
                          setState(() {
                            selectedItemModelPrestamos =
                                int.parse(i.toString());
                            widget.func(
                                prestamoModel[selectedItemModelPrestamos],
                                selectedItemModelPrestamos);
                          });
                        }
                      },
                    ),
                  ),
                  int.parse(i.toString()) >= (prestamoModel.length - 1)
                      ? new ListTile(
                          contentPadding: new EdgeInsets.only(
                              left: 18.0, top: 15.0, right: 0.0, bottom: 20.0),
                          leading: new CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: new Icon(Icons.add, color: Colors.grey),
                          ),
                          title: Text(
                            "CREAR PRESTAMO",
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            _navigateAndDisplaySelection(context, "");
                          },
                        )
                      : new Divider(height: 4.0),
                ],
              );
      },
    );
    return myList;
  }

  List<Widget> _getItems() {
    var items = <Widget>[];
    for (int i = 1; i < prestamoModel.length; i++) {
      var item = new Column(
        children: <Widget>[
          new Divider(
            height: 10.0,
          ),
          new ListTile(
            leading: _leftSectionValues(prestamoModel, i.toString()),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _middleSection(prestamoModel, i.toString()),
                _rightSectionValues(prestamoModel, i.toString())
              ],
            ),
            onLongPress: () {
              print("Tu is ${prestamoModel[i].id}");
              setState(() {
                selectedItemModelPrestamos = int.parse(i.toString());
              });
            },
            onTap: () {
              setState(() {
                print("Tu is 2 ${prestamoModel[i].id}");
                selectedItemModelPrestamos = int.parse(i.toString());
              });
            },
          )
        ],
      );

      items.add(item);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _progressBarActive == true
          ? new Center(
              child: new Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.teal),
              child: new CircularProgressIndicator(),
            ))
          : new RefreshIndicator(
              child: getList(),
              onRefresh: getData,
            ),

      /*
       * ICONOS EN EL FOOTER
       * ABONAR , BORRAR , A, BOTTOM
       */

      bottomNavigationBar: FABBottomAppBar(
        centerItemText: ' ',
        color: Colors.grey,
        selectedColor: Colors.teal,
        notchedShape: CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        estado: selectedItemModelPrestamos,
        items: [
          FABBottomAppBarItem(
              iconData: Icons.payment, text: 'Abonar a \ncapital', text2: ""),
          FABBottomAppBarItem(
            iconData: Icons.payment,
            text: 'Pagar \nintereses',
            text2: "",
          ),
          /*FABBottomAppBarItem(
               iconData:  ((selectedItemModelPrestamos == true) ? Icons.delete : Icons.delete_outline),
               text: 'Borrar',
               text2: ""
          ),*/
          FABBottomAppBarItem(
            iconData: Icons.email,
            text: 'Enviar estado de cuenta',
            text2: "",
          ),
          FABBottomAppBarItem(
            text2: total_valor.toString(),
            text: total_obligacion_mensual.toString(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(
          context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _middleSection(List<PrestamosModel> model, String index) {
    var data = model[int.parse(index)];
    final int con = int.parse(index.toString()) + 1;

    final middleSection = new Expanded(
      child: new Container(
        padding: new EdgeInsets.only(left: 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new Text(
              data.nombres.toString(),
              style: new TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
            new Text(
              data.direccion.toString(),
              style: new TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
            new Text(
              con.toString() +
                  " PAGO " +
                  data.fecha_mes_pago +
                  " TOTAL SALDO " +
                  data.total_saldo.toString(),
              style: new TextStyle(color: Colors.blueGrey, fontSize: 11.0),
            ),
          ],
        ),
      ),
    );
    return middleSection;
  }

  Widget _leftSectionValues(List<PrestamosModel> model, String index) {
    var data = model[int.parse(index)];
    final int con = int.parse(index.toString()) + 1;

    Color color_obligacion = (int.parse(data.obligacion.toString()) ==
            int.parse(data.acu_abono_interes.toString()))
        ? Colors.lightGreen
        : Colors.redAccent;

    final leftSection = new Container(
        child: new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            new CircleAvatar(
              backgroundColor: color_obligacion,
              foregroundColor: Colors.white,
              // backgroundImage:
              // new NetworkImage("https://content-static.upwork.com/uploads/2014/10/01073427/profilephoto1.jpg"),
              child: new Text(
                data.nombres.substring(0, 1),
                textAlign: TextAlign.right,
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              radius: 20.0,
            ),
            (selectedItemModelPrestamos == int.parse(index.toString()))
                ? new Positioned(
                    top: 25.0,
                    right: 0.0,
                    left: 25.0,
                    bottom: 0,
                    child: new Container(
                      decoration: new BoxDecoration(
                        color: Colors.teal,
                        border: new Border.all(color: Colors.teal, width: 0.0),
                        borderRadius: new BorderRadius.circular(100.0),
                      ),
                      child: new Icon(
                        Icons.check,
                        size: 16.0,
                        color: Colors.white,
                      ),
                    ))
                : new Text("")
          ],
        ),

        /*   new Badge.right(
                value: "", // value to show inside the badge
                child: new Icon(
                  Icons.check,
                  size: 16.0,
                  color: Colors.white,
                ), // text to append (required)
            ),
        */

        /* new CircleAvatar(
          backgroundColor: color_obligacion,
          foregroundColor: Colors.white,
         // backgroundImage:
         // new NetworkImage("https://content-static.upwork.com/uploads/2014/10/01073427/profilephoto1.jpg"),
          child: new Text(
              data.nombres.substring(0, 1),
              textAlign: TextAlign.right,
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
              ),

          ),

          radius: 24.0,
        )
*/
      ],
    )

        /*
      child: new CircleAvatar(
        backgroundImage:
        new NetworkImage("https://content-static.upwork.com/uploads/2014/10/01073427/profilephoto1.jpg"),
        backgroundColor: Colors.lightGreen,
        radius: 24.0,
      ),/*
      width: 32.0,
      height: 32.0,
      padding: const EdgeInsets.all(2.0), // borde width
      decoration: new BoxDecoration(
        color: const Color(0xFFFFFFFF), // border color
        shape: BoxShape.circle,
      )*/

      */

        );
    return leftSection;
  }

  // ignore: unused_element
  Widget _rightSectionValues(List<PrestamosModel> model, String index) {
    var data = model[int.parse(index)];
    final int con = int.parse(index.toString()) + 1;

    Color color_obligacion = (int.parse(data.obligacion.toString()) ==
            int.parse(data.acu_abono_interes.toString()))
        ? Colors.lightGreen
        : Colors.redAccent;

    return Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Text(
            data.valor.toString(),
            style: new TextStyle(color: Colors.lightGreen, fontSize: 12.0),
          ),
          new Text(
            data.obligacion.toString(),
            style: new TextStyle(color: Colors.teal, fontSize: 12.0),
          ),
          new Text(
            data.acu_abono_interes.toString(),
            style: new TextStyle(color: color_obligacion, fontSize: 12.0),
          ),
          /*new CircleAvatar(
            backgroundColor: Colors.lightGreen,
            radius: 12.0,
            child: new Text(data.atrasos.toString(),
              style: new TextStyle(color: Colors.white,
                  fontSize: 11.0),),
          )
          */
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final icons = [Icons.sms, Icons.mail, Icons.phone];
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy - icons.length * 35.0),
          /*
          child: FabWithIcons(
            icons: icons,
            // onIconTapped: _selectedFab,
          ),
          */
        );
      },
      child: FloatingActionButton(
        onPressed: () {
          var i = selectedItemModelPrestamos;
          /*Si se ha seleecionado algun item que seleleccione el menu a donde quiere ir*/
          //if(i >= 0) {

          PrestamosModel pre = new PrestamosModel(
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "","");
          List<PrestamosModel> prestamoMod = new List();
          prestamoMod.add(pre);

          _navigateAndDisplaySelection(context, "all");

          /*Color color;
          if((i) != null) {
            if ((int.parse(prestamoModel[i].obligacion.toString()) ==
                int.parse(
                    prestamoModel[i].acu_abono_interes.toString()))) {
              color = Colors.lightGreen;
            } else {
              color = Colors.redAccent;
            }
          } else {
            color = Colors.teal;

          }*/
          // print(((i) == null) ? "" : prestamoModel[i].seq);

          /*  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CrearPrestamos(
                        color,
                        ((i) == null) ? "" : prestamoModel[i].cliente,
                        ((i) == null) ? "" : prestamoModel[i].nombres,
                        ((i) == null) ? "" : prestamoModel[i].id,
                        ((i) == null) ? "" : prestamoModel[i].seq,
                      ),
                ),
              );*/

          // }
        },
        tooltip: 'Crear un prestamo despues ' +
            ((selectedItemModelPrestamos) == null
                ? ""
                : prestamoModel[selectedItemModelPrestamos].nombres),
        child: Icon(
          Icons.attach_money,
          color: Colors.white,
        ),
        elevation: 2.0,
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget getTextField(
      String inputBoxName, TextEditingController inputBoxController) {
    var loginBtn = new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new TextFormField(
        controller: inputBoxController,
        decoration: new InputDecoration(
          hintText: inputBoxName,
        ),
      ),
    );

    return loginBtn;
  }

  // Un método que inicia SelectionScreen y espera por el resultado de
  // Navigator.pop!
  _navigateAndDisplaySelection(BuildContext context, String op) async {
    // Navigator.push devuelve un Future que se completará después de que llamemos
    // Navigator.pop en la pantalla de selección!
    var i = selectedItemModelPrestamos;

    switch (op) {
      case "":
        {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CrearPrestamos(
                      Colors.teal,
                      "",
                      "",
                      "",
                      "",
                    )),
          );

          // Después de que la pantalla de selección devuelva un resultado,
          // oculta cualquier snackbar previo y muestra el nuevo resultado.
          switch (result) {
            case "refresh_list_prestamos":
              getData();
              break;
          }
        }
        break;
      case "all":
        {
          Color color;
          if ((i) != null) {
            if ((int.parse(prestamoModel[i].obligacion.toString()) ==
                int.parse(prestamoModel[i].acu_abono_interes.toString()))) {
              color = Colors.lightGreen;
            } else {
              color = Colors.redAccent;
            }
          } else {
            color = Colors.teal;
          }

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrearPrestamos(
                color,
                ((i) == null) ? "" : prestamoModel[i].cliente,
                ((i) == null) ? "" : prestamoModel[i].nombres,
                ((i) == null) ? "" : prestamoModel[i].id,
                ((i) == null) ? "" : prestamoModel[i].seq,
              ),
            ),
          );

          // Después de que la pantalla de selección devuelva un resultado,
          // oculta cualquier snackbar previo y muestra el nuevo resultado.
          switch (result) {
            case "refresh_list_prestamos":
              getData();
              break;
          }
        }
    }

    /*
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("$result")));*/
  }

  _navigateAndDisplaySelectionPagePagarInteres(BuildContext context) async {
    var i = selectedItemModelPrestamos;

    Color color;
    if ((i) != null) {
      if ((int.parse(prestamoModel[i].obligacion.toString()) ==
          int.parse(prestamoModel[i].acu_abono_interes.toString()))) {
        color = Colors.lightGreen;
      } else {
        color = Colors.redAccent;
      }
    } else {
      color = Colors.teal;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PageAbonosDetalles(
              color,
              ((i) == null) ? "" : prestamoModel[i].id.toString(),
              ((i) == null) ? "" : prestamoModel[i].nombres.toString(),
              ((i) == null) ? "" : prestamoModel[i].id.toString(),
              ((i) == null) ? "" : prestamoModel[i].seq,
              ((i) == null) ? "" : prestamoModel[i].valor,
              ((i) == null) ? "" : prestamoModel[i].valor,
              ((i) == null) ? "" : prestamoModel[i])
          /* PagarInteresPage(
              ((i) == null) ? "" : prestamoModel[i].id.toString(),
              ((i) == null) ? "" : prestamoModel[i].nombres.toString(),
            ),*/
          ),
    );
  }

  _navigateAndDisplaySelectionPagePagarCapital(BuildContext context) async {
    var i = selectedItemModelPrestamos;

    Color color;
    if ((i) != null) {
      if ((int.parse(prestamoModel[i].obligacion.toString()) ==
          int.parse(prestamoModel[i].acu_abono_interes.toString()))) {
        color = Colors.lightGreen;
      } else {
        color = Colors.redAccent;
      }
    } else {
      color = Colors.teal;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PageAbonosCapital(
              color,
              ((i) == null) ? "" : prestamoModel[i].id.toString(),
              ((i) == null) ? "" : prestamoModel[i].nombres.toString(),
              ((i) == null) ? "" : prestamoModel[i].id.toString(),
              ((i) == null) ? "" : prestamoModel[i].seq,
              ((i) == null) ? "" : prestamoModel[i].valor,
              ((i) == null) ? "" : prestamoModel[i].valor,
              ((i) == null) ? "" : prestamoModel[i])
          /* PagarInteresPage(
              ((i) == null) ? "" : prestamoModel[i].id.toString(),
              ((i) == null) ? "" : prestamoModel[i].nombres.toString(),
            ),*/
          ),
    );
  }

  // Un método que inicia SelectionScreen y espera por el resultado de
  // Navigator.pop!
  _navigateAndDisplaySelectionEliminarPrestamos(BuildContext context) async {
    // Navigator.push devuelve un Future que se completará después de que llamemos
    // Navigator.pop en la pantalla de selección!
    var i = selectedItemModelPrestamos;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EliminarPrestamos(
          ((i) == null) ? "" : prestamoModel[i].id.toString(),
          ((i) == null) ? "" : prestamoModel[i].nombres.toString(),
          ((i) == null) ? "" : prestamoModel[i].valor.toString(),
        ),
      ),
    );
    // Después de que la pantalla de selección devuelva un resultado,
    // oculta cualquier snackbar previo y muestra el nuevo resultado.
    switch (result) {
      case "refresh_list_prestamos":
        getData();
        setState(() {
          _itemCount = _itemCount - 1;
        });
        break;
    }

    /*
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("$result")));*/
  }

  _navigateAndDisplaySelectionAbonosPrestamos(BuildContext context) async {
    // Navigator.push devuelve un Future que se completará después de que llamemos
    // Navigator.pop en la pantalla de selección!
    var i = selectedItemModelPrestamos;

    Color color;
    if ((i) != null) {
      if ((int.parse(prestamoModel[i].obligacion.toString()) ==
          int.parse(prestamoModel[i].acu_abono_interes.toString()))) {
        color = Colors.lightGreen;
      } else {
        color = Colors.redAccent;
      }
    } else {
      color = Colors.teal;
    }

/*
    color,
    ((i) == null) ? "" : prestamoModel[i].cliente,
    ((i) == null) ? "" : prestamoModel[i].nombres,
    ((i) == null) ? "" : prestamoModel[i].id,
    ((i) == null) ? "" : prestamoModel[i].seq,*/

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearAbonos(
            color,
            ((i) == null) ? "" : prestamoModel[i].id.toString(),
            ((i) == null) ? "" : prestamoModel[i].nombres.toString(),
            ((i) == null) ? "" : prestamoModel[i].cliente.toString(),
            ((i) == null) ? "" : prestamoModel[i].seq),
      ),
    );

    // Después de que la pantalla de selección devuelva un resultado,
    // oculta cualquier snackbar previo y muestra el nuevo resultado.
    switch (result) {
      case "refresh_list_prestamos":
        getData();
        setState(() {
          _itemCount = _itemCount - 1;
        });
        break;
    }
  }
}
