import 'package:einkaufslite/models/user.dart';
import 'package:einkaufslite/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:einkaufslite/utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // map firebase user → custom User model
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in with email & password
  Future<User?> signInWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log.w('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log.w('Wrong password provided for that user.');
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    try {
      log.i(emailAddress);
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      User? user = credential.user;
      await DatabaseService(uid: user!.uid).addUserData(emailAddress);
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log.i('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        log.i('The account already exists for that email.');
      }
    } catch (e) {
      log.e(e);
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }
}
