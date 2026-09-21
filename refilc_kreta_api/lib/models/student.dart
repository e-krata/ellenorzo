import 'school.dart';
import 'package:refilc/utils/format.dart';

class Student {
  Map? json;
  String id;
  String name;
  School school;
  DateTime birth;
  String yearId;
  String? address;
  String? groupId;
  List<String> parents;
  int gradeDelay;
  String? bankAccount;
  String? className;

  Student({
    required this.id,
    required this.name,
    required this.school,
    required this.birth,
    required this.yearId,
    this.address,
    required this.parents,
    required this.gradeDelay,
    this.bankAccount,
    this.json,
  });

  factory Student.fromJson(Map json) {
    final guardians = json['Gondviselok'];

    final parents = <String>[];

    if (guardians is List) {
      for (final guardian in guardians) {
        if (guardian is Map) {
          final name =
              guardian['Nev']?.toString().trim() ?? '';

          if (name.isNotEmpty) {
            parents.add(name);
          }
        }
      }
    }

    final motherName =
        json['AnyjaNeve']?.toString().trim() ?? '';

    if (motherName.isNotEmpty) {
      parents.insert(0, motherName);
    }

    final normalizedParents = parents
        .map((e) => e.capitalize())
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .toList();

    // ----------------------------------------------------------
    // Születési dátum
    // ----------------------------------------------------------

    DateTime birth = DateTime(0);

    final birthDate =
        json['SzuletesiDatum'];

    if (birthDate != null &&
        birthDate.toString().isNotEmpty) {
      birth = DateTime.tryParse(
            birthDate.toString(),
          )?.toLocal() ??
          DateTime(0);
    } else {
      final year =
          _toInt(json['SzuletesiEv']);

      final month =
          _toInt(json['SzuletesiHonap']);

      final day =
          _toInt(json['SzuletesiNap']);

      if (year > 0 &&
          month > 0 &&
          day > 0) {
        birth = DateTime(
          year,
          month,
          day,
        );
      }
    }

    // ----------------------------------------------------------
    // Cím
    // ----------------------------------------------------------

    String? address;

    final addresses =
        json['Cimek'];

    if (addresses is List &&
        addresses.isNotEmpty) {
      final first =
          addresses.first?.toString().trim() ?? '';

      if (first.isNotEmpty) {
        address = first;
      }
    }

    // ----------------------------------------------------------
    // Beállítások
    // ----------------------------------------------------------

    final institute =
        json['Intezmeny'];

    int gradeDelay = 0;

    if (institute is Map) {
      final settings =
          institute['TestreszabasBeallitasok'];

      if (settings is Map) {
        gradeDelay = _toInt(
          settings[
              'ErtekelesekMegjelenitesenekKesleltetesenekMerteke'],
        );
      }
    }

    // ----------------------------------------------------------
    // Bankszámla
    // ----------------------------------------------------------

    String? bankAccount;

    final bank =
        json['Bankszamla'];

    if (bank is Map) {
      final value =
          bank['BankszamlaSzam']
                  ?.toString()
                  .trim() ??
              '';

      if (value.isNotEmpty) {
        bankAccount = value;
      }
    }

    return Student(
      id:
          json['Uid']?.toString() ?? '',
      name: (
        json['Nev'] ??
        json['SzuletesiNev'] ??
        ''
      ).toString().trim(),
      school: School(
        instituteCode:
            json['IntezmenyAzonosito']
                    ?.toString() ??
                '',
        name:
            json['IntezmenyNev']
                    ?.toString()
                    .trim() ??
                '',
        city: _schoolCity(json),
      ),
      birth: birth,
      yearId:
          json['TanevUid']?.toString() ?? '',
      address: address,
      parents: normalizedParents,
      gradeDelay: gradeDelay,
      bankAccount: bankAccount,
      json: json,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static String _schoolCity(
    Map json,
  ) {
    final institute =
        json['Intezmeny'];

    if (institute is Map) {
      return (
        institute['TelepulesNev'] ??
        institute['Varos'] ??
        ''
      ).toString().trim();
    }

    return '';
  }
}