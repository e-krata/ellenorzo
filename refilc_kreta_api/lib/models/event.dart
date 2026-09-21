class Event {
  Map? json;
  String id;
  DateTime start;
  DateTime end;
  String title;
  String content;

  Event({
    required this.id,
    required this.start,
    required this.end,
    this.title = '',
    this.content = '',
    this.json,
  });

  factory Event.fromJson(
    Map json,
  ) {
    return Event(
      id:
          json['Uid']?.toString() ?? '',
      start:
          _date(
        json['ErvenyessegKezdete'] ??
            json['Kezdet'],
      ),
      end:
          _date(
        json['ErvenyessegVege'] ??
            json['Veg'],
      ),
      title: (
        json['Cim'] ??
        json['Nev'] ??
        ''
      ).toString(),
      content: (
        json['Tartalom'] ??
        json['Szoveg'] ??
        ''
      ).toString().replaceAll(
            '\r',
            '',
          ),
      json: json,
    );
  }

  static DateTime _date(
    dynamic value,
  ) {
    if (value == null ||
        value.toString().isEmpty) {
      return DateTime(0);
    }

    return DateTime.tryParse(
          value.toString(),
        )?.toLocal() ??
        DateTime(0);
  }
}