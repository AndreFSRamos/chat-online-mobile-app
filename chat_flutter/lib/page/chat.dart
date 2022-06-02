import 'dart:io';
import 'package:chat_flutter/page/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // ignore: prefer_typing_uninitialized_variables
  var _currentuser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentuser = user;
    });
  }

  Future _getUser() async {
    if (_currentuser != null) return _currentuser;
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = authResult.user;
      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMassage({String? text, File? imgFile}) async {
    var user = await _getUser();
    if (user == null) {
      _scaffoldKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text('Não foi possivel fazer o login'),
          backgroundColor: Colors.red,
        ),
      );
      print("erro ao logar ");
    }
    Map<String, dynamic> data = {
      "uid": user.uid,
      //"text": user.text,
      //"imgUrl": user.imgUrl,
    };

    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(Duration.microsecondsPerMillisecond.toString())
          .putFile(imgFile);

      TaskSnapshot taskSnapshot = await task.whenComplete(() => null);
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }
    print("$text antes de mandar para o banco");
    if (text != null) data['text'] = text;

    FirebaseFirestore.instance.collection('messagers').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Olá"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messagers')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(documents[index]['text'].toString()));
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(sendMassager: _sendMassage),
        ],
      ),
    );
  }
}
