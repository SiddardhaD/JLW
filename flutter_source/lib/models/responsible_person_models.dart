class ResponsiblePersonsResponse {
  final List<ResponsiblePerson> persons;
  final String? message;

  const ResponsiblePersonsResponse({required this.persons, this.message});

  factory ResponsiblePersonsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['GetPurchaseOrderResponsiblePerson'];
    final list = raw is List
        ? raw
            .whereType<Map<String, dynamic>>()
            .map(ResponsiblePerson.fromJson)
            .toList()
        : <ResponsiblePerson>[];
    return ResponsiblePersonsResponse(
      persons: list,
      message: json['Message']?.toString(),
    );
  }
}

class ResponsiblePerson {
  final String status;
  final int releasedTime;
  final String? releasedDate;
  final String personResponsible;

  const ResponsiblePerson({
    required this.status,
    required this.releasedTime,
    required this.releasedDate,
    required this.personResponsible,
  });

  factory ResponsiblePerson.fromJson(Map<String, dynamic> json) {
    return ResponsiblePerson(
      status: (json['Status'] ?? '').toString(),
      releasedTime: (json['ReleasedTime'] ?? 0) as int,
      releasedDate: json['ReleasedDate']?.toString(),
      personResponsible: (json['PersonResponsible'] ?? '').toString(),
    );
  }
}
