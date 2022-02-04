import 'package:flutter/material.dart';
import 'package:flutter_app_mensuales/pages/util/style.dart';


class EmptyTablePage extends StatefulWidget {
  EmptyTablePage(this.mensaje);
  final String mensaje;
  @override
  _EmptyTablePageState createState() => _EmptyTablePageState();
}

class _EmptyTablePageState extends State<EmptyTablePage> with SingleTickerProviderStateMixin{
  Animation fadeAnimation;
  AnimationController animationController;

  @override
  void initState(){
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animationController);
    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            body: new Container(
              decoration: new BoxDecoration(color: whiteColor),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          child: FadeTransition(
                              opacity: fadeAnimation,
                              child:
                              Image.asset("assets/images/project_empty.png",height: 200.0,)
                          ),
                        ),
                        SizedBox(height: 30),
                        Text('Sin datos', style: headingGrey1,
                        ),
                        Container(
                          padding: new EdgeInsets.only(left: 60.0, right: 60.0),
                          child: new Text(widget.mensaje.toString(),
                            style: textGrey,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height:30),
                       /* ButtonTheme(
                          minWidth: screenSize.width*0.43,
                          height: 45.0,
                          child: RaisedButton(
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5.0)),
                            elevation: 0.0,
                            color: primaryColor,
                            child: new Text('Use My Location'.toUpperCase(),style: headingWhite,
                            ),
                            onPressed: (){

                            },
                          ),
                        ),
                        SizedBox(height:20),
                        InkWell(
                          onTap: (){

                          },
                          child: Text('Skip for now',style: textGrey,),
                        )*/

                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
