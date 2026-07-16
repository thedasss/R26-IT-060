import 'package:flutter/material.dart';
import '../services/zone_api_service.dart';
import '../services/location_service.dart';

class CreateZonePage extends StatefulWidget {
  const CreateZonePage({super.key});

  @override
  State<CreateZonePage> createState() => _CreateZonePageState();
}

class _CreateZonePageState extends State<CreateZonePage> {
  final zoneNameController = TextEditingController();

  List<Map<String, dynamic>?> points = List.generate(4, (_) => null);

  bool isLoading = false;

  Future<void> capturePoint(int index) async {
    try {
      final point = await LocationService.getCurrentPoint();

      setState(() {
        points[index] = point;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Point ${index + 1} captured")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location error: $e")),
      );
    }
  }

  Future<void> createZone() async {
    if (zoneNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter zone name")),
      );
      return;
    }

    if (points.any((point) => point == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please capture all 4 points")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ZoneApiService.createZone(
        zoneName: zoneNameController.text.trim(),
        points: points.map((point) => point!).toList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"].toString())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Create zone failed: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  Widget buildPointCard(int index) {
    final point = points[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Point ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (point == null)
              const Text("Not captured yet")
            else
              Text(
                "Latitude: ${point["latitude"]}\n"
                "Longitude: ${point["longitude"]}\n"
                "Altitude: ${point["altitude"]}",
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => capturePoint(index),
                icon: const Icon(Icons.my_location),
                label: Text(
                  point == null
                      ? "Capture Point ${index + 1}"
                      : "Retake Point ${index + 1}",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    zoneNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final capturedCount = points.where((point) => point != null).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Zone"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: zoneNameController,
              decoration: const InputDecoration(
                labelText: "Zone Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "$capturedCount / 4 points captured",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            ...List.generate(4, buildPointCard),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : createZone,
                child: Text(isLoading ? "Creating..." : "Create Zone"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}