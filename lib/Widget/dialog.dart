import 'package:chit_chat/Model/user_Chat_Model.dart';
import 'package:chit_chat/Widget/view_profile.dart';
import 'package:flutter/material.dart';

import '../main.dart';
class MyDialog extends StatefulWidget{
  final UserChat userChat;

  const MyDialog({super.key, required this.userChat});
  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      content: SizedBox(
        height: mq.height*0.37,
        child: Stack(
          children: [
            Positioned(
              left: mq.width*0.04,
              top: mq.height*0.008,
              width: mq.width*0.55,
                child: Text(widget.userChat.name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,),)),
            Container(
              alignment: Alignment.center,
              child:CircleAvatar(
                  radius: mq.height*0.14,
                  backgroundImage: NetworkImage(widget.userChat.image)
              ),
            ),
            Positioned(
                right: 5,
                child: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewProfile(userChat: widget.userChat)));
                  },
                  icon: Icon(Icons.info_outline_rounded,color: Colors.blue,size: 30,),
                )
            )
          ],
        ),
      ),
    );
  }
}