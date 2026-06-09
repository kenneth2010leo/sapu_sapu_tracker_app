class User {
  final String userId;
  final String nama;
  final String email;
  final String role;

  User({
    required this.userId,
    required this.nama,
    required this.email,
    this.role = 'user',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nama': nama,
      'email': email,
      'role': role,
    };
  }
}