import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants.dart';
import '../../pages/signup_screen.dart';
import '../already_have_an_account_acheck.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: kPrimaryColor,
              decoration: const InputDecoration(
                hintText: "Your password",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.lock),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: _login,
            child: Text("Login".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 사용자의 이메일 인증 상태 확인
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        // 이메일 인증이 완료되지 않은 경우
        await _showCuteAlertDialog('이메일 인증이 완료되지 않았습니다. 이메일을 확인해주세요.');
      } else {
        // 로그인 성공 후 처리
        print(userCredential.user!.uid);
        context.push('/chat');
        // 여기에 로그인 후 이동할 페이지 또는 로직을 추가합니다.
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMessage = '아이디, 비밀번호를 다시 확인해주세요.';
      } else {
        print(e.code);
        errorMessage = '로그인 중 오류가 발생했습니다.';
      }

      await _showCuteAlertDialog(errorMessage);
    }
  }

  Future<Future<Object?>> _showCuteAlertDialog(String message) async {
    return showGeneralDialog(
      context: context,

      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 150), // 애니메이션 지속 시간
      barrierColor: Colors.black.withOpacity(0.5), // 배경 색상 및 투명도
      pageBuilder: (_, __, ___) {
        // AlertDialog 정의
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('알림',
              style:
                  TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
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
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // ScaleTransition을 사용한 애니메이션
        return ScaleTransition(
          scale: CurvedAnimation(
              parent: animation, curve: Curves.easeInOut // 애니메이션 효과
              ),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
