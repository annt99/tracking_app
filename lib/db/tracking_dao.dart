import 'package:tracking_app/db/database.dart';
import 'package:tracking_app/model/tracking_location_model.dart';

class TrackingDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> saveLocation(TrackingLocation location) async {
    var dbClient = await dbProvider.database;
    int res = await dbClient!.insert(tableTracking, location.toJson());
    return res;
  }

  Future<int> deleteLocation(int id) async {
    var dbClient = await dbProvider.database;
    int res =
        await dbClient!.delete(tableTracking, where: 'id = ?', whereArgs: [id]);
    return res;
  }

  Future<List<TrackingLocation>> getAllTrackingLocations() async {
    var dbClient = await dbProvider.database;
    final maps = await dbClient!.query(tableTracking);
    if (maps.isNotEmpty) {
      return maps.map((e) => TrackingLocation.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> deleteAllData() async {
    var dbClient = await dbProvider.database;
    await dbClient!.delete(tableTracking);
  }
}
