import 'dart:convert';

import 'package:flutter_app_mensuales/models/path.dart';
import 'package:http/http.dart' as http;

class ClienteModel {
 // final String id;
  final String nombres;
  final String cedula;
  final String direccion;
  final String telefono;
  final String movil;
  final String email;

  ClienteModel({this.cedula,this.nombres, this.direccion,this.telefono,this.movil,this.email});



  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    ClienteModel newClientes = ClienteModel(
        cedula    : json['te_cedula'],
        nombres   : json['te_nombres'],
        direccion : json['te_direccion'],
        telefono  : json['te_telefono'],
        movil     : json['te_movil'],
        email     : json['te_email']
    );
    return newClientes;
  }

  factory ClienteModel.fromTask(ClienteModel anotherCliente) {
    return ClienteModel(
        cedula    : anotherCliente.cedula,
        nombres   : anotherCliente.nombres,
        direccion : anotherCliente.direccion,
        telefono  : anotherCliente.telefono,
        movil     : anotherCliente.movil
    );
  }
}


//Controllers = "functions relating to Task"
Future<List<ClienteModel>> fetchTasks(http.Client client, String cedula) async {
  var uri = "http://192.168.179.2/vue-globalnet/servicios/public/Terceros/ListClientes";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    Map<String, dynamic> mapResponse = json.decode(response.body);
    if (mapResponse["result"] == "ok") {
      final listas = mapResponse["data"].cast<Map<String, dynamic>>();
      return listas.map<ClienteModel>((json){
        return ClienteModel.fromJson(json);
      }).toList();
    } else {
      return [];
    }
  } else {
    throw Exception('Failed to load Task');
  }
}


Future<dynamic> postClienteModel(String group,var body)async {

  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Terceros/"+group);
  return await http
      .post(Uri.encodeFull(uri), body: body, headers: {"Accept":"application/json"})
      .then((http.Response response) {
    //      print(response.body);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    print(response.body);
    return json.decode(response.body);
  });
}


Future<dynamic> GetClienteByLike(var body) async {
  var res = await http
      .post(Uri.encodeFull(Global().getAccountUrl("Terceros/GetByLike")), body: body, headers: {"Accept": "application/json"});
  var resBody = json.decode(res.body);
  return resBody;
}


Future<ClienteModel> updateClienteModel(http.Client client,  Map<String, dynamic> params) async {
  //Guardar
  //var uri = "http://192.168.179.2/vue-globalnet/servicios/public/Terceros/Guardar";
  //var uri = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/Guardar";
  var uri = Global().getAccountUrl("Terceros/Guardar");
  final response = await http.post(uri, body: params);

  if (response.statusCode == 200) {
    final responseBody = await json.decode(response.body);
    return ClienteModel.fromJson(responseBody);
  } else {
    throw Exception('Failed to update a Task. Error: ${response.toString()}');
  }
}






