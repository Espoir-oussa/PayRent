import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'complaint_detail_state.dart';

class ComplaintDetailController extends StateNotifier<ComplaintDetailState> {
  ComplaintDetailController() : super(ComplaintDetailState());

  void loadComplaint(int complaintId) {
    state = state.copyWith(status: ComplaintDetailStatus.loading);
    try {
      // Mock data
      final complaint = ComplaintDetail(
        id: complaintId,
        subject: 'Chauffage defaillant',
        description:
            'Le chauffage ne fonctionne plus depuis 3 jours. Il fait tres froid dans l\'appartement.',
        status: 'Ouverte',
        createdAt: DateTime(2024, 11, 15),
        propertyId: 1,
      );
      state = state.copyWith(
        status: ComplaintDetailStatus.success,
        complaint: complaint,
      );
    } catch (e) {
      state = state.copyWith(
        status: ComplaintDetailStatus.failure,
        error: e.toString(),
      );
    }
  }
}
