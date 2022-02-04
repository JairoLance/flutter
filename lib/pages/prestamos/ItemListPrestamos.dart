
import 'package:flutter/material.dart';



class ItemListPrestamos extends StatelessWidget {
  final List list;
  ItemListPrestamos({this.list});

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: list == null ? 0 : list.length,
          itemBuilder: (context , i){
            return new Container();
          }
    );
  }
}
