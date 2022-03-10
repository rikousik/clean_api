import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';

class CleanLog {
  init() => Logger.init(
        true,
        isShowFile: false,
        isShowTime: false,
        isShowNavigation: true,
        levelVerbose: 247,
        levelDebug: 15,
        levelInfo: 10,
        levelWarn: 5,
        levelError: 9,
        phoneVerbose: Colors.white,
        phoneDebug: Colors.lightBlue,
        phoneInfo: Colors.greenAccent,
        phoneWarn: Colors.orange,
        phoneError: Colors.redAccent,
      );

  printResponse({required String json, required bool canPrint}) {
    if (canPrint) {
      Logger.json(json, tag: '');
    }
  }

  printError({required String error, required bool canPrint}) {
    if (canPrint) {
      Logger.e(error, tag: '');
    }
  }

  printSuccess({required String msg, required bool canPrint}) {
    if (canPrint) {
      Logger.i(msg, tag: '');
    }
  }

  printWarning({required String warn, required bool canPrint}) {
    if (canPrint) {
      Logger.w(warn, tag: '');
    }
  }

  printInfo({required String info, required bool canPrint}) {
    if (canPrint) {
      Logger.d(info, tag: '');
    }
  }
}
