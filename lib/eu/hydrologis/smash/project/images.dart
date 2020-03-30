/*
 * Copyright (c) 2019-2020. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */

import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smash/eu/hydrologis/dartlibs/dartlibs.dart';
import 'package:smash/eu/hydrologis/flutterlibs/ui/progress.dart';
import 'package:smash/eu/hydrologis/smash/models/project_state.dart';
import 'package:smash/eu/hydrologis/smash/project/objects/images.dart';
import 'package:smash/eu/hydrologis/smash/util/logging.dart';

class ImageWidgetUtilities {
  static Image imageFromBytes(Uint8List bytes) {
    Image img = Image.memory(bytes);
    return img;
  }

  /// Saves the image in file [path] into the db.
  ///
  /// [dbImageToCompleteAndSave] is passed in with the necessary spatial data
  /// (but missing imageDataId, which will be filled here.
  static Future<int> saveImageToSmashDb(BuildContext context, String path,
      DbImage dbImageToCompleteAndSave) async {
    var imageBytes = ImageUtilities.bytesFromImageFile(path);
    var thumbBytes = ImageUtilities.resizeImage(imageBytes, newWidth: 200);

    ProjectState projectState =
        Provider.of<ProjectState>(context, listen: false);
    var db = projectState.projectDb;

    DbImageData imgData = DbImageData()
      ..thumb = thumbBytes
      ..data = imageBytes;

    return await db.transaction((tx) async {
      int imgDataId = await tx.insert(TABLE_IMAGE_DATA, imgData.toMap());
      dbImageToCompleteAndSave.imageDataId = imgDataId;
      int imgId =
          await tx.insert(TABLE_IMAGES, dbImageToCompleteAndSave.toMap());
      if (imgId == null) {
        GpLogger().e("Could not save image to db: $path");
      }
      return imgId;
    });
  }

  static Future<UI.Image> transparentImage({width = 256, height = 256}) async {
    UI.PictureRecorder recorder = UI.PictureRecorder();
    UI.Canvas c = UI.Canvas(recorder);
    final paint = UI.Paint();
    paint.color = const UI.Color.fromARGB(0, 0, 0, 0);
    paint.style = UI.PaintingStyle.fill;
    c.drawPaint(paint);
    var p = recorder.endRecording();
    UI.Image img = await p.toImage(width, height);
    return img;
  }
}

class ImageZoomWidget extends StatelessWidget {
  var _bytes;
  var _title;

  ImageZoomWidget(this._title, this._bytes);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: <Widget>[
      AppBar(
        title: Text(_title),
      ),
      Expanded(
        child: ExtendedImage.memory(
          _bytes,
          fit: BoxFit.contain,
          //enableLoadState: false,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) {
            return GestureConfig(
                minScale: 0.9,
                animationMinScale: 0.7,
                maxScale: 5.0,
                animationMaxScale: 5.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false);
          },
        ),
      )
    ]));
  }
}

/// A widget to view, zoom and pan a smash image.
class SmashImageZoomWidget extends StatelessWidget {
  var _bytes;
  var _title;
  var _image;

  SmashImageZoomWidget(this._image);

  Future<Null> getImageData(var db) async {
    _bytes = await db.getImageDataBytes(_image.id);
  }

  @override
  Widget build(BuildContext context) {
    _title = _image.text;
    ProjectState projectState =
        Provider.of<ProjectState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: FutureBuilder<void>(
        future: getImageData(projectState.projectDb),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return OrientationBuilder(builder: (context, orientation) {
              if (orientation == Orientation.portrait) {
                return Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      Expanded(
                        child: ExtendedImage.memory(
                          _bytes,
                          fit: BoxFit.contain,
                          //enableLoadState: false,
                          mode: ExtendedImageMode.gesture,
                          initGestureConfigHandler: (state) {
                            return GestureConfig(
                                minScale: 0.9,
                                animationMinScale: 0.7,
                                maxScale: 5.0,
                                animationMaxScale: 5.5,
                                speed: 1.0,
                                inertialSpeed: 100.0,
                                initialScale: 1.0,
                                inPageView: false);
                          },
                        ),
                      )
                    ]));
              } else {
                return Center(
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      Expanded(
                        child: ExtendedImage.memory(
                          _bytes,
                          fit: BoxFit.contain,
                          //enableLoadState: false,
                          mode: ExtendedImageMode.gesture,
                          initGestureConfigHandler: (state) {
                            return GestureConfig(
                                minScale: 0.9,
                                animationMinScale: 0.7,
                                maxScale: 5.0,
                                animationMaxScale: 5.5,
                                speed: 1.0,
                                inertialSpeed: 100.0,
                                initialScale: 1.0,
                                inPageView: false);
                          },
                        ),
                      )
                    ]));
              }
            });
          } else {
            // Otherwise, display a loading indicator.
            return Center(
                child: SmashCircularProgress(label: "Loading image..."));
          }
        },
      ),
    );
  }
}
