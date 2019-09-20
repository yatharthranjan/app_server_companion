import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScheduleNotifications extends StatefulWidget {
  static const String restMethodChannelId =
      "org.radarbase.app_server_companion/schedule-rest";
  static const String xmppMethodChannelId =
      "org.radarbase.app_server_companion/schedule-xmpp";
  MethodChannel _methodChannel;

  ScheduleNotifications({Key key, MethodChannel methodChannel})
      : super(key: key) {
    _methodChannel = methodChannel;
  }

  @override
  State<StatefulWidget> createState() =>
      ScheduleNotificationsState(methodChannel: _methodChannel);
}

class ScheduleNotificationsState extends State<ScheduleNotifications> {
  MethodChannel _methodChannel;

  ScheduleNotificationsState({MethodChannel methodChannel}) {
    _methodChannel = methodChannel;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_methodChannel.name == ScheduleNotifications.restMethodChannelId) {
      return Text("REST Schedule");
    } else if (_methodChannel.name == ScheduleNotifications.xmppMethodChannelId) {
      return Text("XMPP Schedule");
    } else {
      return Text("Schedule");
    }
  }
}
