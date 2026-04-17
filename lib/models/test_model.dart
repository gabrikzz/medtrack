class TestModel {
  final String id;
  final String name;
  final DateTime date;
  final String status;
  final Map<String, dynamic> results;

  TestModel({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    required this.results,
  });

  factory TestModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TestModel(
      id: id,
      name: data['name'],
      date: DateTime.parse(data['date']),
      status: data['status'],
      results: data['results'] ?? {},
    );
  }
}