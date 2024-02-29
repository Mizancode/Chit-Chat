import 'package:chit_chat/Helper/date_time.dart';
import 'package:flutter/material.dart';

import '../Model/user_Chat_Model.dart';
import '../main.dart';
class ViewProfile extends StatefulWidget{
  final UserChat userChat;

  const ViewProfile({super.key, required this.userChat});
  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Scaffold(
     appBar: AppBar(
       title: Text(widget.userChat.name,style: TextStyle(fontSize: 19,fontWeight: FontWeight.normal),),
     ),
      body: Column(
        children: [
          SizedBox(height: mq.height*0.03,),
          Container(
              alignment: Alignment.center,
              child:CircleAvatar(
                radius: mq.height*0.12,
                backgroundImage: NetworkImage(widget.userChat.image)
              ),
          ),
          SizedBox(height: mq.height*0.03,),
          Text(widget.userChat.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.black87),),
          SizedBox(height: mq.height*0.02,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('About: ',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w400,fontSize: 18),),
              Text(widget.userChat.about,style: TextStyle(fontSize: 16,color: Colors.black54),),
            ],
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Joined On: ',style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w400,fontSize: 18),),
            Text(MyDateUtil.getLastMessageTime(context: context, time: widget.userChat.createdAt,showYear: true),style: TextStyle(fontSize: 16,color: Colors.black54),),
          ],
        ),
      ),
    );
  }
}