import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:udharo_manager/Screens/loginscreen.dart';

class Signupscreen extends StatefulWidget {
  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final firstnamecontroller=TextEditingController();

  final emailcontroller=TextEditingController();

  final passwordcontroller=TextEditingController();

  final lastnamecontroller=TextEditingController();

  bool isvisible=false;
  final FirebaseAuth _auth=FirebaseAuth.instance;

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
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: 'Enter you email',
              suffixIcon: Icon(CupertinoIcons.phone)
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: firstnamecontroller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: 'Enter you first name',
              suffixIcon: Icon(CupertinoIcons.person)
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: lastnamecontroller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: 'Enter you last name',
              suffixIcon: Icon(CupertinoIcons.person)
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            obscureText: isvisible,
            controller: passwordcontroller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: 'Enter you password',
              suffixIcon: IconButton(onPressed: (){
                setState(() {
                  isvisible=!isvisible;
                });
              }, icon: Icon(Icons.panorama_fish_eye))
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 50,
            width: 400,
            child: ElevatedButton(onPressed: (){
              String email=emailcontroller.text.trim();
              String password=passwordcontroller.text.trim();
              if(firstnamecontroller.text.isEmpty||lastnamecontroller.text.isEmpty||emailcontroller.text.isEmpty){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    content: Text('Enter a full detials'),
                    title: Text('Alert'),
                    actions: [
                      TextButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: Text('ok'))
                    ],
                  );
                }
                );
              } else{
                _auth.createUserWithEmailAndPassword(email: email, password: password).then((UserCredential userCredential){
                  return Navigator.push(context, MaterialPageRoute(builder: (context)=>Loginscreen()));
                });

              }
            }, child: Text('SignUp')),
          )

        ],
      ),
    );
  }
}
