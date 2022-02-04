class LoginUsuariosGrupos {
  String crIdcobro;
  String crNombre;

  LoginUsuariosGrupos({this.crIdcobro, this.crNombre});

  LoginUsuariosGrupos.fromJson(Map<String, dynamic> json) {
    crIdcobro = json['cr_idcobro'];
    crNombre = json['cr_nombre'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cr_idcobro'] = this.crIdcobro;
    data['cr_nombre'] = this.crNombre;
    return data;
  }
}