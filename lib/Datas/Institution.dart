class Institution {
  int id;
  String name;
  String code;
  String url;
  String city;

  Institution(
    this.id,
    this.name,
    this.code,
    this.url,
    this.city,
  );

  Institution.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return;
    }

    id = _intValue(
      json["id"] ??
          json["Id"] ??
          json["InstituteId"],
    );

    name = _stringValue(
      json["name"] ??
          json["Name"] ??
          json["IntezmenyNev"],
    );

    code = _stringValue(
      json["code"] ??
          json["Code"] ??
          json["InstituteCode"] ??
          json["IntezmenyAzonosito"],
    );

    url = _stringValue(
      json["url"] ??
          json["Url"],
    );

    city = _stringValue(
      json["city"] ??
          json["City"] ??
          json["Varos"] ??
          json["Telepules"],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "code": code,
      "url": url,
      "city": city,
    };
  }

  static int _intValue(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static String _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    return value.toString();
  }
}