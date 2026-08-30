import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/features/pharmacy/medicines/data/pharmacy_repository.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';

class PharmacyState {
  final List<MedicineModel> medicines;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;
  final String searchQuery;
  final String selectedCategory;
  final String sortBy;
  final bool inStockOnly;
  final String rxFilter; // 'ALL', 'OTC', 'RX'
  final List<String> categories;

  const PharmacyState({
    this.medicines = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.limit = 20,
    this.searchQuery = '',
    this.selectedCategory = 'ALL',
    this.sortBy = 'name_asc',
    this.inStockOnly = false,
    this.rxFilter = 'ALL',
    this.categories = const [
      'ALL',
      'TABLET',
      'SYRUP',
      'CAPSULE',
      'INJECTION',
      'DROP',
      'OINTMENT',
      'SUSPENSION',
    ],
  });

  PharmacyState copyWith({
    List<MedicineModel>? medicines,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? limit,
    String? searchQuery,
    String? selectedCategory,
    String? sortBy,
    bool? inStockOnly,
    String? rxFilter,
    List<String>? categories,
  }) {
    return PharmacyState(
      medicines: medicines ?? this.medicines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      limit: limit ?? this.limit,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      rxFilter: rxFilter ?? this.rxFilter,
      categories: categories ?? this.categories,
    );
  }
}

final pharmacyProvider =
    StateNotifierProvider<PharmacyNotifier, PharmacyState>((ref) {
  final repository = ref.watch(pharmacyRepositoryProvider);
  return PharmacyNotifier(repository);
});

class PharmacyNotifier extends StateNotifier<PharmacyState> {
  final PharmacyRepository _repository;
  Timer? _debounceTimer;

  PharmacyNotifier(this._repository) : super(const PharmacyState()) {
    loadMedicines();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repository.fetchCategories();
      if (cats.isNotEmpty) {
        final list = ['ALL', ...cats.where((c) => c.toUpperCase() != 'ALL')];
        state = state.copyWith(categories: list);
      }
    } catch (_) {}
  }

  Future<void> loadMedicines({int? page}) async {
    final targetPage = page ?? state.currentPage;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      bool? rxParam;
      if (state.rxFilter == 'OTC') rxParam = false;
      if (state.rxFilter == 'RX') rxParam = true;

      final result = await _repository.fetchMedicines(
        page: targetPage,
        limit: state.limit,
        search: state.searchQuery,
        category: state.selectedCategory,
        sortBy: state.sortBy,
        inStockOnly: state.inStockOnly ? true : null,
        requiresPrescription: rxParam,
      );

      state = state.copyWith(
        medicines: result.items,
        isLoading: false,
        currentPage: result.page,
        totalPages: result.totalPages > 0 ? result.totalPages : 1,
        totalItems: result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load medicines: ${e.toString()}',
      );
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      state = state.copyWith(searchQuery: query, currentPage: 1);
      loadMedicines(page: 1);
    });
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category, currentPage: 1);
    loadMedicines(page: 1);
  }

  void setSortBy(String sortBy) {
    if (state.sortBy == sortBy) return;
    state = state.copyWith(sortBy: sortBy, currentPage: 1);
    loadMedicines(page: 1);
  }

  void setRxFilter(String filter) {
    if (state.rxFilter == filter) return;
    state = state.copyWith(rxFilter: filter, currentPage: 1);
    loadMedicines(page: 1);
  }

  void goToPage(int page) {
    if (page < 1 || page > state.totalPages || page == state.currentPage) return;
    loadMedicines(page: page);
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      goToPage(state.currentPage + 1);
    }
  }

  void prevPage() {
    if (state.currentPage > 1) {
      goToPage(state.currentPage - 1);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
