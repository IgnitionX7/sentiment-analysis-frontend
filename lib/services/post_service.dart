import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/comment.dart';

class PostService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createPost(Post post) async {
    await _db.collection('posts').add(post.toFirestore());
  }

  static Stream<List<Post>> getPosts() {
    return _db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  static Stream<List<Comment>> getComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }

  static Future<void> addComment(String postId, Comment comment) async {
    final batch = _db.batch();
    final commentRef = _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();
    batch.set(commentRef, comment.toFirestore());
    batch.update(_db.collection('posts').doc(postId), {
      'commentCount': FieldValue.increment(1),
    });
    await batch.commit();
  }
}
