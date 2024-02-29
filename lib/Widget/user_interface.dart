import 'package:chit_chat/API/auth.dart';
import 'package:chit_chat/Helper/date_time.dart';
import 'package:chit_chat/Model/user_Chat_Model.dart';
import 'package:chit_chat/Widget/user_chat.dart';
import 'package:chit_chat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/message.dart';
import 'dialog.dart';

class UserInterface extends StatefulWidget{
  final UserChat userChat;

  const UserInterface({super.key, required this.userChat});

  @override
  State<UserInterface> createState() => _UserInterfaceState();
}

class _UserInterfaceState extends State<UserInterface> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return Card(
      elevation: 0.6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.symmetric(horizontal: mq.width*0.04,vertical: mq.height*0.006),
      child: StreamBuilder(
        stream: APIs.getLastMessage(widget.userChat),
        builder: (context,snapshot){
          final data=snapshot.data?.docs;
          final _list= data?.map((e) => Message.fromJson(e.data())).toList()??[];
          if(_list.isNotEmpty) _message=_list[0];
          return ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UserChatScreen(user: widget.userChat,)));
              },
              // ignore: unnecessary_null_comparison
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_)=>MyDialog(userChat: widget.userChat,));
                },
                child: CircleAvatar(
                   radius: 28,
                    backgroundImage: NetworkImage(widget.userChat.image)
                ),
              ),
              title: Text(widget.userChat.name,maxLines: 1,),
              subtitle: Text(_message!=null?
              _message!.msg.startsWith('https')?'image':_message!.msg:widget.userChat.about,maxLines: 1,),
              trailing: _message==null? null : _message!.read.isEmpty && _message!.fromId!=APIs.userDetails.uid ? Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.greenAccent.shade400
                ),
              ): Text(MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),style: TextStyle(color: Colors.black54),)
          );
        },
      )
    );
  }
}