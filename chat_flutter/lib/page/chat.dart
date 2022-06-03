import 'dart:io';
import 'package:chat_flutter/page/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'chat_massage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // ignore: prefer_typing_uninitialized_variables

  // ignore: prefer_typing_uninitialized_variables
  var _currentuser; // Variavel privada para armezanar o usuario logado.
  bool _isLoading = false; // contrla o efeito de carregamento de imagem.

  //Função Init e executada uma unica vez ao inicar a aplicação, ela recupera a
  //instancia do usuário, para determinar se esta logado ou não.
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentuser = user;
      });
    });
  }

  //Função para logar um usuario com a conta google.
  Future _getUser() async {
    //verifica se já tem uma instancia de usuaro, caso sim, apenas retorna o usuario já logado.
    if (_currentuser != null) return _currentuser;
    try {
      //chama o login do google.
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      //faz a autenticação do usuario google.
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      //recuperar os token de ID e acesso.
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
      //recebe um usuario autenticado firebase.
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      // aemazena o usuario autenticado fire base.
      final user = authResult.user;
      //retorna o usuário.
      return user;
    } catch (error) {
      return null;
    }
  }

  // função para enviar as messagem do usuário par ao banco de dados.
  // Recebe uma função anonima como parametrô, que recebe como parametró
  // ou o Texto imformado na messagem ou a imagem do usário.
  void _sendMassage({String? text, File? imgFile}) async {
    //Recupera a instancia do usuário, caso esteja logando.
    var user = await _getUser();

    //Retorna um erro para o usuário caso não consiga efetuar o login, retorna
    //no formata de snack bar.
    if (user == null) {
      // ignore: deprecated_member_use
      _scaffoldKey.currentState!.showSnackBar(
        const SnackBar(
          content: Text('Não foi possivel fazer o login'),
          backgroundColor: Colors.red,
        ),
      );
    }

    //Armazendo as informações do usuario logado, (Id, Nome e hora do envio).
    //OBS: HORA NO ENVIO SERVE PARA ORDENAR A LISTA DE MENSSAGEM.
    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "time": Timestamp.now(),
      //"senderPhotoUrl": user.photoUrl,
    };

    //Verifica se o usuário enviou uma imagem, caso sim, envia para o banco.
    //(Storage). Caso não seja uma imagem ira cair na verificação se o usuário
    // enviou um texto.
    if (imgFile != null) {
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + Duration.microsecondsPerMillisecond.toString())
          .putFile(imgFile);

      //Funação setStat para para exibir uma barra de carregamento, caso o usuario
      // envie uma imagem.
      setState(() {
        _isLoading = true;
      });

      //Recupera a URL da imagem que foi eviada para o Storage.
      TaskSnapshot taskSnapshot = await task.whenComplete(() => null);
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      //Finaliza a barra de carregamento recebendo (FALSE), quando terminar de
      //enviar a imagem para o banco e recupera a URL.
      setState(() {
        _isLoading = false;
      });
    }

    // Verifica se o usuario enviou um TEXTO.
    if (text != null) data['text'] = text;

    //Enviando o Texto para a coloeção "messagers" no firebase.
    FirebaseFirestore.instance.collection('messagers').add(data);
  }

  //Inicio do layout da aplicação.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //I============ Inicio da AppBar =====================
      appBar: AppBar(
        //Texto da AppBar, se o usuario estiver logado, ira contanenar "Ola, " +
        //o nome do usuario, caso contrario exibirar "Chat App"
        title: Text(_currentuser != null
            ? 'Olá, ${_currentuser.displayName}'
            : 'Chat App'),
        elevation: 0,
        //Action da AppBar, aqui é verificado de o usuario está logado, caso SIM
        //ira exibir o botão de logout. Caso contrario, a actions retorna um
        //container vazio, para não exibir nada.
        //Ao clicar no botão de deslogar, é exibida uma SnackBar informando o
        //usuário.
        actions: [
          _currentuser != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    const SnackBar(
                      content: Text('Usuario Deslogado com Sucesso'),
                      backgroundColor: Colors.red,
                    );
                  },
                  icon: const Icon(Icons.exit_to_app))
              : Container()
        ],
      ),
      //=================== Inicio do Corpo da aplicação ======================
      body: Column(
        children: [
          Expanded(
            //É ultilizado o StreamBuilder para exibir a lista de messages, salvas
            //no banco de dados.
            child: StreamBuilder<QuerySnapshot>(
              //Recuperando a instancia da coleção que será usada, ordenada por
              //pela hora de envio.
              stream: FirebaseFirestore.instance
                  .collection('messagers')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //Case 1 verifica se tem conexão, o Case 2 verifica se está
                  //aguardando uma resposta da conexão, ambas retornando um
                  //widget CircularProgress para inciar a espera para o usuario.
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    //Recuperando informarções da coleção e armazenando um uma List.
                    List<DocumentSnapshot> documents =
                        snapshot.data!.docs.toList();
                    return ListView.builder(
                      itemCount: documents
                          .length, //recebendo o tamanho da lista como count.
                      reverse: // controla se a conversa começa de cima para baixo ou vise versa.
                          true,
                      itemBuilder: (context, index) {
                        //Chamando o widget ChatMassage para cara item da lista,
                        //e passando por parametro as informações do item, e se
                        //é TRUE ou FALSE que o usuario que mandou a messagem é
                        //o mesmo que está logado.
                        return ChatMassage(
                            data: documents[index].data(),
                            mine: documents[index]['uid'] == _currentuser?.uid);
                      },
                    );
                }
              },
            ),
          ),
          //mostra a barra de carregamento do envio da imagem para a variavel
          //_isLoading seja TRUE, caso contrario, retorna um container vazio,
          //para não exibir nada.
          _isLoading ? const LinearProgressIndicator() : Container(),
          TextComposer(sendMassager: _sendMassage),
        ],
      ),
    );
  }
}
