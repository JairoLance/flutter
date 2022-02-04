import 'dart:convert';

import 'package:flutter_app_mensuales/components/fab_bottom_app_bar.dart';
import 'package:flutter_app_mensuales/components/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_mensuales/models/cliente_models.dart';
import 'package:flutter_app_mensuales/models/path.dart';
import 'package:flutter_app_mensuales/models/terceros_model.dart';
import 'package:flutter_app_mensuales/pages/prestamos/crear_prestamos.dart';
import 'package:flutter_app_mensuales/pages/terceros/gestion_clientes.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClientesPage extends StatefulWidget {
  final Function func;

  const ClientesPage({Key key, this.func}) : super(key: key);

  @override
  ClientesPageState createState() {
    return new ClientesPageState();
  }
}

class ClientesPageState extends State<ClientesPage> {
  SharedPreferences sharedPreferences;

  int _itemCount = 0;
  int selectedItemModelPrestamos = null;
  bool _progressBarActive = true;
  String _session_grupo;

  TextEditingController _controller_buscar = new TextEditingController();

  List<TercerosModel> tercerosModel = new List();

  Future<List<TercerosModel>> getData(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _session_grupo = (prefs.getString("grupo_id")) ?? "";
    });

    var data = json.encode(
        {'grupo_id': _session_grupo.toString(), 'buscar': text.toString()});
    print(data);
    var uri = Global().getAccountUrl("Terceros/listClientesXGrupo");
    var response = await http.post(Uri.encodeFull(uri),
        body: data, headers: {"Accept": "application/json"});
    var jsondata = json.decode(response.body);

    tercerosModel.clear();
    tercerosModel.length = 0;

    TercerosModel cm;

    print(jsondata["list"].length);

    if (jsondata["list"].length > 0) {
      for (var row in jsondata["list"]) {
        cm = new TercerosModel(
            teCedula: row["te_cedula"],
            teNombres: row["te_nombres"],
            teDireccion: row["te_direccion"],
            teMovil: row["te_movil"],
            teTelefonoFijo: row["te_telefono_fijo"],
            teEmail: row["te_email"],
        );

        setState(() {
          _progressBarActive = false;
          tercerosModel.add(cm);
          _itemCount = tercerosModel.length;
        });
      }
    } else {
      setState(() {
        _progressBarActive = false;
        _itemCount = 0;
      });
    }
  }

  @override
  void initState() {
    this.getData("");
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
                    "CREAR CLIENTE",
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {},
                )
              ])
            : new Column(
                key: new Key(tercerosModel[i].toString()),
                children: <Widget>[
                  new Ink(
                    color:
                        (selectedItemModelPrestamos == int.parse(i.toString()))
                            ? const Color(0XFFF1F2F6)
                            : Colors.white,
                    child: new ListTile(
                      leading: _leftSectionValues(tercerosModel, i.toString()),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _middleSection(tercerosModel, i.toString()),
                          _rightSectionValues(tercerosModel, i.toString())
                        ],
                      ),
                      onLongPress: () {
                        setState(() {
                          selectedItemModelPrestamos = int.parse(i.toString());
                        });
                      },
                      onTap: () {
                        print(selectedItemModelPrestamos);

                        if (selectedItemModelPrestamos != null) {
                          if (tercerosModel[i].teCedula.toString() ==
                              tercerosModel[selectedItemModelPrestamos]
                                  .teCedula
                                  .toString()) {
                            setState(() {
                              selectedItemModelPrestamos = null;
                              try {} catch (e) {}
                            });
                          } else {
                            setState(() {
                              selectedItemModelPrestamos =
                                  int.parse(i.toString());
                            });
                          }
                        } else {
                          setState(() {
                            selectedItemModelPrestamos =
                                int.parse(i.toString());
                          });
                        }
                      },
                    ),
                  ),
                  int.parse(i.toString()) >= (tercerosModel.length - 1)
                      ? new ListTile(
                          contentPadding: new EdgeInsets.only(
                              left: 18.0, top: 15.0, right: 0.0, bottom: 20.0),
                          leading: new CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: new Icon(Icons.add, color: Colors.grey),
                          ),
                          title: Text(
                            "CREAR CLIENTE",
                            style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // _navigateAndDisplaySelection(context, "");
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
    for (int i = 1; i < tercerosModel.length; i++) {
      var item = new Column(
        children: <Widget>[
          new Divider(
            height: 10.0,
          ),
          new ListTile(
            leading: _leftSectionValues(tercerosModel, i.toString()),
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _middleSection(tercerosModel, i.toString()),
                _rightSectionValues(tercerosModel, i.toString())
              ],
            ),
            onLongPress: () {
              print("Tu is ${tercerosModel[i].teCedula}");
              setState(() {
                selectedItemModelPrestamos = int.parse(i.toString());
              });
            },
            onTap: () {
              setState(() {
                print("Tu is 2 ${tercerosModel[i].teCedula}");
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

  onSearchTextChanged(String text) async {
    this.getData(text);
  }

  Widget _buildSearchBox() {
    return new Padding(
      padding: const EdgeInsets.all(5.0),
      child: new Card(
        child: new ListTile(
          dense: true,
          leading: new Icon(Icons.search),
          title: new TextField(
            controller: _controller_buscar,
            decoration: new InputDecoration(
              hintText: 'Buscar',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            ),
            onChanged: onSearchTextChanged,
          ),
          trailing: new IconButton(
            icon: new Icon(Icons.cancel),
            onPressed: () {
              _controller_buscar.clear();
              onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return new Column(
      children: <Widget>[
        new Container(
            color: Theme.of(context).primaryColor, child: _buildSearchBox()),
        new Expanded(
          child: _progressBarActive == true
              ? new Center(
                  child: new Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.teal),
                  child: new CircularProgressIndicator(),
                ))
              : new RefreshIndicator(
                  child: getList(),
                  onRefresh: () {
                    getData("");
                  },
                ),
        ),
      ],
    );
  }

  void _selectedTab(int index) {



    var model = tercerosModel[selectedItemModelPrestamos];

    switch (index) {
      case 0:
        if ((selectedItemModelPrestamos) != null) {

          this.setState(() {
            ClienteModel _cliente_model = new ClienteModel(
                cedula: model.teCedula,
                nombres: model.teNombres,
                telefono: model.teTelefonoFijo == null ? "" : model.teTelefonoFijo,
                direccion: model.teDireccion == null ? "" : model.teDireccion,
                movil: model.teMovil == null ? "" : model.teMovil,
                email: model.teEmail == null ? "" : model.teEmail,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GestionClientes(
                    _cliente_model,model.teCedula.toString(),"Editar"),
              ),
            );
          });

        }
        break;

      case 1:
        if ((selectedItemModelPrestamos) != null) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  CrearPrestamos(
                Colors.teal,
                model.teCedula,
                model.teNombres,
                "",
                "",
              ),
            ),
          );

        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _buildBody(),

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
              iconData: Icons.supervisor_account,
              text: 'Gestionar cliente',
              text2: ""),
          FABBottomAppBarItem(
            iconData: Icons.monetization_on,
            text: 'Gestionar prestamo',
            text2: "",
          ),
          /*FABBottomAppBarItem(
               iconData:  ((selectedItemModelPrestamos == true) ? Icons.delete : Icons.delete_outline),
               text: 'Borrar',
               text2: ""
          ),*/
          FABBottomAppBarItem(
            //iconData: Icons.dashboard,
            text: '',
            text2: "",
          ),
          FABBottomAppBarItem(
            text2: "Total",
            text: _itemCount.toString(),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(
          context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _middleSection(List<TercerosModel> model, String index) {
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
              data.teNombres.toString(),
              style: new TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
            ),
            new Text(
              data.teDireccion == null ? "" : data.teDireccion.toString(),
              style: new TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
            new Text(
              data.teCedula.toString(),
              style: new TextStyle(color: Colors.blueGrey, fontSize: 11.0),
            ),
          ],
        ),
      ),
    );
    return middleSection;
  }

  Widget _leftSectionValues(List<TercerosModel> model, String index) {
    var data = model[int.parse(index)];
    final int con = int.parse(index.toString()) + 1;

    final leftSection = new Container(
        child: new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            new CircleAvatar(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              // backgroundImage:
              // new NetworkImage("https://content-static.upwork.com/uploads/2014/10/01073427/profilephoto1.jpg"),
              child: new Text(
                data.teNombres.substring(0, 1),
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
      ],
    ));
    return leftSection;
  }

  // ignore: unused_element
  Widget _rightSectionValues(List<TercerosModel> model, String index) {
    var data = model[int.parse(index)];
    final int con = int.parse(index.toString()) + 1;

    return Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Text(
            con.toString(),
            style: new TextStyle(color: Colors.lightGreen, fontSize: 12.0),
          ),
          new Text(
            "",
            style: new TextStyle(color: Colors.teal, fontSize: 12.0),
          ),
          new Text(
            "",
            style: new TextStyle(color: Colors.teal, fontSize: 12.0),
          ),
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
        );
      },
      child: FloatingActionButton(
        onPressed: () {},
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
}
