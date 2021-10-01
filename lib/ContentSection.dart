import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ContentPage extends StatefulWidget{
  const ContentPage({Key? key}) : super(key: key);
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> 
{
final List<String> entries = <String>['A', 'B', 'C'];
final List<int> colorCodes = <int>[600, 500, 100];
Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    /*ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: entries.length,
                    itemBuilder: (BuildContext context, int index) {
                        return Container(
                            height: 50,
                            color: Colors.amber[colorCodes[index]],
                            child: Center(child: Text('Entry ${entries[index]}')),
                        );
                    }
                    ),*/
                    Text(
                        'Hello, you made it!',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ]
                )
            )
        )
        );
}
}