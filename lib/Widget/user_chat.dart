import 'dart:io';

import 'package:chit_chat/API/auth.dart';
import 'package:chit_chat/Helper/date_time.dart';
import 'package:chit_chat/Model/message.dart';
import 'package:chit_chat/Model/user_Chat_Model.dart';
import 'package:chit_chat/Widget/view_profile.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import 'message_card.dart';
class UserChatScreen extends StatefulWidget{
  final UserChat user;

  const UserChatScreen({super.key, required this.user});
  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  List<Message> _list=[];
  bool _emojiSelect=false,_isUploading=false;
  final _textController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_emojiSelect){
            setState(() {
              _emojiSelect=false;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 234, 248, 255),
           appBar: PreferredSize(
             preferredSize: Size.fromHeight(mq.height*0.075),
             child: appBar(),
           ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessage(widget.user),
                  builder: (context,snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return SizedBox();
                      case ConnectionState.active:
                      case ConnectionState.done:
                      final data=snapshot.data?.docs;
                      _list= data?.map((e) => Message.fromJson(e.data())).toList()??[];
                        if(_list.isNotEmpty){
                          return ListView.builder(
                            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              reverse:true,
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.015),
                              physics: BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context,index){
                                return MessageCard(message: _list[index]);
                              });
                        }else{
                          return Center(child: Text('Say Hii! 👋',style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),));
                        }
                    }
                  },
                ),
              ),
              if(_isUploading)
              Align(
                alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  )),
              textMessage(),
                if(_emojiSelect)
                SizedBox(
                  height: mq.height*0.35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      bgColor: Color.fromARGB(255, 234, 248, 255),
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS == TargetPlatform.iOS ? 1.30 : 1.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget appBar(){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewProfile(userChat: widget.user,)));
      },
      child: Container(
        padding: EdgeInsets.only(top: mq.height*0.05),
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context,snapshot){
            final data=snapshot.data?.docs;
            final _list= data?.map((e) => UserChat.fromJson(e.data())).toList()??[];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(icon:Icon(Icons.arrow_back),onPressed: (){
                  Navigator.pop(context);
                },),
                CircleAvatar(
                  radius: 27,
                  backgroundImage: NetworkImage(widget.user.image),
                ),
                SizedBox(width: mq.width*0.03,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_list.isNotEmpty?_list[0].name:widget.user.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                    Text(_list.isNotEmpty? _isUploading?'online':MyDateUtil().getLastActiveTime(context: context, lastActive: _list[0].lastActive):MyDateUtil().getLastActiveTime(context: context, lastActive: widget.user.lastActive),style: TextStyle(fontSize: 13),),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
  Widget textMessage(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.width*0.025,vertical: mq.height*0.01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
              ),
              child: Row(
                children: [
                  IconButton(onPressed: (){
                       setState(() {
                         FocusScope.of(context).unfocus();
                         _emojiSelect=!_emojiSelect;
                       });
                  }, icon: Icon(Icons.emoji_emotions_rounded,color: Colors.blueAccent,)),
                  Expanded(child: TextField(
                    onTap: (){
                      if(_emojiSelect){
                        _emojiSelect=!_emojiSelect;
                      }
                    },
                    controller: _textController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Type Something Here...',
                      hintStyle: TextStyle(color: Colors.blueAccent,fontSize: 15),
                      border: InputBorder.none
                    ),
                  )),
                  IconButton(onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final List<XFile>? images = await picker.pickMultiImage(imageQuality: 70);
                    for(var i in images!){
                      setState(() {
                        _isUploading=true;
                      });
                      await APIs.sendChatImage(widget.user,File(i.path)).then((value) {
                        setState(() {
                          _isUploading=false;
                        });
                      });
                    }
                  }, icon: Icon(Icons.photo,color: Colors.blueAccent,)),
                  IconButton(onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                  if(image!=null){
                    setState(() {
                      _isUploading=true;
                    });
                  await APIs.sendChatImage(widget.user,File(image.path)).then((value) {
                    setState(() {
                      _isUploading=true;
                    });
                  });
                  Navigator.pop(context);}
                  }, icon: Icon(Icons.camera_alt,color: Colors.blueAccent,)),
                ],
              ),
            ),
          ),
          MaterialButton(onPressed: (){
             if(_textController.text.isNotEmpty){
               if(_list.isEmpty){
                APIs.sendFirstMessage(widget.user, _textController.text);
               }else {
                 APIs.sendMessage(widget.user, _textController.text);
               }
               _textController.text='';
             }
          },child: Icon(Icons.send,color: Colors.white,),
            color: Colors.green,shape: CircleBorder(),
            padding: EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
            minWidth: 0,
          ),
        ],
      ),
    );
  }
}