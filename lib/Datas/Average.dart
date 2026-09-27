import 'User.dart';

class Average {
  String subject;
  String subjectCategory;
  String subjectCategoryName;

  double value;
  double classValue;
  double difference;

  User owner;

  Average({
    this.subject = '',
    this.subjectCategory = '',
    this.subjectCategoryName = '',
    this.value = 0.0,
    this.classValue = 0.0,
    this.difference = 0.0,
    this.owner,
  });

  // ============================================================
  // JSON -> MODEL
  // ============================================================

  static Average fromJson(
    Map<String, dynamic> json, [
    User owner,
  ]) {
    if (json == null) {
      return Average(
        owner: owner,
      );
    }

    final Average result = Average(
      owner: owner,
    );

    result.subject = _stringValue(
      json['Subject'],
      _stringValue(
        json['Tantargy'],
        _stringValue(
          json['TantargyNeve'],
        ),
      ),
    );

    result.subjectCategory = _categoryUid(
      json['SubjectCategory'],
      json['Tantargy'],
    );

    result.subjectCategoryName =
        _categoryName(
      json['SubjectCategoryName'],
      json['Tantargy'],
    );

    result.value = _doubleValue(
      json['Value'],
      _doubleValue(
        json['Atlag'],
        _doubleValue(
          json['Average'],
        ),
      ),
    );

    result.classValue = _doubleValue(
      json['ClassValue'],
      _doubleValue(
        json['OsztalyAtlag'],
        _doubleValue(
          json['ClassAverage'],
        ),
      ),
    );

    result.difference = _doubleValue(
      json['Difference'],
      result.value - result.classValue,
    );

    if (json['owner'] is Map) {
      result.owner = User.fromJson(
        Map<String, dynamic>.from(
          json['owner'],
        ),
      );
    }

    return result;
  }

  // ============================================================
  // MODEL -> JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'Subject': subject,
      'SubjectCategory': subjectCategory,
      'SubjectCategoryName': subjectCategoryName,
      'Value': value,
      'ClassValue': classValue,
      'Difference': difference,
      'owner': owner?.toMap(),
    };
  }

  // ============================================================
  // SEGÉDEK
  // ============================================================

  static String _stringValue(
    dynamic value, [
    String defaultValue = '',
  ]) {
    if (value == null) {
      return defaultValue;
    }

    return value.toString();
  }

  static double _doubleValue(
    dynamic value, [
    double defaultValue = 0.0,
  ]) {
    if (value == null) {
      return defaultValue;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    final String text = value
        .toString()
        .trim()
        .replaceAll(',', '.');

    return double.tryParse(
          text,
        ) ??
        defaultValue;
  }

  static String _categoryUid(
    dynamic category,
    dynamic subject,
  ) {
    if (category != null &&
        category is! Map) {
      return category.toString();
    }

    if (category is Map) {
      return _stringValue(
        category['Uid'],
        _stringValue(
          category['Id'],
        ),
      );
    }

    if (subject is Map) {
      final dynamic nested =
          subject['Kategoria'];

      if (nested is Map) {
        return _stringValue(
          nested['Uid'],
          _stringValue(
            nested['Id'],
          ),
        );
      }

      if (nested != null) {
        return nested.toString();
      }
    }

    return '';
  }

  static String _categoryName(
    dynamic categoryName,
    dynamic subject,
  ) {
    if (categoryName != null &&
        categoryName is! Map) {
      return categoryName.toString();
    }

    if (categoryName is Map) {
      return _stringValue(
        categoryName['Nev'],
        _stringValue(
          categoryName['Name'],
        ),
      );
    }

    if (subject is Map) {
      final dynamic nested =
          subject['Kategoria'];

      if (nested is Map) {
        return _stringValue(
          nested['Nev'],
          _stringValue(
            nested['Name'],
          ),
        );
      }
    }

    return '';
  }

  @override
  String toString() {
    return 'Average('
        'subject: $subject, '
        'subjectCategory: $subjectCategory, '
        'subjectCategoryName: $subjectCategoryName, '
        'value: $value, '
        'classValue: $classValue, '
        'difference: $difference'
        ')';
  }
}