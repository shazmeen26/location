import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NashaMuktiCenter {
  final String name;
  final LatLng location;
  final String information;

  NashaMuktiCenter({required this.name, required this.location, required this.information});
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nasha Mukti Kendra Locator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NashaMuktiKendraLocator(),
    );
  }
}

class NashaMuktiKendraLocator extends StatefulWidget {
  @override
  _NashaMuktiKendraLocatorState createState() => _NashaMuktiKendraLocatorState();
}

class _NashaMuktiKendraLocatorState extends State<NashaMuktiKendraLocator> {
  LocationData? _currentLocation;
  List<NashaMuktiCenter> _centers = [
    NashaMuktiCenter(
      name: 'Center 1',
      location: LatLng(28.6139, 77.209),
      information: 'Information about Center 1',
    ),
    NashaMuktiCenter(
      name: 'Center 2',
      location: LatLng(28.6358, 77.22),
      information: 'Information about Center 2',
    ),
    // Add more centers here
  ];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      _currentLocation = _locationData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nasha Mukti Kendra Locator'),
      ),
      body: _currentLocation != null
          ? Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                zoom: 12.0,
              ),
              layers:[
                TileLayerOptions(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayerOptions(
                  markers: _centers
                      .map((center) => Marker(
                    width: 40.0,
                    height: 40.0,
                    point: center.location,
                    builder: (ctx) => IconButton(
                      icon: Icon(Icons.location_pin),
                      onPressed: () {
                        // Handle marker tap
                        _showCenterDetails(center);
                      },
                    ),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _centers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_centers[index].name),
                  onTap: () {
                    // Handle list item tap
                    _showCenterDetails(_centers[index]);
                  },
                );
              },
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showCenterDetails(NashaMuktiCenter center) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(center.name),
        content: Text(center.information),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
