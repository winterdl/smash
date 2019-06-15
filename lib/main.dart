/*
 * Copyright (c) 2019. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

import 'package:flutter/material.dart';
import 'package:geopaparazzi_light/eu/geopaparazzi/library/utils/colors.dart';
import 'package:geopaparazzi_light/eu/geopaparazzi/library/models/models.dart';
import 'package:geopaparazzi_light/eu/hydrologis/geopaparazzi/widgets/dashboard.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(GeopaparazziApp());

class GeopaparazziApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GeopaparazziAppState();
  }
}

class GeopaparazziAppState extends State<GeopaparazziApp> {
  @override
  void initState() {
    super.initState();
    gpProjectModel = GPProjectModel();
  }

  @override
  void dispose() {
    if (gpProjectModel != null) {
      gpProjectModel.close();
      gpProjectModel = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geopaparazzi',
      theme: ThemeData(
          primarySwatch: GeopaparazziColors.mainDecorationsMc,
          accentColor: GeopaparazziColors.mainSelectionMc,
          canvasColor: GeopaparazziColors.mainBackground,
          brightness: Brightness.light,
          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 55, 135, 86)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 55, 135, 86)),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 128, 128, 128)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 153, 51, 0)),
            ),
            labelStyle: const TextStyle(
              color: Color.fromARGB(255, 128, 128, 128),
            ),
          )),
      debugShowMaterialGrid: false,
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      home: DashboardWidget(),
    );
  }
}