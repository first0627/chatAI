import 'package:chatprj/clean_arcitecture/presentation/pages/chat.dart';
import 'package:chatprj/clean_arcitecture/presentation/pages/welcome_screen.dart';
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
  //redirect 이건 모든 라우터에 다 적용
  redirect: (context, state) {
    //return string (path) ==> 해당 라우트로 이동한다 (path)
    //return null -> 원래 이동하려던 라우트로 이동한다.
    if (state.matchedLocation == '/login/private' && !authState) {
      //로그인이 안됐을때는 로그인 화면으로 가라
      return '/login';
    }
    //로그인이 됐을때는 그냥 그대로 가라
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
      routes: [
        GoRoute(
            path: 'login', builder: (context, state) => const LoginScreen()),
        GoRoute(
            path: 'signup', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: 'chat', builder: (context, state) => const ChatScreen()),
      ],
    ),
  ],
);
