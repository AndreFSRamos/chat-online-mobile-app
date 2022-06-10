import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({Key? key, required this.sendMassager}) : super(key: key);

  //Função enviada pela classe Chat, que recebe por parametro outra função anonima
  //que tem como parametro uma Strig(Texto enviado do usuario) e uma File(Imagem
  // enviado pelo usuario), ambas podem ser nulas.
  final Function({String? text, File? imgFile}) sendMassager;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

//variavel _isComposing, auxiia no controle de habilitar e desabilitar o botão
// de enviar menssagem.
bool _isComposing = false;

//Controller do campo de texto.
final TextEditingController controller = TextEditingController();

//Essa classe se trata ta barra de menssagem, que é formado por um container,
//que possui uma linha, e dentro da linha há um iconButton(Camera), TextFiel(campo de texto)
//é o botão de enviar menssagem.
class _TextComposerState extends State<TextComposer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepPurple,
      //margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            //Função do iconButtom (Camera), ao clicar é aberta a camera do celular
            //onde pode se tirar a foto ou não. Caso sim pe armazenada a foto e
            //chamada a função senMassger para retornar a imagem. Caso contrario
            //cai do IF que valida se a variavel e igual a nula e retorna nada.
            onPressed: () async {
              ImagePicker imagePicker = ImagePicker();
              XFile? imgXFile =
                  await imagePicker.pickImage(source: ImageSource.camera);
              File imgFile = File(imgXFile!.path);
              if (imgFile == null) return;
              widget.sendMassager(imgFile: imgFile);
            },
            icon: const Icon(Icons.photo_camera),
          ),
          Expanded(
            child: TextField(
              controller: controller,

              decoration: const InputDecoration.collapsed(
                  hintText: "Enviar uma messagem"),
              //função onChange do texxField, troca a varial _isComposing
              // para nulo, para apagar a messagem enviada pelo usuario do campo
              //necessario o setStat para atualizar a tela em tempo real.
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              //função onSubmitted do texxField, chama a função sendMassager e
              //passa por parametro o text digitado pelo usuario, em seguida
              // chama a funação _reset para trocar  a varial _isComposing para
              //vazio, para desabilitar o botaõ assim que envia a messagem.
              //nessario o setStat para atualizar a tela em tempo real.
              onSubmitted: (text) {
                widget.sendMassager(text: text);
                _reset();
              },
              cursorColor: Colors.white,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
              onPressed: _isComposing
                  ? () {
                      widget.sendMassager(text: controller.text);
                      _reset();
                    }
                  : null,
              icon: const Icon(Icons.send)),
        ],
      ),
    );
  }

  //função pra auxilar do estado do botão de eviar messagem.
  void _reset() {
    controller.clear();
    setState(() {
      _isComposing = false;
    });
  }
}
