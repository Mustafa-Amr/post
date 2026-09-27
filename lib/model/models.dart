import 'package:cloud_firestore/cloud_firestore.dart';

class Models {
  String? id;
  String? email;
   String? post;
  List<String>? likes;

  Models({required this.id, required this.email, required this.post,  this.likes});


 factory Models.fromStore(Map<String,dynamic>store){
   return Models(
       id: store['id'],
       email: store['email'],
       post: store['post'],
       likes: store['likes']);
 }

 Map<String,dynamic>toStore(){
   return {
     'id' : id,
     'email' : email,
     'post' : post,
     'likes' : likes,
     'creatAt' : FieldValue.serverTimestamp()
   };
 }

}