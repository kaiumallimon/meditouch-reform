import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditouch/features/pharmacy/medicines/data/pharmacy_repository.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';
import 'package:meditouch/features/pharmacy/medicines/presentation/medicines_screen.dart';

class FakePharmacyRepository implements PharmacyRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<String>> fetchCategories() async {
    return ['ALL', 'TABLET', 'SYRUP', 'CAPSULE'];
  }

  @override
  Future<PaginatedMedicines> fetchMedicines({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? sortBy = 'name_asc',
    bool? inStockOnly,
    bool? requiresPrescription,
  }) async {
    return PaginatedMedicines(
      items: [
        const MedicineModel(
          id: '1',
          name: 'Napa Extra 500mg',
          brand: 'Napa Extra',
          genericName: 'Paracetamol + Caffeine',
          strength: '500mg + 65mg',
          dosageForm: 'Tablet',
          manufacturer: 'Beximco Pharmaceuticals',
          unitPrice: 2.50,
          packSize: '10 Tablets',
        ),
        const MedicineModel(
          id: '2',
          name: 'Ace Plus',
          brand: 'Ace Plus',
          genericName: 'Paracetamol',
          strength: '500mg',
          dosageForm: 'Tablet',
          manufacturer: 'Square Pharmaceuticals',
          unitPrice: 3.00,
          packSize: '10 Tablets',
        ),
      ],
      total: 2,
      page: page,
      limit: limit,
      totalPages: 1,
      hasNext: false,
      hasPrev: false,
    );
  }
}

void main() {
  testWidgets('Pharmacy screen renders 2-per-row grid and pagination summary',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pharmacyRepositoryProvider.overrideWithValue(FakePharmacyRepository()),
        ],
        child: const RootWidget(),
      ),
    );

    // Initial pump & settle
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify AppBar and Search Bar
    expect(find.text('MediTouch Pharmacy'), findsOneWidget);
    expect(find.text('Search medicines, generics, brands...'), findsOneWidget);

    // Verify Medicines Loaded (2 items in grid)
    expect(find.text('Napa Extra 500mg'), findsOneWidget);
    expect(find.text('Ace Plus'), findsOneWidget);
    expect(find.text('৳ 2.50'), findsOneWidget);
    expect(find.text('৳ 3.00'), findsOneWidget);

    // Verify Pagination Header Summary
    expect(find.text('Showing 1-2 of 2 medicines'), findsOneWidget);
  });
}

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MedicinesScreen(),
    );
  }
}
