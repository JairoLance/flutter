import 'dart:convert';

import 'package:flutter_app_mensuales/models/path.dart';
import 'package:http/http.dart' as http;

Future<dynamic> GuardarProfile(var body) async {

  //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  var uri = Global().getAccountUrl("App/GuardarProfile");
  return await http.post(Uri.encodeFull(uri),
      body: body,
      headers: {"Accept": "application/json"}).then((http.Response response) {
    final int statusCode = response.statusCode;
    print(response);
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }

    return json.decode(response.body);
  });
}