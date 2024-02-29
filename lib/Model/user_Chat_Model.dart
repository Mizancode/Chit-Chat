class UserChat {
  UserChat({
  required this.about,
  required this.createdAt,
  required this.email,
  required this.id,
  required this.image,
  required this.isOnline,
  required this.lastActive,
  required this.name,
  required this.pushToken,
});
late String about;
late String createdAt;
late String email;
late String id;
late String image;
late bool isOnline;
late String lastActive;
late String name;
late String pushToken;

  UserChat.fromJson(Map<String, dynamic> json){
about = json['about'] ?? "";
createdAt = json['created At'] ?? "";
email = json['email'] ?? "";
id = json['id'] ?? "";
image = json['image'] ?? "";
isOnline = json['is Online'] ?? "";
lastActive = json['last Active'] ?? "";
name = json['name'] ?? "";
pushToken = json['push Token'] ?? "";
}

Map<String, dynamic> toJson() {
final data = <String, dynamic>{};
data['about'] = about;
data['created At'] = createdAt;
data['email'] = email;
data['id'] = id;
data['image'] = image;
data['is Online'] = isOnline;
data['last Active'] = lastActive;
data['name'] = name;
data['push Token'] = pushToken;
return data;
}
}