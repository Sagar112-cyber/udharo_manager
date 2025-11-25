import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udharo_manager/Screens/homescreen.dart';
import 'package:udharo_manager/Screens/signupscreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen>
    with SingleTickerProviderStateMixin {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool isVisible = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final AnimationController _animController =
  AnimationController(vsync: this, duration: const Duration(seconds: 1));

  late final Animation<double> _anim =
  Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Opacity(
            opacity: _anim.value,
            child: child,
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.lock_circle_fill,
                    color: Colors.white,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  // Email
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: Colors.black45,
                    child: TextFormField(
                      controller: emailcontroller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'Enter your email',
                        prefixIcon:
                        Icon(CupertinoIcons.mail, color: Colors.purple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: Colors.black45,
                    child: TextFormField(
                      obscureText: isVisible,
                      controller: passwordcontroller,
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'Enter your password',
                        prefixIcon:
                        const Icon(CupertinoIcons.lock, color: Colors.purple),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(isVisible
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      onPressed: () async {
                        String email = emailcontroller.text.trim();
                        String password = passwordcontroller.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Enter the required details!'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Ok'),
                                )
                              ],
                            ),
                          );
                          return;
                        }

                        try {
                          await _auth.signInWithEmailAndPassword(
                              email: email, password: password);
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Homescreen()),
                          );
                        } catch (error) {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(error.toString()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Ok'),
                                )
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Color(0xFF4A00E0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Signupscreen()));
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellowAccent),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
