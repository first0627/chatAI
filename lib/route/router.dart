import 'package:chatprj/clean_arcitecture/presentation/pages/chat.dart';
import 'package:chatprj/clean_arcitecture/presentation/pages/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../clean_arcitecture/presentation/pages/login_screen.dart';
import '../clean_arcitecture/presentation/pages/signup_screen.dart';

// 로그인이 됐는지 안됐는지
// true - login OK / false - login NO
bool authState = false;
//https://blog.codefactory.ai -> /도메인 왼쪽을 path라고 한다.
//https://blog.codefactory.ai/flutter -> /flutter 이렇게 본다는 뜻임

// / 이게 home이었음
// /basic  이건 basic screen

// /named
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/login';
    //final isLoggingIn = state.subloc == '/login';

    print('라우터');
    print(FirebaseAuth.instance.currentUser?.uid);

    // 로그인 상태이고, 로그인 페이지가 아니면 ChatScreen으로 리디렉션
    if (isLoggedIn && !isLoggingIn) {
      return '/chat';
    }

    // 로그인 상태가 아니면 로그인 페이지로 리디렉션
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: 'chat',
          builder: (context, state) => const ChatScreen(),
        ),
      ],
    ),
  ],
);
