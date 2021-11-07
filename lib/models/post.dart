import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;


  Post({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc.documentID,
      ownerId: doc['owner'],
      likes: doc['likes'],
      username: doc['username'],
      description: doc['description'],
      location: doc['location'],
      url: doc['url'],
      likeCount: 5,
    );
  }
}