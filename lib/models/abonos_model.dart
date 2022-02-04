import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app_mensuales/models/path.dart';

class AbonosModel {
  final String id;
  final String compra;
  final String fecha;
  final String valor;
  final String descuento;
  final String liquidacion;
  final String nombres;
  final String obligacion;
  final String obligacion_mensual;
  final String valor_prestamo_anterior;
  final String valor_prestamo_actual;

  AbonosModel(this.id, this.compra, this.fecha,this.valor, this.descuento,
      this.liquidacion, this.nombres, this.obligacion , this.obligacion_mensual,
      this.valor_prestamo_anterior , this.valor_prestamo_actual
      );
}

Future<dynamic> CrearAbonosModel(var body) async {
  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Abonos/Guardar");
  return await http.post(Uri.encodeFull(uri),
      body: body,
      headers: {"Accept": "application/json"}).then((http.Response response) {
    //      print(response.body);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    print(response.body);
    return json.decode(response.body);
  });
}

Future<dynamic> EliminarAbonosModel(var body) async {
  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Abonos/EliminarAbonos");
  return await http.post(Uri.encodeFull(uri),
      body: body,
      headers: {"Accept": "application/json"}).then((http.Response response) {
    //      print(response.body);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    print(response.body);
    return json.decode(response.body);
  });
}

Future<dynamic> HistorialAbonos(var body) async {
  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Abonos/HistorialAbonosByCompra");
  return await http.post(Uri.encodeFull(uri),
      body: body,
      headers: {"Accept": "application/json"}).then((http.Response response) {

    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error recibiendo datos.");
    }
    return json.decode(response.body);
  });
}
