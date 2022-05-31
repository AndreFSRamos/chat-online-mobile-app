import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  const TextComposer({Key? key, required this.sendMassager}) : super(key: key);

  final Function({String? text, File? imgFile}) sendMassager;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

bool _isComposing = false;
final TextEditingController controller = TextEditingController();

class _TextComposerState extends State<TextComposer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
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
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMassager(text: text);
                _reset();
              },
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

  void _reset() {
    controller.clear();
    setState(() {
      _isComposing = false;
    });
  }
}
