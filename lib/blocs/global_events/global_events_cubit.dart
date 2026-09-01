import 'dart:developer';

import 'package:Bloomee/services/db/dao/settings_dao.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_events_state.dart';

class GlobalEventsCubit extends Cubit<GlobalEventsState> {
  GlobalEventsCubit({required SettingsDAO settingsDao})
      : super(GlobalEventsInitial()) {
    checkForUpdates();
  }

  void checkForUpdates() async {
    log("Checking for updates...", name: 'GlobalEventsCubit');
    // Automatic update notifications disabled for TejaBeats
  }

  void showAlertDialog(String title, String content) {
    emit(AlertDialogState(title: title, content: content));
  }
}
