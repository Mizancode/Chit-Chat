import 'dart:io';

import 'package:chit_chat/API/auth.dart';
import 'package:chit_chat/Helper/dialog.dart';
import 'package:chit_chat/Screens/home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAnimated=false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
      isAnimated=true;
      setState(() {

      });
    });
  }
  Future<UserCredential?> _signInWithGoogle() async {
    DialogMsg.showProgress(context);
    try{
      await InternetAddress.lookup('google.in');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await APIs.auths.signInWithCredential(credential);
    }catch(e){
     DialogMsg.showSnackBar(context, 'Something went wrong!');
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Chit Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height*0.15,
              right: isAnimated?mq.width*0.25:-mq.width*0.5,
              width: mq.width*0.5,
              duration: Duration(seconds: 1),
              child: Image.asset('assets/images/chat.png')
          ),
          Positioned(
              bottom: mq.height*0.15,
              left: mq.width*0.05,
              width: mq.width*0.9,
              height: mq.height*0.06,
              child: ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.lightGreenAccent.shade100,
                 ),
                  onPressed: (){
                      _signInWithGoogle().then((user) async => {
                        Navigator.pop(context),
                        if(user!=null){
                          if((await APIs.userExists())){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()))
                          }else{
                            await APIs.createUser().then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen())))
                          }
                        }
                      });
                  }, icon: Image.asset('assets/images/google.png',height: mq.height*0.03,), label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),
                  children: [
                    TextSpan(text: 'Sign In with '),
                    TextSpan(text: 'Google',style: TextStyle(fontWeight: FontWeight.w900))
                  ]
                ),
              )),
          ),
        ],
      ),
    );
  }
}