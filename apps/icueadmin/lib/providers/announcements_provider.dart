import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:provider/provider.dart';

import '../models/announcement_titles.dart';
import '../models/announcements.dart';
import '../models/routes.dart';
import '../services/api_client.dart';
import '../services/hive_service.dart';
import '../utils/app_utils.dart';
import 'vehicle_provider.dart';

@lazySingleton
class AnnouncementsProvider extends ChangeNotifier {
  AnnouncementsProvider(this._apiClient);

  List<AnnouncementTitle> announcementTitles = [];
  List<Announcements> announcements = [];
  bool loading = false;

  final ApiClient _apiClient;

  Future<void> getAnnouncements() async {
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/v1.0/getAnnouncements');
      announcements = List<Announcements>.from(
        (response.data as List).map(
          (x) => Announcements.fromJson(x as Map<String, dynamic>),
        ),
      );
      announcements.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getAnnouncements', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getAnnouncementTitles() async {
    // announcementTitles = HiveService.announcementTitleBox.values.toList();
    // if (announcementTitles.isNotEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final response = await _apiClient.post('/v1.0/getAnnouncementTitles');
      final data = AnnouncementTitles.fromJson(
        response.data as Map<String, dynamic>,
      );
      announcementTitles = data.data ?? [];
      announcementTitles.add(
        AnnouncementTitle(
          type: 1000,
          title: 'Custom',
          descHeader: 'Custom',
          descBody: 'Custom',
          descFooter: 'Custom',
          vars: [],
          isActive: true,
        ),
      );
      await HiveService.announcementTitleBox.clear();
      await HiveService.announcementTitleBox.addAll(announcementTitles);
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/getAnnouncementTitles', error, stack);
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> postAnnouncement(
    BuildContext context, {
    required String title,
    required String description,
    required List<int> routes,
    required List<int> studentId,
    required String mode,
    List<String>? points,
  }) async {
    AppUtils.showLoadingDialog(context, 'Posting... Please wait...');
    try {
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );

      final allRoutes = routes.isNotEmpty
          ? routes
          : vehicleProvider.routes
                .where((f) => modeValues.reverse[f.mode] == mode)
                .map((e) => e.id)
                .toList();

      final studentIds = studentId.isNotEmpty
          ? studentId
          : [
              for (final int route in allRoutes)
                for (final Point f
                    in vehicleProvider.routes
                        .firstWhere(
                          (e) => e.id == route,
                          orElse: () => Routee(
                            routeNo: '0',
                            mode: Mode.DROP,
                            id: 0,
                            points: [],
                          ),
                        )
                        .points)
                  ...f.studentIds,
            ];

      await _apiClient.post(
        '/v1.0/createFleetAnnouncement',
        data: {
          'Title': title,
          'Description': description,
          'Mode': mode,
          'Routes': allRoutes,
          'PickUpPoints': points,
          'StudentIds': studentIds,
        },
      );
      AppUtils.showSucessMessage(context, 'Announcement sent successfully!');
      await getAnnouncements();
      return true;
    } catch (error, stack) {
      if (error.runtimeType.toString() != 'DioException') {
        _apiClient.logCrash('/createFleetAnnouncement', error, stack);
      }
      AppUtils.showErrorMessage(
        context,
        'Something went wrong... Please try again!',
      );
      return false;
    } finally {
      AppUtils.hideLoadingDialog(context);
    }
  }
}
