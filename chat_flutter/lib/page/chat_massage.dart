// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';

class ChatMassage extends StatelessWidget {
  const ChatMassage({Key? key, required this.data, required this.mine})
      : super(key: key);

  final data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    TimeOfDay hour = TimeOfDay.now();
    return Card(
      elevation: 20,
      color: Colors.deepPurple[600],
      margin: !mine
          ? const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 70)
          : const EdgeInsets.only(top: 10, bottom: 10, left: 70, right: 10),
      child: Row(
        children: [
          !mine
              ? Padding(
                  padding: mine
                      ? const EdgeInsets.only(right: 10)
                      : const EdgeInsets.only(left: 10),
                  child: const CircleAvatar(
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
                !mine
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: mine
                                  ? const EdgeInsets.only(right: 10)
                                  : const EdgeInsets.only(left: 10),
                              child: Text(
                                data['senderName'],
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: !mine
                                  ? const EdgeInsets.only(right: 10)
                                  : const EdgeInsets.only(left: 10),
                              child: Text(
                                "$hour",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: !mine
                                  ? const EdgeInsets.only(right: 10)
                                  : const EdgeInsets.only(left: 10),
                              child: Text(
                                "$hour",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: mine
                                  ? const EdgeInsets.only(right: 10)
                                  : const EdgeInsets.only(left: 10),
                              child: Text(
                                data['senderName'],
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                data['imgUrl'] != null
                    ? Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.network(
                          data['imgUrl'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : Padding(
                        padding: mine
                            ? const EdgeInsets.only(
                                left: 10, bottom: 10, right: 10)
                            : const EdgeInsets.only(
                                right: 10, bottom: 10, left: 10),
                        child: Text(
                          data['text'],
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: mine
                      ? const EdgeInsets.only(right: 10)
                      : const EdgeInsets.only(left: 10),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      data['senderPhotoUrl'],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
