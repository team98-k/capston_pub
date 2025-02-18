import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateMeetingPage extends ConsumerStatefulWidget {
  const CreateMeetingPage({Key? key}) : super(key: key);

  @override
  CreateMeetingPageState createState() => CreateMeetingPageState();
}

class CreateMeetingPageState extends ConsumerState<CreateMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  late String _meetingTitle;
  late String _meetingDescription;
  int? _meetPeople;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임 생성'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: '모임 이름'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이름을 작성해 주세요.';
                  }
                  return null;
                },
                onSaved: (value) => _meetingTitle = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '모임 소개'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '어떤 모임인지 소개해 주세요..';
                  }
                  return null;
                },
                onSaved: (value) => _meetingDescription = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '인원제한'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '모임의 인원을 알려주세요.';
                  }
                  if (int.tryParse(value) == null) {
                    return '올바른 숫자를 입력하십시오.';
                  }
                  final int limit = int.parse(value);
                  if (limit < 1 || limit > 30) {
                    return '인원은 1에서 30 사이여야 합니다.';
                  }
                  return null;
                },
                onChanged: (value) {
                  _meetPeople = int.tryParse(value);
                },
                keyboardType: TextInputType.number,
              ),
              TextButton(
                child: const Text('모임 생성'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Create the meeting in Firebase
                    FirebaseFirestore.instance.collection('meetings').add({
                      'title': _meetingTitle,
                      'description': _meetingDescription,
                      'people': _meetPeople,
                      'init_p': 1,
                    });
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
