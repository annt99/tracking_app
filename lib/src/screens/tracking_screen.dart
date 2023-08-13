import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracking_app/db/tracking_dao.dart';
import 'package:tracking_app/model/tracking_location_model.dart';
import 'package:tracking_app/src/screens/map_view.dart';
import 'package:tracking_app/src/utils/utils.dart';
import 'package:background_location/background_location.dart' as BgLocation;

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool isTracking = false;
  Set<TrackingLocation> locations = {};
  TrackingDao trackingDao = TrackingDao();

  @override
  void initState() {
    super.initState();
    getAllLocation();
  }

  Future<void> getAllLocation() async {
    final _locations = await trackingDao.getAllTrackingLocations();
    setState(() {
      locations.addAll(_locations);
    });
  }

  startTracking() async {
    await BgLocation.BackgroundLocation.setAndroidNotification(
      title: 'Background service is running',
      message: 'Background location in progress',
      icon: '@mipmap/ic_launcher',
    );
    await BgLocation.BackgroundLocation.startLocationService();
    BgLocation.BackgroundLocation.getLocationUpdates((location) async {
      print('test location');
      addLocation(location.latitude ?? 0, location.longitude ?? 0);
    });
  }

  stopTracking() async {
    await BgLocation.BackgroundLocation.stopLocationService();
  }

  Future<void> addLocation(double lat, double lng) async {
    double minDistanceThreshold = 100.0;

    if (locations.isNotEmpty) {
      if (lat != locations.last.lat && lng != locations.last.lng) {
        double distance = Geolocator.distanceBetween(
            locations.last.lat, locations.last.lng, lat, lng);
        print('test distance : $distance');

        if (distance > minDistanceThreshold) {
          final String address = await Utils.getAddressFromPosition(lat, lng);
          final time = DateTime.now().millisecondsSinceEpoch;
          final trackingLocation =
              TrackingLocation(id: time, lat: lat, lng: lng, address: address);
          if (!locations.contains(trackingLocation)) {
            locations.add(trackingLocation);
            await trackingDao.saveLocation(trackingLocation);
          }
        }
      }
    } else {
      print('test distance 1');
      final String address = await Utils.getAddressFromPosition(lat, lng);
      final time = DateTime.now().millisecondsSinceEpoch;
      final trackingLocation =
          TrackingLocation(id: time, lat: lat, lng: lng, address: address);
      locations.add(trackingLocation);
      await trackingDao.saveLocation(trackingLocation);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location History',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 65,
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xff40A9F8), Color(0xff1CCBCB)],
            stops: [0, 1],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )),
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              colors: [Color(0xff40A9F8), Color(0xff1CCBCB)],
              stops: [0, 1],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )),
          ),
          ClipPath(
            clipper: TopBorderRadiusClipper(),
            child: Container(
                color: const Color.fromARGB(255, 240, 240, 240),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                          title: const Text(
                            'Turn On/Off Location History',
                            style: TextStyle(fontSize: 15),
                          ),
                          trailing: CupertinoSwitch(
                            value: isTracking,
                            onChanged: (value) {
                              setState(() {
                                isTracking = value;
                              });
                              if (isTracking) {
                                startTracking();
                              } else {
                                stopTracking();
                              }
                            },
                          )),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                        child: locations.isEmpty
                            ? const Center(child: Text('No location'))
                            : ListView.builder(
                                itemCount: locations.length,
                                itemBuilder: (context, index) {
                                  final item = locations.elementAt(index);
                                  final previousDate = index > 0
                                      ? Utils.getDate(
                                          locations.elementAt(index).id)
                                      : null;
                                  final currentDate = Utils.getDate(item.id);
                                  final showDateHeader =
                                      currentDate != previousDate;
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GoogleMapsWebViewScreen(
                                          latitude: item.lat,
                                          longitude: item.lng,
                                          label: item.address,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showDateHeader)
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 10, top: 10),
                                            child: Text(
                                              currentDate.split(' ').first,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              locations
                                                  .elementAt(index)
                                                  .address,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  currentDate.split(' ').last,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: const Icon(
                                                      Icons.more_vert),
                                                  offset: const Offset(20, 50),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                  onSelected: (value) {
                                                    // Handle menu item selection
                                                    if (value == 'save') {
                                                      // Handle Option 1
                                                    } else if (value ==
                                                        'share') {
                                                      // Handle Option 2
                                                    } else if (value ==
                                                        'delete') {
                                                      setState(() {
                                                        trackingDao
                                                            .deleteLocation(
                                                                locations
                                                                    .elementAt(
                                                                        index)
                                                                    .id);
                                                        locations.remove(
                                                            locations.elementAt(
                                                                index));
                                                      });
                                                    }
                                                  },
                                                  itemBuilder:
                                                      (BuildContext context) {
                                                    return [
                                                      PopupMenuItem<String>(
                                                        value: 'save',
                                                        child: SizedBox(
                                                          width: 100,
                                                          child: Row(
                                                            children: [
                                                              Image.asset(
                                                                  'assets/images/save.png'),
                                                              const SizedBox(
                                                                  width: 15),
                                                              const Text(
                                                                  'Save'),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      PopupMenuItem<String>(
                                                          value: 'share',
                                                          child: SizedBox(
                                                            width: 100,
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                    'assets/images/share.png'),
                                                                const SizedBox(
                                                                    width: 15),
                                                                const Text(
                                                                    'Share'),
                                                              ],
                                                            ),
                                                          )),
                                                      PopupMenuItem<String>(
                                                          value: 'delete',
                                                          child: SizedBox(
                                                            width: 100,
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                    'assets/images/delete.png'),
                                                                const SizedBox(
                                                                    width: 15),
                                                                const Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                    ];
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ))
                  ],
                )),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () async {
          try {
            await Geolocator.requestPermission();
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
            );
            addLocation(position.latitude, position.longitude);
          } catch (e) {
            print('Error getting location: $e');
          }
        },
        child: Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              gradient: LinearGradient(
                colors: [Color(0xff40A9F8), Color(0xff1CCBCB)],
                stops: [0, 1],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )),
          child: const Text(
            '+ Mark Location',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class TopBorderRadiusClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = Radius.circular(20.0); // Adjust the radius as needed
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, radius.y)
      ..arcToPoint(Offset(radius.x, 0), radius: radius)
      ..lineTo(size.width - radius.x, 0)
      ..arcToPoint(Offset(size.width, radius.y), radius: radius)
      ..lineTo(size.width, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(TopBorderRadiusClipper oldClipper) => false;
}
