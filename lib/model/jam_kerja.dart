class JamKerja {
  final String masuk, pulang;
  final int weekday;

  JamKerja({required this.weekday, required this.masuk, required this.pulang});

  factory JamKerja.fromJson(Map<String, dynamic> json) {
    return JamKerja(
        weekday: json['weekday'], masuk: json['masuk'], pulang: json['pulang']);
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'masuk': masuk,
      'pulang': pulang,
    };
  }

  @override
  String toString() {
    return "weekday : $weekday, masuk : $masuk, pulang : $pulang";
  }

  String dayName() {
    String name = '';
    switch (weekday) {
      case 1:
        name = 'Senin';
        break;
      case 2:
        name = 'Selasa';
        break;
      case 3:
        name = 'Rabu';
        break;
      case 4:
        name = 'Kamis';
        break;
      case 5:
        name = 'Jum\'at';
        break;
      case 6:
        name = 'Sabtu';
        break;
      case 7:
        name = 'Minggu';
        break;
    }

    return name;
  }
}
