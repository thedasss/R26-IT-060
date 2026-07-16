import 'package:flutter/material.dart';
import '../services/zone_api_service.dart';

class ViewZonesPage extends StatefulWidget {
  const ViewZonesPage({super.key});

  @override
  State<ViewZonesPage> createState() => _ViewZonesPageState();
}

class _ViewZonesPageState extends State<ViewZonesPage> {
  List zones = [];
  bool isLoading = true;

  Future<void> loadZones() async {
    setState(() => isLoading = true);

    try {
      final response = await ZoneApiService.getAllZones();
      setState(() {
        zones = response["zones"] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> deleteZone(String zoneId) async {
    try {
      final response = await ZoneApiService.deleteZone(zoneId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"].toString())),
      );

      loadZones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Zones"),
        actions: [
          IconButton(
            onPressed: loadZones,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : zones.isEmpty
              ? const Center(child: Text("No zones found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: zones.length,
                  itemBuilder: (context, index) {
                    final zone = zones[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          zone["zone_name"] ?? "Unnamed Zone",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Lat: ${zone["min_lat"]} - ${zone["max_lat"]}\n"
                          "Lon: ${zone["min_lon"]} - ${zone["max_lon"]}\n"
                          "Alt: ${zone["min_alt"]} - ${zone["max_alt"]}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteZone(zone["zone_id"]);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}