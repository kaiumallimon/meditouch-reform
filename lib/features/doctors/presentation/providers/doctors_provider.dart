import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/features/doctors/data/doctor_repository.dart';
import 'package:meditouch/features/doctors/domain/doctor_model.dart';

class DoctorsState {
  final List<DoctorModel> doctors;
  final List<DoctorSpecialtyModel> specialties;
  final List<DoctorModel> featuredDoctors;
  final bool isLoading;
  final bool isLoadingSpecialties;
  final bool isLoadingFeatured;
  final String? errorMessage;
  final String? selectedSpecialty;
  final String searchQuery;
  final double? minFee;
  final double? maxFee;
  final int? minExperience;
  final double? minRating;
  final String sortBy;
  final int page;
  final int totalPages;
  final int total;

  const DoctorsState({
    this.doctors = const [],
    this.specialties = const [],
    this.featuredDoctors = const [],
    this.isLoading = false,
    this.isLoadingSpecialties = false,
    this.isLoadingFeatured = false,
    this.errorMessage,
    this.selectedSpecialty,
    this.searchQuery = '',
    this.minFee,
    this.maxFee,
    this.minExperience,
    this.minRating,
    this.sortBy = 'rating_desc',
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
  });

  bool get hasActiveFilters =>
      (selectedSpecialty != null && selectedSpecialty!.isNotEmpty && selectedSpecialty != 'All') ||
      minFee != null ||
      maxFee != null ||
      minExperience != null ||
      minRating != null ||
      sortBy != 'rating_desc';

  DoctorsState copyWith({
    List<DoctorModel>? doctors,
    List<DoctorSpecialtyModel>? specialties,
    List<DoctorModel>? featuredDoctors,
    bool? isLoading,
    bool? isLoadingSpecialties,
    bool? isLoadingFeatured,
    String? errorMessage,
    String? selectedSpecialty,
    bool clearSpecialty = false,
    String? searchQuery,
    double? minFee,
    bool clearMinFee = false,
    double? maxFee,
    bool clearMaxFee = false,
    int? minExperience,
    bool clearMinExperience = false,
    double? minRating,
    bool clearMinRating = false,
    String? sortBy,
    int? page,
    int? totalPages,
    int? total,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      specialties: specialties ?? this.specialties,
      featuredDoctors: featuredDoctors ?? this.featuredDoctors,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSpecialties: isLoadingSpecialties ?? this.isLoadingSpecialties,
      isLoadingFeatured: isLoadingFeatured ?? this.isLoadingFeatured,
      errorMessage: errorMessage,
      selectedSpecialty: clearSpecialty ? null : (selectedSpecialty ?? this.selectedSpecialty),
      searchQuery: searchQuery ?? this.searchQuery,
      minFee: clearMinFee ? null : (minFee ?? this.minFee),
      maxFee: clearMaxFee ? null : (maxFee ?? this.maxFee),
      minExperience: clearMinExperience ? null : (minExperience ?? this.minExperience),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
    );
  }
}

final doctorsProvider = StateNotifierProvider<DoctorsNotifier, DoctorsState>((ref) {
  final repo = ref.watch(doctorRepositoryProvider);
  return DoctorsNotifier(repo);
});

class DoctorsNotifier extends StateNotifier<DoctorsState> {
  final DoctorRepository _repo;
  Timer? _debounceTimer;

  DoctorsNotifier(this._repo) : super(const DoctorsState()) {
    init();
  }

  Future<void> init() async {
    await Future.wait([
      loadSpecialties(),
      loadFeaturedDoctors(),
      loadDoctors(),
    ]);
  }

  Future<void> loadSpecialties() async {
    state = state.copyWith(isLoadingSpecialties: true);
    try {
      final list = await _repo.getSpecialties();
      state = state.copyWith(specialties: list, isLoadingSpecialties: false);
    } catch (_) {
      state = state.copyWith(isLoadingSpecialties: false);
    }
  }

  Future<void> loadFeaturedDoctors() async {
    state = state.copyWith(isLoadingFeatured: true);
    try {
      final list = await _repo.getFeaturedDoctors(limit: 6);
      state = state.copyWith(featuredDoctors: list, isLoadingFeatured: false);
    } catch (_) {
      state = state.copyWith(isLoadingFeatured: false);
    }
  }

  Future<void> loadDoctors({int? page}) async {
    final targetPage = page ?? state.page;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _repo.getDoctors(
        search: state.searchQuery,
        specialty: state.selectedSpecialty,
        minFee: state.minFee,
        maxFee: state.maxFee,
        minExperience: state.minExperience,
        minRating: state.minRating,
        sortBy: state.sortBy,
        page: targetPage,
        limit: 20,
      );

      state = state.copyWith(
        doctors: result.items,
        total: result.total,
        page: result.page,
        totalPages: result.totalPages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      state = state.copyWith(searchQuery: query, page: 1);
      loadDoctors(page: 1);
    });
  }

  void selectSpecialty(String? specialty) {
    final next = (state.selectedSpecialty == specialty || specialty == 'All') ? null : specialty;
    state = state.copyWith(
      selectedSpecialty: next,
      clearSpecialty: next == null,
      page: 1,
    );
    loadDoctors(page: 1);
  }

  void setSortBy(String sortBy) {
    if (state.sortBy == sortBy) return;
    state = state.copyWith(sortBy: sortBy, page: 1);
    loadDoctors(page: 1);
  }

  void applyAdvancedFilters({
    double? minFee,
    double? maxFee,
    int? minExperience,
    double? minRating,
    String? sortBy,
  }) {
    state = state.copyWith(
      minFee: minFee,
      clearMinFee: minFee == null,
      maxFee: maxFee,
      clearMaxFee: maxFee == null,
      minExperience: minExperience,
      clearMinExperience: minExperience == null,
      minRating: minRating,
      clearMinRating: minRating == null,
      sortBy: sortBy ?? state.sortBy,
      page: 1,
    );
    loadDoctors(page: 1);
  }

  void resetFilters() {
    state = state.copyWith(
      clearSpecialty: true,
      clearMinFee: true,
      clearMaxFee: true,
      clearMinExperience: true,
      clearMinRating: true,
      sortBy: 'rating_desc',
      page: 1,
    );
    loadDoctors(page: 1);
  }

  void goToPage(int page) {
    if (page < 1 || page > state.totalPages || page == state.page) return;
    loadDoctors(page: page);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
