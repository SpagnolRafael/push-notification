class DemandDto {
  final String id;
  bool viewed;
  DemandDto({required this.id, required this.viewed});

  static DemandDto fromJson(Map<String, dynamic> json) =>
      DemandDto(id: json['id'], viewed: json['viewed']);
}
