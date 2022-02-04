import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormCard extends StatelessWidget {


  final TextEditingController emailController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      height: ScreenUtil.getInstance().setHeight(500),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Entrada v.1",
                style: TextStyle(
                    color:Colors.teal,
                    fontSize: ScreenUtil.getInstance().setSp(45),
                    fontFamily: "Poppins-Bold",
                    letterSpacing: .6)),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(30),
            ),
            Text("Tu usuario",
                style: TextStyle(
                    fontFamily: "Poppins-Medium",
                    fontSize: ScreenUtil.getInstance().setSp(26))),
            TextFormField(
              controller: emailController,
              validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
             // onSaved: (value) => _email = value.trim(),
              decoration: InputDecoration(
                  hintText: "Nombre de usuario",
                  icon: new Icon(
                    Icons.account_circle,
                    color: Colors.teal,
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(30),
            ),
            Text("Tu contraseña",

                style: TextStyle(

                    fontFamily: "Poppins-Medium",
                    fontSize: ScreenUtil.getInstance().setSp(26))),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                  hintText: "Contraseña",
                  icon: new Icon(
                    Icons.lock,
                    color: Colors.teal,
                  ),
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.0)),
            ),
            SizedBox(
              height: ScreenUtil.getInstance().setHeight(35),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  "Olvido su contraseña?",
                  style: TextStyle(
                      color:Colors.teal,
                      fontFamily: "Poppins-Medium",
                      fontSize: ScreenUtil.getInstance().setSp(22)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
