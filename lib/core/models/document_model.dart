class DocumentModel {
  final String type;
  final String filePath;
  final DateTime uploadedAt;

  DocumentModel({
    required this.type,
    required this.filePath,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'filePath': filePath,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        type: json['type'] as String,
        filePath: json['filePath'] as String,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      );
}
