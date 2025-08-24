import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Gerando mocks usando anotações
@GenerateMocks([
  firebase_auth.FirebaseAuth,
  firebase_auth.User,
  firebase_auth.UserCredential,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  SetOptions,
  // Firebase Storage mocks
  FirebaseStorage,
  Reference,
  UploadTask,
  TaskSnapshot,
  FullMetadata,
])
void main() {}
