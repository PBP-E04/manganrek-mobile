// To parse this JSON data, do
//
//     final rumahMakan = rumahMakanFromJson(jsonString);

import 'dart:convert';

List<RumahMakan> rumahMakanFromJson(String str) => List<RumahMakan>.from(json.decode(str).map((x) => RumahMakan.fromJson(x)));

String rumahMakanToJson(List<RumahMakan> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RumahMakan {
    String model;
    String pk;
    Fields fields;

    RumahMakan({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory RumahMakan.fromJson(Map<String, dynamic> json) => RumahMakan(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String nama;
    String alamat;
    int tingkatKepedasan;
    double latitude;
    double longitude;

    Fields({
        required this.nama,
        required this.alamat,
        required this.tingkatKepedasan,
        required this.latitude,
        required this.longitude,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        nama: json["nama"],
        alamat: json["alamat"],
        tingkatKepedasan: json["tingkat_kepedasan"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "nama": nama,
        "alamat": alamat,
        "tingkat_kepedasan": tingkatKepedasan,
        "latitude": latitude,
        "longitude": longitude,
    };
}
