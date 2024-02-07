
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carpoolRepositoryProvider = Provider((ref) => CarpoolRepository(ref));

class CarpoolRepository {
  Ref ref;

  CarpoolRepository(this.ref);


}