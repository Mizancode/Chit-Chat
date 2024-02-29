import 'package:chit_chat/API/auth.dart';
import 'package:chit_chat/Auth/login_screen.dart';
import 'package:chit_chat/Screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500),(){
      if(APIs.auths.currentUser!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: mq.height*0.2,
          width: mq.width*0.5,
          left: mq.width*0.25,
          child: Image.asset('assets/images/chat.png')
          ),
          Positioned(
              bottom: mq.height*0.2,
              left: mq.width*0.19,
              child: Text('Hello Welcome To Chit Chat ❤',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),)
          )
        ],
      ),
    );
  }
}