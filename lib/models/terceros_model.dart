class TercerosModel {
  String teCedula;
  String teNombres;
  String teDireccion;
  String teMovil;
  String teTelefonoFijo;
  String teEmail;

  TercerosModel(
      {this.teCedula,
      this.teNombres,
      this.teDireccion,
      this.teMovil,
      this.teTelefonoFijo,
      this.teEmail});

  TercerosModel.fromJson(Map<String, dynamic> json) {
    teCedula = json['te_cedula'];
    teNombres = json['te_nombres'];
    teDireccion = json['te_direccion'];
    teMovil = json['te_movil'];
    teTelefonoFijo = json['te_telefono_fijo'];
    teEmail = json['te_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['te_cedula'] = this.teCedula;
    data['te_nombres'] = this.teNombres;
    data['te_direccion'] = this.teDireccion;
    data['te_movil'] = this.teMovil;
    data['te_telefono_fijo'] = this.teTelefonoFijo;
    data['te_email'] = this.teEmail;
    return data;
  }
}
