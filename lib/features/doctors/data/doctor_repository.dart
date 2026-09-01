import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/network/api_client.dart';
import 'package:meditouch/features/doctors/domain/doctor_detail_model.dart';
import 'package:meditouch/features/doctors/domain/doctor_model.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DoctorRepository(apiClient);
});

class DoctorRepository {
  final ApiClient _apiClient;

  DoctorRepository(this._apiClient);

  Future<({List<DoctorModel> items, int total, int page, int totalPages})> getDoctors({
    String? search,
    String? specialty,
    double? minFee,
    double? maxFee,
    int? minExperience,
    double? minRating,
    String? sortBy = 'rating_desc',
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
    };
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (specialty != null && specialty.trim().isNotEmpty && specialty.toUpperCase() != 'ALL') {
      query['specialty'] = specialty.trim();
    }
    if (minFee != null) query['min_fee'] = minFee;
    if (maxFee != null) query['max_fee'] = maxFee;
    if (minExperience != null) query['min_experience'] = minExperience;
    if (minRating != null) query['min_rating'] = minRating;

    final response = await _apiClient.get(
      ApiEndpoints.doctors,
      queryParameters: query,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final itemsList = (data['items'] as List<dynamic>?)
            ?.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return (
      items: itemsList,
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
    );
  }

  Future<List<DoctorSpecialtyModel>> getSpecialties() async {
    final response = await _apiClient.get(ApiEndpoints.doctorSpecialties);
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => DoctorSpecialtyModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DoctorModel>> getFeaturedDoctors({int limit = 10}) async {
    final response = await _apiClient.get(
      ApiEndpoints.featuredDoctors,
      queryParameters: {'limit': limit},
    );
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => DoctorModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DoctorDetailModel> getDoctorDetail(String doctorId) async {
    final response = await _apiClient.get(ApiEndpoints.doctorDetails(doctorId));
    final data = response.data['data'] as Map<String, dynamic>;
    return DoctorDetailModel.fromJson(data);
  }

  Future<List<TimeslotModel>> getDoctorTimeslots(String doctorId) async {
    final response = await _apiClient.get(ApiEndpoints.doctorAvailableTimeslots(doctorId));
    final list = response.data['data'] as List<dynamic>;
    return list.map((e) => TimeslotModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
