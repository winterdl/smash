/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image/image.dart' as IMG;
import 'package:latlong/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:proj4dart/proj4dart.dart' as proj4dart;
import 'package:dart_hydrologis_utils/dart_hydrologis_utils.dart';
import 'package:smashlibs/smashlibs.dart';
import 'package:smash/eu/hydrologis/smash/maps/layers/core/layersource.dart';

class WorldImageSource extends RasterLayerSource {
  String _absolutePath;
  String _name;
  double opacityPercentage = 100;
  bool isVisible = true;
  LatLngBounds _imageBounds;
  bool loaded = false;
  MemoryImage _memoryImage;
  int _srid;
  var originPrj;

  WorldImageSource.fromMap(Map<String, dynamic> map) {
    String relativePath = map[LAYERSKEY_FILE];
    _name = FileUtilities.nameFromFile(relativePath, false);
    _absolutePath = Workspace.makeAbsolute(relativePath);

    _srid = map[LAYERSKEY_SRID];
    isVisible = map[LAYERSKEY_ISVISIBLE];

    opacityPercentage = map[LAYERSKEY_OPACITY] ?? 100;
    if (_srid == null) {
      getSridFromPath();
    }
  }

  WorldImageSource(this._absolutePath) {
    _name = FileUtilities.nameFromFile(_absolutePath, false);
    getSridFromPath();
  }

  void getSridFromPath() {
    originPrj = SmashPrj.fromImageFile(_absolutePath);
    _srid = SmashPrj.getSrid(originPrj);
    if (_srid == null) {
      var prjPath = SmashPrj.getPrjForImage(_absolutePath);
      var prjFile = File(prjPath);
      if (prjFile.existsSync()) {
        var wktPrj = FileUtilities.readFile(prjPath);
        _srid = SmashPrj.getSridFromWkt(wktPrj);
      }
    }
  }

  static String getWorldFile(String imagePath) {
    String folder = FileUtilities.parentFolderFromFile(imagePath);
    var name = FileUtilities.nameFromFile(imagePath, false);
    var ext = FileUtilities.getExtension(imagePath);
    var wldExt;
    if (ext == FileManager.JPG_EXT) {
      wldExt = FileManager.JPG_WLD_EXT;
    } else if (ext == FileManager.PNG_EXT) {
      wldExt = FileManager.PNG_WLD_EXT;
    } else if (ext == FileManager.TIF_EXT) {
      wldExt = FileManager.TIF_WLD_EXT;
    } else {
      return null;
    }

    var wldPath = FileUtilities.joinPaths(folder, name + "." + wldExt);
    var wldFile = File(wldPath);
    if (wldFile.existsSync()) {
      return wldPath;
    }
    return null;
  }

  Future<void> load(BuildContext context) {
    if (!loaded) {
      // print("LOAD WORLD FILE");
      _name = FileUtilities.nameFromFile(_absolutePath, false);
      File imageFile = new File(_absolutePath);

      if (_srid == null) {
        getSridFromPath();
      } else {
        originPrj = SmashPrj.fromSrid(_srid);
      }

      var ext = FileUtilities.getExtension(_absolutePath);
      IMG.Image _decodedImage;
      var bytes = imageFile.readAsBytesSync();
      if (ext == FileManager.JPG_EXT) {
        _decodedImage = IMG.decodeJpg(bytes);
        _memoryImage = MemoryImage(bytes);
      } else if (ext == FileManager.PNG_EXT) {
        _decodedImage = IMG.decodePng(bytes);
        _memoryImage = MemoryImage(bytes);
      } else if (ext == FileManager.TIF_EXT) {
        _decodedImage = IMG.decodeTiff(bytes);
        _memoryImage = MemoryImage(IMG.encodeJpg(_decodedImage));
      }

      var width = _decodedImage.width;
      var height = _decodedImage.height;

      var worldFile = getWorldFile(_absolutePath);
      var tfwList = FileUtilities.readFileToList(worldFile);
      var xRes = double.parse(tfwList[0]);
      var yRes = -double.parse(tfwList[3]);
      var xExtent = width * xRes;
      var yExtent = height * yRes;

      var west = double.parse(tfwList[4]) - xRes / 2.0;
      var north = double.parse(tfwList[5]) + yRes / 2.0;
      var east = west + xExtent;
      var south = north - yExtent;

      var ll = proj4dart.Point(x: west, y: south);
      var ur = proj4dart.Point(x: east, y: north);
      var llDest = SmashPrj.transformToWgs84(originPrj, ll);
      var urDest = SmashPrj.transformToWgs84(originPrj, ur);

      _imageBounds = LatLngBounds(
        LatLng(llDest.y, llDest.x),
        LatLng(urDest.y, urDest.x),
      );

      loaded = true;
    }
  }

  bool hasData() {
    return true;
  }

  String getAbsolutePath() {
    return _absolutePath;
  }

  String getUrl() {
    return null;
  }

  String getName() {
    return _name;
  }

  String getAttribution() {
    return "";
  }

  bool isActive() {
    return isVisible;
  }

  void setActive(bool active) {
    isVisible = active;
  }

  String toJson() {
    var relativePath = Workspace.makeRelative(_absolutePath);
    var json = '''
    {
        "$LAYERSKEY_LABEL": "$_name",
        "$LAYERSKEY_FILE":"$relativePath",
        "$LAYERSKEY_ISVISIBLE": $isVisible,
        "$LAYERSKEY_SRID": $_srid,
        "$LAYERSKEY_OPACITY": $opacityPercentage
    }
    ''';
    return json;
  }

  @override
  Future<List<LayerOptions>> toLayers(BuildContext context) async {
    await load(context);

    List<LayerOptions> layers = [
      OverlayImageLayerOptions(overlayImages: [
        OverlayImage(
            gaplessPlayback: true,
            imageProvider: _memoryImage,
            bounds: _imageBounds,
            opacity: opacityPercentage / 100.0),
      ]),
    ];

    return layers;
  }

  @override
  Future<LatLngBounds> getBounds() async {
    if (_imageBounds == null) {
      await load(null);
    }
    return _imageBounds;
  }

  @override
  void disposeSource() {
    _absolutePath = null;
    _name = null;

    _imageBounds = LatLngBounds();
    loaded = false;
    _memoryImage = null;
  }

  @override
  bool hasProperties() {
    return true;
  }

  Widget getPropertiesWidget() {
    return TiffPropertiesWidget(this);
  }

  @override
  bool isZoomable() {
    return true;
  }

  @override
  int getSrid() {
    return _srid;
  }
}

/// The tiff properties page.
class TiffPropertiesWidget extends StatefulWidget {
  final WorldImageSource _source;
  TiffPropertiesWidget(this._source);

  @override
  State<StatefulWidget> createState() {
    return TiffPropertiesWidgetState(_source);
  }
}

class TiffPropertiesWidgetState extends State<TiffPropertiesWidget> {
  WorldImageSource _source;
  double _opacitySliderValue = 100;
  bool _somethingChanged = false;

  TiffPropertiesWidgetState(this._source);

  @override
  void initState() {
    _opacitySliderValue = _source.opacityPercentage;
    if (_opacitySliderValue > 100) {
      _opacitySliderValue = 100;
    }
    if (_opacitySliderValue < 0) {
      _opacitySliderValue = 0;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_somethingChanged) {
            _source.opacityPercentage = _opacitySliderValue;
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("Tiff Properties"),
          ),
          body: ListView(
            children: <Widget>[
              Padding(
                padding: SmashUI.defaultPadding(),
                child: Card(
                  shape: SmashUI.defaultShapeBorder(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(MdiIcons.opacity),
                        title: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("Opacity"),
                        ),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                                flex: 1,
                                child: Slider(
                                  activeColor: SmashColors.mainSelection,
                                  min: 0.0,
                                  max: 100,
                                  divisions: 10,
                                  onChanged: (newRating) {
                                    _somethingChanged = true;
                                    setState(
                                        () => _opacitySliderValue = newRating);
                                  },
                                  value: _opacitySliderValue,
                                )),
                            Container(
                              width: 50.0,
                              alignment: Alignment.center,
                              child: SmashUI.normalText(
                                '${_opacitySliderValue.toInt()}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
