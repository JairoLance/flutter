import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_mensuales/components/Animation/FadeAnimation.dart';
import 'package:flutter_app_mensuales/components/fab_bottom_app_bar.dart';
import 'package:flutter_app_mensuales/components/layout.dart';
import 'package:flutter_app_mensuales/components/table_empty.dart';
import 'package:flutter_app_mensuales/models/abonos_model.dart';
import 'package:flutter_app_mensuales/models/prestamos_model.dart';
import 'package:flutter_app_mensuales/pages/util/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProgressDialog pr;

class HistorialAbonosCapitalPage extends StatefulWidget {
  HistorialAbonosCapitalPage(this.compra_id, this.nombres);
  final String compra_id;
  final String nombres;
  @override
  _HistorialAbonosCapitalPageState createState() =>
      _HistorialAbonosCapitalPageState();
}

class _HistorialAbonosCapitalPageState
    extends State<HistorialAbonosCapitalPage> {
  int _selectedItemModel = null;
  final TextEditingController valor_abono = new TextEditingController();

  int _itemCount = 0;
  bool _progressBarActive = true;

  List<AbonosModel> abonosModel = new List();

  double total_valor = 0;
  double total_saldo = 0;
  double total_obligacion = 0;
  double total_obligacion_mensual = 0;
  String nombre_selected = "";
  double total_sum_abono_capital = 0;
  double saldo_total_capital = 0;
  List<int> selectedList = [];

  Future<List<AbonosModel>> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var body = json.encode({
      "cobro": (prefs.getString("grupo_id")) ?? "",
      "compra": widget.compra_id.toString(),
      "descuento": 5
    });

    var jsondata = await HistorialAbonos(body);

    abonosModel.clear();
    abonosModel.length = 0;
    total_valor = 0;
    total_saldo = 0;
    total_obligacion = 0;
    total_obligacion_mensual = 0;
    total_sum_abono_capital = 0;
    saldo_total_capital = 0;

    for (var row in jsondata["list"]) {
      AbonosModel cm = new AbonosModel(
          row["ab_idabono"],
          row["co_idcompras"],
          row["ab_fecha"],
          row["ab_valor"],
          row["co_idcompras"],
          row["co_idcompras"],
          row["te_nombres"],
          row["obligacion"],
          row["obligacion_mensual"],
          row["ab_valor_prestamo"],
          row["co_valor"]);

      total_valor = double.parse(row["acu_abono_interes"].toString());
      total_saldo = double.parse(row["total_saldo"].toString());
      total_obligacion = double.parse(row["obligacion"].toString());
      total_obligacion_mensual =
          double.parse(row["obligacion_mensual"].toString());
      nombre_selected = row["te_nombres"].toString();
      total_sum_abono_capital =
          double.parse(row["acu_abono_capital"].toString());
      saldo_total_capital = double.parse(row["co_saldo"].toString());
      //new Future<dynamic>.delayed(new Duration(seconds: 5)).then((_) {

      setState(() {
        _itemCount = 0;
        _progressBarActive = false;
        abonosModel.add(cm);
        _itemCount = abonosModel.length;
      });
    }
  }

  @override
  void initState() {
    //var connectivityResult = new Connectivity().checkConnectivity();
    //initConnectivity();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('Historial abonos a capital'),
          elevation: 0.7,
          actions: <Widget>[
            _selectedItemModel == null
                ? new IconButton(
                    icon: new Icon(Icons.delete_outline, color: Colors.grey),
                    color: Colors.grey,
                    onPressed: null)
                : new IconButton(
                    icon: new Icon(Icons.delete_forever, color: Colors.white),
                    highlightColor: Colors.pink,
                    onPressed: () {
                      _DialogConfirmDeleteAbono();
                    },
                  ),
            /*new IconButton(
              icon: new Icon(Icons.settings_power),
              highlightColor: Colors.pink,
              onPressed: () {},
            ),*/
          ]),
      body: abonosModel.length <= 0
          ? FadeAnimation(
              1.6,
              EmptyTablePage(
                  "Abonos vacios , agregar los abonos para este cliente , " +
                      widget.nombres.toString()))
          : _progressBarActive == true
              ? new Center(
                  child: new Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.teal),
                  child: new CircularProgressIndicator(),
                ))
              : new RefreshIndicator(
                  child: FadeAnimation(1, getList()),
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
        //onTabSelected: _selectedTab,
        estado: _selectedItemModel,
        items: [
          FABBottomAppBarItem(
              text2: "Obligacion",
              text: "\$" + total_obligacion_mensual.toString(),
              is_numeric: true),
          FABBottomAppBarItem(
              text2: "Debe pagar",
              text: "\$" + total_saldo.toString(),
              is_numeric: true),
          FABBottomAppBarItem(
              text2: "Abonos ",
              text: "\$" + total_sum_abono_capital.toString(),
              is_numeric: true),
          FABBottomAppBarItem(
            text2: "Saldo ",
            text: "\$" + saldo_total_capital.toString(),
            align: TextAlign.center,
            is_numeric: true,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(
          context), // This trailing comma makes auto-formatting nicer for build methods.
    );
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

  _onPressedEliminarAbonos() async {
    var id = abonosModel[_selectedItemModel].id;
    if (_selectedItemModel != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      _ShowDialogProgress();
      var body =
          json.encode({"cobro": (prefs.getString("grupo_id")) ?? "", "id": id});
      var jsonr = await EliminarAbonosModel(body);
      Future.delayed(Duration(seconds: 1)).then((value) {
        pr.hide().whenComplete(() {
          _Toasted(jsonr["type"], jsonr["message"]);
          if (jsonr["type"] == "error") {
          } else {
            setState(() {
              _selectedItemModel = null;
            });
            Navigator.of(context).pop();
            this.getData();
          }
        });
      });
    }
  }

  _onPressedGuardarAbonos() async {
    /*Validacion 1*/
    if (valor_abono.text.isEmpty) {
      _Toasted("error", "No se aceptan valores vacios.");
    } else if (int.parse(valor_abono.text.trim()) <= 0) {
      _Toasted("error", "Ingrese un valor mayor a 0");
    } else if (double.parse(total_obligacion.toString()) > 0) {
      _Toasted(
          "error",
          "Lo sentimos , tiene una mora de intereses por valor de \$" +
              total_obligacion.toString() +
              ".");
    } else {
      _ShowDialogProgress();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      var body = json.encode({
        "cobro": (prefs.getString("grupo_id")) ?? "",
        "co_idcompras": widget.compra_id.toString(),
        "valor": int.parse(valor_abono.text.trim()),
        "ab_descuento": 5,
      });

      var jsonr = await AbonarCapital(body);

      Future.delayed(Duration(seconds: 1)).then((value) {
        pr.hide().whenComplete(() {
          _Toasted(jsonr["type"], jsonr["message"]);
          if (jsonr["type"] == "error") {
          } else {
            this.getData();
            Navigator.of(context).pop();
          }
        });
      });
    }
  }

  Future<void> _DialogConfirmDeleteAbono() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar",
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.teal,
                  fontFamily: "Poppins-Bold",
                  letterSpacing: .5,
                  fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("¿ Desea eliminar este abono ?",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: "Poppins-Bold",
                        fontWeight: FontWeight.normal)),
                Text(
                  'El Abono a eliminar es  , \$' +
                      abonosModel[_selectedItemModel].valor.toString(),
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
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
                      ),
                      Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: new RaisedButton(
                onPressed: () {
                  _onPressedEliminarAbonos();
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
                        size: 18,
                      )
                    ],
                  ),
                ),
              ),
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
          openAlertBox(widget.nombres.toString());
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        elevation: 2.0,
        backgroundColor: Colors.teal,
      ),
    );
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
                          "Ingrese el valor del abono a capital , recuerde que para abonar a capital , es necesario que el cliente este a paz y salvo con los intereses  .",
                          style: textStyle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Tu saldo de intereses es" +
                              "\$ " +
                              total_obligacion.toString(),
                          style: textStyleSubtitle,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Tu saldo de capital es \$" +
                              saldo_total_capital.toString(),
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

  // Function to validate the number
  bool isNumber(String value) {
    if (value == null) {
      return true;
    }
    final n = num.tryParse(value);
    return n != null;
  }

  Widget _middleSection(List<AbonosModel> model, String index) {
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
              data.fecha.toString(),
              style: new TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
            /*new Text(
              con.toString() +
                  " PAGO " +
                  data.fecha_mes_pago +
                  " MESES PAGADO " +
                  data.mes_pago.toString(),
              style: new TextStyle(color: Colors.grey, fontSize: 11.0),
            ),*/
          ],
        ),
      ),
    );
    return middleSection;
  }

  // ignore: unused_element
  Widget _rightSectionValues(List<AbonosModel> model, String index) {
    var data = model[int.parse(index)];
    final int con = int.parse(index.toString()) + 1;

    return Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Text(
            "\$" + data.valor.toString(),
            style: new TextStyle(color: Colors.lightGreen, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget getList() {
    ListView myList = new ListView.builder(
      itemCount: abonosModel.length,
      itemBuilder: (context, i) {
        return new Column(
          //key: new Key(abonosModel[i].toString()),
          children: <Widget>[
            /* new Divider(
                height: 10.0,
              ),*/
            /* new Padding(
                padding:EdgeInsets.only(
                    left: 0.0, top: 0.0, bottom: 10.0, right: 0.0),
            ),*/
            new Ink(
              color: (_selectedItemModel == int.parse(i.toString()))
                  ? const Color(0XFFF1F2F6)
                  : Colors.white,
              child: new ListTile(
                leading: _leftSectionValues(abonosModel, i.toString()),
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _middleSection(abonosModel, i.toString()),
                    _rightSectionValues(abonosModel, i.toString())
                  ],
                ),
                onLongPress: () {
                  setState(() {
                    // _selectedItemModel = int.parse(i.toString());
                  });
                },
                onTap: () {
                  try {
                    print(int.parse(i.toString()));
                    if (_selectedItemModel != null) {
                      if (abonosModel[i].id.toString() ==
                          abonosModel[_selectedItemModel].id.toString()) {
                        setState(() {
                          _selectedItemModel = null;
                          try {} catch (e) {}
                        });
                      } else {
                        setState(() {
                          _selectedItemModel = int.parse(i.toString());
                        });
                      }
                    } else {
                      setState(() {
                        _selectedItemModel = int.parse(i.toString());
                      });
                    }
                  } catch (e) {
                    _selectedItemModel = int.parse(i.toString());
                  }
                },
              ),
            ),
            int.parse(i.toString()) >= (abonosModel.length - 1)
                ? new ListTile(
                    contentPadding: new EdgeInsets.only(
                        left: 18.0, top: 15.0, right: 0.0, bottom: 20.0),
                    leading: new CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: new Icon(Icons.add, color: Colors.grey),
                    ),
                    title: Text(
                      "Abonar",
                      style: TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // _navigateAndDisplaySelection(context, "");
                      openAlertBox(abonosModel[i].nombres.toString());
                    },
                  )
                : new Divider(height: 4.0),
          ],
        );
      },
    );
    return myList;
  }

  Widget _leftSectionValues(List<AbonosModel> model, String index) {
    var data = model[int.parse(index)];
    final int con = int.parse(index.toString()) + 1;
    print(" index " + index);
    print(" select " + _selectedItemModel.toString());
    Color color_obligacion =
        (int.parse(data.id.toString()) == int.parse(data.id.toString()))
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
                con.toString(),
                textAlign: TextAlign.right,
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              radius: 20.0,
            ),
            (_selectedItemModel == int.parse(index.toString()))
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
      ],
    ));
    return leftSection;
  }
}
