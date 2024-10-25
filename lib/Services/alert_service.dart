import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'navigation_service.dart';

class AlertService {
  GetIt getIt = GetIt.instance;
  late NavigationService _navigationService;

  AlertService() {
    _navigationService = getIt.get<NavigationService>();
  }

  void showToast({required String text, IconData icon = Icons.info}) {
    try {
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        autoDismiss: true,
        builder: (context) {
          return ToastCard(
            title: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w200,
              ),
            ),
            leading: Icon(
              icon,
              size: 20,
            ),
          );
        },
      ).show(_navigationService.navigatorKey!.currentContext!);
    } catch (e) {
      print(e.toString());
    }
  }
}
