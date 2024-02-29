class Message {
  Message({
    required this.fromId,
    required this.msg,
    required this.read,
    required this.sent,
    required this.toId,
    required this.type,
  });
  late final String fromId;
  late final String msg;
  late final String read;
  late final String sent;
  late final String toId;
  late final String type;

  Message.fromJson(Map<String, dynamic> json){
    fromId = json['fromId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    sent = json['sent'].toString();
    toId = json['toId'].toString();
    type = json['type'].toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromId'] = fromId;
    data['msg'] = msg;
    data['read'] = read;
    data['sent'] = sent;
    data['toId'] = toId;
    data['type'] = type;
    return data;
  }
}
enum Type{text,image}
