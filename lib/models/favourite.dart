class Favourite {
  final int? id;
  final int makanan_id;

  Favourite({this.id, required this.makanan_id});

  Map<String, dynamic> toMap() => {
        'id': id,
        'makanan_id': makanan_id,
      };

  factory Favourite.fromMap(Map<String, dynamic> map) => Favourite(
        id: map['id'],
        makanan_id: map['makanan_id'],
      );
}