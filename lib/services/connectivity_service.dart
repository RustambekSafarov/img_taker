import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetSubscription;
  bool _previousStatus = true;

  void initialize() {
    // Check initial connectivity
    _checkInitialConnection();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _checkConnection();
    });

    // Listen to internet connection changes
    _internetSubscription = _internetChecker.onStatusChange.listen((
      InternetStatus status,
    ) {
      final isConnected = status == InternetStatus.connected;
      if (isConnected != _previousStatus) {
        _previousStatus = isConnected;
        _connectionStatusController.add(isConnected);
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final hasInternet = await _internetChecker.hasInternetAccess;
    _previousStatus = hasInternet;
    _connectionStatusController.add(hasInternet);
  }

  Future<void> _checkConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (_previousStatus != false) {
        _previousStatus = false;
        _connectionStatusController.add(false);
      }
    } else {
      final hasInternet = await _internetChecker.hasInternetAccess;
      if (hasInternet != _previousStatus) {
        _previousStatus = hasInternet;
        _connectionStatusController.add(hasInternet);
      }
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _connectionStatusController.close();
  }
}
