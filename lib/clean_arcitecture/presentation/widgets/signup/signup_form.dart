import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../constants.dart';
import '../../pages/login_screen.dart';
import '../already_have_an_account_acheck.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 이메일 필드
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            onSaved: (email) {},
            decoration: const InputDecoration(
              hintText: "Your email",
              prefixIcon: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person),
              ),
            ),
            // ... 나머지 설정들 ...
          ),
          // 패스워드 필드
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
              // ... 나머지 설정들 ...
            ),
          ),
          // 회원가입 버튼
          ElevatedButton(
            onPressed: _register,
            child: Text("Sign Up".toUpperCase()),
          ),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
          ),
          // 나머지 위젯들
        ],
      ),
    );
  }

  Future<void> _register() async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection("users").add({
        "uid": userCredential.user?.uid ?? "",
        "email": userCredential.user?.email ?? "",
      });

      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        // 이메일 인증 요청에 대한 알림 메시지
        print("ss");
        await _showCuteAlertDialog('이메일 인증 메일이 발송되었습니다. 메일을 확인해 주세요.');
        print("ss2");
        context.push('/login');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'weak-password') {
        errorMessage = '비밀번호가 너무 약합니다.';
        debugPrint('The password provided is too weak.');
        // 에러 처리
      } else if (e.code == 'email-already-in-use') {
        errorMessage = '이미 등록된 이메일입니다.';
        debugPrint('The account already exists for that email.');
        // 에러 처리
      } else {
        errorMessage = e.code;
      }

      await _showCuteAlertDialog(errorMessage);
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // 사용자의 이메일 인증 상태 확인
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        // 이메일 인증이 완료되지 않은 경우
        await _showCuteAlertDialog('이메일 인증이 완료되지 않았습니다. 이메일을 확인해주세요.');
      } else {
        // 로그인 성공 후 처리
        print(userCredential.user!.uid);
        // 여기에 로그인 후 이동할 페이지 또는 로직을 추가합니다.
        context.push('/chat');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = '동일한 이메일로 이미 가입된 계정이 있습니다.';
      } else {
        errorMessage = '로그인 중 오류가 발생했습니다.';
      }

      await _showCuteAlertDialog(errorMessage);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
