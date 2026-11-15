import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_network_interceptor.dart';

class ApiClient {
  late final Dio dio;

  ApiClient(SharedPreferences prefs) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.voyageai.internal/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Edition': 'VoyageAI-Enterprise',
        },
      ),
    );

    dio.interceptors.add(MockNetworkInterceptor(prefs));
  }
}
