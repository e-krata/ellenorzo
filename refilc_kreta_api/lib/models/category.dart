import 'grade.dart';

class Category {
  String id;
  String description;
  String name;

  Category({
    required this.id,
    this.description = '',
    this.name = '',
  });

  factory Category.fromJson(
    Map json,
  ) {
    final description =
        json['Leiras']?.toString() ?? '';

    final name =
        json['Nev']?.toString() ?? '';

    return Category(
      id:
          json['Uid']?.toString() ?? '',
      description:
          description == 'Na'
              ? ''
              : description,
      name:
          name == 'Na'
              ? ''
              : name,
    );
  }

  static GradeType getGradeType(
    String string,
  ) {
    switch (string) {
      case 'evkozi_jegy_ertekeles':
        return GradeType.midYear;

      case 'I_ne_jegy_ertekeles':
        return GradeType.firstQ;

      case 'II_ne_jegy_ertekeles':
        return GradeType.secondQ;

      case 'felevi_jegy_ertekeles':
        return GradeType.halfYear;

      case 'III_ne_jegy_ertekeles':
        return GradeType.thirdQ;

      case 'IV_ne_jegy_ertekeles':
        return GradeType.fourthQ;

      case 'evvegi_jegy_ertekeles':
        return GradeType.endYear;

      case 'osztalyozo_vizsga':
        return GradeType.levelExam;

      default:
        return GradeType.unknown;
    }
  }
}