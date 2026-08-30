import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:meditouch/features/pharmacy/medicines/data/pharmacy_repository.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_detail_model.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';
import 'package:meditouch/features/pharmacy/medicines/presentation/medicine_detail_screen.dart';
import 'package:meditouch/features/pharmacy/medicines/presentation/medicines_screen.dart';

class FakePharmacyRepository implements PharmacyRepository {
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
          id: 'med_1',
          name: 'Napa Extra',
          brand: 'Napa Extra',
          genericName: 'Paracetamol + Caffeine',
          strength: '500mg+65mg',
          dosageForm: 'Tablet',
          categoryName: 'Tablet',
          manufacturer: 'Beximco Pharmaceuticals Ltd',
          unitPrice: 2.50,
          packSize: '1 Strip',
          slug: 'napa-extra-500mg-65mg',
          rxRequired: false,
          inStock: true,
        ),
      ],
      total: 1,
      page: 1,
      limit: 20,
      totalPages: 1,
      hasNext: false,
      hasPrev: false,
    );
  }

  @override
  Future<List<String>> fetchCategories() async {
    return ['ALL', 'TABLET', 'SYRUP'];
  }

  @override
  Future<MedicineDetailModel> fetchMedicineDetails(String slug) async {
    return MedicineDetailModel(
      id: 'med_1',
      slug: 'napa-extra-500mg-65mg',
      medicineName: 'Napa Extra',
      genericName: 'Paracetamol + Caffeine',
      manufacturerName: 'Beximco Pharmaceuticals Ltd',
      strength: '500mg+65mg',
      dosageForm: 'Tablet',
      unitPrice: 2.50,
      packSize: '1 Strip',
      rxRequired: false,
      inStock: true,
      unitPrices: const [
        UnitPriceModel(unit: '1 Strip', unitSize: 10, price: 25.00),
        UnitPriceModel(unit: '1 Box', unitSize: 100, price: 250.00),
      ],
      medicineDetails: const {
        'Indications': 'Napa Extra is indicated for relief of fever, headache, migraine, toothache, and body pain.',
        'Dosage And Administration': '1-2 tablets every 4-6 hours. Maximum 8 tablets in 24 hours.',
        'Pharmacology': 'Paracetamol produces analgesia by elevation of the pain threshold.',
        'Side Effects': 'Side effects are rare and mild.',
        'Faq': 'Q: Can I take this on an empty stomach?\nA: Yes, it can be taken with or without food.',
      },
      sections: [
        const MonographSectionModel(
          id: 'indications',
          label: 'Indications & Uses',
          tag: 'Prescribing Info',
          content: 'Napa Extra is indicated for relief of fever, headache, migraine, toothache, and body pain.',
        ),
        const MonographSectionModel(
          id: 'dosage',
          label: 'Dosage & Administration',
          tag: 'Clinical Dosage',
          content: '1-2 tablets every 4-6 hours. Maximum 8 tablets in 24 hours.',
        ),
        const MonographSectionModel(
          id: 'faq',
          label: 'Frequently Asked Questions',
          tag: 'FAQ',
          content: 'Q: Can I take this on an empty stomach?\nA: Yes, it can be taken with or without food.',
          faqItems: [
            FaqItemModel(
              question: 'Can I take this on an empty stomach?',
              answer: 'Yes, it can be taken with or without food.',
            ),
          ],
        ),
      ],
      relatedMedicines: const [
        MedicineModel(
          id: 'med_alt_1',
          name: 'Ace Plus',
          brand: 'Ace Plus',
          genericName: 'Paracetamol + Caffeine',
          manufacturer: 'Square Pharmaceuticals PLC',
          dosageForm: 'Tablet',
          unitPrice: 2.50,
          packSize: '1 Strip',
          slug: 'ace-plus',
        ),
      ],
    );
  }
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Medicine Detail Model Unit Tests', () {
    test('FaqItemModel parses raw Q&A content correctly', () {
      const rawFaq = '''
      Q: What should I do if I miss a dose?
      A: Take it as soon as you remember, unless it is almost time for your next dose.

      Question 2: Is it safe during pregnancy?
      Answer 2: Consult your physician before taking this medication.
      ''';

      final items = FaqItemModel.parseFaqContent(rawFaq);
      expect(items.length, equals(2));
      expect(items[0].question, equals('What should I do if I miss a dose?'));
      expect(items[0].answer, contains('Take it as soon as you remember'));
      expect(items[1].question, equals('Is it safe during pregnancy?'));
    });

    test('MedicineDetailModel deserializes complete JSON payload', () {
      final json = {
        'id': 'med_123',
        'slug': 'seclo-20mg',
        'medicine_name': 'Seclo',
        'generic_name': 'Omeprazole',
        'manufacturer_name': 'Square Pharmaceuticals PLC',
        'product_info': {
          'strength': '20mg',
          'dosage_form': 'Capsule',
          'unit_price': 6.00,
          'rx_required': false,
          'in_stock': true,
          'unit_prices': [
            {'unit': 'Strip', 'unit_size': 10, 'price': 60.00},
          ],
        },
        'medicine_details': {
          'Indications': 'Treatment of acid reflux and peptic ulcers.',
          'Side Effects': 'Headache, nausea, diarrhea.',
        },
      };

      final model = MedicineDetailModel.fromJson(json);
      expect(model.slug, equals('seclo-20mg'));
      expect(model.medicineName, equals('Seclo'));
      expect(model.genericName, equals('Omeprazole'));
      expect(model.manufacturerName, equals('Square Pharmaceuticals PLC'));
      expect(model.strength, equals('20mg'));
      expect(model.unitPrices.length, equals(1));
      expect(model.sections.length, equals(2));
      expect(model.sections.first.id, equals('indications'));
    });

    test('MedicineDetailModel parses Tufnil with string prices and HTML monograph tags', () {
      final json = {
        'id': 'b2342342-ee3b-49a5-996b-4126f454d9a2',
        'slug': 'tufnil-200-mg-tablet',
        'medicine_name': 'Tufnil',
        'generic_name': 'Tolfenamic acid',
        'category_name': 'Tablet',
        'manufacturer_name': 'Eskayef Bangladesh Ltd.',
        'product_info': {
          'strength': '200 mg',
          'unit_prices': [
            {'unit': "10's Strip", 'unit_size': 10, 'price': '100.00'},
            {'unit': "60's Pack", 'unit_size': 60, 'price': '600.00'},
            {'unit': "150's pack", 'unit_size': 150, 'price': '1500.00'},
          ],
        },
        'medicine_details': {
          'Indications': "<p class='text-gray-800 leading-relaxed'><strong>Tolfenamic acid</strong> is an NSAID of the fenamate class.</p><ul class='list-disc'><li>Acute treatment of migraine attacks</li><li>Mild to moderate pain</li></ul>",
          'Dosage And Administration': "<h2>Acute Migraine Attack</h2><p>200 mg at onset.</p>",
          'Pharmacology': "Inhibits COX-1 and COX-2 enzymes.",
          'Side Effects': "Dyspepsia, nausea, abdominal pain.",
          'Contraindications': "Active gastrointestinal bleeding.",
          'Faq': "<p><strong>Q:</strong> What is Tolfenamic acid used for?</p><p><strong>A:</strong> It is used for acute migraine attacks.</p>",
        },
      };

      final model = MedicineDetailModel.fromJson(json);
      expect(model.slug, equals('tufnil-200-mg-tablet'));
      expect(model.medicineName, equals('Tufnil'));
      expect(model.genericName, equals('Tolfenamic acid'));
      expect(model.manufacturerName, equals('Eskayef Bangladesh Ltd.'));
      expect(model.unitPrices.length, equals(3));
      expect(model.unitPrices[0].price, equals(100.00));
      expect(model.unitPrices[1].price, equals(600.00));
      expect(model.unitPrices[2].price, equals(1500.00));
      expect(model.sections.length, equals(6));
      expect(model.sections.first.content, contains('Tolfenamic acid is an NSAID of the fenamate class'));
      expect(model.sections.first.content, contains('• Acute treatment of migraine attacks'));
    });

    test('MedicineModel extracts price and pack size from unit_prices when unit_price is absent', () {
      final json = {
        'id': 19095,
        'medicine_name': 'Coralcin-DX',
        'category_name': 'Tablet',
        'generic_name': 'Calcium Carbonate + Vitamin D3',
        'manufacturer_name': 'Renata Limited',
        'slug': 'coralcin-dx-tablet',
        'unit_prices': [
          {
            'id': 31149,
            'unit': "30's pack",
            'unit_size': 30,
            'price': 450,
          },
        ],
      };

      final model = MedicineModel.fromJson(json);
      expect(model.name, equals('Coralcin-DX'));
      expect(model.unitPrice, equals(450.0));
      expect(model.packSize, equals("30's pack"));
      expect(model.manufacturer, equals('Renata Limited'));
    });

    test('MedicineDetailModel and MedicineModel resolve manufacturer_name and ignore numeric IDs', () {
      final detailJson = {
        'id': 'med_test_1',
        'slug': '3w-clinic-vita-c',
        'medicine_name': '3W Clinic DR.K Vita-C Whitening Cream 100g',
        'brand': '3W Clinic',
        'generic_name': '',
        'product_info': {
          'manufacturer': 537,
          'unit_price': 950.00,
          'dosage_form': 'Cream',
        },
      };

      final detailModel = MedicineDetailModel.fromJson(detailJson);
      expect(detailModel.manufacturerName, equals('3W Clinic'));

      final medJson = {
        'id': 'med_1',
        'name': '3W Clinic DR.K Vita-C Whitening Cream 100g',
        'brand': '3W Clinic',
        'generic_name': '',
        'manufacturer': 537,
      };
      final medModel = MedicineModel.fromJson(medJson);
      expect(medModel.genericName, isNull);
      expect(medModel.manufacturer, equals('3W Clinic'));
    });
  });

  group('Medicine Detail Screen Widget Tests', () {
    testWidgets('Renders hero product details, price, pack sizes, and clinical sections',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = FakePharmacyRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pharmacyRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: MedicineDetailScreen(slug: 'napa-extra-500mg-65mg'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Hero Information
      expect(find.text('Napa Extra'), findsWidgets);
      expect(find.text('Paracetamol + Caffeine'), findsOneWidget);
      expect(find.text('500mg+65mg'), findsOneWidget);
      expect(find.text('Beximco Pharmaceuticals Ltd'), findsOneWidget);
      expect(find.text('OFFICIAL RETAIL PRICE (MRP)'), findsOneWidget);
      expect(find.text('1 Strip'), findsWidgets);
      expect(find.text('1 Box'), findsOneWidget);

      // Verify Monograph Sections
      expect(find.text('Clinical Monograph & Details'), findsOneWidget);
      expect(find.text('Indications & Uses'), findsWidgets);

      // Verify Bottom Action Bar
      expect(find.textContaining('Add to Cart'), findsOneWidget);

      // Tap on Pack Size '1 Box' to switch selected pack
      final boxPackFinder = find.text('1 Box');
      expect(boxPackFinder, findsOneWidget);
      await tester.tap(boxPackFinder);
      await tester.pumpAndSettle();

      // Scroll down to reveal remaining monograph sections and FAQ
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final faqItemFinder = find.text('Can I take this on an empty stomach?');
      expect(faqItemFinder, findsOneWidget);

      // Scroll further down to reveal Generic Alternatives
      await tester.drag(find.byType(ListView).first, const Offset(0, -500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final altFinder = find.text('Generic Alternatives & Substitutes');
      expect(altFinder, findsOneWidget);
      expect(find.text('Ace Plus'), findsOneWidget);

      expect(find.text('1'), findsWidgets);
    });

    testWidgets('Tapping a medicine card navigates to MedicineDetailScreen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeRepo = FakePharmacyRepository();

      final router = GoRouter(
        initialLocation: '/pharmacy',
        routes: [
          GoRoute(
            path: '/pharmacy',
            builder: (context, state) => const Scaffold(
              body: MedicinesScreen(),
            ),
          ),
          GoRoute(
            path: '/pharmacy/medicine/:slug',
            builder: (context, state) {
              final slug = state.pathParameters['slug'] ?? '';
              final initialMedicine = state.extra as MedicineModel?;
              return MedicineDetailScreen(
                slug: slug,
                initialMedicine: initialMedicine,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pharmacyRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify card rendered on pharmacy list
      expect(find.text('Napa Extra'), findsOneWidget);

      // Tap on the medicine card
      await tester.tap(find.text('Napa Extra'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify navigated to MedicineDetailScreen
      expect(find.text('Clinical Monograph & Details'), findsOneWidget);
    });
  });
}
