import 'dart:async';
import 'dart:convert';
import 'package:flutter_app_mensuales/components/Animation/FadeAnimation.dart';
import 'package:flutter_app_mensuales/components/CircleIconButton.dart';
import 'package:flutter_app_mensuales/components/calculator/calculator.dart';
import 'package:flutter_app_mensuales/models/cliente_models.dart';
import 'package:flutter_app_mensuales/models/par_condicion.dart';
import 'package:flutter_app_mensuales/models/path.dart';
import 'package:flutter_app_mensuales/models/prestamos_model.dart';
import 'package:flutter_app_mensuales/pages/abonos_page.dart';
import 'package:flutter_app_mensuales/pages/prestamos_screen.dart';
import 'package:flutter_app_mensuales/pages/terceros/gestion_clientes.dart';
import 'package:flutter_app_mensuales/pages/util/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProgressDialog pr;

class CrearPrestamos extends StatefulWidget {
  CrearPrestamos(this.EstadoAtrasoColor, this._cedula_index,
      this._nombres_index, this._idcompra_index, this._secuencia_index);

  final _cedula_index;
  final _nombres_index;
  final _idcompra_index;
  final _secuencia_index;

  Color EstadoAtrasoColor;

  @override
  CrearPrestamosState createState() {
    return new CrearPrestamosState();
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

class CrearPrestamosState extends State<CrearPrestamos> {
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
  String _radioValue2 = "";
  int correctScore = 0;
  int correctScore2 = 0;

  FocusNode _focusNodeCedula;

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

  void _handleRadioValueChange2(String value) {
    setState(() {
      _radioValue2 = value;
      switch (_radioValue2) {
        case "si":
          Fluttertoast.showToast(
              msg: ' Antes <', toastLength: Toast.LENGTH_SHORT);
          correctScore2++;
          break;
        case "no":
          Fluttertoast.showToast(
              msg: 'Despues >', toastLength: Toast.LENGTH_SHORT);
          break;
      }
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _txt_tiempo = new TextEditingController();
  final TextEditingController _txt_cedula = new TextEditingController();
  final TextEditingController _txt_valor_prestamos =
      new TextEditingController();
  final TextEditingController _txt_fecha_prestamos =
      new TextEditingController();

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

  Map<String, int> map_interes_fijos = {
    'Si': 1,
    'No': 0,
  };
  bool _interes_fijos = false;
  bool _mes_adelantado = true;
  bool _pendiente = false;
  bool _envio_email = false;

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
    print("Focus " + val);
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

  _loadvariable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _session_grupo = (prefs.getString("grupo_id")) ?? "";
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

    print("Esta es la seq "+ this._data.seq);

    if (widget._cedula_index != null) {
      _txt_cedula.text = widget._cedula_index.toString();
    }

    _focusNodeCedula = FocusNode();
    _focusNodeCedula.addListener(() {
      if (_focusNodeCedula.hasFocus) {
        textChanged(_txt_cedula.text.toString());
      }
    });

    this._radioValue1 =
        widget._secuencia_index.toString() == "" ? "ultimo" : "despues";

    this.getDataTiempo();

    super.initState();
  }

  @override
  void dispose() {
    print("cerro");
    super.dispose();
  }

  _GuardarPrestamos() async {
    if (this._formKey.currentState.validate()) {
      // Fluttertoast.showToast(msg: "Tiempo :" + _mySelectionTiempo.toString() , toastLength: Toast.LENGTH_SHORT);

      var body = json.encode({
        "cobro": _session_grupo.toString(),
        "ref_secuencia": _data.seq == "" ? 0 : _data.seq.toString(),
        "sw": this._radioValue1,
        "nit": _txt_cedula.text,
        "fecha": _txt_fecha_prestamos.text,
        "valor": _txt_valor_prestamos.text,
        "tiempo": _mySelectionTiempo.toString(),
        "mes_adelantado": (this._mes_adelantado) ? "0" : "1",
        "interes_fijos": (this._interes_fijos) ? "1" : "0",
        "co_envio_email" : (_envio_email) ? "1" : "0"
      });

      print(body);

      //bool _pendiente = false;

      if (isValidDob(_txt_fecha_prestamos.text)) {
        Fluttertoast.showToast(
            msg: "Fecha invalida",
            backgroundColor: Colors.redAccent,
            toastLength: Toast.LENGTH_SHORT);
      } else if (_txt_valor_prestamos.text == "") {
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
        _ShowDialogProgress();

        final response = await CrearPrestamosModel(body);

        Future.delayed(Duration(seconds: 1)).then((value) {
          pr.hide().whenComplete(() {
            if (response["type"] == 'error') {
              Fluttertoast.showToast(
                  msg: response["content"].toString(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 15.0
              );
            } else {
              Fluttertoast.showToast(
                  msg: response["content"].toString(),
                  backgroundColor: Colors.teal,
                  toastLength: Toast.LENGTH_SHORT);
              Navigator.pop(context, 'refresh_list_prestamos');
            }
          });
        });
      }
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

  Widget BodyWidgetAbonos() {
    return new Container(
        child: new Form(
      key: this._formKey,
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        children: <Widget>[
          new ListTile(
            title: new TextField(
              //  controller: _textController,
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: textChanged,
              focusNode: _focusNodeCedula,
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
                hintText: 'Cedula del cliente',
                helperText: ClientehelperText,
                labelText: 'Nit/Cedula *',
                suffixIcon: _progressBarActive == false
                    ? CircleIconButton(
                        icon: (ex_cliente) ? Icons.edit : Icons.add,
                        onPressed: () {
                          this.setState(() {
                            ClienteModel _cliente_model = new ClienteModel(
                                cedula: "0",
                                nombres: "",
                                telefono: "",
                                direccion: "",
                                movil: "");
                            var miModels;
                            try {
                              miModels = newClienteModel is ClienteModel
                                  ? _cliente_model
                                  : newClienteModel;
                            } on Exception catch (_) {
                              miModels = _cliente_model;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GestionClientes(
                                    miModels, _txt_cedula.text ?? "","Guardar"),
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
                controller: _txt_valor_prestamos,
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
              controller: _txt_fecha_prestamos,
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
/*
            new ListTile(
              contentPadding: new EdgeInsets.only(left: 16, top: 0, bottom: 0),
              title: new Text('Los intereses son fijos :',
                  style: new TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0,
                      color: Colors.teal)),
              subtitle: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[

                  new Row(children: <Widget>[
                    new Text(
                      'Si',
                      style: new TextStyle(fontSize: 13.0),
                    ),
                    new Radio(
                      value: "si",
                      groupValue: _radioValue2,
                      onChanged: _handleRadioValueChange2,
                    ),
                    new Text(
                      'No',
                      style: new TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    new Radio(
                      value: "no",
                      groupValue: _radioValue2,
                      onChanged: _handleRadioValueChange2,
                    ),
                  ]),
                  SizedBox(height: 12,),
                  new Row(
                    children: <Widget>[
                      new Text('Posicion del prestamo:',
                          style: new TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                              color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),*/
          new Padding(
            padding: new EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Card(
                  elevation: 0,
                  color: Colors.white30,
                  child: new Container(
                    child: CheckboxListTile(
                      title: Text(
                        "Los intereses son fijos ",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.teal),
                      ),
                      subtitle: Text(
                        "El pago de los intereses dependera del saldo del capital .",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                      value: _interes_fijos,
                      onChanged: (bool val) {
                        setState(() {
                          _interes_fijos = val;
                        });
                      },
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                )
              ],
            ),
          ),
          new Padding(
            padding: new EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Card(
                  elevation: 0,
                  color: Colors.white30,
                  child: new Container(
                    child: CheckboxListTile(
                      title: Text(
                        "Mes adelantado",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.teal),
                      ),
                      subtitle: Text(
                        "El cliente comenzara a realizar sus abonos el mes siguiente.",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                      value: _mes_adelantado,
                      onChanged: (bool val) {
                        setState(() {
                          _mes_adelantado = val;
                        });
                      },
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                )
              ],
            ),
          ),

          new Padding(
            padding: new EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Card(
                  elevation: 0,
                  color: Colors.white30,
                  child: new Container(
                    child: CheckboxListTile(
                      title: Text(
                        "Pendiente",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.teal),
                      ),
                      subtitle: Text(
                        "El prestamo dependera de la autorizacion del administrador o secretaria.",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                      value: _pendiente,
                      onChanged: (bool val) {
                        setState(() {
                          _pendiente = val;
                        });
                      },
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                )
              ],
            ),
          ),
          new Padding(
            padding: new EdgeInsets.all(3.5),
            child: new ListTile(
              contentPadding: new EdgeInsets.only(left: 16, top: 0, bottom: 0),
              title: new Text('Posicion del prestamo:',
                  style: new TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0,
                      color: Colors.teal)),
              subtitle: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    'Antes',
                    style: new TextStyle(fontSize: 13.0),
                  ),
                  new Radio(
                    value: "antes",
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
                    value: "despues",
                    groupValue: _radioValue1,
                    onChanged: _handleRadioValueChange1,
                  ),
                  new Text(
                    'Ultimo',
                    style: new TextStyle(fontSize: 13.0),
                  ),
                  new Radio(
                    value: "ultimo",
                    groupValue: _radioValue1,
                    onChanged: _handleRadioValueChange1,
                  ),
                ],
              ),
            ),
          ),

          new Padding(
            padding: new EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Card(
                  elevation: 0,
                  color: Colors.white30,
                  child: new Container(
                    child: CheckboxListTile(
                      title: Text(
                        "Avisos",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.teal),
                      ),
                      subtitle: Text(
                        "El cliente autoriza para este prestamo , el envio de mensajes de alerta del estado de su cuenta y su proxima fecha de sus abonos.",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey),
                      ),
                      value: _envio_email,
                      onChanged: (bool val) {
                        setState(() {
                          _envio_email = val;
                        });
                      },
                    ),
                    padding: EdgeInsets.all(0),
                  ),
                )
              ],
            ),
          ),
          //  new Divider(height: 1.0, color: Colors.grey),
        ],
      ),
    ));
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
                'PRESTAMOS ',
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
              icon: new Icon(Icons.save),
              onPressed: () {
                _GuardarPrestamos();
              },
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
/*
      floatingActionButton: new FloatingActionButton(
        onPressed: () async {},
        tooltip: 'Guardar prestamo',
        backgroundColor: Colors.teal,
        elevation: 10.0,
        child: new Icon(Icons.save, color: Colors.white),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
        resizeToAvoidBottomInset: false,
        body: FadeAnimation(1.6, BodyWidgetAbonos()));
  }
}
