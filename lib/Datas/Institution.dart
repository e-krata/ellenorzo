class Institution {
  int id;
  String name;
  String code;
  String url;
  String city;

  // Az új API string alapú azonosítója.
  String uid;

  // Az intézmény rövid neve.
  String shortName;

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

    /*
     * Új API:
     *
     * {
     *   "Uid": "dae0004",
     *   "Kod": "dae0004",
     *   "Nev": "SuliKód Gimnázium",
     *   "RovidNev": "SuliKód",
     *   "Varos": "Kisvárda"
     * }
     *
     * A régi mezőneveket is megtartjuk,
     * hogy a korábban mentett adatokkal
     * továbbra is működjön.
     */

    uid = _stringValue(
      json["Uid"] ??
          json["uid"] ??
          json["InstituteUid"],
    );

    id = _intValue(
      json["id"] ??
          json["Id"] ??
          json["InstituteId"],
    );

    name = _stringValue(
      json["Nev"] ??
          json["nev"] ??
          json["name"] ??
          json["Name"] ??
          json["IntezmenyNev"],
    );

    shortName = _stringValue(
      json["RovidNev"] ??
          json["rovidNev"] ??
          json["shortName"] ??
          json["ShortName"],
    );

    code = _stringValue(
      json["Kod"] ??
          json["kod"] ??
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
      json["Varos"] ??
          json["varos"] ??
          json["city"] ??
          json["City"] ??
          json["Telepules"],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "uid": uid,
      "name": name,
      "shortName": shortName,
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