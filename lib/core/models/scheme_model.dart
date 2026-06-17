class SchemeModel {
  final String name;
  final String department;
  final String description;

  final int minAge;
  final int maxAge;
  final double incomeLimit;
  final List<String> eligibleCategories;
  final List<String> eligibleStates;
  final List<String> eligibleOccupations;
  final List<String> eligibleGenders;
  final List<String> requiredDocuments;

  final DateTime uploadDate;
  final bool isNew;
  final String applyLink;

  SchemeModel({
    required this.name,
    required this.department,
    required this.description,
    required this.minAge,
    required this.maxAge,
    required this.incomeLimit,
    required this.eligibleCategories,
    required this.eligibleStates,
    required this.eligibleOccupations,
    required this.eligibleGenders,
    required this.requiredDocuments,
    required this.uploadDate,
    required this.isNew,
    required this.applyLink,
  });
}
