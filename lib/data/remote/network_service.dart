import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flashcards/config/app_keys.dart';
import 'package:flutter/material.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  NetworkService() {
    //print("Connectivity setup");
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    //print("Connectivity changed");
    final hasConnection = results.any((r) => r != ConnectivityResult.none);

    if (!hasConnection) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          duration: const Duration(days: 1),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating, // slično kao "GROUNDED"
          margin: EdgeInsets.zero, // popuni celu širinu
          content: Row(
            children: const [
              Icon(Icons.wifi_off, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'فضلاً اتصل بالإنترنت',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      rootScaffoldMessengerKey.currentState?.clearSnackBars();
    }
  }
}
