import 'package:page_transition/page_transition.dart';
import 'package:safeguard_home_ai/Animations/FadeAnimation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safeguard_home_ai/screens/dashboard.dart';
import 'package:safeguard_home_ai/screens/register_page.dart';
import 'package:quickalert/quickalert.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<UserCredential> signInWithFirebase(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xAA1A1B1E),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FadeAnimation(1.2, const Text("Let's sign you in.",
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),)),
            const SizedBox(height: 30,),
            FadeAnimation(1.5, Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xAA1A1B1E),
                  border: Border.all(color: const Color(0xFF373A3F))
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF373A3F)))
                    ),
                    child: TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFF5C5F65)),
                        hintText: "Email or Phone number",
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Color(0xFF5C5F65)),
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            child: const Icon(Icons.remove_red_eye, color: Color(0xFF5C5F65),)),
                        hintText: "Password",
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 40,),
            FadeAnimation(1.6, Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?", style: TextStyle(color: Color(0xFF5C5F65)),),
                const SizedBox(width: 6,),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade, child: const RegisterPage()
                          )
                      );
                    },
                    child: const Text("Register", style: TextStyle(color: Colors.blue ),)
                )
              ],
            )),
            const SizedBox(height: 20,),
            FadeAnimation(1.8, Center(
              child: MaterialButton(
                onPressed: () async {
                  try {
                    UserCredential userCredential = await signInWithFirebase(emailController.text, passwordController.text);
                    if (userCredential.user != null) {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        text: 'Signed In Successfully!',
                        showConfirmBtn: true,
                      ).then((value) {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade, child: const Dashboard()));
                      });

                      print("User is logged in");
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                color: const Color(0xAA3A5BDA),
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Center(child: Text("Login", style: TextStyle(color: Colors.white.withOpacity(.7), fontSize: 16),)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}