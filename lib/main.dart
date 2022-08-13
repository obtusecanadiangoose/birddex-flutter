// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'page.dart';
import 'place_symbol.dart';
import 'custom_marker.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:flutter/services.dart';

import 'bottom_sheet/bottom_sheet_bar_icon.dart';
import 'bottom_sheet/bottom_sheet_expandable_bar.dart';

import 'package:lottie/lottie.dart';

final List<ExamplePage> _allPages = <ExamplePage>[
  PlaceSymbolPage(),
  CustomMarkerPage()
];

class MapsDemo extends StatefulWidget {
  // FIXME: You need to pass in your access token via the command line argument
  // --dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE
  // It is also possible to pass it in while running the app via an IDE by
  // passing the same args there.
  //
  // Alternatively you can replace `String.fromEnvironment("ACCESS_TOKEN")`
  // in the following line with your access token directly.
  //static const String ACCESS_TOKEN = String.fromEnvironment("ACCESS_TOKEN");

  //use sk for android (and ios I think?)
  static const String ACCESS_TOKEN =
      'sk.eyJ1Ijoib2dpbHZpZWxpYW0iLCJhIjoiY2wyemRlMHNyMDNzdDNwcDY3cGJpZjBjZCJ9.dGfejZYJJpvCZuBGNCab0w';

  //use pk for web
  //static const String ACCESS_TOKEN =
  //    'pk.eyJ1Ijoib2dpbHZpZWxpYW0iLCJhIjoiY2t0cWo5OTdyMHIwNjJ1cXN5dGdrc3UxbiJ9.pYwKqx5yeorTKH62sOrltA';

  @override
  State<MapsDemo> createState() => _MapsDemoState();
}

class _MapsDemoState extends State<MapsDemo> {
  @override
  void initState() {
    super.initState();
  }

  AppBar _appBar = AppBar(
    backgroundColor: Colors.white,
    title: Text(
      "Birddex".toUpperCase(),
      style: TextStyle(fontSize: 19.0, color: Colors.black87),
    ),
    automaticallyImplyLeading: false,
    centerTitle: true,
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color.fromARGB(0, 255, 0, 0),
      statusBarIconBrightness: Brightness.dark,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    return Scaffold(
        //appBar: _appBar,
        extendBody: true,
        body: CustomMarkerPage() //SafeArea(child: CustomMarkerPage()),
        );
  }
}

void main() {
  runApp(MaterialApp(
      theme: ThemeData(
        /// Add this line
        bottomSheetTheme:
            BottomSheetThemeData(backgroundColor: Colors.transparent),
      ),
      home: MapsDemo()));
}
