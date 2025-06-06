import 'package:flutter/material.dart';

Widget getCustomButton(BuildContext context, String text, String path){
    return ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, path);
            },
            child: Text(text),
          );
}