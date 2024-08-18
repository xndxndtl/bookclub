import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookclub.app/firebase_options.dart'; // 경로 수정 필요

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        await saveUserData(userCredential.user!); // 사용자 데이터 저장
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

  Future<void> saveUserData(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'lastSignIn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Failed to save user data: $e");
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getUserClubs() {
    return _firestore.collection('clubs')
        .where('createdBy', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Clubs"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserClubs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("You aren't a member of any clubs"));
          }
          final clubs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(clubs[index]['name']),
                subtitle: Text(clubs[index]['description']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _createNewClub(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _createNewClub(BuildContext context) async {
    TextEditingController clubNameController = TextEditingController();
    TextEditingController clubDescriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Create a New Club"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: clubNameController,
                decoration: InputDecoration(labelText: "Club Name"),
              ),
              TextField(
                controller: clubDescriptionController,
                decoration: InputDecoration(labelText: "Club Description"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (clubNameController.text.isNotEmpty &&
                    clubDescriptionController.text.isNotEmpty) {
                  await _firestore.collection('clubs').add({
                    'name': clubNameController.text,
                    'description': clubDescriptionController.text,
                    'createdBy': _auth.currentUser?.uid,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }
}
class ClubCreationSuccessScreen extends StatelessWidget {
  final String clubName;
  final String inviteLink;

  ClubCreationSuccessScreen({required this.clubName, required this.inviteLink});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new club"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Icon(Icons.check_circle_outline, color: Colors.black, size: 100),
            SizedBox(height: 20),
            Text(
              "CREATED A NEW CLUB SUCCESSFULLY!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: "My Club: ",
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(
                    text: clubName,
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            _buildSectionTitle("Send email invitation"),
            TextField(
              decoration: InputDecoration(
                hintText: "Add email(s) addresses",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // 이메일 초대 로직
              },
              child: Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // 비활성화된 색상
              ),
            ),
            SizedBox(height: 30),
            _buildSectionTitle("Send text invitation"),
            ElevatedButton(
              onPressed: () {
                // 문자 초대 로직
              },
              child: Text("Send"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            SizedBox(height: 30),
            _buildSectionTitle("Invite link"),
            GestureDetector(
              onTap: () {
                // 초대 링크 복사 로직
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(inviteLink)),
                    Icon(Icons.copy, color: Colors.orange),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Copy/paste to send friends this link to invite them to your club",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            _buildSectionTitle("Pending invitations"),
            Text(
              "No pending invitation yet",
              style: TextStyle(color: Colors.grey),
            ),
            Spacer(),
            OutlinedButton(
              onPressed: () {
                // 클럽 설정 완료 후 진행할 로직
              },
              child: Text("Continue setting up my club"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}