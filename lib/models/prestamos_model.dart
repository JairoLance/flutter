import 'dart:convert';

import 'package:flutter_app_mensuales/models/path.dart';
import 'package:http/http.dart' as http;

class PrestamosModel {
  final String id;
  final String seq;
  final String fecha;
  final String cobro;
  final String cliente;
  final String fiador;
  final String valor;
  final String saldo;
  final String tiempo;
  final String estado;
  final String nombres;
  final String direccion;
  final String telefono;
  final String movil;
  final String atrasos;
  final String fecha_mes_pago;
  final String mes_pago;
  final String obligacion;
  final String obligacion_mensual;
  final String acu_abono_interes;
  final String porcentaje;
  final String dias_abonos;
  final String mes_abonos;
  final String total_saldo;
  final String meses_obligacion;
  final String email;
  final String mes_adelantado;
  final String interes_fijo;
  final String acu_abono_capital;
  final String atraso_total_hoy;

  PrestamosModel(
      this.id,
      this.seq,
      this.fecha,
      this.cobro,
      this.cliente,
      this.fiador,
      this.valor,
      this.saldo,
      this.tiempo,
      this.estado,
      this.nombres,
      this.direccion,
      this.telefono,
      this.movil,
      this.atrasos,
      this.fecha_mes_pago,
      this.mes_pago,
      this.obligacion,
      this.obligacion_mensual,
      this.acu_abono_interes,
      this.porcentaje,
      this.dias_abonos,
      this.mes_abonos,
      this.meses_obligacion,
      this.total_saldo,
      this.email,
      this.mes_adelantado,
      this.interes_fijo,
      this.acu_abono_capital,
      this.atraso_total_hoy);

  //Do the same as Todo
  /* factory PrestamosModel.fromJson(Map<String, dynamic> json) {
    PrestamosModel newPrestamosModel = PrestamosModel(
        id: json['co_idcompras'],
        seq: json['co_secuencia'],
        fecha: json['co_fecha'],
        cobro: json['co_cobro'],
        cliente :json["co_cliente"],
        fiador :json["co_fiador"],
        valor : json["co_valor"],
        saldo : json["co_saldo"],
        tiempo : json["co_tiempo"],
        estado  : json["co_estado"],
        nombres  : json["te_nombres"],
        direccion  : json["te_direccion_domicilio"],
        telefono  : json["te_telefono"],
        movil   : json["te_movil"],
        atrasos  : json["atraso"],
        fecha_mes_pago  : json["fecha_mes_pago"],
        mes_pago  : json["mes_pago"],
        obligacion  : json["obligacion"],
        acu_abono_interes  : json["acu_abono_interes"]
    );
    return newPrestamosModel;
  }*/

  //clone a Task, or "copy constructor"
  /* factory PrestamosModel.fromTask(PrestamosModel anotherPrestamosModel) {
    return PrestamosModel(
          id :row["co_idcompras"],
          seq
          fecha
          cobro
          cliente
          fiador
          valor
          saldo
          tiempo
          estado
          nombres
          direccion
          telefono
          movil
          atrasos
          fecha_mes_pago
          mes_pago
          obligacion
          acu_abono_interes

    );
  }*/

}

Future<dynamic> GuardarAbonos(var body) async {
  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Abonos/Guardar");
  return await http.post(Uri.encodeFull(uri),
      body: body,
      headers: {"Accept": "application/json"}).then((http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }

    return json.decode(response.body);
  });
}

Future<dynamic> AbonarCapital(var body) async {
  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Abonos/AbonarCapital");
  return await http.post(Uri.encodeFull(uri),
      body: body,
      headers: {"Accept": "application/json"}).then((http.Response response) {
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }

    return json.decode(response.body);
  });
}

Future<dynamic> CrearPrestamosModel(var body) async {

  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Compras/GuardarPrestamos");
  return await http.post(Uri.encodeFull(uri),
      body: body,
      headers: {"Accept": "application/json"}).then((http.Response response) {
    final int statusCode = response.statusCode;
    print(statusCode);
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }

    return json.decode(response.body);
  });
}

Future<dynamic> EliminarPrestamosModel(var body) async {
  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("Compras/EliminarPrestamos");
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

/*
Future<List<PrestamosModel>> fetchPrestamosModel(http.Client client, int cobro) async {
  var uri = "http://192.168.179.2/vue-globalnet/servicios/public/Compras/listComprasActivas";
  final response = await client.get(uri);
  if (response.statusCode == 200) {
    Map<String, dynamic> mapResponse = json.decode(response.body);
    if (mapResponse["result"] == "ok") {
      final listas = mapResponse["data"].cast<Map<String, dynamic>>();
      return listas.map<PrestamosModel>((json){
        return PrestamosModel.fromJson(json);
      }).toList();
    } else {
      return [];
    }
  } else {
    throw Exception('Failed to load Task');
  }
}
*/
