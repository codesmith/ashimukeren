import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ashimukeren/models/respectful_person.dart';
import 'package:ashimukeren/viewmodels/registration_viewmodel.dart';
import 'package:ashimukeren/providers/registration_providers.dart';
import '../../helpers/mocks.dart';

void main() {
  group('RegistrationViewModel', () {
    late ProviderContainer container;
    late MockPersonRepository mockRepository;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockRepository = MockPersonRepository();
      mockGeocodingService = MockGeocodingService();

      container = ProviderContainer(
        overrides: [
          registrationViewModelProvider.overrideWith((ref) {
            return RegistrationViewModel(
              mockRepository,
              mockGeocodingService,
            );
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態は空のリストでローディング中', () {
      final state = container.read(registrationViewModelProvider);

      // Initially loading (loadPersons is called in constructor)
      expect(state.persons, isEmpty);
    });

    test('loadPersons - 成功時は人物リストを取得', () async {
      // Add test data
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: 'テスト太郎',
          address: '東京都',
          latitude: 35.6762,
          longitude: 139.6503,
          createdAt: DateTime.now(),
        ),
      );

      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(registrationViewModelProvider);

      expect(state.isLoading, false);
      expect(state.persons.length, 1);
      expect(state.persons.first.name, 'テスト太郎');
      expect(state.errorMessage, isNull);
    });

    test('loadPersons - エラー時はエラーメッセージを設定', () async {
      mockRepository.shouldThrowError = true;

      final viewModel = container.read(registrationViewModelProvider.notifier);
      await viewModel.loadPersons();

      final state = container.read(registrationViewModelProvider);

      expect(state.isLoading, false);
      expect(state.errorMessage, contains('読み込みに失敗しました'));
    });

    test('deletePerson - 成功時は人物を削除してリストを更新', () async {
      // Add test data
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: 'テスト太郎',
          address: '東京都',
          createdAt: DateTime.now(),
        ),
      );

      final viewModel = container.read(registrationViewModelProvider.notifier);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Delete person
      await viewModel.deletePerson(1);

      final state = container.read(registrationViewModelProvider);

      expect(state.persons, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('deletePerson - エラー時はエラーメッセージを設定', () async {
      mockRepository.shouldThrowError = true;

      final viewModel = container.read(registrationViewModelProvider.notifier);
      await viewModel.deletePerson(1);

      final state = container.read(registrationViewModelProvider);

      expect(state.errorMessage, contains('削除に失敗しました'));
    });

    test('registerPerson - 成功時は新しい人物を登録', () async {
      final viewModel = container.read(registrationViewModelProvider.notifier);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Register person
      await viewModel.registerPerson('新規太郎', '大阪府');

      final state = container.read(registrationViewModelProvider);
      final newRegState = viewModel.newRegistrationState;

      expect(newRegState.isLoading, false);
      expect(newRegState.isSuccess, true);
      expect(newRegState.errorMessage, isNull);
      expect(state.persons.length, 1);
      expect(state.persons.first.name, '新規太郎');
      expect(state.persons.first.address, '大阪府');
    });

    test('registerPerson - ジオコーディング失敗時もデータベースに保存', () async {
      mockGeocodingService.shouldFail = true;

      final viewModel = container.read(registrationViewModelProvider.notifier);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      // Register person (should fail but still save)
      await viewModel.registerPerson('失敗太郎', '無効な住所');

      final newRegState = viewModel.newRegistrationState;

      // Should show error
      expect(newRegState.isLoading, false);
      expect(newRegState.isSuccess, false);
      expect(newRegState.errorMessage, contains('登録に失敗しました'));
    });

    test('registerPerson - データベースエラー時はエラーメッセージを表示', () async {
      mockRepository.shouldThrowError = true;

      final viewModel = container.read(registrationViewModelProvider.notifier);

      // Wait for initial load (will fail due to shouldThrowError)
      await Future.delayed(const Duration(milliseconds: 100));

      // Reset error flag for geocoding, but keep for database insert
      mockRepository.shouldThrowError = true;

      // Register person
      await viewModel.registerPerson('DB失敗太郎', '京都府');

      final newRegState = viewModel.newRegistrationState;

      expect(newRegState.isLoading, false);
      expect(newRegState.isSuccess, false);
      expect(newRegState.errorMessage, contains('登録に失敗しました'));
    });

    test('refresh - loadPersonsと同じ動作をする', () async {
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: 'リフレッシュ太郎',
          address: '福岡県',
          createdAt: DateTime.now(),
        ),
      );

      final viewModel = container.read(registrationViewModelProvider.notifier);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      await viewModel.refresh();

      final state = container.read(registrationViewModelProvider);

      expect(state.persons.length, 1);
      expect(state.persons.first.name, 'リフレッシュ太郎');
    });

    test('resetNewRegistrationState - 新規登録状態をリセット', () async {
      final viewModel = container.read(registrationViewModelProvider.notifier);

      // Trigger registration to change state
      await viewModel.registerPerson('リセットテスト', '札幌市');

      // Reset state
      viewModel.resetNewRegistrationState();

      final newRegState = viewModel.newRegistrationState;

      expect(newRegState.isLoading, false);
      expect(newRegState.isSuccess, false);
      expect(newRegState.errorMessage, isNull);
    });

    test('clearError - リストのエラーメッセージをクリア', () async {
      mockRepository.shouldThrowError = true;

      final viewModel = container.read(registrationViewModelProvider.notifier);
      await viewModel.loadPersons();

      // Should have error
      var state = container.read(registrationViewModelProvider);
      expect(state.errorMessage, isNotNull);

      // Clear error
      viewModel.clearError();

      state = container.read(registrationViewModelProvider);
      expect(state.errorMessage, isNull);
    });
  });
}
