import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../config/env.dart';
import '../models/user_info.dart';
import '../utils/app_utils.dart';
import '../utils/navigation/app_router.dart';
import 'crashlytics_service.dart';
import 'hive_service.dart';

const _sourceKey = 'Source';
const _branchKey = 'BranchId';
const _sourceValue = 'adminapp';

@lazySingleton
class ApiClient {
  ApiClient(this._dio, this._crashlytics) {
    // Initialize once and reuse interceptor.
    _appInterceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        final user = _currentUser;
        if (user != null) {
          options.headers['token'] = user.token;
        }

        // Only inject extra fields for requests that allow data.
        if (options.method != 'GET') {
          final extraFields = {
            _sourceKey: _sourceValue,
            _branchKey: _currentBranchId,
          }..removeWhere((_, v) => v == null);

          if (options.data is Map) {
            options.data = {...(options.data as Map), ...extraFields};
          } else if (options.data is FormData) {
            final formData = options.data as FormData;
            final existingFields = {
              for (var f in formData.fields) f.key: f.value,
            };

            extraFields.forEach((key, value) {
              if (!existingFields.containsKey(key)) {
                formData.fields.add(MapEntry(key, value.toString()));
              }
            });
            options.data = formData;
          } else {
            options.data ??= extraFields;
          }
        }

        _logRequest(options);
        handler.next(options);
      },

      onResponse: (response, handler) {
        if (kDebugMode) {
          log(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
          );
        }
        handler.next(response);
      },

      onError: (error, handler) async {
        final path = error.requestOptions.path;
        if (kDebugMode) {
          log('ERROR[${error.response?.statusCode}] => $path');
        }

        if (path.contains('getDriverDocs') || path.contains('getVehicleDocs')) {
          handler.next(error);
          return;
        }

        // Determine if this is a connection/network error (should be non-fatal)
        final isConnectionError = _isConnectionError(error);

        final message = _extractErrorMessage(error);
        if (navigatorKey.currentContext != null) {
          AppUtils.showErrorMessage(navigatorKey.currentContext!, message);
        }

        // Skip reporting expected user validation & authentication errors to Crashlytics
        final statusCode = error.response?.statusCode;
        final isAuthOrValidationError =
            statusCode == 401 ||
            statusCode == 400 ||
            statusCode == 403 ||
            statusCode == 422 ||
            path.contains('login') ||
            path.contains('getloginotp');

        final isBadResponse = error.type == DioExceptionType.badResponse;
        if (!isAuthOrValidationError && !isConnectionError) {
          logCrash(
            path,
            error,
            error.stackTrace,
            fatal: !isBadResponse,
            message: message,
          );
        }

        if (error.response?.statusCode == 401) {
          invalidateSessionCache();
          await HiveService.clearAll();
          final ctx = navigatorKey.currentContext;
          if (ctx != null) ctx.go('/login');
        }

        handler.next(error);
      },
    );

    // Add interceptor once.
    _dio.options.baseUrl = '${Env().config.baseUrl}/api';
    _dio.interceptors.add(_appInterceptor);
  }

  late final InterceptorsWrapper _appInterceptor;
  final CrashlyticsService _crashlytics;
  final Dio _dio;

  // Public APIs
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) => _dio.post(
    path,
    data: data,
    options: Options(headers: headers),
  );

  Future<Response> get(String path) => _dio.get(path);

  String? handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out sending data to the server. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond. Please try again later.';
      case DioExceptionType.badCertificate:
        return 'The server certificate is invalid. Please contact support.';
      case DioExceptionType.badResponse:
        return 'Received an invalid response from the server.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.connectionError:
        // Provide more specific error message for connection errors
        final errorMessage = error.message ?? '';
        if (errorMessage.contains('Failed host lookup') ||
            errorMessage.contains('nodename nor servname')) {
          return 'Unable to reach the server. Please check your internet connection and ensure the server is accessible.';
        }
        return 'Network error occurred. Please check your internet connection and try again.';
      case DioExceptionType.unknown:
        // Check if it's a connection-related unknown error
        final errorMessage = error.message ?? '';
        if (errorMessage.contains('Failed host lookup') ||
            errorMessage.contains('nodename nor servname') ||
            errorMessage.contains('connection')) {
          return 'Unable to connect to the server. Please check your internet connection.';
        }
        return null;
      case DioExceptionType.transformTimeout:
        return 'Request timed out processing data. Please try again.';
    }
  }

  /// Determines if the error is a connection/network error that should be non-fatal
  bool _isConnectionError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.type == DioExceptionType.unknown &&
            (error.message?.contains('Failed host lookup') == true ||
                error.message?.contains('nodename nor servname') == true ||
                error.message?.contains('connection') == true));
  }

  void logCrash(
    String from,
    Object error,
    StackTrace? stack, {
    bool fatal = true,
    String? message,
  }) {
    if (kIsWeb) return;

    log('ERROR in $from: $message', error: error);

    final user = _currentUser;
    _crashlytics.recordError(
      error,
      stack,
      fatal: fatal,
      reason: message,
      information: [
        {
          'from': from,
          'user': user != null
              ? {
                  'Id': user.id,
                  'OrganizationId': user.organizationId,
                  'ZoneId': user.zoneId,
                  'BranchId': user.branchId,
                  'SchoolName': user.schoolName,
                  'Role': user.roles.map((r) => r.toJson()).toList(),
                }
              : null,
        },
      ],
    );
  }

  String _extractErrorMessage(DioException error) {
    // For connection errors, prioritize user-friendly messages
    if (_isConnectionError(error)) {
      final connectionMsg = handleError(error);
      if (connectionMsg != null) {
        return connectionMsg;
      }
    }

    final data = error.response?.data;
    String msg = '';
    if (data is String) {
      msg = data;
    } else if (data is Map && data['message'] != null) {
      msg = data['message'];
    } else {
      msg = error.message ?? handleError(error) ?? 'Unexpected error occurred.';
    }

    return msg.contains('<!DOCTYPE html>') ? 'Something went wrong...' : msg;
  }

  void _logRequest(RequestOptions options) {
    if (!kDebugMode) return;
    dynamic data = options.data;
    if (data is FormData) {
      data = Map.fromEntries(data.fields.map((f) => MapEntry(f.key, f.value)));
    }

    log(
      'REQUEST[${options.method}] => PATH: ${options.baseUrl}${options.path} => BODY: '
      '${jsonEncode(data ?? {})}',
    );
  }

  UserInfo? _cachedUser;
  dynamic _cachedBranchId;

  /// Clear in-memory session cache on logout or credential change
  void invalidateSessionCache() {
    _cachedUser = null;
    _cachedBranchId = null;
  }

  UserInfo? get _currentUser {
    if (_cachedUser != null) return _cachedUser;
    if (HiveService.userInfoBox.isOpen &&
        HiveService.userInfoBox.values.isNotEmpty) {
      _cachedUser = HiveService.userInfoBox.values.first;
    }
    return _cachedUser;
  }

  dynamic get _currentBranchId {
    if (_cachedBranchId != null) return _cachedBranchId;
    if (HiveService.zonalBranch.isOpen) {
      _cachedBranchId =
          HiveService.zonalBranch.get('selected')?.id ?? _currentUser?.branchId;
    } else {
      _cachedBranchId = _currentUser?.branchId;
    }
    return _cachedBranchId;
  }
}
