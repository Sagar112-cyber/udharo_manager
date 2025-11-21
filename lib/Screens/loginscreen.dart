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

class _LoginscreenState extends State<Loginscreen> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool isvisible = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          TextFormField(
            controller: emailcontroller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: 'Enter your email',
              suffixIcon: Icon(CupertinoIcons.mail),
            ),
          ),

          SizedBox(height: 10),

          TextFormField(
            obscureText: isvisible,
            controller: passwordcontroller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: 'Enter your password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isvisible = !isvisible;
                  });
                },
                icon: Icon(
                    isvisible ? CupertinoIcons.eye : CupertinoIcons.eye_slash),
              ),
            ),
          ),

          SizedBox(height: 30),

          SizedBox(
            height: 50,
            width: 400,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
              ),
              onPressed: () async {
                String email = emailcontroller.text.trim();
                String password = passwordcontroller.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  if (!mounted) return;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Enter the required details!!!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Ok'),
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

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Homescreen(),
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text(error.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Ok'),
                        )
                      ],
                    ),
                  );
                }
              },
              child: Text('Login'),
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dont have Account?'),
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Signupscreen()));
                }, child: Text('SignUp',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.blue,fontSize: 13),))
              ],
            ),
          )
        ],
      ),
    );
  }
}
