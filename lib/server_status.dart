import 'dart:async';
import 'dart:convert';

import 'package:app_server_companion/logging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ServerStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ServerStatusState();
}

class ServerStatusState extends State<ServerStatus> {
  static const String _healthUrl = "http://10.181.135.95:8080/actuator/health";
  static const int _pollIntervalSeconds = 60;

  String _status;
  Icon _connectionIcon;

  static const String _TAG = "ServerStatus";

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: _pollIntervalSeconds), (Timer t) {
      _updateConnectionStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10),
            child: _connectionIcon,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.all(10), child: Text("Status: $_status")),
            ),
          )
        ],
      ),
      elevation: 20,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Future<void> _updateConnectionStatus() async {
    Response _response;
    try {
      _response = await get(_healthUrl);

      if (_response.statusCode == 200) {
        setState(() {
          dynamic body = jsonDecode(_response.body);
          _status = body;
          _connectionIcon = Icon(
            Icons.brightness_1,
            color: Colors.green,
          );
        });
      } else {
        throw Exception(
            "Code: ${_response.statusCode}, Message: ${_response.reasonPhrase}");
      }
    } on Exception catch (e) {
      Logging.log(_TAG, e.toString());
      setState(() {
        _status = e.toString();
        _connectionIcon = Icon(
          Icons.brightness_1,
          color: Colors.red,
        );
      });
    }
  }
}
