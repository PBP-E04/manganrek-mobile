// To parse this JSON data, do
//
//     final makanan = makananFromJson(jsonString);

import 'dart:convert';

List<Makanan> makananFromJson(String str) => List<Makanan>.from(json.decode(str).map((x) => Makanan.fromJson(x)));

String makananToJson(List<Makanan> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Makanan {
    String model;
    String pk;
    Fields fields;

    Makanan({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Makanan.fromJson(Map<String, dynamic> json) => Makanan(
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
    String idRumahMakan;
    String namaMakanan;
    int harga;

    Fields({
        required this.idRumahMakan,
        required this.namaMakanan,
        required this.harga,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        idRumahMakan: json["id_rumah_makan"],
        namaMakanan: json["nama_makanan"],
        harga: json["harga"],
    );

    Map<String, dynamic> toJson() => {
        "id_rumah_makan": idRumahMakan,
        "nama_makanan": namaMakanan,
        "harga": harga,
    };
}
