import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udharo_manager/Screens/loginscreen.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({super.key});

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen>
    with SingleTickerProviderStateMixin {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isVisible = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _animController;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _anim =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _animController,
          curve: Curves.easeInOut,
        ));
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
              colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
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
                  // Header Icon
                  Icon(
                    CupertinoIcons.person_crop_circle_fill,
                    color: Colors.white,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 40),

                  // First Name
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: Colors.black45,
                    child: TextFormField(
                      controller: firstnameController,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'First Name',
                        prefixIcon:
                        Icon(CupertinoIcons.person, color: Colors.purple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: Colors.black45,
                    child: TextFormField(
                      controller: lastnameController,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'Last Name',
                        prefixIcon:
                        Icon(CupertinoIcons.person_alt, color: Colors.purple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    shadowColor: Colors.black45,
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'Email',
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
                      controller: passwordController,
                      obscureText: isVisible,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'Password',
                        prefixIcon:
                        const Icon(CupertinoIcons.lock, color: Colors.purple),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isVisible
                                ? CupertinoIcons.eye
                                : CupertinoIcons.eye_slash,
                          ),
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // SignUp Button
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
                        String firstName = firstnameController.text.trim();
                        String lastName = lastnameController.text.trim();
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        if (firstName.isEmpty ||
                            lastName.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty) {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Please fill all fields'),
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
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Loginscreen()),
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
                        'Sign Up',
                        style: TextStyle(
                            color: Color(0xFF4A00E0),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Loginscreen()));
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellowAccent),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
