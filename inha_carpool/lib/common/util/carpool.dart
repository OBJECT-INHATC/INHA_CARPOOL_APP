import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirebaseCarpool {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addDataToFirestore({
    required DateTime selectedDate,
    required DateTime selectedTime,
    required LatLng startPoint,
    required LatLng endPoint,
    required String endPointName,
    required String startPointName,
    required String selectedLimit,
    required String selectedGender,
    required String myID,
  }) async {
    DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    int dateAsInt = combinedDateTime.millisecondsSinceEpoch;

    try {
      CollectionReference users = _firestore.collection('carpool');
      GeoPoint geoStart = GeoPoint(startPoint.latitude, startPoint.longitude);
      GeoPoint geoEnd = GeoPoint(endPoint.latitude, endPoint.longitude);
      List<String> hobbies = [myID];

      DocumentReference carpoolDocRef = await users.add({
        'admin': myID,
        'endPointName': endPointName,
        'endPoint': geoEnd,
        'startPointName': startPointName,
        'startPoint': geoStart,
        'maxMember': selectedLimit.replaceAll(RegExp(r'[^\d]'), ''),
        'gender': selectedGender,
        'startTime': dateAsInt,
        'nowMember': 1,
        'status': false,
        'members': hobbies,
      });

      CollectionReference membersCollection =
          carpoolDocRef.collection('messages');
      await membersCollection.add({
        'memberID': myID,
        'joinedDate': DateTime.now(),
      });

      print('Data added to Firestore.');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
}

