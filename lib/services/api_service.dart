// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import '../models/payment_model.dart';
import '../models/user_model.dart';

class ApiService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> registerUser(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      fb_auth.UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // Save additional user info to Firestore
        await _db.collection('users').doc(credential.user!.uid).set({
          'full_name': fullName,
          'email_address': email,
          'created_at': FieldValue.serverTimestamp(),
        });

        return {
          "status": "success",
          "user": User(
            id: credential.user!.uid,
            fullName: fullName,
            emailAddress: email,
            imageUrl: null,
          ),
        };
      }
      return {"status": "error", "message": "Registration failed"};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      fb_auth.UserCredential credential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await _db
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      return {
        "status": "success",
        "user": User(
          id: credential.user!.uid,
          fullName: userData['full_name'],
          emailAddress: userData['email_address'],
          imageUrl: userData['image_url'],
        ),
      };
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String fullName,
    required String email,
    String? imageUrl,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'full_name': fullName,
        'email_address': email,
      };
      if (imageUrl != null) updateData['image_url'] = imageUrl;

      await _db.collection('users').doc(userId).update(updateData);

      if (_auth.currentUser?.email != email) {
        await _auth.currentUser?.updateEmail(email);
      }

      return {"status": "success"};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Method to fetch products from the database
  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot snapshot = await _db.collection('products').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      // ignore: avoid_print
      print("Exception during fetchProducts: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> submitOrder(
    String userId,
    String paymentId,
    double totalAmount,
    List<Map<String, dynamic>> orderItems,
  ) async {
    try {
      DocumentReference docRef = await _db.collection('orders').add({
        "user_id": userId,
        "payment_id": paymentId,
        "total_amount": totalAmount,
        "order_items": orderItems,
        "status": "pending",
        "created_at": FieldValue.serverTimestamp(),
      });

      return {"status": "success", "order_id": docRef.id};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Note: Payments like M-Pesa require a secure backend environment.
  // You should use Firebase Cloud Functions to interact with the Daraja API.
  // Below are placeholders representing that logic.

  Future<Map<String, dynamic>> initiateMpesaPayment(
    String phoneNumber,
    double amount,
    String userId,
  ) async {
    // This should call a Firebase Cloud Function via httpsCallable
    return {
      "status": "error",
      "message": "Cloud Function for M-Pesa not implemented",
    };
  }

  Future<Map<String, dynamic>> checkMpesaStatus(
    String checkoutRequestId,
  ) async {
    return {
      "status": "error",
      "message": "Cloud Function status check not implemented",
    };
  }

  Future<List<dynamic>> fetchRentalHistory(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> processCardPayment({
    required String userId,
    required double amount,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    return {
      "status": "error",
      "message": "Secure card processing requires a dedicated payment gateway",
    };
  }

  Future<Map<String, dynamic>> savePaymentRecord(PaymentModel payment) async {
    try {
      DocumentReference docRef = await _db
          .collection('payments')
          .add(payment.toJson());
      return {"status": "success", "payment_id": docRef.id};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
