/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/material.dart';
import 'package:smash/eu/hydrologis/smash/util/notifier.dart';
import 'package:provider/provider.dart';

/// A dedicated map builder class.
///
/// Used to trigger just map builds and keep context.
class SmashMapBuilder extends ChangeNotifierPlus {
  BuildContext context;
  GlobalKey<ScaffoldState> scaffoldKey;

  bool _inProgress = false;

  /// Ask for a map rebuild
  ///
  /// Doesn't reload anything, just rebuild using the current configuration and settings.
  void reBuild() {
    notifyListenersMsg("rebuild map");
  }

  bool get inProgress => _inProgress;

  setInProgress(bool progress) {
    _inProgress = progress;
    notifyListeners();
  }

  static void reBuildStatic(BuildContext context) {
    var mapBuilder = Provider.of<SmashMapBuilder>(context, listen: false);
    mapBuilder.reBuild();
  }
}
