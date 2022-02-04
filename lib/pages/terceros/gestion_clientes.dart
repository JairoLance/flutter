import 'dart:async';
import 'dart:convert';
import 'package:flutter_app_mensuales/models/cliente_models.dart';
import 'package:flutter_app_mensuales/models/par_condicion.dart';
import 'package:flutter_app_mensuales/models/prestamos_model.dart';
import 'package:flutter_app_mensuales/pages/util/style.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GestionClientes extends StatefulWidget  {



  GestionClientes(this.clienteModel,this._cedula_index,this._op);

  /*Parametros de entrada al router vista*/
  final String _cedula_index;
  final String _op;
  ClienteModel clienteModel;


  @override
  GestionClientesState createState() {
    return new GestionClientesState();
  }
}


class _ClienteData {

  String cedula  = "";
  String nombres = "";
  String direccion = "";
  String telefono = "";
  String movil = "";
  String email = "";

}


class GestionClientesState extends State<GestionClientes> {

  ClienteModel newClienteModel = new ClienteModel();
  _ClienteData _data = new _ClienteData();



  String op = "Editar";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

 final TextEditingController _txt_cedula  = new TextEditingController();
 final TextEditingController _txt_nombres = new TextEditingController();
 final TextEditingController _txt_direccion = new TextEditingController();
 final TextEditingController _txt_telefono = new TextEditingController();
 final TextEditingController _txt_movil = new TextEditingController();
  TextEditingController _textEditConEmail = TextEditingController();



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

  String _validateNombre(String value) {
    if (value.length < 4) {
      return 'El nombre es demasiado corto';
    }

    if (value.isEmpty) {
      return 'El nombre es requerido';
    }

    return null;
  }


  String _validateCedula(String value) {
    if (value.length < 4) {
      return 'La cedula es demasiada corta';
    }

    if (value.isEmpty) {
      return 'No de cedula requerida';
    }

    return null;
  }


  void _resetForms(){
    _formKey.currentState?.reset();
    _data.nombres = "";
    _data.cedula = "";

    _txt_nombres.clear();
    _txt_cedula.clear();
    _txt_direccion.clear();
    _txt_telefono.clear();
    _txt_movil.clear();

     setState(() {
       this.op = "Guardar";
     });

  }
  @override
  void initState() {

    var model = widget.clienteModel;
    this.op = widget._op.toString();

    this._data.cedula  = widget._cedula_index.toString();
    this._data.nombres = model.nombres;
    this._data.direccion = model.direccion;
    this._data.telefono  = model.telefono;
    this._data.movil    = model.movil;
    this._data.email    = model.email;

    _txt_cedula.text    = _data.cedula.toString();
    _txt_nombres.text   = _data.nombres.toString();
    _txt_direccion.text = _data.direccion.toString();
    _txt_telefono.text  = _data.telefono.toString();
    _txt_movil.text     = _data.movil.toString();
    _textEditConEmail.text = _data.email.toString();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   /* var model = widget.data[widget.index];

    this._data.cedula  = model.cliente;
    this._data.nombres = model.nombres;
    this._data.direccion = model.direccion;
    this._data.telefono  = model.telefono;
    this._data.movil    = model.movil;*/

  /*  _txt_cedula.text    = _data.cedula.toString();
    _txt_nombres.text   = _data.nombres.toString();
    _txt_direccion.text = _data.direccion.toString();
    _txt_telefono.text  = _data.telefono.toString();
    _txt_movil.text     = _data.movil.toString();
*/
    final _btnSave = RaisedButton(
        child: new Text("Guardar",
          style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13.0),),
        color: Colors.teal,
        elevation: 4.0,
        onPressed: () async {
          if (this._formKey.currentState.validate()) {


            SharedPreferences prefs = await SharedPreferences.getInstance();


            var body = json.encode({
              "cobro"     : (prefs.getString("grupo_id")) ?? "",
              "nit"       : _data.cedula.toString(),
              "nombres"   : _data.nombres.toString(),
              "direccion" : _data.direccion.toString(),
              "telefono"  : _data.telefono.toString(),
              "movil"     : _data.movil.toString(),
              "email"     : _textEditConEmail.text.toString(),
              "op"        : this.op
            });

            // final response = await http.post("http://192.168.179.2/vue-globalnet/servicios/public/Terceros/Guardar", body:params);
            final response = await postClienteModel(this.op,body);
            final mensaje = response["content"].toString();
            //var datauser = json.decode(response.body);
            // final response = await updateClienteModel(http.Client(), params);

              _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text('Mensaje : ' + mensaje),
                    duration: Duration(seconds: 13),
                  ));
          }
        }
    );

    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'CLIENTES',
              ),
              Visibility(
                visible: true,
                child: Text(
                  _data.nombres,
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],

          ),
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.filter_none),
                onPressed: () {
                  _resetForms();
                },
            ),
            new IconButton(icon: new Icon(Icons.save),
              onPressed: () async {
                if (this._formKey.currentState.validate()) {
                  var body = json.encode({
                    "cobro": "115",
                    "nit": _txt_cedula.text,
                    "nombres": _txt_nombres.text,
                    "direccion": _txt_direccion.text,
                    "telefono": _txt_telefono.text,
                    "movil": _txt_movil.text,
                    "email" : _textEditConEmail.text.toString()
                  });

                  // final response = await http.post("http://192.168.179.2/vue-globalnet/servicios/public/Terceros/Guardar", body:params);
                  final response = await postClienteModel(this.op,body);
                  final mensaje  = response["content"].toString();
                  final type     = response["type"].toString();
                  print(response);

                  Color typeColor = Colors.blueAccent;
                  var duracion = 4;
                  if(type == "error"){
                    typeColor = Colors.redAccent;
                    duracion = 10;
                  }
                  //var datauser = json.decode(response.body);
                  // final response = await updateClienteModel(http.Client(), params);

                  _scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text('Mensaje : ' + mensaje),
                        duration: Duration(seconds: duracion),
                        backgroundColor: typeColor,
                      ));
                }
              },
            ),
            new IconButton(icon: new Icon(Icons.menu),
              onPressed: (){},
            ),
          ],
        ),
        body: new Container(
            child: new Form(
              key: this._formKey,
              child: new ListView(
                children: <Widget>[
                  new Container(
                      child: Image.asset("assets/images/grupo_clientes.png",height: 200.0,)
                  ),
                  SizedBox(height: 7),
                  /*Text('Enable Your Location', style: heading35Black,
                ),*/
                  Container(
                    padding: new EdgeInsets.only(left: 40.0, right: 40.0),
                    child: new Text( 'Actualize los datos del cliente e envie correos del estado de la cuenta !',
                      style: textGrey,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.confirmation_number),
                    title: new TextFormField(
                        keyboardType: TextInputType.text, // Use email input type for emails.
                        controller:  _txt_cedula,
                        autofocus: true,
                       // initialValue:  this._data.cedula,
                        decoration: new InputDecoration(
                            hintText: 'Numero de identificacion',
                            labelText: 'Cedula o Nit'
                        ),
                        validator: this._validateCedula,
                        onSaved: (String value) {
                          this._data.cedula = value;
                        }
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: new TextFormField(
                        keyboardType: TextInputType.text, // Use email input type for emails.
                        controller:  _txt_nombres,
                        //initialValue: this._data.nombres,
                        decoration: new InputDecoration(
                            hintText: 'Nombres y apellidos completos',
                            labelText: 'Nombres y apellidos'
                        ),
                        validator: this._validateNombre,
                        onSaved: (String value) {
                          this._data.nombres = value;
                        }
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: new TextFormField(
                        keyboardType: TextInputType.text, // Use email input type for emails.
                        controller:  _txt_direccion,
                        //    initialValue: this._data.nombres,
                        decoration: new InputDecoration(
                            hintText: 'Direccion',
                            labelText: 'Direccion'
                        ),
                        //validator: this._validateNombre,
                        onSaved: (String value) {
                          this._data.direccion = value;
                        }
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: new TextFormField(
                        keyboardType: TextInputType.number, // Use email input type for emails.
                        controller:  _txt_telefono,
                        //    initialValue: this._data.nombres,
                        decoration: new InputDecoration(
                            hintText: 'Telefono',
                            labelText: 'Telefono fijo'
                        ),
                        //validator: this._validateNombre,
                        onSaved: (String value) {
                          this._data.telefono = value;
                        }
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: new TextFormField(
                        keyboardType: TextInputType.number, // Use email input type for emails.
                        controller:  _txt_movil,
                        //    initialValue: this._data.nombres,
                        decoration: new InputDecoration(
                            hintText: 'Celular o movil',
                            labelText: 'Celular'
                        ),
                        //validator: this._validateNombre,
                        onSaved: (String value) {
                          this._data.movil = value;
                        }
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.email),
                    title: new TextFormField(
                      controller: _textEditConEmail,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      decoration: new InputDecoration(
                          hintText: 'Su correo electronico',
                          labelText: 'Email'
                      ),
                    ),
                  ),


                ],
              ),
            )
        ),



    );

  }





}
