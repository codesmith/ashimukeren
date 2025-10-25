import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/direction_data.dart';
import '../models/respectful_person.dart';
import '../models/user_location.dart';
import '../services/compass_service.dart';
import '../services/database_service.dart';
import '../services/direction_calculator.dart';
import '../services/location_service.dart';
import '../widgets/compass_display.dart';
import '../utils/constants.dart';

/// Screen for displaying compass with direction-aware warnings
///
/// Shows compass with registered people's directions and warns with
/// red background when pointing toward them (±15° tolerance)
class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  // Services
  final _databaseService = DatabaseService();
  final _locationService = LocationService();
  final _compassService = CompassService();

  // Stream subscriptions
  StreamSubscription<UserLocation>? _locationSubscription;
  StreamSubscription<double?>? _headingSubscription;
  StreamSubscription<PhoneOrientation>? _orientationSubscription;

  // State
  List<RespectfulPerson> _persons = [];
  List<DirectionData> _directions = [];
  UserLocation? _currentLocation;
  double? _currentHeading;
  PhoneOrientation _phoneOrientation = PhoneOrientation.unknown;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasCompass = false;

  // Warning state
  bool _isPointingTowardPerson = false;
  String? _warningPersonName;

  // Heading smoothing (circular buffer for averaging)
  final List<double> _headingBuffer = [];
  static const int _headingBufferSize = 10; // Store last 10 readings
  double? _smoothedHeading;

  // Debounce timer for color changes (SC-003: reduced to 200ms)
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _headingSubscription?.cancel();
    _orientationSubscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Initialize compass - check permissions, sensors, load data, start streams
  Future<void> _initializeCompass() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // T038: Check location permission
      final hasPermission = await _locationService.hasPermission();
      if (!hasPermission) {
        final granted = await _locationService.requestPermission();
        if (!granted) {
          setState(() {
            _errorMessage = 'コンパスを使用するには位置情報の許可が必要です';
            _isLoading = false;
          });
          return;
        }
      }

      // Check if location services enabled
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = '位置情報サービスが無効です。有効にしてください。';
          _isLoading = false;
        });
        return;
      }

      // T039: Check compass availability
      _hasCompass = await _compassService.isCompassAvailable();
      if (!_hasCompass) {
        setState(() {
          _errorMessage =
              'このデバイスではコンパス/磁力計が利用できません。\n実機でお試しください。';
          _isLoading = false;
        });
        return;
      }

      // T043: Load all persons with coordinates from database
      _persons = await _databaseService.getPersonsWithCoordinates();

      // T040: Start location stream
      _startLocationStream();

      // T041: Start heading stream
      _startHeadingStream();

      // T042: Start orientation stream
      _startOrientationStream();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'コンパスの初期化エラー: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// T040: Start location stream
  void _startLocationStream() {
    _locationSubscription = _locationService.getLocationStream().listen(
      (location) {
        if (mounted) {
          setState(() {
            _currentLocation = location;
            _updateDirections();
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = '位置情報エラー: ${error.toString()}';
          });
        }
      },
    );
  }

  /// T041: Start compass heading stream
  void _startHeadingStream() {
    _headingSubscription = _compassService.getHeadingStream().listen(
      (heading) {
        if (mounted && heading != null) {
          setState(() {
            _currentHeading = heading;
            _updateSmoothedHeading(heading);
            _checkWarningState();
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = 'コンパスエラー: ${error.toString()}';
          });
        }
      },
    );
  }

  /// Smooth heading using circular buffer averaging
  /// Handles 0°/360° wraparound by converting to vectors
  void _updateSmoothedHeading(double newHeading) {
    // Add new heading to buffer
    _headingBuffer.add(newHeading);

    // Keep buffer size limited
    if (_headingBuffer.length > _headingBufferSize) {
      _headingBuffer.removeAt(0);
    }

    // Need at least 3 readings for meaningful smoothing
    if (_headingBuffer.length < 3) {
      _smoothedHeading = newHeading;
      return;
    }

    // Convert headings to unit vectors and average
    // This handles 0°/360° wraparound correctly
    double sumX = 0.0;
    double sumY = 0.0;

    for (final heading in _headingBuffer) {
      final radians = heading * pi / 180.0;
      sumX += cos(radians);
      sumY += sin(radians);
    }

    final avgX = sumX / _headingBuffer.length;
    final avgY = sumY / _headingBuffer.length;

    // Convert back to degrees
    final avgRadians = atan2(avgY, avgX);
    double avgHeading = avgRadians * 180.0 / pi;

    // Normalize to 0-360
    if (avgHeading < 0) {
      avgHeading += 360.0;
    }

    _smoothedHeading = avgHeading;
  }

  /// T042: Start phone orientation stream
  void _startOrientationStream() {
    _orientationSubscription = _compassService.getOrientationStream().listen(
      (orientation) {
        if (mounted) {
          setState(() {
            _phoneOrientation = orientation;
          });
        }
      },
      onError: (error) {
        // Orientation errors are not critical, just log
        debugPrint('Orientation error: $error');
      },
    );
  }

  /// T044: Calculate directions to all persons from current location
  void _updateDirections() {
    if (_currentLocation == null || _persons.isEmpty) {
      _directions = [];
      return;
    }

    _directions = _persons
        .where((person) => person.hasValidCoordinates)
        .map((person) {
      try {
        return DirectionCalculator.calculateDirectionToPerson(
          _currentLocation!,
          person,
        );
      } catch (e) {
        debugPrint('Error calculating direction for ${person.name}: $e');
        return null;
      }
    }).whereType<DirectionData>().toList();

    // Update warning state after directions change
    _checkWarningState();
  }

  /// T045: Check if heading points toward any person (within ±15° tolerance)
  /// Now uses smoothed heading to prevent oscillation around tolerance boundaries
  void _checkWarningState() {
    // Require both sensor data and smoothed heading
    if (_currentHeading == null || _smoothedHeading == null || _directions.isEmpty) {
      _updateWarningState(false, null);
      return;
    }

    // Check if pointing toward any person using SMOOTHED heading
    for (final direction in _directions) {
      // Use SMOOTHED heading for direction check
      if (DirectionCalculator.isPointingToward(
        _smoothedHeading!,
        direction.bearing,
        tolerance: AppConstants.compassDirectionTolerance,
      )) {
        _updateWarningState(true, direction.person.name);
        return;
      }
    }

    // Not pointing toward anyone
    _updateWarningState(false, null);
  }

  /// Update warning state with debouncing (SC-003: 500ms)
  void _updateWarningState(bool isPointing, String? personName) {
    // Cancel existing timer
    _debounceTimer?.cancel();

    // Check if state would change
    final wouldChange = isPointing != _isPointingTowardPerson ||
        personName != _warningPersonName;

    if (!wouldChange) {
      return;
    }

    // Set debounce timer
    _debounceTimer = Timer(AppConstants.compassDebounceDelay, () {
      if (mounted) {
        setState(() {
          _isPointingTowardPerson = isPointing;
          _warningPersonName = personName;
        });
      }
    });
  }

  /// T046: Get background color based on state
  /// Red when pointing toward person, green when safe, grey otherwise
  Color _getBackgroundColor() {
    // T048: Check if phone is horizontal
    if (!_phoneOrientation.isHorizontal) {
      return AppConstants.compassNeutralColor; // Grey when not horizontal
    }

    if (_persons.isEmpty) {
      return AppConstants.compassNeutralColor; // Grey when no people registered
    }

    if (_currentHeading == null || _currentLocation == null) {
      return AppConstants.compassNeutralColor; // Grey when sensors not ready
    }

    // T046: Red when pointing toward, green when safe
    if (_isPointingTowardPerson) {
      return AppConstants.compassWarningColor; // Red warning
    } else {
      return AppConstants.compassSafeColor; // Green safe
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('コンパス'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeCompass,
            tooltip: '更新',
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        color: _getBackgroundColor(),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Show error message
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // T048: Show "hold phone horizontally" message if not horizontal
    if (!_phoneOrientation.isHorizontal) {
      return _buildHoldHorizontallyMessage();
    }

    // Show empty state if no people registered
    if (_persons.isEmpty) {
      return _buildEmptyState();
    }

    // Show compass display
    return _buildCompassView();
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            Text(
              'エラー',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCompass,
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  /// T048: Build "hold phone horizontally" message
  Widget _buildHoldHorizontallyMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.screen_rotation,
              size: 100,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            Text(
              'スマホを水平に持ってください',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[100],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'コンパスを使用するには、スマホを地面と平行に持ってください',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no people registered
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.explore_outlined,
              size: 100,
              color: Colors.white70,
            ),
            const SizedBox(height: 24),
            Text(
              '登録されていません',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '人を登録するとコンパスで方角が表示されます',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// T049: Build compass view with compass display and warning/safe text
  Widget _buildCompassView() {
    return SafeArea(
      child: Column(
        children: [
          // T047: Warning text at top (if pointing toward person)
          if (_isPointingTowardPerson && _warningPersonName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black26,
              child: Column(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '警告：足を向けてはいけない方向です',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _warningPersonName!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Safe message at top (if pointing safe direction)
          if (!_isPointingTowardPerson &&
              _currentHeading != null &&
              _currentLocation != null &&
              _persons.isNotEmpty &&
              _phoneOrientation.isHorizontal)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.black26,
              child: const Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '足を向けて寝ることができる方角です！',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Compass display in center
          Expanded(
            child: Center(
              child: _currentHeading != null && _smoothedHeading != null
                  ? CompassDisplay(
                      heading: _smoothedHeading!,
                      directions: _directions,
                      size: 300,
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
          ),

          // Info at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black26,
            child: Column(
              children: [
                Text(
                  '${_persons.length}人登録済み',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentLocation != null)
                  Text(
                    '精度: ${_currentLocation!.accuracy.toStringAsFixed(0)}m',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
