import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_small_daily_routine/constants/gaps.dart';
import 'package:a_small_daily_routine/constants/sizes.dart';
import 'package:a_small_daily_routine/features/users/view_models/users_view_model.dart';
import 'package:a_small_daily_routine/features/users/views/widgets/avatar.dart';
import 'package:a_small_daily_routine/utils.dart';

class VideoComments extends ConsumerStatefulWidget {
  final String meetingId;

  const VideoComments({
    super.key,
    required this.meetingId,
  });

  @override
  ConsumerState<VideoComments> createState() => _VideoCommentsState();
}

class _VideoCommentsState extends ConsumerState<VideoComments> {
  bool _isWriting = false;
  late String _message;
  final _formKey = GlobalKey<FormState>();

  final ScrollController _scrollController = ScrollController();

  void _onClosePressed() {
    Navigator.of(context).pop();
  }

  void _stopWriting(String uid, String creator) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      // Send the message to Firebase
      FirebaseFirestore.instance.collection("comments").add({
        'text': _message,
        'timestamp': DateTime.now(),
        'creator': creator,
        'avtar':
            "https://firebasestorage.googleapis.com/v0/b/capstone-bf0b4.appspot.com/o/avatars%2F$uid?alt=media&haha=${DateTime.now().toString()}"
      });
    }
    _formKey.currentState?.reset();

    FocusScope.of(context).unfocus();

    setState(() {
      _isWriting = false;
    });
  }

  void _onStartWriting() {
    setState(() {
      _isWriting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = isDarkMode(context);
    return ref.watch(usersProvider).when(
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          data: (data) => Container(
            height: size.height * 0.75,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.size14),
            ),
            child: Scaffold(
              backgroundColor: isDark ? null : Colors.grey.shade50,
              appBar: AppBar(
                backgroundColor: isDark ? null : Colors.grey.shade50,
                automaticallyImplyLeading: false,
                title: const Text('댓글'),
                actions: [
                  IconButton(
                    onPressed: _onClosePressed,
                    icon: const FaIcon(FontAwesomeIcons.xmark),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  Scrollbar(
                    controller: _scrollController,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('comments')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            itemExtent: Sizes.size56,
                            padding: const EdgeInsets.only(
                              top: Sizes.size10,
                              bottom: Sizes.size96 + Sizes.size20,
                              left: Sizes.size16,
                              right: Sizes.size16,
                            ),
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot document =
                                  snapshot.data!.docs[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        document['avtar'].toString()),
                                  ),
                                  Gaps.h10,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          document['text'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: Sizes.size14,
                                              color: Colors.grey.shade500),
                                        ),
                                        Text(
                                          document['creator'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: Sizes.size14,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Gaps.h10,
                                  Column(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.heart,
                                        size: Sizes.size20,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }),
                  ),
                  Positioned(
                    bottom: 0,
                    width: size.width,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: Sizes.size16,
                          right: Sizes.size16,
                          top: Sizes.size10,
                          bottom: Sizes.size48,
                        ),
                        child: Row(
                          children: [
                            Avatar(
                                uid: data.uid,
                                hasAvatar: data.hasAvatar,
                                name: data.name,
                                avatarSize: 20),
                            Gaps.h10,
                            Expanded(
                              child: SizedBox(
                                height: Sizes.size44,
                                child: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    onSaved: (value) => _message = value!,
                                    onTap: _onStartWriting,
                                    expands: true,
                                    minLines: null,
                                    maxLines: null,
                                    textInputAction: TextInputAction.newline,
                                    cursorColor: Theme.of(context).primaryColor,
                                    decoration: InputDecoration(
                                        hintText: "댓글을 작성해 주세요...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            Sizes.size12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: Sizes.size12,
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              right: Sizes.size14),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.at,
                                                color: isDark
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade900,
                                              ),
                                              Gaps.h14,
                                              FaIcon(
                                                FontAwesomeIcons.gift,
                                                color: isDark
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade900,
                                              ),
                                              Gaps.h14,
                                              FaIcon(
                                                FontAwesomeIcons.faceSmile,
                                                color: isDark
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade900,
                                              ),
                                              Gaps.h14,
                                              if (_isWriting)
                                                GestureDetector(
                                                  onTap: () => _stopWriting(
                                                      data.uid, data.creator),
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .circleArrowUp,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
  }
}
