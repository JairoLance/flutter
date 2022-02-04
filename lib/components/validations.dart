class Validations {
  String validateName(String value) {
    if (value.isEmpty) return 'Nombre es requerido.';
    final RegExp nameExp = new RegExp(r'^[A-za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Por favor ingrese solo caracteres alfabéticos.';
    return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Ingrese un email valido';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.isEmpty) return 'Por favor elija una contraseña.';
    return null;
  }

  String validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return 'Por favor, introduzca el número de móvil';
    } else if (!regExp.hasMatch(value)) {
      return 'Por favor ingrese un número de móvil válido';
    } else if (value.length != 10){
      return 'El número de móvil debe ser de 10 dígitos.';
    }
    return null;
  }
}
