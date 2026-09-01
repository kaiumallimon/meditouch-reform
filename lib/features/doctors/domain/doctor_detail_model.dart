import 'package:meditouch/features/doctors/domain/doctor_model.dart';

class DoctorDetailModel extends DoctorModel {
  final DateTime? nextAvailableSlot;
  final List<TimeslotModel> upcomingTimeslots;

  const DoctorDetailModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.phone,
    super.email,
    required super.bmdcRegNumber,
    super.specialties,
    super.qualifications,
    super.experienceYears,
    super.bio,
    super.avatarUrl,
    super.consultationFee,
    super.isVerified,
    super.isActive,
    super.rating,
    super.totalReviews,
    super.totalConsultations,
    super.hospitalAffiliations,
    super.languages,
    super.availableDays,
    this.nextAvailableSlot,
    this.upcomingTimeslots = const [],
  });

  factory DoctorDetailModel.fromJson(Map<String, dynamic> json) {
    final base = DoctorModel.fromJson(json);
    return DoctorDetailModel(
      id: base.id,
      userId: base.userId,
      name: base.name,
      phone: base.phone,
      email: base.email,
      bmdcRegNumber: base.bmdcRegNumber,
      specialties: base.specialties,
      qualifications: base.qualifications,
      experienceYears: base.experienceYears,
      bio: base.bio,
      avatarUrl: base.avatarUrl,
      consultationFee: base.consultationFee,
      isVerified: base.isVerified,
      isActive: base.isActive,
      rating: base.rating,
      totalReviews: base.totalReviews,
      totalConsultations: base.totalConsultations,
      hospitalAffiliations: base.hospitalAffiliations,
      languages: base.languages,
      availableDays: base.availableDays,
      nextAvailableSlot: json['next_available_slot'] != null
          ? DateTime.tryParse(json['next_available_slot'].toString())?.toLocal()
          : null,
      upcomingTimeslots: (json['upcoming_timeslots'] as List<dynamic>?)
              ?.map((e) => TimeslotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
