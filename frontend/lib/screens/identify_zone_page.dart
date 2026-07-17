import 'package:flutter/material.dart';
import '../services/zone_api_service.dart';
import '../services/location_service.dart';

class IdentifyZonePage extends StatefulWidget {
  const IdentifyZonePage({super.key});

  @override
  State<IdentifyZonePage> createState() => _IdentifyZonePageState();
}

class _IdentifyZonePageState extends State<IdentifyZonePage> {
  String result = "Press the button to identify your current zone";
  Map<String, dynamic>? currentPoint;
  bool isLoading = false;

  Future<void> identifyCurrentZone() async {
    setState(() {
      isLoading = true;
      result = "Getting current location...";
      currentPoint = null;
    });

    try {
      final point = await LocationService.getCurrentPoint();

      if (!mounted) return;

      setState(() {
        currentPoint = point;
        result = "Sending location to backend...";
      });

      final response = await ZoneApiService.identifyZone(
        latitude: point["latitude"],
        longitude: point["longitude"],
        altitude: point["altitude"],
      );

      if (!mounted) return;

      if (response["zones"] != null && response["zones"].isNotEmpty) {
        final zones = response["zones"] as List;
        final zoneNames = zones.map((z) => z["zone_name"]).join(", ");

        setState(() {
          result = "Matched Zone: $zoneNames";
        });
      } else if (response["zone_name"] != null) {
        setState(() {
          result = "Matched Zone: ${response["zone_name"]}";
        });
      } else {
        setState(() {
          result = response["message"].toString();
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        result = "Error: $e";
      });
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Widget _locationCard() {
    if (currentPoint == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Current location not captured yet"),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Latitude: ${currentPoint!["latitude"]}\n"
          "Longitude: ${currentPoint!["longitude"]}\n"
          "Altitude: ${currentPoint!["altitude"]}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Identify Zone"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _locationCard(),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : identifyCurrentZone,
                icon: const Icon(Icons.my_location),
                label: Text(
                  isLoading ? "Identifying..." : "Identify My Current Zone",
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              result,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (isLoading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}