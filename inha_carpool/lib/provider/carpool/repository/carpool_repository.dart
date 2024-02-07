
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';

final carpoolRepositoryProvider = Provider((ref) => CarpoolRepository(ref));

class CarpoolRepository {
  Ref ref;
  final _fireStore = FirebaseFirestore.instance;

  CarpoolRepository(this.ref);











}