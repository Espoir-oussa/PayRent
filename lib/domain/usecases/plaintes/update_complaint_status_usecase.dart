import '../../repositories/plainte_repository.dart';

class UpdateComplaintStatusUseCase {
  final PlainteRepository repository;

  UpdateComplaintStatusUseCase(this.repository);

  Future<void> call(int complaintId, String newStatus) async {
    await repository.updateComplaintStatus(complaintId, newStatus);
  }
}
