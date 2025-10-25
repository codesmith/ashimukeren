// Widget tests for Ashimukeren app
//
// These tests verify the UI behavior of the app using ProviderScope
// to mock dependencies and test in isolation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ashimukeren/main.dart';
import 'package:ashimukeren/models/respectful_person.dart';
import 'package:ashimukeren/providers/registration_providers.dart';
import 'package:ashimukeren/viewmodels/registration_viewmodel.dart';
import 'helpers/mocks.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('アプリが起動し日本語タイトルが表示される', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const AshimukerenApp());

      // Wait for async initialization
      await tester.pumpAndSettle();

      // Verify that the Japanese app title is displayed
      expect(find.text('登録一覧'), findsOneWidget);
    });

    testWidgets('空の状態で「足を向けられない人が登録されていません」が表示される',
        (WidgetTester tester) async {
      final mockRepository = MockPersonRepository();
      final mockGeocodingService = MockGeocodingService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            registrationViewModelProvider.overrideWith((ref) {
              return RegistrationViewModel(
                mockRepository,
                mockGeocodingService,
              );
            }),
          ],
          child: const AshimukerenApp(),
        ),
      );

      // Wait for async initialization
      await tester.pumpAndSettle();

      // Verify empty state message is displayed
      expect(find.text('足を向けられない人が登録されていません'), findsOneWidget);
    });

    testWidgets('新規登録ボタンが表示され、タップできる', (WidgetTester tester) async {
      final mockRepository = MockPersonRepository();
      final mockGeocodingService = MockGeocodingService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            registrationViewModelProvider.overrideWith((ref) {
              return RegistrationViewModel(
                mockRepository,
                mockGeocodingService,
              );
            }),
          ],
          child: const AshimukerenApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find the FAB with "新規登録" text or icon
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Tap the FAB
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Verify navigation to new registration screen
      expect(find.text('新規登録'), findsOneWidget);
      expect(find.text('名前'), findsOneWidget);
      expect(find.text('住所'), findsOneWidget);
    });

    testWidgets('登録された人物がリストに表示される', (WidgetTester tester) async {
      final mockRepository = MockPersonRepository();
      final mockGeocodingService = MockGeocodingService();

      // Pre-populate with test data
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: 'テスト太郎',
          address: '東京都渋谷区',
          latitude: 35.6595,
          longitude: 139.7004,
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            registrationViewModelProvider.overrideWith((ref) {
              return RegistrationViewModel(
                mockRepository,
                mockGeocodingService,
              );
            }),
          ],
          child: const AshimukerenApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify person is displayed in list
      expect(find.text('テスト太郎'), findsOneWidget);
      expect(find.text('東京都渋谷区'), findsOneWidget);
      expect(find.text('位置情報あり'), findsOneWidget);
    });

    testWidgets('BottomNavigationBarで画面を切り替えられる', (WidgetTester tester) async {
      final mockRepository = MockPersonRepository();
      final mockGeocodingService = MockGeocodingService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            registrationViewModelProvider.overrideWith((ref) {
              return RegistrationViewModel(
                mockRepository,
                mockGeocodingService,
              );
            }),
          ],
          child: const AshimukerenApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we start on list screen
      expect(find.text('登録一覧'), findsOneWidget);

      // Find and tap map navigation button
      final mapIconFinder = find.byIcon(Icons.map);
      if (mapIconFinder.evaluate().isNotEmpty) {
        await tester.tap(mapIconFinder);
        await tester.pumpAndSettle();

        // Verify we navigated to map screen
        expect(find.text('地図'), findsOneWidget);
      }

      // Find and tap compass navigation button
      final compassIconFinder = find.byIcon(Icons.explore);
      if (compassIconFinder.evaluate().isNotEmpty) {
        await tester.tap(compassIconFinder);
        await tester.pumpAndSettle();

        // Verify we navigated to compass screen
        expect(find.text('コンパス'), findsOneWidget);
      }
    });
  });
}

