import 'package:flutter/material.dart';

class ChatMassage extends StatelessWidget {
  const ChatMassage({Key? key, required this.data, required this.mine})
      : super(key: key);

  final data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !mine
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://bluesundobrasil.com.br/teste/public/avatar/3.jpg",
                    ),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                data['imgUrl'] != null
                    ? Image.network(data['imgUrl'], width: 250)
                    : Text(
                        data['text'],
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: const TextStyle(fontSize: 16),
                      ),
                Text(
                  data['senderName'],
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          mine
              ? const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://bluesundobrasil.com.br/teste/public/avatar/3.jpg",
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
