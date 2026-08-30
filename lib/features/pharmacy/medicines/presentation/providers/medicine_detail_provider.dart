import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/features/pharmacy/medicines/data/pharmacy_repository.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_detail_model.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';

class MedicineDetailState {
  final bool isLoading;
  final MedicineDetailModel? medicine;
  final int selectedPackIndex;
  final String activeSectionId;
  final int quantity;
  final String? errorMessage;

  const MedicineDetailState({
    this.isLoading = true,
    this.medicine,
    this.selectedPackIndex = 0,
    this.activeSectionId = 'indications',
    this.quantity = 1,
    this.errorMessage,
  });

  MedicineDetailState copyWith({
    bool? isLoading,
    MedicineDetailModel? medicine,
    int? selectedPackIndex,
    String? activeSectionId,
    int? quantity,
    String? errorMessage,
  }) {
    return MedicineDetailState(
      isLoading: isLoading ?? this.isLoading,
      medicine: medicine ?? this.medicine,
      selectedPackIndex: selectedPackIndex ?? this.selectedPackIndex,
      activeSectionId: activeSectionId ?? this.activeSectionId,
      quantity: quantity ?? this.quantity,
      errorMessage: errorMessage,
    );
  }

  UnitPriceModel? get activePack {
    if (medicine == null || medicine!.unitPrices.isEmpty) return null;
    if (selectedPackIndex >= 0 && selectedPackIndex < medicine!.unitPrices.length) {
      return medicine!.unitPrices[selectedPackIndex];
    }
    return medicine!.unitPrices.first;
  }

  double get activePrice {
    final pack = activePack;
    if (pack != null) return pack.price;
    return medicine?.unitPrice ?? 0.0;
  }

  String get activeUnitLabel {
    final pack = activePack;
    if (pack != null) return pack.unit;
    return medicine?.packSize ?? '1 Unit';
  }
}

final medicineDetailProvider = StateNotifierProvider.autoDispose
    .family<MedicineDetailNotifier, MedicineDetailState, String>((ref, slug) {
  final repository = ref.watch(pharmacyRepositoryProvider);
  return MedicineDetailNotifier(repository, slug);
});

class MedicineDetailNotifier extends StateNotifier<MedicineDetailState> {
  final PharmacyRepository _repository;
  final String slug;

  MedicineDetailNotifier(this._repository, this.slug)
      : super(const MedicineDetailState()) {
    loadDetails();
  }

  Future<void> loadDetails({MedicineModel? initialMedicine}) async {
    if (initialMedicine != null) {
      // Immediate optimistic render from list card
      final optimisticModel = MedicineDetailModel(
        id: initialMedicine.id,
        slug: initialMedicine.slug ?? initialMedicine.id,
        medicineName: initialMedicine.name,
        genericName: initialMedicine.genericName ?? '',
        categoryName: initialMedicine.categoryName,
        manufacturerName: initialMedicine.manufacturer,
        strength: initialMedicine.strength,
        dosageForm: initialMedicine.dosageForm,
        image: initialMedicine.image,
        unitPrice: initialMedicine.unitPrice,
        packSize: initialMedicine.packSize,
        rxRequired: initialMedicine.rxRequired,
        inStock: initialMedicine.inStock,
      );
      state = state.copyWith(medicine: optimisticModel, isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final detail = await _repository.fetchMedicineDetails(slug);
      final initialSec = detail.sections.isNotEmpty
          ? detail.sections.first.id
          : 'indications';

      state = state.copyWith(
        isLoading: false,
        medicine: detail,
        activeSectionId: initialSec,
        errorMessage: null,
      );
    } catch (e) {
      if (state.medicine == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load medicine details. Please try again.',
        );
      } else {
        // We already had optimistic data, just finish loading
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void setSelectedPackIndex(int index) {
    state = state.copyWith(selectedPackIndex: index);
  }

  void setActiveSection(String sectionId) {
    state = state.copyWith(activeSectionId: sectionId);
  }

  void setQuantity(int q) {
    if (q >= 1) {
      state = state.copyWith(quantity: q);
    }
  }

  void incrementQuantity() {
    state = state.copyWith(quantity: state.quantity + 1);
  }

  void decrementQuantity() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }
}
