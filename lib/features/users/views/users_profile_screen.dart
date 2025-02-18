import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_small_daily_routine/common/mode_config/mode_config.dart';
import 'package:a_small_daily_routine/constants/breakpoints.dart';
import 'package:a_small_daily_routine/constants/gaps.dart';
import 'package:a_small_daily_routine/constants/sizes.dart';
import 'package:a_small_daily_routine/features/setting/settings_screen.dart';
import 'package:a_small_daily_routine/features/users/view_models/users_view_model.dart';
import 'package:a_small_daily_routine/features/users/views/widgets/avatar.dart';
import 'package:a_small_daily_routine/features/users/views/widgets/update_profile.dart';
import 'package:a_small_daily_routine/utils.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String username;

  const UserProfileScreen({super.key, required this.username});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _imagesStream;

  void _onGearPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _onEditPressed({required String creator, required String link}) =>
      Navigator.of(context).push(
        UpdateProfile.route(
          creator: creator,
          link: link,
        ),
      );

  @override
  void initState() {
    super.initState();
    _imagesStream = FirebaseFirestore.instance.collection('images').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(context);
    return ref.watch(usersProvider).when(
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          data: (data) => Scaffold(
            backgroundColor:
                modeConfig.autoMode || isDark ? Colors.black : Colors.white10,
            body: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      centerTitle: true,
                      title: Text(
                        data.creator,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () => _onEditPressed(
                            creator: data.creator,
                            link: data.link,
                          ),
                          icon: const Icon(
                            Icons.edit_note,
                          ),
                        ),
                        IconButton(
                          onPressed: _onGearPressed,
                          icon: const Icon(
                            Icons.settings,
                          ),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Gaps.v20,
                          Avatar(
                            uid: data.uid,
                            name: data.name,
                            hasAvatar: data.hasAvatar,
                            avatarSize: 50,
                          ),
                          Gaps.v20,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.creator,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.size18,
                                ),
                              ),
                              Gaps.h5,
                              data.hasAvatar
                                  ? FaIcon(
                                      FontAwesomeIcons.solidCircleCheck,
                                      size: Sizes.size16,
                                      color: Colors.blue.shade500,
                                    )
                                  : FaIcon(
                                      FontAwesomeIcons.solidCircleCheck,
                                      size: Sizes.size16,
                                      color: Colors.red.shade500,
                                    ),
                            ],
                          ),
                          Gaps.h4,
                          const FaIcon(
                            FontAwesomeIcons.link,
                            size: Sizes.size12,
                          ),
                          Gaps.h4,
                          Text(
                            data.link,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Gaps.v20,
                        ],
                      ),
                    ),
                  ];
                },
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
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: images?.length ?? 0,
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > Breakpoints.lg
                                ? 5
                                : 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 9 / 16,
                      ),
                      itemBuilder: (context, index) {
                        final imageDoc = images![index];
                        return Stack(
                          children: [
                            Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(Sizes.size4),
                              ),
                              child: AspectRatio(
                                aspectRatio: 9 / 16,
                                child: Image.network(
                                  imageDoc['fileUrl'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
  }
}
