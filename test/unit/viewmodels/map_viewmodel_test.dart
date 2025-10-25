import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ashimukeren/models/respectful_person.dart';
import 'package:ashimukeren/viewmodels/map_viewmodel.dart';
import 'package:ashimukeren/providers/map_providers.dart';
import '../../helpers/mocks.dart';

void main() {
  group('MapViewModel', () {
    late ProviderContainer container;
    late MockPersonRepository mockRepository;

    setUp(() {
      mockRepository = MockPersonRepository();

      container = ProviderContainer(
        overrides: [
          mapViewModelProvider.overrideWith((ref) {
            return MapViewModel(mockRepository);
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態はデフォルトポジション（東京）', () async {
      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(mapViewModelProvider);

      expect(state.isLoading, false);
      expect(state.persons, isEmpty);
      expect(state.markers, isEmpty);
      expect(state.initialPosition, MapState.defaultPosition);
      expect(state.errorMessage, isNull);
    });

    test('loadPersonsForMap - 成功時は人物リストとマーカーを取得', () async {
      // Add test data
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: 'マップ太郎',
          address: '東京都渋谷区',
          latitude: 35.6595,
          longitude: 139.7004,
          createdAt: DateTime.now(),
        ),
      );
      mockRepository.persons.add(
        RespectfulPerson(
          id: 2,
          name: 'マップ次郎',
          address: '大阪府大阪市',
          latitude: 34.6937,
          longitude: 135.5023,
          createdAt: DateTime.now(),
        ),
      );

      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.loadPersonsForMap();

      final state = container.read(mapViewModelProvider);

      expect(state.isLoading, false);
      expect(state.persons.length, 2);
      expect(state.markers.length, 2);
      expect(state.errorMessage, isNull);

      // Initial position should be first person's location
      expect(state.initialPosition.latitude, 35.6595);
      expect(state.initialPosition.longitude, 139.7004);

      // Check marker properties
      final marker = state.markers.first;
      expect(marker.markerId.value, 'person_1');
      expect(marker.infoWindow.title, 'マップ太郎');
    });

    test('loadPersonsForMap - 座標のない人物はマーカーを作成しない', () async {
      // Add person without coordinates
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: '座標なし太郎',
          address: '不明な住所',
          latitude: null,
          longitude: null,
          createdAt: DateTime.now(),
        ),
      );

      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.loadPersonsForMap();

      final state = container.read(mapViewModelProvider);

      expect(state.isLoading, false);
      expect(state.persons.length, 0); // Filtered out by getPersonsWithCoordinates
      expect(state.markers, isEmpty);
      expect(state.initialPosition, MapState.defaultPosition); // Default to Tokyo
    });

    test('loadPersonsForMap - エラー時はエラーメッセージを設定', () async {
      mockRepository.shouldThrowError = true;

      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.loadPersonsForMap();

      final state = container.read(mapViewModelProvider);

      expect(state.isLoading, false);
      expect(state.errorMessage, contains('位置情報の読み込みエラー'));
    });

    test('calculateCameraBounds - 人物がいない場合はnull', () async {
      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.loadPersonsForMap();

      final bounds = viewModel.calculateCameraBounds();

      expect(bounds, isNull);
    });

    test('calculateCameraBounds - 1人の場合はその人の座標を含むbounds', () async {
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: 'バウンズ太郎',
          address: '京都府',
          latitude: 35.0116,
          longitude: 135.7681,
          createdAt: DateTime.now(),
        ),
      );

      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.loadPersonsForMap();

      final bounds = viewModel.calculateCameraBounds();

      expect(bounds, isNotNull);
      expect(bounds!.southwest.latitude, 35.0116);
      expect(bounds.southwest.longitude, 135.7681);
      expect(bounds.northeast.latitude, 35.0116);
      expect(bounds.northeast.longitude, 135.7681);
    });

    test('calculateCameraBounds - 複数人の場合は全員を含むbounds', () async {
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: '東京太郎',
          address: '東京都',
          latitude: 35.6762, // North
          longitude: 139.6503, // East
          createdAt: DateTime.now(),
        ),
      );
      mockRepository.persons.add(
        RespectfulPerson(
          id: 2,
          name: '福岡次郎',
          address: '福岡県',
          latitude: 33.5904, // South
          longitude: 130.4017, // West
          createdAt: DateTime.now(),
        ),
      );

      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.loadPersonsForMap();

      final bounds = viewModel.calculateCameraBounds();

      expect(bounds, isNotNull);
      expect(bounds!.southwest.latitude, 33.5904); // Min lat (福岡)
      expect(bounds.southwest.longitude, 130.4017); // Min lng (福岡)
      expect(bounds.northeast.latitude, 35.6762); // Max lat (東京)
      expect(bounds.northeast.longitude, 139.6503); // Max lng (東京)
    });

    test('refresh - loadPersonsForMapと同じ動作をする', () async {
      mockRepository.persons.add(
        RespectfulPerson(
          id: 1,
          name: 'リフレッシュ太郎',
          address: '沖縄県',
          latitude: 26.2124,
          longitude: 127.6809,
          createdAt: DateTime.now(),
        ),
      );

      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.refresh();

      final state = container.read(mapViewModelProvider);

      expect(state.persons.length, 1);
      expect(state.markers.length, 1);
      expect(state.persons.first.name, 'リフレッシュ太郎');
    });

    test('clearError - エラーメッセージをクリア', () async {
      mockRepository.shouldThrowError = true;

      final viewModel = container.read(mapViewModelProvider.notifier);
      await viewModel.loadPersonsForMap();

      // Should have error
      var state = container.read(mapViewModelProvider);
      expect(state.errorMessage, isNotNull);

      // Clear error
      viewModel.clearError();

      state = container.read(mapViewModelProvider);
      expect(state.errorMessage, isNull);
    });
  });
}
