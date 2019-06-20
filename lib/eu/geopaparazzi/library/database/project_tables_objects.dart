/*
 * Copyright (c) 2019. Antonello Andrea (www.hydrologis.com). All rights reserved.
 * Use of this source code is governed by a GPL3 license that can be
 * found in the LICENSE file.
 */
import 'package:sqflite/sqflite.dart';
import 'package:latlong/latlong.dart';
import 'package:geopaparazzi_light/eu/geopaparazzi/library/utils/utils.dart';

/////////////////////////////////////
/////////////////////////////////////
/// TABLE NAMES
/////////////////////////////////////
/////////////////////////////////////

final String TABLE_NOTES = "notes";
final String TABLE_GPSLOGS = "gpslogs";
final String TABLE_GPSLOG_PROPERTIES = "gpslogsproperties";
final String TABLE_GPSLOG_DATA = "gpslogsdata";

/////////////////////////////////////
/////////////////////////////////////
/// NOTES
/////////////////////////////////////
/////////////////////////////////////

/*
 * id of the note, Generated by the db.
 */
final String NOTES_COLUMN_ID = "_id";
/*
 * Longitude of the note in WGS84.
 */
final String NOTES_COLUMN_LON = "lon";
/*
 * Latitude of the note in WGS84.
 */
final String NOTES_COLUMN_LAT = "lat";
/*
 * Elevation of the note.
 */
final String NOTES_COLUMN_ALTIM = "altim";
/*
 * Timestamp of the note.
 */
final String NOTES_COLUMN_TS = "ts";
/*
 * Description of the note.
 */
final String NOTES_COLUMN_DESCRIPTION = "description";
/*
 * Simple text of the note.
 */
final String NOTES_COLUMN_TEXT = "text";
/*
 * Form data of the note.
 */
final String NOTES_COLUMN_FORM = "form";
/*
 * Is dirty field =0 = false, 1 = true)
 */
final String NOTES_COLUMN_ISDIRTY = "isdirty";
/*
 * Style of the note.
 */
final String NOTES_COLUMN_STYLE = "style";

class Note {
  int id;
  String text;
  String description;
  int timeStamp;
  double lon;
  double lat;
  double altim;
  String style;
  String form;
  int isDirty = 1;

  Map<String, dynamic> toMap() {
    var map = {
      NOTES_COLUMN_LAT: lat,
      NOTES_COLUMN_LON: lon,
      NOTES_COLUMN_TS: timeStamp,
      NOTES_COLUMN_TEXT: text,
      NOTES_COLUMN_ISDIRTY: isDirty,
    };
    if (id != null) {
      map[NOTES_COLUMN_ID] = id;
    }
    if (form != null) {
      map[NOTES_COLUMN_FORM] = form;
    }
    if (altim != null) {
      map[NOTES_COLUMN_ALTIM] = altim;
    }
    if (description != null) {
      map[NOTES_COLUMN_DESCRIPTION] = description;
    }
    if (style != null) {
      map[NOTES_COLUMN_STYLE] = style;
    }
    return map;
  }
}

/////////////////////////////////////
/////////////////////////////////////
/// LOGS
/////////////////////////////////////
/////////////////////////////////////

/*
 * id of the log, Generated by the db.
 */
final String LOGS_COLUMN_ID = "_id";
/*
 * the start UTC timestamp.
 */
final String LOGS_COLUMN_STARTTS = "startts";
/*
 * the end UTC timestamp.
 */
final String LOGS_COLUMN_ENDTS = "endts";
/*
 * The length of the track in meters, as last updated.
 */
final String LOGS_COLUMN_LENGTHM = "lengthm";
/*
 * Is dirty field =0=false, 1=true)
 */
final String LOGS_COLUMN_ISDIRTY = "isdirty";
/*
 * the name of the log.
 */
final String LOGS_COLUMN_TEXT = "text";

/*
 * id of the log, Generated by the db.
 */
final String LOGSPROP_COLUMN_ID = "_id";
/*
 * field for log visibility.
 */
final String LOGSPROP_COLUMN_VISIBLE = "visible";
/*
 * the lgo stroke width.
 */
final String LOGSPROP_COLUMN_WIDTH = "width";
/*
 * the log stroke color.
 */
final String LOGSPROP_COLUMN_COLOR = "color";
/*
 * the id of the parent gps log.
 */
final String LOGSPROP_COLUMN_LOGID = "logid";

/*
 * id of the log point, Generated by the db.
 */
final String LOGSDATA_COLUMN_ID = "_id";
/*
 * the longitude of the point.
 */
final String LOGSDATA_COLUMN_LON = "lon";
/*
 * the latitude of the point.
 */
final String LOGSDATA_COLUMN_LAT = "lat";
/*
 * the elevation of the point.
 */
final String LOGSDATA_COLUMN_ALTIM = "altim";
/*
 * the UTC timestamp
 */
final String LOGSDATA_COLUMN_TS = "ts";
/*
 * the id of the parent gps log.
 */
final String LOGSDATA_COLUMN_LOGID = "logid";

class Log {
  int id;
  int startTime;
  int endTime;
  double lengthm;
  String text;
  int isDirty;

  List<LatLng> logData = [];

  Map<String, dynamic> toMap() {
    var map = {
      LOGS_COLUMN_STARTTS: startTime,
      LOGS_COLUMN_ENDTS: endTime,
      LOGS_COLUMN_LENGTHM: lengthm,
      LOGS_COLUMN_TEXT:
          text == null ? ISO8601_TS_FORMATTER.format(new DateTime.now()) : text,
      LOGS_COLUMN_ISDIRTY: isDirty,
    };
    if (id != null) {
      map[LOGS_COLUMN_ID] = id;
    }
    return map;
  }
}

class LogProperty {
  int id;
  int isVisible;
  double width;
  String color;
  int logid;

  Map<String, dynamic> toMap() {
    var map = {
      LOGSPROP_COLUMN_COLOR: color,
      LOGSPROP_COLUMN_VISIBLE: isVisible,
      LOGSPROP_COLUMN_WIDTH: width,
      LOGSPROP_COLUMN_LOGID: logid,
    };
    if (id != null) {
      map[LOGSPROP_COLUMN_ID] = id;
    }
    return map;
  }
}

class LogDataPoint {
  int id;
  double lon;
  double lat;
  double altim;
  int ts;
  int logid;

  Map<String, dynamic> toMap() {
    var map = {
      LOGSDATA_COLUMN_LAT: lat,
      LOGSDATA_COLUMN_LON: lon,
      LOGSDATA_COLUMN_ALTIM: altim,
      LOGSDATA_COLUMN_TS: ts,
      LOGSDATA_COLUMN_LOGID: logid,
    };
    if (id != null) {
      map[LOGSDATA_COLUMN_ID] = id;
    }
    return map;
  }
}
