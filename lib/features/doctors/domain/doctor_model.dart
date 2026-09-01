class DoctorModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String? email;
  final String bmdcRegNumber;
  final List<String> specialties;
  final List<String> qualifications;
  final int experienceYears;
  final String? bio;
  final String? avatarUrl;
  final double consultationFee;
  final bool isVerified;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final int totalConsultations;
  final List<String> hospitalAffiliations;
  final List<String> languages;
  final List<String> availableDays;

  const DoctorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.email,
    required this.bmdcRegNumber,
    this.specialties = const [],
    this.qualifications = const [],
    this.experienceYears = 0,
    this.bio,
    this.avatarUrl,
    this.consultationFee = 0.0,
    this.isVerified = false,
    this.isActive = false,
    this.rating = 5.0,
    this.totalReviews = 0,
    this.totalConsultations = 0,
    this.hospitalAffiliations = const [],
    this.languages = const ['English', 'Bengali'],
    this.availableDays = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      bmdcRegNumber: json['bmdc_reg_number'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      qualifications: (json['qualifications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      experienceYears: json['experience_years'] as int? ?? 0,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalConsultations: json['total_consultations'] as int? ?? 0,
      hospitalAffiliations: (json['hospital_affiliations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['English', 'Bengali'],
      availableDays: (json['available_days'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'bmdc_reg_number': bmdcRegNumber,
      'specialties': specialties,
      'qualifications': qualifications,
      'experience_years': experienceYears,
      'bio': bio,
      'avatar_url': avatarUrl,
      'consultation_fee': consultationFee,
      'is_verified': isVerified,
      'is_active': isActive,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_consultations': totalConsultations,
      'hospital_affiliations': hospitalAffiliations,
      'languages': languages,
      'available_days': availableDays,
    };
  }
}

class DoctorSpecialtyModel {
  final String specialty;
  final int doctorCount;
  final String? iconName;
  final String? description;

  const DoctorSpecialtyModel({
    required this.specialty,
    required this.doctorCount,
    this.iconName,
    this.description,
  });

  factory DoctorSpecialtyModel.fromJson(Map<String, dynamic> json) {
    return DoctorSpecialtyModel(
      specialty: json['specialty'] as String? ?? '',
      doctorCount: json['doctor_count'] as int? ?? 0,
      iconName: json['icon_name'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty': specialty,
      'doctor_count': doctorCount,
      'icon_name': iconName,
      'description': description,
    };
  }
}

class TimeslotModel {
  final String id;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  const TimeslotModel({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory TimeslotModel.fromJson(Map<String, dynamic> json) {
    return TimeslotModel(
      id: json['id'] as String? ?? '',
      doctorId: json['doctor_id'] as String? ?? '',
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'AVAILABLE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status,
    };
  }
}
