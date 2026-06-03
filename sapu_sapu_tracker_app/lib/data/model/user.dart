class User {
  final String userId;
  final String nama;
  final String email;

  User({required this.userId, required this.nama, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nama': nama,
      'email': email,
    };
  }
}