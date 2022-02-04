import 'dart:async';
import 'dart:convert';
import 'package:flutter_app_mensuales/models/cliente_models.dart';
import 'package:flutter_app_mensuales/models/par_condicion.dart';
import 'package:flutter_app_mensuales/models/prestamos_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


class GestionClientes extends StatefulWidget  {
  GestionClientes(this.index,this.data,this.EstadoAtrasoColor);

  /*Parametros de entrada al router vista*/
  final int index;
  final List<PrestamosModel> data;
  Color EstadoAtrasoColor;

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


  Par_condicion selectedPar_condicion;
  List<Par_condicion> par_condicion = <Par_condicion>[const Par_condicion(1,'Abono'), const Par_condicion(2,'Abono a capital')];



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

    var model = widget.data[widget.index];

    this._data.cedula  = model.cliente;
    this._data.nombres = model.nombres;
    this._data.direccion = model.direccion;
    this._data.telefono  = model.telefono;
    this._data.movil    = model.movil;

    _txt_cedula.text    = _data.cedula.toString();
    _txt_nombres.text   = _data.nombres.toString();
    _txt_direccion.text = _data.direccion.toString();
    _txt_telefono.text  = _data.telefono.toString();
    _txt_movil.text     = _data.movil.toString();

    selectedPar_condicion = par_condicion[0];

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

            var body = json.encode({
              "cobro"     : "115",
              "nit"       : _data.cedula.toString(),
              "nombres"   : _data.nombres.toString(),
              "direccion" : _data.direccion.toString(),
              "telefono"  : _data.telefono.toString(),
              "movil"     : _data.movil.toString(),
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
          title: new Text(_data.nombres),
          backgroundColor: widget.EstadoAtrasoColor,
        ),
        body: new Container(
            child: new Form(
              key: this._formKey,
              child: new ListView(
                children: <Widget>[

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
                  new Center(
                    child: new DropdownButton<Par_condicion>(
                      value: selectedPar_condicion,
                      isDense: true,
                      // key : new Key(selectedPar_condicion.id.toString()),
                      onChanged: (Par_condicion newValue) {
                        print("P "+ newValue.name);
                        setState(() {
                          selectedPar_condicion = newValue;
                        });
                      },
                      items: par_condicion.map((Par_condicion condicion) {

                        return new DropdownMenuItem<Par_condicion>(
                          value:  condicion,
                          child: new Text(
                            condicion.name,
                            style: new TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                ],
              ),
            )
        ),

        bottomNavigationBar:_buildBottomNavigationBar()


    );

  }


  _buildBottomNavigationBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: RaisedButton(
              onPressed: () async {
                if (this._formKey.currentState.validate()) {
                  var body = json.encode({
                    "cobro": "115",
                    "nit": _txt_cedula.text,
                    "nombres": _txt_nombres.text,
                    "direccion": _txt_direccion.text,
                    "telefono": _txt_telefono.text,
                    "movil": _txt_movil.text
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
              color: Colors.teal,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "GUARDAR",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: RaisedButton(
              onPressed: () {
                _resetForms();

              },
              color: Colors.tealAccent,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.create_new_folder,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      "NUEVO CLIENTE",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



}
