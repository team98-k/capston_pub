import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:a_small_daily_routine/features/users/view_models/users_view_model.dart';

class ChatPage extends ConsumerStatefulWidget {
  static const String routeName = "chats";
  static const String routeUrl = "/chats";

  final String meetingId;
  const ChatPage({
    super.key,
    required this.meetingId,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends ConsumerState<ChatPage> {
  final _formKey = GlobalKey<FormState>();
  late String _message;
  int participantCount = 0;

  CollectionReference<Map<String, dynamic>> store =
      FirebaseFirestore.instance.collection('meetings');

  void _chatSend(String uid, String creator) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      // Send the message to Firebase
      FirebaseFirestore.instance
          .collection('meetings')
          .doc(widget.meetingId)
          .collection('messages')
          .add({
        'text': _message,
        'timestamp': DateTime.now(),
        'creator': creator,
        'avtar':
            "https://firebasestorage.googleapis.com/v0/b/capstone-bf0b4.appspot.com/o/avatars%2F$uid?alt=media&haha=${DateTime.now().toString()}",
      });
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(usersProvider).when(
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          data: (data) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('모임 채팅'),
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('meetings')
                    .doc(widget.meetingId)
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text(document['text']),
                        subtitle: Text(document['creator'].toString()),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(document['avtar'].toString()),
                        ),
                      );
                    },
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('메시지 보내기'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('취소'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('보내기'),
                            onPressed: () => _chatSend(data.uid, data.creator),
                          ),
                        ],
                        content: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                decoration:
                                    const InputDecoration(labelText: '메시지'),
                                validator: (value) =>
                                    value!.isEmpty ? '메시지를 작성해 주세요.' : null,
                                onSaved: (value) => _message = value!,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
  }
}
