
class Global {
  //One instance, needs factory
  static Global _instance;
  factory Global() => _instance ??= new Global._();
  Global._();
  //

  String route ='';
 //var url = "http://31.220.62.119/compras/servicios/public/index.php/Terceros/"+group;
  String getServerUrl(){
    return 'http://31.220.62.119';
  }

  String getAccountUrl(String router){
    return getServerUrl()+'/compras/servicios/public/index.php/'+router;
  }
}