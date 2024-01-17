import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../screens/Signup/components/or_divider.dart';
import '../../../screens/Signup/components/social_icon.dart';

class SocalSignUp extends StatefulWidget {
  const SocalSignUp({
    super.key,
  });

  @override
  State<SocalSignUp> createState() => _SocalSignUpState();
}

class _SocalSignUpState extends State<SocalSignUp> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OrDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SocalIcon(
              iconSrc: "assets/icons/facebook.svg",
              press: () {},
            ),
            SocalIcon(
              iconSrc: "assets/icons/twitter.svg",
              press: () {},
            ),
            SocalIcon(
              iconSrc: "assets/icons/google-plus.svg",
              press: () {
                _signInWithGoogle();
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      print('Google 로그인 시도');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print('Google 로그인 시도2');
      if (googleUser == null) {
        print('Google 로그인 취소');
        await _showCuteAlertDialog('로그인이 취소되었습니다.');
        return;
      }
      print('Google 로그인 시도3');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Google 로그인 시도4');
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Google 로그인 시도5');

      // Firebase에 사용자 인증
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('Google 로그인 성공: ${userCredential.user?.uid}');

      // 성공적인 로그인 처리
      await _showCuteAlertDialog('성공적으로 로그인 되었습니다.');
      context.push('/chat');
      print('Google 로그인 시도6');
      // 필요한 경우 다른 화면으로 이동
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 관련 에러 처리
      await _showCuteAlertDialog('Firebase 인증 실패: ${e.message}');
    } on PlatformException catch (e) {
      print("Platform Exception: ${e.message}");
    } catch (e) {
      // 그 외 예외 처리
      print("Exception: ${e.toString()}");
      await _showCuteAlertDialog('오류 발생: ${e.toString()}');
    }
  }

  Future<void> _showCuteAlertDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text(
            '알림',
            style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message, style: const TextStyle(color: Colors.deepPurple)),
                // 이미지 추가
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인', style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.lightBlue[50],
        );
      },
    );
  }
}
