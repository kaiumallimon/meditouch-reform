class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String? gender;
  final String? bloodGroup;
  final String? defaultAddress;
  final String? postalCode;

  const UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.gender,
    this.bloodGroup,
    this.defaultAddress,
    this.postalCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? 'User',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? json['phone_number']?.toString(),
      role: json['role']?.toString() ?? 'PATIENT',
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString() ?? json['image']?.toString(),
      gender: json['gender']?.toString(),
      bloodGroup: json['blood_group']?.toString() ?? json['bloodGroup']?.toString(),
      defaultAddress: json['default_address']?.toString() ?? json['address']?.toString(),
      postalCode: json['postal_code']?.toString() ?? json['zip_code']?.toString() ?? json['postalCode']?.toString(),
    );
  }

  bool get isGuest =>
      email == 'guest@meditouch.health' ||
      role.toUpperCase() == 'GUEST' ||
      id.startsWith('guest_') ||
      name.toLowerCase().contains('guest');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'gender': gender,
      'blood_group': bloodGroup,
      'default_address': defaultAddress,
      'postal_code': postalCode,
    };
  }
}

