import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:a_small_daily_routine/common/main_navigation/widgets/main_navigation/widgets/nav_tab.dart';
import 'package:a_small_daily_routine/common/main_navigation/widgets/main_navigation/widgets/post_video_button.dart';
import 'package:a_small_daily_routine/common/mode_config/mode_config.dart';
import 'package:a_small_daily_routine/constants/gaps.dart';
import 'package:a_small_daily_routine/constants/sizes.dart';
import 'package:a_small_daily_routine/features/discover/new_discover_screen.dart';
import 'package:a_small_daily_routine/features/inbox/views/inbox_screen.dart';
import 'package:a_small_daily_routine/features/users/views/users_profile_screen.dart';
import 'package:a_small_daily_routine/features/videos/views/video_recording_screen.dart';
import 'package:a_small_daily_routine/features/videos/views/video_timeline_screen.dart';
import 'package:a_small_daily_routine/utils.dart';

class MainNavigationScreen extends StatefulWidget {
  static String routeName = "/mainNavigation";

  final String tab;

  const MainNavigationScreen({
    super.key,
    required this.tab,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final List<String> _tabs = [
    "home",
    "discover",
    "xxxxx",
    "inbox",
    "profile",
  ];

  late int _selectedIndex = _tabs.indexOf(widget.tab);
  void _onTap(int index) {
    context.go("/${_tabs[index]}");
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onPostVideoButtonTap() {
    context.pushNamed(VideoRecordingScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _selectedIndex == 0 || modeConfig.autoMode || isDark
          ? Colors.black
          : Colors.white,
      body: Stack(
        children: [
          Offstage(
            offstage: _selectedIndex != 0,
            child: const VideoTimelineScreen(),
          ),
          Offstage(
            offstage: _selectedIndex != 1,
            child: const NewDiscoverScreen(),
          ),
          Offstage(
            offstage: _selectedIndex != 3,
            child: const InboxScreen(),
          ),
          Offstage(
            offstage: _selectedIndex != 4,
            child: const UserProfileScreen(
              username: 'nara',
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: _selectedIndex == 0 || modeConfig.autoMode || isDark
            ? Colors.grey.shade800
            : Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.bottom + Sizes.size10,
              bottom: MediaQuery.of(context).padding.bottom + Sizes.size10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NavTab(
                text: "홈",
                isSelected: _selectedIndex == 0,
                icon: FontAwesomeIcons.house,
                selectedIcon: FontAwesomeIcons.house,
                onTap: () => _onTap(0),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                text: "일상",
                isSelected: _selectedIndex == 1,
                icon: FontAwesomeIcons.compass,
                selectedIcon: FontAwesomeIcons.solidCompass,
                onTap: () => _onTap(1),
                selectedIndex: _selectedIndex,
              ),
              Gaps.h24,
              GestureDetector(
                onTap: _onPostVideoButtonTap,
                child: PostVideoButton(inverted: _selectedIndex != 0),
              ),
              Gaps.h24,
              NavTab(
                text: "모임",
                isSelected: _selectedIndex == 3,
                icon: FontAwesomeIcons.userGroup,
                selectedIcon: FontAwesomeIcons.userGroup,
                onTap: () => _onTap(3),
                selectedIndex: _selectedIndex,
              ),
              NavTab(
                text: "프로필",
                isSelected: _selectedIndex == 4,
                icon: FontAwesomeIcons.user,
                selectedIcon: FontAwesomeIcons.solidUser,
                onTap: () => _onTap(4),
                selectedIndex: _selectedIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
