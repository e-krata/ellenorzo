class School {
  String instituteCode;
  String name;
  String city;

  School({
    required this.instituteCode,
    required this.name,
    required this.city,
  });

  factory School.fromJson(Map json) {
    return School(
      instituteCode: (
        json['instituteCode'] ??
        json['IntezmenyAzonosito'] ??
        json['Kod'] ??
        ''
      ).toString(),
      name: (
        json['name'] ??
        json['IntezmenyNev'] ??
        json['Nev'] ??
        ''
      ).toString().trim(),
      city: (
        json['city'] ??
        json['TelepulesNev'] ??
        json['Varos'] ??
        ''
      ).toString().trim(),
    );
  }
}