import 'dart:async';
import 'dart:convert';
import 'package:flutter_app_mensuales/components/CircleIconButton.dart';
import 'package:flutter_app_mensuales/models/abonos_model.dart';
import 'package:flutter_app_mensuales/models/cliente_models.dart';
import 'package:flutter_app_mensuales/models/path.dart';
import 'package:flutter_app_mensuales/pages/terceros/gestion_clientes.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearAbonos extends StatefulWidget {
  CrearAbonos(this.EstadoAtrasoColor, this._cedula_index, this._nombres_index,
      this._idcompra_index, this._secuencia_index);

  final _cedula_index;
  final _nombres_index;
  final _idcompra_index;
  final _secuencia_index;

  Color EstadoAtrasoColor;

  @override
  CrearAbonosState createState() {
    return new CrearAbonosState();
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

class CrearAbonosState extends State<CrearAbonos> {
  ClienteModel newClienteModel = new ClienteModel();
  _ClienteData _data = new _ClienteData();

  String _session_grupo;

  String op = "Editar";
  bool isSwitched = true;

  /*Parametros de cliente*/
  bool ex_cliente = false;
  bool _progressBarActive = false;
  Timer timeHandle;
  String textValue;
  String ClientehelperText = "***";

  String _radioValue1 = "";
  int correctScore = 0;

  void _handleRadioValueChange1(String value) {
    setState(() {
      _radioValue1 = value;
      switch (_radioValue1) {
        case "antes":
          Fluttertoast.showToast(
              msg: ' Antes <', toastLength: Toast.LENGTH_SHORT);
          correctScore++;
          break;
        case "despues":
          Fluttertoast.showToast(
              msg: 'Despues >', toastLength: Toast.LENGTH_SHORT);
          break;
        case "ultimo":
          Fluttertoast.showToast(
              msg: 'Ultimo !', toastLength: Toast.LENGTH_SHORT);
          break;
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _txt_tiempo = new TextEditingController();
  final TextEditingController _txt_cedula = new TextEditingController();
  final TextEditingController _txt_valor_Abonos = new TextEditingController();
  final TextEditingController _txt_fecha_Abonos = new TextEditingController();

  String _mySelectionTiempo;

  List data_list_tiempo = List(); //edited line
  Future<String> getDataTiempo() async {
    var res = await http.post(
        Uri.encodeFull(Global().getAccountUrl("Parametros/ListTiempos")),
        headers: {"Accept": "application/json"});
    var resBody = json.decode(res.body);
    setState(() {
      data_list_tiempo = resBody;
    });
    return "Sucess";
  }

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.date;
  bool editable = true;
  DateTime date;

  void textChanged(String val) async {
    ClienteModel _cliente_model;

    textValue = val;
    setState(() {
      _progressBarActive = true;
    });

    if (timeHandle != null) {
      timeHandle.cancel();
    }

    var body = json.encode({"nit": textValue.toString()});
    final response = await GetClienteByLike(body);

    _cliente_model = new ClienteModel(
        cedula: response["row"]["te_cedula"],
        nombres: response["row"]["te_nombres"],
        telefono: response["row"]["te_telefono_fijo"],
        direccion: response["row"]["te_direccion"],
        movil: response["row"]["te_movil"]);

    timeHandle = Timer(Duration(seconds: 1), () {
      setState(() {
        this.ClientehelperText = response["row"]["te_nombres"];
        this.ex_cliente = (response["row"]["te_nombres"] != "") ? true : false;
        _progressBarActive = false;
        newClienteModel = _cliente_model;
      });
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  bool isValidDob(String dob) {
    if (dob.isEmpty) return true;
    var d = convertToDate(dob);
    return d != null && d.isBefore(new DateTime.now());
  }

  void _resetForms() {
    _formKey.currentState?.reset();
    setState(() {
      this.op = "Guardar";
    });
  }

  @override
  void initState() {
    _loadvariable();

    this._data.cedula = widget._cedula_index;
    this._data.nombres = widget._nombres_index;
    this._data.direccion = "";
    this._data.telefono = "";
    this._data.movil = "";
    this._data.seq = widget._secuencia_index;

    this._radioValue1 =
        widget._secuencia_index.toString() == "" ? "ultimo" : "despues";

    this.getDataTiempo();

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

  @override
  Widget build(BuildContext context) {
    final _btnSave = RaisedButton(
        child: new Text(
          "Guardar",
          style: new TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.0),
        ),
        color: Colors.teal,
        elevation: 4.0,
        onPressed: () async {});

    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Abonos',
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
          new IconButton(
            icon: new Icon(Icons.filter_none),
            onPressed: () {
              _resetForms();
            },
          ),
          new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
        backgroundColor: widget.EstadoAtrasoColor,
      ),

      /*AppBar(
              title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "CREAR PRESTAMO",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    Text(
                      _data.nombres,
                      style: TextStyle(color: Colors.white70 , fontSize: 13.0),
                    ),

                  ]),
              backgroundColor: widget.EstadoAtrasoColor,
            ),*/

      floatingActionButton: new FloatingActionButton(
        onPressed: () async {
          if (this._formKey.currentState.validate()) {
            // Fluttertoast.showToast(msg: "Tiempo :" + _mySelectionTiempo.toString() , toastLength: Toast.LENGTH_SHORT);

            var body = json.encode({
              "cobro": _session_grupo.toString(),
              "ref_secuencia": _data.seq == "" ? 0 : _data.seq.toString(),
              "sw": this._radioValue1,
              "nit": _txt_cedula.text,
              "fecha": _txt_fecha_Abonos.text,
              "valor": _txt_valor_Abonos.text,
              "tiempo": _mySelectionTiempo.toString()
            });

            if (isValidDob(_txt_fecha_Abonos.text)) {
              Fluttertoast.showToast(
                  msg: "Fecha invalida",
                  backgroundColor: Colors.redAccent,
                  toastLength: Toast.LENGTH_SHORT);
            } else if (_txt_valor_Abonos.text == "") {
              Fluttertoast.showToast(
                  msg: "Error valor del prestamo",
                  backgroundColor: Colors.redAccent,
                  toastLength: Toast.LENGTH_SHORT);
            } else if ((_mySelectionTiempo) == null) {
              Fluttertoast.showToast(
                  msg: "Escoja el porcentaje de interes",
                  backgroundColor: Colors.redAccent,
                  toastLength: Toast.LENGTH_SHORT);
            } else {
              final response = await CrearAbonosModel(body);
              if (response["type"] == 'error') {
                Fluttertoast.showToast(
                    msg: response["content"].toString(),
                    backgroundColor: Colors.redAccent,
                    toastLength: Toast.LENGTH_SHORT);
              } else {
                Fluttertoast.showToast(
                    msg: response["content"].toString(),
                    backgroundColor: Colors.teal,
                    toastLength: Toast.LENGTH_SHORT);
                Navigator.pop(context, 'refresh_list_Abonos');
              }
            }

            /*var body = json.encode({
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
            */
          }

          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MyApp()
            ),
          );*/
        },
        tooltip: 'Guardar prestamo',
        backgroundColor: Colors.teal,
        elevation: 10.0,
        child: new Icon(Icons.save, color: Colors.white),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      resizeToAvoidBottomInset: false,
      body: new Container(
          child: new Form(
        key: this._formKey,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          children: <Widget>[
            new ListTile(
              title: new TextField(
                //  controller: _textController,
                keyboardType: TextInputType.number,
                onChanged: textChanged,
                controller: _txt_cedula,
                style: new TextStyle(
                  fontWeight: FontWeight.w200,
                  color: (ex_cliente) ? Colors.black : Colors.redAccent,
                  fontSize: 17.0,
                ),

                decoration: new InputDecoration(
                  //  hintStyle: TextStyle(fontSize: 20.0, color: Colors.redAccent),
                  prefixIcon: CircleIconButton(
                    icon: (ex_cliente) ? Icons.search : Icons.search,
                    onPressed: () {
                      this.setState(() {
                        //  _textController.clear();
                      });
                    },
                  ),
                  hintText: 'hiny',
                  helperText: ClientehelperText,
                  labelText: 'Nit/Cedula *',
                  suffixIcon: _progressBarActive == false
                      ? CircleIconButton(
                          icon: (ex_cliente) ? Icons.edit : Icons.add,
                          onPressed: () {
                            this.setState(() {
                              //  _textController.clear();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GestionClientes(
                                      newClienteModel == null
                                          ? ""
                                          : newClienteModel,
                                      _txt_cedula.text == null
                                          ? ""
                                          : _txt_cedula.text,
                                      (ex_cliente) ? "Editar" : "Guardar"
                                  ),
                                ),
                              );
                            });
                          },
                        )
                      : new Container(
                          child: new Theme(
                          data: Theme.of(context)
                              .copyWith(accentColor: Colors.teal),
                          child: new CircularProgressIndicator(),
                        )),
                ),
                maxLines: 1,
              ),
            ),

            new ListTile(
              // leading: const Icon(Icons.timer),
              //contentPadding:  new EdgeInsets.all(16.0),
              /* leading: const Icon(
                      Icons.playlist_add_check,
                      color: Colors.black,
                    ),*/
              dense: false,

              title: new DropdownButton(
                hint: new Text("Porcentaje%...", textAlign: TextAlign.center),
                isDense: false,
                isExpanded: true,
                value: _mySelectionTiempo,
                // key : new Key(selectedPar_condicion.id.toString()),
                onChanged: (item) {
                  setState(() {
                    _mySelectionTiempo = item;
                  });
                },
                items: data_list_tiempo.map((item) {
                  return new DropdownMenuItem(
                    value: item['ti_idtiempo'],
                    child: new Text(
                      item['ti_frecu_pago_letras'],
                      style: new TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),

            new ListTile(
              title: new TextFormField(
                  keyboardType:
                      TextInputType.number, // Use email input type for emails.
                  controller: _txt_valor_Abonos,
                  validator: (String arg) {
                    if (arg.isEmpty) {
                      return 'Digite el valor del prestamo';
                    } else if (int.parse(arg) <= 0) {
                      return 'Debe ser mayor a 0';
                    } else {
                      return null;
                    }
                  },
                  //    initialValue: this._data.nombres,
                  decoration: new InputDecoration(
                      prefixIcon: Icon(Icons.attach_money),
                      hintText: '0',
                      labelText: 'Valor del prestamo'),
                  //validator: this._validateNombre,
                  onSaved: (String value) {
                    this._data.movil = value;
                  }),
            ),

            new ListTile(
              title: DateTimePickerFormField(
                inputType: inputType,
                format: formats[inputType],
                editable: editable,
                initialValue: DateTime.now(),
                controller: _txt_fecha_Abonos,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                  prefixIcon: Icon(Icons.calendar_today),
                  //  icon: const Icon(Icons.calendar_today),
                  labelText: 'Fecha del prestamo',
                ),
                onChanged: (dt) => setState(() => date = dt),
              ),
            ),

            new Padding(
              padding: new EdgeInsets.all(8.0),
            ),

            new ListTile(
              contentPadding: new EdgeInsets.only(left: 16, top: 0, bottom: 0),
              title: new Text('Posicion del prestamo:',
                  style: new TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0,
                      color: Colors.teal)),
              subtitle: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Radio(
                    value: "antes",
                    groupValue: _radioValue1,
                    onChanged: _handleRadioValueChange1,
                  ),
                  new Text(
                    'Antes',
                    style: new TextStyle(fontSize: 13.0),
                  ),
                  new Radio(
                    value: "despues",
                    groupValue: _radioValue1,
                    onChanged: _handleRadioValueChange1,
                  ),
                  new Text(
                    'Despues',
                    style: new TextStyle(
                      fontSize: 13.0,
                    ),
                  ),
                  new Radio(
                    value: "ultimo",
                    groupValue: _radioValue1,
                    onChanged: _handleRadioValueChange1,
                  ),
                  new Text(
                    'Ultimo',
                    style: new TextStyle(fontSize: 13.0),
                  ),
                ],
              ),
            ),
            //  new Divider(height: 1.0, color: Colors.grey),
          ],
        ),
      )),
    );
  }
}
