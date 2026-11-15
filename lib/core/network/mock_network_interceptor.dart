import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class MockNetworkInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  MockNetworkInterceptor(this._prefs);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final forced503 = _prefs.getBool(AppConstants.keyForce503Errors) ?? false;
    final configuredLatency =
        _prefs.getInt(AppConstants.keySimulatedLatencyMs) ?? 500;

    // Apply configurable jitter latency between 400ms and 850ms
    final jitter = Random().nextInt(150) - 75;
    final latency = (configuredLatency + jitter).clamp(400, 850);
    await Future.delayed(Duration(milliseconds: latency));

    if (forced503) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage:
                'Service Unavailable (Simulated Recruiter Debug Mode)',
            data: {
              'error': 'Service Unavailable',
              'message': 'Simulated server maintenance active via Recruiter Debug Drawer. Please retry.',
              'statusCode': 503,
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    return handler.next(options);
  }
}
