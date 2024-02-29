import 'package:chit_chat/API/auth.dart';
import 'package:chit_chat/Helper/date_time.dart';
import 'package:chit_chat/Helper/dialog.dart';
import 'package:chit_chat/Model/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../main.dart';
class MessageCard extends StatefulWidget{
  final Message message;

  const MessageCard({super.key, required this.message});
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    bool isMe=APIs.userDetails.uid==widget.message.fromId;
    return InkWell(
      onLongPress: (){
        _showBottomModel(isMe);
      },
      child: isMe?greenMessage():blueMessage(),
    );
  }
  Widget blueMessage(){
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: mq.width*0.04,vertical: mq.height*0.01),
            padding: EdgeInsets.all(mq.width*0.04),
            child: !widget.message.msg.startsWith('https')?Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black87,fontWeight: FontWeight.bold),):
             ClipRRect(
             borderRadius: BorderRadius.circular(15),
             child: Image(image: NetworkImage(widget.message.msg),)),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 234, 248, 255),
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.only(
                  topLeft:Radius.circular(30),
                   topRight:Radius.circular(30),
                   bottomRight:Radius.circular(30))
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width*0.04),
          child: Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),style: TextStyle(fontSize: 12,color: Colors.black87),)
        )
      ],
    );
  }
  Widget greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width*0.04,),
            if(widget.message.read.isNotEmpty)
              Icon(Icons.done_all_rounded, color: Colors.blue, size: 20,),
            SizedBox(width: mq.width*0.01,),
            Text(MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),style: TextStyle(fontSize: 12,color: Colors.black87),),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: mq.width*0.04,vertical: mq.height*0.01),
            padding: EdgeInsets.all(mq.width*0.04),
            child: !widget.message.msg.startsWith('https')?Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.black87,fontWeight: FontWeight.bold),):
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
                child: Image(image: NetworkImage(widget.message.msg),)),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color: Colors.greenAccent),
                borderRadius: BorderRadius.only(
                    topLeft:Radius.circular(30),
                    topRight:Radius.circular(30),
                    bottomLeft:Radius.circular(30))
            ),
          ),
        ),
      ],
    );
  }
  void _showBottomModel(bool isMe){
    showModalBottomSheet(shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
    ),context: context, builder: (context){
      return ListView(
        shrinkWrap: true,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: mq.height*0.015,horizontal: mq.width*0.4),
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey,
              borderRadius: BorderRadius.circular(8)
            ),
          ),
          !widget.message.msg.startsWith('http')?_optional(icon: Icon(Icons.copy_all_rounded,size: 26,color: Colors.blueAccent,), name: 'Copy Text', onTap: () async {
            await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value){
            Navigator.pop(context);
            DialogMsg.showSnackBar(context, 'Text Copied!');
            });
          }):_optional(icon: Icon(Icons.download_rounded,size: 26,color: Colors.blueAccent,), name: 'Save Image', onTap: (){
            try{
              GallerySaver.saveImage(widget.message.msg,albumName: 'Chit Chat').then((success) {
                Navigator.pop(context);
                if(success!=null && success){
                  DialogMsg.showSnackBar(context, 'Image Saved Successfully!');
                }
              });
            }catch(e){}
          }),
          if(isMe)
          Divider(
            endIndent: mq.height*0.04,
            indent: mq.height*0.04,
          ),
          if(!widget.message.msg.startsWith('http') && isMe)_optional(icon: Icon(Icons.edit,size: 26,color: Colors.blueAccent,), name: 'Edit Message', onTap: (){
            Navigator.pop(context);
            _showMessageUpdateDialog();
          }),
          if(isMe)
          _optional(icon: Icon(Icons.delete_forever,size: 26,color: Colors.redAccent,), name: 'Delete Message', onTap: () async {
            await APIs.deleteMessage(widget.message).then((value){
              Navigator.pop(context);
              DialogMsg.showSnackBar(context, 'Deleted!');
            });
          }),
          Divider(
            endIndent: mq.height*0.04,
            indent: mq.height*0.04,
          ),
          if(isMe)_optional(icon: Icon(Icons.remove_red_eye,color: Colors.blueAccent,), name: 'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}', onTap: (){}),
          _optional(icon: Icon(Icons.remove_red_eye,color: Colors.greenAccent,), name: widget.message.read.isEmpty? 'Read At: Not Seen yet' : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}', onTap: (){}),
        ],
      );
    });
  }
  void _showMessageUpdateDialog(){
    String updatedMsg=widget.message.msg;
    showDialog(context: context, builder: (_)=>AlertDialog(
      contentPadding: EdgeInsets.only(right: 24,left: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      title: Row(
        children: [
          Icon(Icons.message,color: Colors.blueAccent,size: 28,),
          Text(' Update Message')
        ],
      ),
      content: TextFormField(
        autofocus: true,
        maxLines: null,
        onChanged: (value)=>updatedMsg=value,
        initialValue: updatedMsg,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)
          )
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          navigatorKey.currentState?.pop();
        },child: Text('Cancel',style: TextStyle(color: Colors.blueAccent,fontSize: 16),),),
        MaterialButton(onPressed: (){
          navigatorKey.currentState?.pop();
          APIs.updateMessage(widget.message, updatedMsg);
        },child: Text('Update',style: TextStyle(color: Colors.blueAccent,fontSize: 16),),),
      ],
    ));
  }
}
class _optional extends StatelessWidget{
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _optional({super.key, required this.icon, required this.name, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=>onTap(),
      child: Padding(
        padding: EdgeInsets.only(left: mq.width*0.05,top: mq.height*0.015,bottom: mq.height*0.02),
        child: Row(
          children: [
            icon,
            Flexible(child: Text('     $name',style: TextStyle(color: Colors.black54,fontSize: 15,letterSpacing: 0.5),)),
          ],
        ),
      ),
    );
  }
}