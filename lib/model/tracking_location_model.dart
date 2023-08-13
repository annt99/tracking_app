const String tableTracking = "Tracking";
final trackingTableColumns = <String>['id', 'lat', 'lng', 'address'];

class TrackingLocation {
  TrackingLocation({
    required this.id,
    required this.lat,
    required this.lng,
    required this.address,
  });
  final int id;
  final double lat;
  final double lng;
  final String address;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingLocation &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;

  Map<String, dynamic> toJson() {
    return {
      trackingTableColumns[0]: id,
      trackingTableColumns[1]: lat,
      trackingTableColumns[2]: lng,
      trackingTableColumns[3]: address.toString()
    };
  }

  factory TrackingLocation.fromJson(Map<String, dynamic> json) {
    return TrackingLocation(
      id: json["id"],
      lat: json["lat"],
      lng: json["lng"],
      address: json["address"],
    );
  }
}
