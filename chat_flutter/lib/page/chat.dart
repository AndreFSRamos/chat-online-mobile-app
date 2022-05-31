import 'dart:io';
import 'package:chat_flutter/page/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

void sendMassage({String? text, File? imgFile}) async {
  Map<String, dynamic> data = {};

  if (imgFile != null) {
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child(TimeOfDay.now().minute.toString())
        .putFile(imgFile);

    TaskSnapshot taskSnapshot = await task.whenComplete(() => null);
    String url = await taskSnapshot.ref.getDownloadURL();
    data['imgUrl'] = url;
  }

  if (text != null) data['text'] = text;

  FirebaseFirestore.instance.collection("messagers").add(data);
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Olá"),
        elevation: 0,
      ),
      body: const TextComposer(sendMassager: sendMassage),
    );
  }
}
