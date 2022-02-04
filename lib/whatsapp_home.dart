import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_app_mensuales/components/fab_bottom_app_bar.dart';
import 'package:flutter_app_mensuales/components/fab_with_icons.dart';
import 'package:flutter_app_mensuales/components/layout.dart';
import 'package:flutter_app_mensuales/pages/call_screen.dart';
import 'package:flutter_app_mensuales/pages/camera_screen.dart';
import 'package:flutter_app_mensuales/pages/login_page.dart';
import 'package:flutter_app_mensuales/pages/prestamos/eliminar_prestamos.dart';
import 'package:flutter_app_mensuales/pages/prestamos/page_profile.dart';
import 'package:flutter_app_mensuales/pages/prestamos_screen.dart';
import 'package:flutter_app_mensuales/pages/reportes/historial_abonos.dart';
import 'package:flutter_app_mensuales/pages/reportes/historial_abonos_capital.dart';
import 'package:flutter_app_mensuales/pages/clientes_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_mensuales/pages/terceros/gestion_clientes.dart';
import 'package:flutter_app_mensuales/pages/util/style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/cliente_models.dart';
import 'models/prestamos_model.dart';

class WhatsAppHome extends StatefulWidget {
  @override
  _WhatsAppHomeState createState() => _WhatsAppHomeState();
}

class _WhatsAppHomeState extends State<WhatsAppHome>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  SharedPreferences sharedPreferences;

  String _session_usuario;
  String _session_grupo_nombre;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, initialIndex: 0, length: 3);
    checkLoginStatus();
    _loadvariable() ?? "";
  }

  PrestamosModel _models;
  int _state_models = null;

  callback(new_models, int state_models) {
    setState(() {
      try {
        _state_models = state_models;
        _models = new_models;
      } catch (e) {}
    });
  }

  _loadvariable() async {
    // load variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _session_usuario = (prefs.getString("usuario")) ?? "";
      _session_grupo_nombre = (prefs.getString("grupo_nombre")) ?? "";
    });
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("FoundSoft",
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.teal,
                  fontFamily: "Poppins-Bold",
                  letterSpacing: .5,
                  fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("¿ Deseas salir del sistema ?",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Poppins-Bold",
                        fontWeight: FontWeight.normal)),
                Text(
                    'Al cerrar el sistema , tendras que ingresar de nuevo , con tu cuenta de usuario.'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: Text('Si'),
              textColor: Colors.greenAccent,
              onPressed: () {
                sharedPreferences.clear();
                sharedPreferences.commit();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginPage()),
                    (Route<dynamic> route) => false);
              },
            ),
            new FlatButton(
              child: Text('No'),
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

  Widget build(BuildContext context) {
    //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return new Scaffold(
      appBar: new AppBar(
          title: new Text('FoundSoft - ' + _session_usuario.toString()),
          elevation: 0.7,
          bottom: new TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              //new Tab(icon : new Icon(Icons.camera_alt),),
              new Tab(text: "PRESTAMOS "),
              new Tab(text: "CLIENTES"),
              new Tab(text: "ESTADOS"),
            ],
          ),
          actions: <Widget>[
            /*
            new Icon(Icons.search),
            new Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0)),
            new Icon(Icons.more_vert),
            new Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0)),*/
            new IconButton(
              icon: new Icon(Icons.settings_power),
              highlightColor: Colors.pink,
              onPressed: () {
                _neverSatisfied();
              },
            ),
          ]),
      drawer: new Drawer(
        child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Expanded(
                  //_session_grupo
                  child: new ListView(
                    children: <Widget>[
                      new UserAccountsDrawerHeader(
                        accountName: new Text(_session_usuario.toString()),
                        accountEmail:
                            new Text(_session_grupo_nombre.toString()),
                        margin: EdgeInsets.only(
                            bottom: 1, top: 0, left: 0, right: 0),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                        ),
                        currentAccountPicture: new CircleAvatar(
                          backgroundColor: Colors.white,
                          child: new Text(""),
                        ),
                        otherAccountsPictures: <Widget>[
                          new CircleAvatar(
                            backgroundColor: Colors.tealAccent,
                            child: new Text(""),
                          )
                        ],
                      ),
                      (_state_models == null)
                          ? new Divider(color: Colors.white)
                          : Container(
                              padding: EdgeInsets.only(
                                  left: 10.0,
                                  top: 10.0,
                                  right: 10.0,
                                  bottom: 10.0),
                              decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(1),
                                    topRight: Radius.circular(1),
                                  )),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: Image.asset(
                                          'assets/avatar_hombre.jpg',
                                          width: 40.0,
                                          height: 40.0,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            (_state_models == null)
                                                ? ""
                                                : _models.nombres.toString(),
                                            style: textBoldBlack,
                                          ),
                                          Text(
                                            "Ced : " +
                                                (_state_models == null
                                                    ? ""
                                                    : _models.cliente
                                                        .toString()),
                                            style: textGrey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])),

                      //VALIDAMOS QUE EL USUARIO HAYA SELECCIONADO EL PRESTAMOS DE LA PANTALLA PRINCIPAL
                      _models == null
                          ? new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              title: new Text("Historial de abonos",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black26)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.grey),
                            )
                          : new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              title: new Text("Historial de abonos",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.teal),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistorialAbonosPage(
                                          _models.id.toString(),
                                          _models.nombres.toString())),
                                );
                              },
                            ),
                      new Divider(height: 0),

                      _models == null
                          ? new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              title: new Text("Historial de abonos",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black26)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.grey),
                            )
                          : new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              title: new Text("Historial de abonos a capital",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.teal),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HistorialAbonosCapitalPage(
                                              _models.id.toString(),
                                              _models.nombres.toString())),
                                );
                              },
                            ),
                      new Divider(height: 0),

                      _models == null
                          ? new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              //leading: new Icon(Icons.local_airport),
                              title: new Text("Historial del cliente",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black26)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.grey))
                          : new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              //leading: new Icon(Icons.local_airport),
                              title: new Text("Historial del cliente",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.teal),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                      new Divider(height: 0),
                      _models == null
                          ? new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              //leading: new Icon(Icons.local_airport),
                              title: new Text("Historial de prestamos",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black26)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.grey))
                          : new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              //leading: new Icon(Icons.local_airport),
                              title: new Text("Historial de prestamos",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400)),
                              trailing: new Icon(Icons.insert_drive_file,
                                  color: Colors.teal),
                              onTap: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            HistorialAbonosPage(
                                                _models.id.toString(),
                                                _models.nombres.toString())),
                                    (Route<dynamic> route) => false);
                              },
                            ),
                      new Divider(height: 0),

                      _models == null
                          ? new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              title: new Text("Eliminar prestamo",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black26)),
                              trailing: new Icon(Icons.delete_forever,
                                  color: Colors.grey))
                          : new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              //leading: new Icon(Icons.local_airport),
                              title: new Text("Eliminar prestamo",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400)),
                              trailing: new Icon(Icons.delete_forever,
                                  color: Colors.teal),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EliminarPrestamos(
                                        _models.id.toString(),
                                        _models.nombres.toString(),
                                        _models.valor.toString()),
                                  ),
                                );

                                /*
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EliminarPrestamos(
                                          _models.id.toString(),
                                          _models.nombres.toString()
                                      )
                              ),
                                  (Route<dynamic> route) => false);*/
                              },
                            ),
                      new Divider(height: 0),

                      _models == null
                          ? new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              //leading: new Icon(Icons.local_airport),
                              title: new Text("Editar cliente",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black26)),
                              trailing:
                                  new Icon(Icons.person, color: Colors.grey))
                          : new ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 0, bottom: 0),
                              //leading: new Icon(Icons.local_airport),
                              title: new Text("Editar cliente",
                                  style: new TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400)),
                              trailing:
                                  new Icon(Icons.person, color: Colors.teal),
                              onTap: () {
                                this.setState(() {
                                  ClienteModel _cliente_model =
                                      new ClienteModel(
                                          cedula: _models.cliente,
                                          nombres: _models.nombres,
                                          telefono: _models.telefono == null
                                              ? ""
                                              : _models.telefono,
                                          direccion: _models.direccion == null
                                              ? ""
                                              : _models.direccion,
                                          movil: _models.movil == null
                                              ? ""
                                              : _models.movil);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GestionClientes(
                                          _cliente_model,
                                          _models.cliente.toString(),
                                          "Editar"),
                                    ),
                                  );
                                });

                                /*Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HistorialAbonosPage(
                                          _models.id.toString(),
                                          _models.nombres.toString())),
                                  (Route<dynamic> route) => false);*/
                              },
                            ),
                      new Divider(
                          height:
                              0), /*
                      _models == null
                          ? new ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.only(
                              left: 10, right: 10, top: 0, bottom: 0),
                          //leading: new Icon(Icons.local_airport),
                          title: new Text("Eliminar cliente",
                              style: new TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black26)),
                          trailing: new Icon(Icons.delete_outline,
                              color: Colors.grey))
                          : new ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.only(
                            left: 10, right: 10, top: 0, bottom: 0),
                        //leading: new Icon(Icons.local_airport),
                        title: new Text("Eliminar cliente",
                            style: new TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400)),
                        trailing: new Icon(Icons.delete_forever,
                            color: Colors.teal),
                        onTap: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EliminarPrestamos(
                                 _models.id.toString(),
                                 _models.nombres.toString(),
                              ),
                            ),
                          );
                        },
                      ),
                      new Divider(height: 0),*/
                    ],
                  ),
                ),
                Container(
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                            child: Column(
                          children: <Widget>[
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.settings),
                              title: Text('Ajustes'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PageProfile()),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.power_settings_new),
                              title: Text('Salir'),
                              onTap: () {},
                            )
                          ],
                        ))))
              ],
            )),
      ),
      body: new TabBarView(controller: _tabController, children: <Widget>[
        // new CameraScreen(),
        new PrestamosScreen(func: callback),
        new ClientesPage(),
        new CallsScreen()
      ]),
      /*floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: new FloatingActionButton(
          onPressed: ()=> print("Open chats"),
          backgroundColor: Theme.of(context).accentColor,
          child: new Icon(Icons.message,color:Colors.white),
          elevation: 2.0,
        ),
      */
    );
  }
}
