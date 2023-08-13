import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:tracking_app/db/tracking_dao.dart';
import 'package:tracking_app/model/tracking_location_model.dart';
import 'package:tracking_app/src/screens/map_view.dart';
import 'package:tracking_app/src/screens/tracking_service.dart';
import 'package:tracking_app/src/utils/utils.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool isTracking = false;
  TrackingDao trackingDao = TrackingDao();
  Set<TrackingLocation> locations = {};

  @override
  void initState() {
    super.initState();
    TrackingService.instance.getAllLocation(() {
      setState(() {
        locations = TrackingService.instance.locations;
      });
    });
    setState(() {
      isTracking = TrackingService.instance.isTracking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.key,
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
                                TrackingService.instance.start(() {
                                  setState(() {
                                    locations =
                                        TrackingService.instance.locations;
                                  });
                                });
                              } else {
                                TrackingService.instance.stop();
                              }
                            },
                          )),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                        child: locations.isEmpty
                            ? const Center(child: Text('No location'))
                            : GroupedListView(
                                elements: locations.toList().reversed.toList(),
                                groupBy: (element) =>
                                    element.group.split(" ").first,
                                groupSeparatorBuilder: (String groupByValue) =>
                                    Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 10, top: 10),
                                      child: Text(
                                        groupByValue,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ),
                                itemBuilder: (context,
                                        TrackingLocation element) =>
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  GoogleMapsWebViewScreen(
                                                    latitude: element.lat,
                                                    longitude: element.lng,
                                                    label: element.address,
                                                  ))),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            element.address,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                element.group.split(' ').last,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              PopupMenuButton<String>(
                                                icon:
                                                    const Icon(Icons.more_vert),
                                                offset: const Offset(20, 50),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                onSelected: (value) {
                                                  // Handle menu item selection
                                                  if (value == 'save') {
                                                    // Handle Option 1
                                                  } else if (value == 'share') {
                                                    // Handle Option 2
                                                  } else if (value ==
                                                      'delete') {
                                                    setState(() {
                                                      trackingDao
                                                          .deleteLocation(
                                                              element.id);
                                                      locations.remove(element);
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
                                                            const Text('Save'),
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
                                    )))
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
            TrackingService.instance
                .addLocation(position.latitude, position.longitude, () {
              setState(() {
                locations = TrackingService.instance.locations;
              });
            });
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
