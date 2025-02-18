import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:a_small_daily_routine/constants/sizes.dart';

import '../../../../constants/gaps.dart';

class EventButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const EventButton({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('videos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Builder(builder: (context) {
            return Column(
              children: [
                FaIcon(
                  icon,
                  color: Colors.white,
                  size: Sizes.size40,
                ),
                Gaps.v5,
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          });
        });
  }
}
