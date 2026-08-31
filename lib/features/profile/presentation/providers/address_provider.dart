import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/features/profile/data/address_repository.dart';
import 'package:meditouch/features/profile/domain/address_model.dart';

final savedAddressesProvider = StateNotifierProvider<AddressNotifier, AsyncValue<List<AddressModel>>>((ref) {
  final repo = ref.watch(addressRepositoryProvider);
  return AddressNotifier(repo);
});

class AddressNotifier extends StateNotifier<AsyncValue<List<AddressModel>>> {
  final AddressRepository _repo;

  AddressNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getSavedAddresses();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAddress(AddressModel address) async {
    try {
      final updated = await _repo.addAddress(address);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final updated = await _repo.deleteAddress(id);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
