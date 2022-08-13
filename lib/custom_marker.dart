import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'; // ignore: unnecessary_import
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';
import 'page.dart';

import 'bottom_sheet/bottom_sheet_bar_icon.dart';
import 'bottom_sheet/bottom_sheet_expandable_bar.dart';

import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';

const randomMarkerNum = 100;

class CustomMarkerPage extends ExamplePage {
  CustomMarkerPage() : super(const Icon(Icons.place), 'Custom marker');

  @override
  Widget build(BuildContext context) {
    return CustomMarker();
  }
}

class CustomMarker extends StatefulWidget {
  const CustomMarker();

  @override
  State createState() => CustomMarkerState();
}

///////////////////////
class CustomMarkerState extends State<CustomMarker> {
  var active_popup;
  var popup_tap;

  Map<String, String> pin_popup_map = {};
  final Random _rnd = new Random();
  Icon _location_icon = Icon(Icons.my_location_outlined);

  late MapboxMapController _mapController;
  List<Marker> _markers = [];
  List<_MarkerState> _markerStates = [];

  MyLocationTrackingMode _myLocationTrackingMode =
      MyLocationTrackingMode.Tracking;
  bool _myLocationEnabled = true;

  //////Screenshotting
  int _counter = 0;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  String container_text = "heelo";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  ///////////////place_symbol add function

  int _symbolCount = 0;

  void _add(String iconImage, LatLng geometry, double opacity) {
    List<int> availableNumbers =
        Iterable<int>.generate(120).toList(); //max number of symbols
    _mapController.symbols.forEach(
        (s) => availableNumbers.removeWhere((i) => i == s.data!['count']));
    if (availableNumbers.isNotEmpty) {
      _mapController.addSymbol(
          _getSymbolOptions(
              iconImage, availableNumbers.first, geometry, opacity),
          {'count': availableNumbers.first});
      setState(() {
        _symbolCount += 1;
      });
      _mapController.onSymbolTapped.add(_onSymbolTapped);
      print(_mapController.symbols.last.id);
      pin_popup_map[_mapController.symbols.last.id] = "";
    }
  }

  SymbolOptions _getSymbolOptions(
      String iconImage, int symbolCount, LatLng geometry, double opacity) {
    // LatLng geometry = LatLng(
    //     //center.latitude + sin(symbolCount * pi / 6.0) / 20.0,
    //     //center.longitude + cos(symbolCount * pi / 6.0) / 20.0,
    //     0,
    //     0);
    return iconImage == 'customFont'
        ? SymbolOptions(
            geometry: geometry,
            iconImage: 'airport-15',
            fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
            textField: 'Airport',
            textSize: 12.5,
            textOffset: Offset(0, 0.8),
            textAnchor: 'top',
            textColor: '#000000',
            textHaloBlur: 1,
            textHaloColor: '#ffffff',
            textHaloWidth: 0.8,
          )
        : SymbolOptions(
            geometry: geometry,
            textField: 'Tap to Enter Some Text',
            //textOffset: Offset(0, 0.8),
            iconImage: iconImage,
            textSize: 0,
            textOffset: Offset(0, -5.5),
            iconAnchor: 'bottom',
            iconOpacity: opacity,
            textHaloWidth: 1,
            textColor: Colors.black.toHexStringRGB(),
            //textHaloColor: Colors.black.toHexStringRGB(),
          );
  }
  ////////////////////////////////////////////////////////
  ///
  ///

  void _addMarkerStates(_MarkerState markerState) {
    _markerStates.add(markerState);
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
    _mapController.setSymbolIconAllowOverlap(true);
    controller.addListener(() {
      if (controller.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
  }

  void _onStyleLoadedCallback() {
    print('onStyleLoadedCallback');
  }

//////////////////////////////////

  void _onMapLongClickCallback(Point<double> point, LatLng coordinates) {
    HapticFeedback.vibrate();
    _add("assets/pin_blue.png", coordinates, 1);
  }

  void _onMapClickCallback(Point<double> point, LatLng coordinates) {
    HapticFeedback.vibrate();
    if (active_popup != null) {
      _mapController.updateSymbol(
        active_popup,
        SymbolOptions(textSize: 0, iconImage: "assets/pin_blue.png"),
      );
      active_popup = null;
    }
  }

  // Future<void> _generatePopup(String pin_id) async {
  //   String dir = (await getApplicationDocumentsDirectory()).path;
  //   String savePath = '$dir/$pin_id.png';
  //   container_text = "$pin_id";

  //   screenshotController
  //       .captureFromWidget(
  //           InheritedTheme.captureAll(
  //               context,
  //               Material(
  //                   child: Container(
  //                       padding: const EdgeInsets.all(30.0),
  //                       decoration: BoxDecoration(
  //                         border:
  //                             Border.all(color: Colors.blueAccent, width: 5.0),
  //                         color: Colors.redAccent,
  //                       ),
  //                       child: Text(
  //                         container_text,
  //                         style: TextStyle(fontWeight: FontWeight.bold),
  //                       )))),
  //           delay: Duration(seconds: 1))
  //       .then((capturedImage) {
  //     File(savePath).writeAsBytes(capturedImage);
  //     _mapController.addImage('$pin_id', capturedImage);
  //   });

  //   //_add("assets/pin_blue.png", coordinates, 1);

  //   //setState(() => BottomBarSheetState.showSecondState = true);
  // }
//////////////////////////////////////

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    _mapController.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        _markerStates[i].updatePosition(points[i]);
      });
    });
  }

  void _addMarker(Point<double> point, LatLng coordinates) {
    setState(() {
      _markers.add(Marker(_rnd.nextInt(100000).toString(), coordinates, point,
          _addMarkerStates));
    });
  }

  ////Tapping
  void _onSymbolTapped(Symbol symbol) {
    //print(symbol.id);

    //print(symbol.options.geometry as LatLng);
    if (active_popup == null) {
      active_popup = symbol;
      _mapController.updateSymbol(
          symbol,
          SymbolOptions(
              //textField: "Red-Winged Blackbird",
              textSize: 20,
              iconImage: "assets/pin_blue_popped.png",
              textOffset: Offset(0, -5.5)));
      active_popup = symbol;
      popup_tap += 1;
    } else if (active_popup != symbol) {
      _mapController.updateSymbol(
        active_popup,
        SymbolOptions(textSize: 0, iconImage: "assets/pin_blue.png"),
      );
      _mapController.updateSymbol(
          symbol,
          SymbolOptions(
              //textField: "Red-Winged Blackbird",
              textSize: 20,
              iconImage: "assets/pin_blue_popped.png",
              textOffset: Offset(0, -5.5)));
      active_popup = symbol;
      popup_tap += 1;
    } else if (symbol.options.iconImage == "assets/pin_blue_popped.png") {
      BottomBarSheetState.popped_symbol = symbol;
      BottomBarSheetState.mapController = _mapController;
      setState(() => BottomBarSheetState.showSecondState = true);
      // _mapController.updateSymbol(
      //     symbol,
      //     SymbolOptions(
      //       textField: "Blue Footed Boobie",
      //     ));
    }
    print(popup_tap);
    //print(_mapController.cameraPosition?.zoom); //check for clustered markers?
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      new Scaffold(
        body: Stack(children: [
          MapboxMap(
            accessToken: MapsDemo.ACCESS_TOKEN,
            trackCameraPosition: true,
            onMapCreated: _onMapCreated,
            onMapLongClick: _onMapLongClickCallback,
            onMapClick: _onMapClickCallback,
            onCameraIdle: _onCameraIdleCallback,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            compassEnabled: true,
            myLocationEnabled: _myLocationEnabled,
            myLocationTrackingMode: _myLocationTrackingMode,
            //myLocationRenderMode: MyLocationRenderMode.GPS,
            initialCameraPosition: const CameraPosition(
                target: LatLng(35.0, 135.0),
                zoom: 18), //Replace with last known location?
          ),
          IgnorePointer(
              ignoring: true,
              child: Stack(
                children: _markers,
              ))
        ]),
        bottomSheet: null,
      ),
      Align(
          alignment: Alignment.bottomRight,
          child: Padding(
              padding: EdgeInsets.only(bottom: 90, right: 4.5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                ),
                onPressed: () {
                  if (_myLocationEnabled) {
                    setState(
                      () => _location_icon =
                          Icon(Icons.location_disabled_outlined),
                    );
                    setState(() => _myLocationEnabled = false);
                    setState(() =>
                        _myLocationTrackingMode = MyLocationTrackingMode.None);
                  } else {
                    setState(
                      () => _location_icon = Icon(Icons.my_location_outlined),
                    );
                    setState(() => _myLocationEnabled = true);
                    setState(() => _myLocationTrackingMode =
                        MyLocationTrackingMode.Tracking);
                  }
                },
                child: _location_icon,
              ))),
      Align(
        alignment: Alignment.bottomCenter,
        child: BottomBarSheet(
          children: [
            BottomSheetBarIcon(
              icon: Icon(Icons.map),
              color: Colors.redAccent,
              onTap: () {},
            ),
            BottomSheetBarIcon(
              icon: Icon(Icons.search),
              color: Colors.blueAccent,
              onTap: () {},
            ),
            BottomSheetBarIcon(
              icon: Icon(Icons.list_rounded),
              color: Colors.blue[800],
              onTap: () {},
            ),
            BottomSheetBarIcon(
              icon: Icon(Icons.person),
              color: Colors.orangeAccent,
              onTap: () {},
            ),
          ],
        ),
      )
    ]);
  }

  // ignore: unused_element
  void _measurePerformance() {
    final trial = 10;
    final batches = [500, 1000, 1500, 2000, 2500, 3000];
    var results = Map<int, List<double>>();
    for (final batch in batches) {
      results[batch] = [0.0, 0.0];
    }

    _mapController.toScreenLocation(LatLng(0, 0));
    Stopwatch sw = Stopwatch();

    for (final batch in batches) {
      //
      // primitive
      //
      for (var i = 0; i < trial; i++) {
        sw.start();
        var list = <Future<Point<num>>>[];
        for (var j = 0; j < batch; j++) {
          var p = _mapController
              .toScreenLocation(LatLng(j.toDouble() % 80, j.toDouble() % 300));
          list.add(p);
        }
        Future.wait(list);
        sw.stop();
        results[batch]![0] += sw.elapsedMilliseconds;
        sw.reset();
      }

      //
      // batch
      //
      for (var i = 0; i < trial; i++) {
        sw.start();
        var param = <LatLng>[];
        for (var j = 0; j < batch; j++) {
          param.add(LatLng(j.toDouble() % 80, j.toDouble() % 300));
        }
        Future.wait([_mapController.toScreenLocationBatch(param)]);
        sw.stop();
        results[batch]![1] += sw.elapsedMilliseconds;
        sw.reset();
      }

      print(
          'batch=$batch,primitive=${results[batch]![0] / trial}ms, batch=${results[batch]![1] / trial}ms');
    }
  }
}

class Marker extends StatefulWidget {
  final Point _initialPosition;
  final LatLng _coordinate;
  final void Function(_MarkerState) _addMarkerState;

  Marker(
      String key, this._coordinate, this._initialPosition, this._addMarkerState)
      : super(key: Key(key));

  @override
  State<StatefulWidget> createState() {
    final state = _MarkerState(_initialPosition);
    _addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State with TickerProviderStateMixin {
  final _iconSize = 20.0;

  Point _position;

  late AnimationController _controller;
  late Animation<double> _animation;

  _MarkerState(this._position);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }

    return Positioned(
        left: _position.x / ratio - _iconSize / 2,
        top: _position.y / ratio - _iconSize / 2,
        child: RotationTransition(
            turns: _animation,
            child: Image.asset('airport-15', height: _iconSize)));
  }

  void updatePosition(Point<num> point) {
    setState(() {
      _position = point;
    });
  }

  LatLng getCoordinate() {
    return (widget as Marker)._coordinate;
  }
}
