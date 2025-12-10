import '../../data/models/plainte_model.dart';

abstract class PlainteRepository {
  Future<List<PlainteModel>> getOwnerComplaints(int ownerId);
  Future<void> updateComplaintStatus(int complaintId, String newStatus);
}
