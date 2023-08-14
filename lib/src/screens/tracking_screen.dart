import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:tracking_app/db/tracking_dao.dart';
import 'package:tracking_app/model/tracking_location_model.dart';
import 'package:tracking_app/src/screens/tracking_service.dart';
import 'package:tracking_app/src/screens/widgets.dart';

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
      appBar: myAppBar(),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          const GradientBackground(),
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
                                groupComparator: (value1, value2) =>
                                    value2.compareTo(value1),
                                groupBy: (element) =>
                                    element.group.split(" ").first,
                                groupSeparatorBuilder: (String groupByValue) =>
                                    GroupSeparatorItem(value: groupByValue),
                                itemBuilder: (context,
                                        TrackingLocation element) =>
                                    TrackingLocationItem(
                                        element: element,
                                        deleteFunction: () => setState(() {
                                              trackingDao
                                                  .deleteLocation(element.id);
                                              locations.remove(element);
                                            }))))
                  ],
                )),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MaskLocationButton(function: () async {
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
      }),
    );
  }
}
