import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // 사용자가 로그인을 취소한 경우
      if (googleUser == null) {
        await _showCuteAlertDialog('로그인이 취소되었습니다.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 새 사용자 계정 생성
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: googleUser.email,
        password: '여기에_사용할_비밀번호_입력',
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // 성공적인 로그인 처리
      await _showCuteAlertDialog('성공적으로 회원가입 되었습니다.');
      // 필요한 경우 다른 화면으로 이동
    } on FirebaseAuthException catch (e) {
      // 로그인 실패 처리
      await _showCuteAlertDialog('로그인에 실패했습니다: ${e.message}');
    } catch (e) {
      // 기타 오류 처리
      await _showCuteAlertDialog('오류가 발생했습니다: ${e.toString()}');
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
