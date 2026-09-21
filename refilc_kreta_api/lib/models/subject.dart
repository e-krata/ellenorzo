import 'package:refilc_kreta_api/models/teacher.dart';

import 'category.dart';

class GradeSubject {
  String id;
  Category category;
  String name;
  String? renamedTo;
  double? customRounding;
  Teacher? teacher;

  bool get isRenamed =>
      renamedTo != null;

  bool get hasCustomRounding =>
      customRounding != null;

  GradeSubject({
    required this.id,
    required this.category,
    required this.name,
    this.renamedTo,
    this.customRounding,
    this.teacher,
  });

  factory GradeSubject.fromJson(
    Map json,
  ) {
    final category =
        json['Kategoria'];

    return GradeSubject(
      id: (
        json['Uid'] ??
        json['TantargyUid'] ??
        ''
      ).toString(),
      category: Category.fromJson(
        category is Map
            ? category
            : {},
      ),
      name: (
        json['Nev'] ??
        json['TantargyNev'] ??
        ''
      ).toString().trim(),
    );
  }

  @override
  bool operator ==(other) {
    if (other is! GradeSubject) {
      return false;
    }

    return id == other.id;
  }

  @override
  int get hashCode =>
      id.hashCode;
}