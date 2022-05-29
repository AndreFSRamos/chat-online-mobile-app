import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /*FirebaseFirestore.instance
      .collection("col")
      .doc("doc")
      .set({"texto": "André"});*/

  await FirebaseFirestore.instance
      .collection("col")
      .snapshots()
      .listen((event) {
    event.docs.forEach((element) {
      print(element.data());
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(),
    );
  }
}
