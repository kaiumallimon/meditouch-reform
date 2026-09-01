import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/features/doctors/data/doctor_repository.dart';
import 'package:meditouch/features/doctors/domain/doctor_detail_model.dart';
import 'package:meditouch/features/doctors/domain/doctor_model.dart';

class DoctorDetailState {
  final DoctorDetailModel? doctor;
  final TimeslotModel? selectedTimeslot;
  final DateTime selectedDate;
  final bool isLoading;
  final String? errorMessage;

  DoctorDetailState({
    this.doctor,
    this.selectedTimeslot,
    DateTime? selectedDate,
    this.isLoading = false,
    this.errorMessage,
  }) : selectedDate = selectedDate ?? DateTime.now();

  DoctorDetailState copyWith({
    DoctorDetailModel? doctor,
    TimeslotModel? selectedTimeslot,
    bool clearTimeslot = false,
    DateTime? selectedDate,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DoctorDetailState(
      doctor: doctor ?? this.doctor,
      selectedTimeslot: clearTimeslot ? null : (selectedTimeslot ?? this.selectedTimeslot),
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final doctorDetailProvider = StateNotifierProvider.family<DoctorDetailNotifier, DoctorDetailState, String>(
  (ref, doctorId) {
    final repo = ref.watch(doctorRepositoryProvider);
    return DoctorDetailNotifier(repo, doctorId);
  },
);

class DoctorDetailNotifier extends StateNotifier<DoctorDetailState> {
  final DoctorRepository _repo;
  final String doctorId;

  DoctorDetailNotifier(this._repo, this.doctorId) : super(DoctorDetailState()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final doc = await _repo.getDoctorDetail(doctorId);
      final firstSlot = doc.upcomingTimeslots.isNotEmpty ? doc.upcomingTimeslots.first : null;
      state = state.copyWith(
        doctor: doc,
        selectedTimeslot: firstSlot,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void selectTimeslot(TimeslotModel slot) {
    state = state.copyWith(selectedTimeslot: slot);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date, clearTimeslot: true);
  }
}
