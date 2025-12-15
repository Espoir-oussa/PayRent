enum ComplaintDetailStatus { initial, loading, success, failure }

class ComplaintDetail {
  final int id;
  final String subject;
  final String description;
  final String status;
  final DateTime createdAt;
  final int propertyId;

  ComplaintDetail({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.propertyId,
  });
}

class ComplaintDetailState {
  final ComplaintDetailStatus status;
  final ComplaintDetail? complaint;
  final String? error;

  ComplaintDetailState({
    this.status = ComplaintDetailStatus.initial,
    this.complaint,
    this.error,
  });

  ComplaintDetailState copyWith({
    ComplaintDetailStatus? status,
    ComplaintDetail? complaint,
    String? error,
  }) {
    return ComplaintDetailState(
      status: status ?? this.status,
      complaint: complaint ?? this.complaint,
      error: error ?? this.error,
    );
  }
}
