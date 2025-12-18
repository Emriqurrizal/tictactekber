import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instance Setup: Get the tools ready
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign In Function
  /// Input: email and password
  /// Output: Returns User object if successful, throws error if not
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Ask Firebase Auth to verify credentials
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error codes to readable messages
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials. Please check your email and password';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Check if username already exists
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isEmpty; // true if available
    } catch (e) {
      throw Exception('Failed to check username: $e');
    }
  }

  /// Sign Up Function
  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    // Check if username is already taken FIRST
    final isAvailable = await isUsernameAvailable(username);
    if (!isAvailable) {
      throw Exception('Username "$username" is already taken. Please choose another one.');
    }

    try {
      //Create authentication account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        // This stores the user's game data (username, score, etc.)
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username,
          'email': email,
          'score': 0, // Starting score for leaderboard
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update the display name in Firebase Auth (optional, but helpful)
        await user.updateDisplayName(username);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Convert Firebase error codes to readable messages
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message}';
      }
      throw Exception(errorMessage);
    }
  }

  /// Sign Out Function
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Update user score
  Future<void> incrementScore(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'score': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to update score: $e');
    }
  }
}
