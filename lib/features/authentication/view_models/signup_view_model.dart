import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:a_small_daily_routine/features/authentication/repos/authentication_repo.dart';
import 'package:a_small_daily_routine/features/onboarding/interests_screen.dart';
import 'package:a_small_daily_routine/features/users/view_models/users_view_model.dart';
import 'package:a_small_daily_routine/utils.dart';

class SignUpViewModel extends AsyncNotifier<void> {
  late final AuthenticationRepository _authRepo;

  @override
  FutureOr<void> build() {
    _authRepo = ref.read(authRepo);
  }

  Future<void> signUp(BuildContext context) async {
    state = const AsyncValue.loading();
    final form = ref.read(signUpForm);
    final users = ref.read(usersProvider.notifier);
    state = await AsyncValue.guard(() async {
      final userCredential = await _authRepo.emailSignUp(
        form["email"],
        form["password"],
      );
      await users.createProfile(
        credential: userCredential,
        email: form['email'],
        name: form['name'],
        birthday: form['birthday'],
      );
    });
    if (state.hasError) {
      // ignore: use_build_context_synchronously
      showFirebaseErrorSnack(context, state.error);
    } else {
      // ignore: use_build_context_synchronously
      context.goNamed(InterestsScreen.routeName);
    }
  }
}

final signUpForm = StateProvider((ref) => {});

final signUpProvider = AsyncNotifierProvider<SignUpViewModel, void>(
  () => SignUpViewModel(),
);
