/*
 * Copyright (c) 2019. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
import 'dart:io';
import 'dart:async';

import 'package:badges/badges.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydro_flutter_libs/hydro_flutter_libs.dart';
import 'package:path/path.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:screen/screen.dart';
import 'package:smash/eu/hydrologis/smash/widgets/settings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const String KEY_DO_NOTE_IN_GPS = "KEY_DO_NOTE_IN_GPS";

class DashboardUtils {
  static Widget makeToolbarBadge(Widget widget, int badgeValue) {
    if (badgeValue > 0) {
      return Badge(
        badgeColor: SmashColors.mainSelection,
        shape: BadgeShape.circle,
        toAnimate: false,
        badgeContent: Text(
          '$badgeValue',
          style: TextStyle(color: Colors.white),
        ),
        child: widget,
      );
    } else {
      return widget;
    }
  }

  static Widget makeToolbarZoomBadge(Widget widget, int badgeValue) {
    if (badgeValue > 0) {
      return Badge(
        badgeColor: SmashColors.mainDecorations,
        shape: BadgeShape.circle,
        toAnimate: false,
        badgeContent: Text(
          '$badgeValue',
          style: TextStyle(color: Colors.white),
        ),
        child: widget,
      );
    } else {
      return widget;
    }
  }

  static List<MenuItem> getAddNoteMenuItems() {
    var style = TextStyle(fontSize: 10, color: SmashColors.mainTextColor);
    var size = GpConstants.SMALL_DIALOG_ICON_SIZE;
    var list = <MenuItem>[
      MenuItem(
          textStyle: style,
          title: 'Center Note',
          image: Icon(
            Icons.add_comment,
            color: SmashColors.mainDecorations,
            size: size,
          )),
      MenuItem(
          textStyle: style,
          title: 'Center Image',
          image: Icon(
            Icons.add_a_photo,
            color: SmashColors.mainDecorations,
            size: size,
          )),
      MenuItem(
          textStyle: style,
          title: 'Center Forms',
          image: Icon(
            Icons.menu,
            color: SmashColors.mainDecorations,
            size: size,
          )),
    ];
    if (GpsHandler().hasFix()) {
      list.add(
        MenuItem(
            textStyle: style,
            title: 'GPS Note',
            image: Icon(
              Icons.add_comment,
              color: SmashColors.mainSelection,
              size: size,
            )),
      );
      list.add(
        MenuItem(
            textStyle: style,
            title: 'GPS Image',
            image: Icon(
              Icons.add_a_photo,
              color: SmashColors.mainSelection,
              size: size,
            )),
      );
      list.add(
        MenuItem(
            textStyle: style,
            title: 'GPS Forms',
            image: Icon(
              Icons.menu,
              color: SmashColors.mainSelection,
              size: size,
            )),
      );
    }
    return list;
  }

  static List<Widget> getDrawerTilesList(
      Color c,
      double iconSize,
      double textSize,
      BuildContext context,
      MapController mapController,
      MainEventHandler mainEventsHandler) {
    return [
      ListTile(
        leading: new Icon(
          Icons.create_new_folder,
          color: c,
          size: iconSize,
        ),
        title: Text(
          "New Project",
          style: TextStyle(fontSize: textSize, color: c),
        ),
        onTap: () => _createNewProject(context, mainEventsHandler),
      ),
      ListTile(
        leading: new Icon(
          Icons.folder_open,
          color: c,
          size: iconSize,
        ),
        title: Text(
          "Open Project",
          style: TextStyle(fontSize: textSize, color: c),
        ),
        onTap: () => _openProject(context, mainEventsHandler),
      ),
      ListTile(
        leading: new Icon(
          Icons.file_download,
          color: c,
          size: iconSize,
        ),
        title: Text(
          "Import",
          style: TextStyle(fontSize: textSize, color: c),
        ),
        onTap: () {},
      ),
      ListTile(
        leading: new Icon(
          Icons.file_upload,
          color: c,
          size: iconSize,
        ),
        title: Text(
          "Export",
          style: TextStyle(fontSize: textSize, color: c),
        ),
        onTap: () {},
      ),
      ListTile(
        leading: new Icon(
          Icons.settings,
          color: c,
          size: iconSize,
        ),
        title: Text(
          "Settings",
          style: TextStyle(fontSize: textSize, color: c),
        ),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsWidget())),
      ),
      ListTile(
        leading: new Icon(
          Icons.bug_report,
          color: c,
          size: iconSize,
        ),
        title: Text(
          "Run diagnostics",
          style: TextStyle(fontSize: textSize, color: c),
        ),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => DiagnosticWidget())),
      ),
      ListTile(
        leading: new Icon(
          Icons.info_outline,
          color: c,
          size: iconSize,
        ),
        title: Text(
          "About",
          style: TextStyle(fontSize: textSize, color: c),
        ),
        onTap: () => print("TODO add about"),
      ),
    ];
  }

  static List<Widget> getEndDrawerListTiles(
      Color c,
      double iconSize,
      TextStyle textStyle,
      BuildContext context,
      MapController mapController,
      MainEventHandler mainEventsHandler) {
    List<Widget> list = []
      ..add(
        ListTile(
          leading: new Icon(
            Icons.navigation,
            color: c,
            size: iconSize,
          ),
          title: Text(
            "Go to",
            style: textStyle,
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GeocodingPage(mainEventsHandler)));
          },
        ),
      )
      ..add(
        ListTile(
          leading: new Icon(
            Icons.share,
            color: c,
            size: iconSize,
          ),
          title: Text(
            "Share position",
            style: textStyle,
          ),
          onTap: () {},
        ),
      )
      ..add(
        ListTile(
          leading: new Icon(
            FontAwesomeIcons.crosshairs,
            color: c,
            size: iconSize,
          ),
          title: Text(
            "Notes in GPS position",
            style: textStyle,
          ),
          trailing: Checkbox(
              value: mainEventsHandler.getInsertInGps(),
              onChanged: (value) {
                mainEventsHandler.setInsertInGps(value);
              }),
        ),
      )
      ..add(
        ListTile(
          leading: new Icon(
            Icons.center_focus_weak,
            color: c,
            size: iconSize,
          ),
          title: Text(
            "Center on GPS stream",
            style: textStyle,
          ),
          trailing: Checkbox(
              value: mainEventsHandler.isCenterOnGpsStream(),
              onChanged: (value) {
                mainEventsHandler.setCenterOnGpsStream(value);
                GpPreferences().setCenterOnGps(value);
//                  Navigator.of(context).pop();
              }),
        ),
      );

    if (!Platform.isIOS) {
      list.add(
        ListTile(
          leading: new Icon(
            Icons.rotate_right,
            color: c,
            size: iconSize,
          ),
          title: Text(
            "Rotate with GPS heading",
            style: textStyle,
          ),
          trailing: Checkbox(
              value: mainEventsHandler.isRotateOnHeading(),
              onChanged: (value) {
                mainEventsHandler.setRotateOnHeading(value);
                if (!value) {
                  mapController.rotate(0);
                }
                GpPreferences().setRotateOnHeading(value);
//                  Navigator.of(context).pop();
              }),
        ),
      );
    }
    return list;
  }

  static Future _openProject(
      BuildContext context, MainEventHandler mainEventsHandler) async {
    File file =
        await FilePicker.getFile(type: FileType.ANY, fileExtension: 'gpap');
    if (file != null && file.existsSync()) {
      await GPProject().setNewProject(file.path);
      await mainEventsHandler.reloadProjectFunction();
    }
    Navigator.of(context).pop();
  }

  static Future _createNewProject(
      BuildContext context, MainEventHandler mainEventsHandler) async {
    String projectName =
        "geopaparazzi_${TimeUtilities.DATE_TS_FORMATTER.format(DateTime.now())}";

    var userString = await showInputDialog(
      context,
      "New Project",
      "Enter a name for the new project or accept the proposed.",
      hintText: '',
      defaultText: projectName,
      validationFunction: fileNameValidator,
    );
    if (userString != null) {
      if (userString.trim().length == 0) userString = projectName;
      var file = await Workspace.getStorageFolder();
      var newPath = join(file.path, userString);
      if (!newPath.endsWith(".gpap")) {
        newPath = "$newPath.gpap";
      }
      var gpFile = new File(newPath);
      await GPProject().setNewProject(gpFile.path);
      await mainEventsHandler.reloadProjectFunction();
    }

    Navigator.of(context).pop();
  }

  static Icon getGpsStatusIcon(GpsStatus status) {
    Color color;
    IconData iconData;
    switch (status) {
      case GpsStatus.OFF:
        {
          color = SmashColors.gpsOff;
          iconData = Icons.gps_off;
          break;
        }
      case GpsStatus.ON_WITH_FIX:
        {
          color = SmashColors.gpsOnWithFix;
          iconData = Icons.gps_fixed;
          break;
        }
      case GpsStatus.ON_NO_FIX:
        {
          iconData = Icons.gps_not_fixed;
          color = SmashColors.gpsOnNoFix;
          break;
        }
      case GpsStatus.LOGGING:
        {
          iconData = Icons.gps_fixed;
          color = SmashColors.gpsLogging;
          break;
        }
      case GpsStatus.NOPERMISSION:
        {
          iconData = Icons.gps_off;
          color = SmashColors.gpsNoPermission;
          break;
        }
    }
    return Icon(
      iconData,
      color: color,
    );
  }

  static Icon getLoggingIcon(GpsStatus status) {
    Color color;
    IconData iconData;
    switch (status) {
      case GpsStatus.LOGGING:
        {
          iconData = Icons.timeline;
          color = SmashColors.gpsLogging;
          break;
        }
      case GpsStatus.OFF:
      case GpsStatus.ON_WITH_FIX:
      case GpsStatus.ON_NO_FIX:
      case GpsStatus.NOPERMISSION:
        {
          iconData = Icons.timeline;
          color = SmashColors.mainBackground;
          break;
        }
      default:
        {
          iconData = Icons.timeline;
          color = SmashColors.mainBackground;
        }
    }
    return Icon(
      iconData,
      color: color,
    );
  }
}

class DataLoaderUtilities {
  static void addNote(BuildContext context, bool doInGps,
      MapController mapController, MainEventHandler mainEventsHandler) async {
    int ts = DateTime.now().millisecondsSinceEpoch;
    Position pos;
    double lon;
    double lat;
    if (doInGps) {
      pos = GpsHandler().lastPosition;
    } else {
      var center = mapController.center;
      lon = center.longitude;
      lat = center.latitude;
    }
    Note note = Note()
      ..text = "double tap to change"
      ..description = "POI"
      ..timeStamp = ts
      ..lon = pos != null ? pos.longitude : lon
      ..lat = pos != null ? pos.latitude : lat
      ..altim = pos != null ? pos.altitude : -1;
    if (pos != null) {
      NoteExt next = NoteExt()
        ..speedaccuracy = pos.speedAccuracy
        ..speed = pos.speed
        ..heading = pos.heading
        ..accuracy = pos.accuracy;
      note.noteExt = next;
    }
    var db = await GPProject().getDatabase();
    await db.addNote(note);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NotePropertiesWidget(mainEventsHandler, note)));
  }

  static void addImage(BuildContext context, bool doInGps,
      MapController mapController, MainEventHandler mainEventsHandler) async {
    DbImage dbImage = DbImage()
      ..timeStamp = DateTime.now().millisecondsSinceEpoch
      ..isDirty = 1;

    if (doInGps) {
      var pos = GpsHandler().lastPosition;

      dbImage.lon = pos.longitude;
      dbImage.lat = pos.latitude;
      dbImage.altim = pos.altitude;
      dbImage.azim = pos.heading;
    } else {
      var center = mapController.center;
      dbImage.lon = center.longitude;
      dbImage.lat = center.latitude;
      dbImage.altim = -1;
      dbImage.azim = -1;
    }

    openCamera(context, (takenImagePath) async {
      Navigator.of(context).pop();
      if (takenImagePath != null) {
        dbImage.text =
            "IMG_${TimeUtilities.DATE_TS_FORMATTER.format(DateTime.fromMillisecondsSinceEpoch(dbImage.timeStamp))}.jpg";
        bool done = await ImageWidgetUtilities.saveImageToSmashDb(
            takenImagePath, dbImage);
        if (done) {
          await mainEventsHandler.reloadProjectFunction();
        }
        File file = File(takenImagePath);
        if (file.existsSync()) {
          file.delete();
        }
      }
    });
  }

  static void loadNotesMarkers(
      var db,
      List<Marker> tmp,
      MainEventHandler mainEventHandler,
      Function _showSnackbar,
      Function _hideSnackbar) async {
    List<Note> notesList = await db.getNotes();
    notesList.forEach((note) {
      NoteExt noteExt = note.noteExt;
      tmp.add(Marker(
        width: noteExt.size,
        height: noteExt.size,
        point: new LatLng(note.lat, note.lon),
        builder: (ctx) => new Container(
            child: GestureDetector(
          onTap: () {
            _showSnackbar(SnackBar(
              backgroundColor: SmashColors.snackBarColor,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(GpConstants.DEFAULT_PADDING),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Table(
                          columnWidths: {
                            0: FlexColumnWidth(0.4),
                            1: FlexColumnWidth(0.6),
                          },
                          children: [
                            TableRow(
                              children: [
                                TableUtilities.cellForString("Note"),
                                TableUtilities.cellForString(note.text),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableUtilities.cellForString("Longitude"),
                                TableUtilities.cellForString(
                                    note.lon.toString()),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableUtilities.cellForString("Latitude"),
                                TableUtilities.cellForString(
                                    note.lat.toString()),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableUtilities.cellForString("Altitude"),
                                TableUtilities.cellForString(
                                    note.altim.toInt().toString()),
                              ],
                            ),
                            TableRow(
                              children: [
                                TableUtilities.cellForString("Timestamp"),
                                TableUtilities.cellForString(TimeUtilities
                                    .ISO8601_TS_FORMATTER
                                    .format(DateTime.fromMillisecondsSinceEpoch(
                                        note.timeStamp))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.share,
                            color: SmashColors.mainSelection,
                          ),
                          iconSize: GpConstants.MEDIUM_DIALOG_ICON_SIZE,
                          onPressed: () {
                            var label =
                                "note: ${note.text}\nlat: ${note.lat}\nlon: ${note.lon}\naltim: ${note.altim.round()}\nts: ${TimeUtilities.ISO8601_TS_FORMATTER.format(DateTime.fromMillisecondsSinceEpoch(note.timeStamp))}";
                            shareText(label);
                            _hideSnackbar();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: SmashColors.mainSelection,
                          ),
                          iconSize: GpConstants.MEDIUM_DIALOG_ICON_SIZE,
                          onPressed: () {
                            Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                    builder: (context) => NotePropertiesWidget(
                                        mainEventHandler, note)));
                            _hideSnackbar();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: SmashColors.mainSelection,
                          ),
                          iconSize: GpConstants.MEDIUM_DIALOG_ICON_SIZE,
                          onPressed: () async {
                            var doRemove = await showConfirmDialog(
                                ctx,
                                "Remove Note",
                                "Are you sure you want to remove note ${note.id}?");
                            if (doRemove) {
                              var db = await GPProject().getDatabase();
                              await db.deleteNote(note.id);
                              await mainEventHandler.reloadProjectFunction();
                            }
                            _hideSnackbar();
                          },
                        ),
                        Spacer(flex: 1),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: SmashColors.mainDecorationsDark,
                          ),
                          iconSize: GpConstants.MEDIUM_DIALOG_ICON_SIZE,
                          onPressed: () {
                            _hideSnackbar();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              duration: Duration(seconds: 5),
            ));
          },
          child: Icon(
            NOTES_ICONDATA[noteExt.marker],
            size: noteExt.size,
            color: ColorExt(noteExt.color),
          ),
        )),
      ));
    });
  }

  static void loadImageMarkers(
      var db,
      List<Marker> tmp,
      MainEventHandler mainEventHandler,
      Function _showSnackbar,
      Function _hideSnackbar) async {
    // IMAGES
    var imagesList = await db.getImages(false);
    imagesList.forEach((image) async {
      var size = 48.0;
      var lat = image.lat;
      var lon = image.lon;
      var label =
          "image: ${image.text}\nlat: ${image.lat}\nlon: ${image.lon}\naltim: ${image.altim.round()}\nts: ${TimeUtilities.ISO8601_TS_FORMATTER.format(DateTime.fromMillisecondsSinceEpoch(image.timeStamp))}";
      tmp.add(Marker(
        width: size,
        height: size,
        point: new LatLng(lat, lon),
        builder: (ctx) => new Container(
            child: GestureDetector(
          onTap: () async {
            var thumb = await db.getThumbnail(image.imageDataId);
            _showSnackbar(SnackBar(
              backgroundColor: SmashColors.snackBarColor,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          label,
                          style: GpConstants.MEDIUM_DIALOG_TEXT_STYLE_NEUTRAL,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: SmashColors.mainDecorations)),
                    padding: EdgeInsets.all(5),
                    child: GestureDetector(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          thumb,
                        ],
                      ),
                      onTap: () async {
                        Navigator.push(
                            ctx,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SmashImageZoomWidget(image)));
                        _hideSnackbar();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.share,
                            color: SmashColors.mainSelection,
                          ),
                          iconSize: GpConstants.MEDIUM_DIALOG_ICON_SIZE,
                          onPressed: () {
                            shareImage(label);
                            _hideSnackbar();
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: SmashColors.mainSelection,
                          ),
                          iconSize: GpConstants.MEDIUM_DIALOG_ICON_SIZE,
                          onPressed: () async {
                            var doRemove = await showConfirmDialog(
                                ctx,
                                "Remove Image",
                                "Are you sure you want to remove image ${image.id}?");
                            if (doRemove) {
                              var db = await GPProject().getDatabase();
                              await db.deleteImage(image.id);
                              await mainEventHandler.reloadProjectFunction();
                            }
                            _hideSnackbar();
                          },
                        ),
                        Spacer(flex: 1),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: SmashColors.mainDecorationsDark,
                          ),
                          iconSize: GpConstants.MEDIUM_DIALOG_ICON_SIZE,
                          onPressed: () {
                            _hideSnackbar();
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              duration: Duration(seconds: 5),
            ));
          },
          child: Icon(
            NOTES_ICONDATA['camera'],
            size: size,
            color: Colors.blue,
          ),
        )),
      ));
    });
  }

  static Future<PolylineLayerOptions> loadLogLinesLayer(var db) async {
    String logsQuery = '''
        select l.$LOGS_COLUMN_ID, p.$LOGSPROP_COLUMN_COLOR, p.$LOGSPROP_COLUMN_WIDTH 
        from $TABLE_GPSLOGS l, $TABLE_GPSLOG_PROPERTIES p 
        where l.$LOGS_COLUMN_ID = p.$LOGSPROP_COLUMN_ID and p.$LOGSPROP_COLUMN_VISIBLE=1
    ''';

    List<Map<String, dynamic>> resLogs = await db.query(logsQuery);
    Map<int, List> logs = Map();
    resLogs.forEach((map) {
      var id = map['_id'];
      var color = map["color"];
      var width = map["width"];

      logs[id] = [color, width, <LatLng>[]];
    });

    String logDataQuery =
        "select $LOGSDATA_COLUMN_LAT, $LOGSDATA_COLUMN_LON, $LOGSDATA_COLUMN_LOGID from $TABLE_GPSLOG_DATA order by $LOGSDATA_COLUMN_LOGID, $LOGSDATA_COLUMN_TS";
    List<Map<String, dynamic>> resLogData = await db.query(logDataQuery);
    resLogData.forEach((map) {
      var logid = map[LOGSDATA_COLUMN_LOGID];
      var log = logs[logid];
      if (log != null) {
        var lat = map[LOGSDATA_COLUMN_LAT];
        var lon = map[LOGSDATA_COLUMN_LON];
        var coordsList = log[2];
        coordsList.add(LatLng(lat, lon));
      }
    });

    List<Polyline> lines = [];
    logs.forEach((key, list) {
      var color = list[0];
      var width = list[1];
      var points = list[2];
      lines.add(
          Polyline(points: points, strokeWidth: width, color: ColorExt(color)));
    });

    return PolylineLayerOptions(
      polylines: lines,
    );
  }
}