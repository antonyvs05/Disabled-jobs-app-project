import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user_model.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Collections
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get jobsCollection => _firestore.collection('jobs');
  CollectionReference get applicationsCollection => _firestore.collection('applications');

  // Auth Methods
  Future<auth.User?> signUp(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  Future<auth.User?> signIn(String email, String password) async {
    try {
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // User CRUD Operations
  Future<void> createUser(User user) async {
    try {
      await usersCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(userId).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Stream<User?> getUserStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return User.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Job CRUD Operations
  Future<String> createJob(Job job) async {
    try {
      DocumentReference docRef = await jobsCollection.add(job.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating job: $e');
      rethrow;
    }
  }

  Future<Job?> getJob(String jobId) async {
    try {
      DocumentSnapshot doc = await jobsCollection.doc(jobId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting job: $e');
      rethrow;
    }
  }

  Stream<List<Job>> getAllJobs() {
    return jobsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Job>> getJobsByEmployer(String employerId) {
    return jobsCollection
        .where('employer_id', isEqualTo: employerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Job.fromJson(data);
      }).toList();
    });
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    try {
      await jobsCollection.doc(jobId).update(data);
    } catch (e) {
      print('Error updating job: $e');
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await jobsCollection.doc(jobId).delete();
    } catch (e) {
      print('Error deleting job: $e');
      rethrow;
    }
  }

  // Application CRUD Operations
  Future<String> createApplication(Application application) async {
    try {
      DocumentReference docRef = await applicationsCollection.add(application.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating application: $e');
      rethrow;
    }
  }

  Stream<List<Application>> getUserApplications(String userId) {
    return applicationsCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Application.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<Application>> getJobApplications(String jobId) {
    return applicationsCollection
        .where('job_id', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Application.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> updateApplicationStatus(
      String userId, String jobId, ApplicationStatus status) async {
    try {
      QuerySnapshot snapshot = await applicationsCollection
          .where('user_id', isEqualTo: userId)
          .where('job_id', isEqualTo: jobId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'status': status.toString().split('.').last,
        });
      }
    } catch (e) {
      print('Error updating application status: $e');
      rethrow;
    }
  }

  // Check if user has applied to a job
  Future<bool> hasApplied(String userId, String jobId) async {
    try {
      QuerySnapshot snapshot = await applicationsCollection
          .where('user_id', isEqualTo: userId)
          .where('job_id', isEqualTo: jobId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking application: $e');
      rethrow;
    }
  }
}