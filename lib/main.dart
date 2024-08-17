import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookclub.app/firebase_options.dart';
// import 'package:flutter_naver_login/flutter_naver_login.dart';
// import 'package:kakao_flutter_sdk/all.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화를 보장
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 초기화
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Club App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        print("Logged in with Google: ${userCredential.user!.uid}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyClubsScreen()),
        );
      }
    } catch (e) {
      print("Failed to sign in with Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with Google. Please try again!'))
      );
    }
  }
  /*
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Logged in with Google: ${userCredential.user!.uid}");
    } catch (e) {
      print("Failed to sign in with Google: $e");
    }
  }
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Your email",
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 로그인 로직 추가
              },
              child: Text("SIGN IN"),
            ),
            TextButton(
              onPressed: () {
                // 비밀번호 재설정 또는 회원가입 로직 추가
              },
              child: Text("Forgot password?"),
            ),
            TextButton(
              onPressed: () {
                // 회원가입 화면 이동 로직 추가
              },
              child: Text("New to Bookclubs? Create Your Account"),
            ),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text("Continue with Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Facebook 로그인 로직 추가
              },
              child: Text("Continue with Facebook"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyClubsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Clubs"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("You aren't a member of any clubs"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 클럽 생성 로직
                print("Create a new club");
              },
              child: Text("Create a new club"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // 클럽 가입 로직
                print("Join a book club");
              },
              child: Text("Join a book club"),
            ),
          ],
        ),
      ),
    );
  }
}

/*

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Flutter 엔진 초기화 보장
 /* await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); */
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }
  runApp(SignInScreen());
}


class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Logged in with Google: ${userCredential.user!.uid}");
    } catch (e) {
      print("Failed to sign in with Google: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Your email",
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 로그인 로직 추가
              },
              child: Text("SIGN IN"),
            ),
            TextButton(
              onPressed: () {
                // 비밀번호 재설정 또는 회원가입 로직 추가
              },
              child: Text("Forgot password?"),
            ),
            TextButton(
              onPressed: () {
                // 회원가입 화면 이동 로직 추가
              },
              child: Text("New to Bookclubs? Create Your Account"),
            ),
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text("Continue with Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색
                foregroundColor: Colors.black, // 글자색
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Facebook 로그인 로직 추가
              },
              child: Text("Continue with Facebook"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/*
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text("Sign in with Google"),
              onPressed: _signInWithGoogle,
            ),
 /*           ElevatedButton(
              child: Text("Sign in with Naver"),
              onPressed: _signInWithNaver,
            ),
            ElevatedButton(
              child: Text("Sign in with Kakao"),
              onPressed: _signInWithKakao,
            ), */
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      print("Logged in with Google: ${userCredential.user}");
    } catch (e) {
      print("Failed to sign in with Google: $e");
    }
  }
/*
  Future<void> _signInWithNaver() async {
    try {
      NaverLoginResult res = await FlutterNaverLogin.logIn();
      print("Logged in with Naver: ${res.account}");
    } catch (e) {
      print("Failed to sign in with Naver: $e");
    }
  }

  Future<void> _signInWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      var result = isInstalled
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      print("Logged in with Kakao: $result");
    } catch (e) {
      print("Failed to sign in with Kakao: $e");
    }
  }
 */
}

/*
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
 */

 */
*/

