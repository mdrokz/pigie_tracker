// To parse this JSON data, do
//
//     final pigie = pigieFromJson(jsonString);

import 'dart:convert';

List<History> historyFromJson(String str) => List<History>.from(json.decode(str).map((x) => History.fromJson(x)));

String historyToJson(List<History> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

Status getStatusFromString(String statusAsString) {
  for (Status element in Status.values) {
    if (element.toString() == statusAsString) {
      return element;
    }
  }
  return null;
}

Time getTimeFromString(String timeAsString) {
  for (Time element in Time.values) {
    if (element.toString() == timeAsString) {
      return element;
    }
  }
  return null;
}

enum Time {
  Day,
  Night
}

enum Status {
  Present,
  Unknown
}

class History {
  History({
    this.date,
    this.time,
    this.pigeons,
  });

  DateTime date;
  Time time;
  List<Pigeon> pigeons;

  factory History.fromJson(Map<String, dynamic> json) => History(
    date: DateTime.parse(json["date"]),
    time: getTimeFromString(json["time"]),
    pigeons: List<Pigeon>.from(json["pigeons"].map((x) => Pigeon.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date": date.toIso8601String(),
    "time": time.toString(),
    "pigeons": List<dynamic>.from(pigeons.map((x) => x.toJson())),
  };
}
class Pigeon {
  Pigeon({
    this.name,
    this.status,
  });

  String name;
  Status status;

  factory Pigeon.fromJson(Map<String, dynamic> json) => Pigeon(
    name: json["name"],
    status: getStatusFromString(json["status"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "status": status.toString(),
  };
}
