import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:a_small_daily_routine/common/mode_config/mode_config.dart';
import 'package:a_small_daily_routine/constants/breakpoints.dart';
import 'package:a_small_daily_routine/constants/gaps.dart';
import 'package:a_small_daily_routine/constants/sizes.dart';
import 'package:a_small_daily_routine/utils.dart';

class NewDiscoverScreen extends StatefulWidget {
  const NewDiscoverScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NewDiscoverScreenState createState() => _NewDiscoverScreenState();
}

class _NewDiscoverScreenState extends State<NewDiscoverScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _imagesStream;

  final TextEditingController _textEditingController =
      TextEditingController(text: "Initial Text");

  void _onSearchChanged(String value) {
    print("Searching form $value");
  }

  void _onSearchSubmitted(String value) {
    print("Submitted $value");
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _imagesStream = FirebaseFirestore.instance.collection('images').snapshots();
  }

  Future<void> _toggleLike(
      DocumentSnapshot<Map<String, dynamic>> imageDoc) async {
    final bool isLiked = imageDoc['isLiked'] ?? false;
    final int currentLikes = imageDoc['likes'] ?? 0;

    await imageDoc.reference.update({
      'isLiked': !isLiked,
      'likes': isLiked ? currentLikes - 1 : currentLikes + 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.sm,
          ),
          child: CupertinoSearchTextField(
            controller: _textEditingController,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            style: TextStyle(
                color: isDarkMode(context) || modeConfig.autoMode
                    ? Colors.white
                    : Colors.black),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _imagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final images = snapshot.data?.docs;

          return GridView.builder(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: images?.length ?? 0,
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.of(context).size.width > Breakpoints.lg ? 5 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 9 / 16,
            ),
            itemBuilder: (context, index) {
              final imageDoc = images![index];
              final bool isLiked = imageDoc['isLiked'] ?? false;
              final int likes = imageDoc['likes'] ?? 0;

              return GestureDetector(
                onTap: () => _toggleLike(imageDoc),
                child: Stack(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Sizes.size4),
                      ),
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: Image.network(
                          imageDoc['fileUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Gaps.v10,
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          Gaps.v8,
                          Text(
                            likes.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
