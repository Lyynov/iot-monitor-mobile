import '../models/node_model.dart';

class DemoDataService {
  // Demo dashboard summary data
  static DashboardSummary getDemoSummary() {
    return DashboardSummary(
      totalNodes: 6,
      activeRelays: 4,
      manualNodes: 2,
      avgTemperature: 28.5,
      avgHumidity: 65.2,
      avgTds: 245.8,
    );
  }

  // Demo nodes data
  static List<NodeData> getDemoNodes() {
    final now = DateTime.now();
    
    return [
      NodeData(
        nodeId: 1,
        nodeType: 'Sensor',
        temperature: 29.5,
        humidity: 68.2,
        tds: 234.5,
        relayState: true,
        manualMode: false,
        timestamp: now.subtract(Duration(minutes: 2)).toIso8601String(),
      ),
      NodeData(
        nodeId: 2,
        nodeType: 'Controller',
        temperature: 27.8,
        humidity: 62.1,
        tds: 198.3,
        relayState: false,
        manualMode: true,
        timestamp: now.subtract(Duration(minutes: 5)).toIso8601String(),
      ),
      NodeData(
        nodeId: 3,
        nodeType: 'Relay',
        temperature: 30.2,
        humidity: 71.5,
        tds: 267.9,
        relayState: true,
        manualMode: false,
        timestamp: now.subtract(Duration(minutes: 1)).toIso8601String(),
      ),
      NodeData(
        nodeId: 4,
        nodeType: 'Sensor',
        temperature: 26.9,
        humidity: 58.7,
        tds: 189.2,
        relayState: true,
        manualMode: true,
        timestamp: now.subtract(Duration(minutes: 3)).toIso8601String(),
      ),
      NodeData(
        nodeId: 5,
        nodeType: 'Controller',
        temperature: 31.1,
        humidity: 74.3,
        tds: 298.6,
        relayState: false,
        manualMode: false,
        timestamp: now.subtract(Duration(minutes: 7)).toIso8601String(),
      ),
      NodeData(
        nodeId: 6,
        nodeType: 'Sensor',
        temperature: 28.7,
        humidity: 66.8,
        tds: 223.4,
        relayState: true,
        manualMode: false,
        timestamp: now.subtract(Duration(minutes: 4)).toIso8601String(),
      ),
    ];
  }

  // Demo history data for a specific node
  static List<HistoryData> getDemoHistory(int nodeId, {int hours = 24}) {
    final now = DateTime.now();
    final List<HistoryData> history = [];
    
    // Generate demo data for the last 24 hours (every 30 minutes)
    for (int i = 0; i < hours * 2; i++) {
      final timestamp = now.subtract(Duration(minutes: i * 30));
      
      // Simulate realistic sensor variations
      final baseTemp = 28.0 + (i % 10) * 0.5 + (i % 3) * 0.2;
      final baseHumidity = 65.0 + (i % 8) * 2.0 + (i % 5) * 1.5;
      final baseTds = 240.0 + (i % 12) * 10.0 + (i % 7) * 5.0;
      
      // Add some randomness
      final tempVariation = (i % 7) * 0.3 - 1.0;
      final humidityVariation = (i % 9) * 1.0 - 4.0;
      final tdsVariation = (i % 11) * 8.0 - 20.0;
      
      history.add(HistoryData(
        id: i + 1,
        nodeId: nodeId,
        nodeType: 'Sensor',
        temperature: baseTemp + tempVariation,
        humidity: baseHumidity + humidityVariation,
        tds: baseTds + tdsVariation,
        relayState: i % 4 != 0, // Relay on most of the time
        timestamp: timestamp.toIso8601String(),
      ));
    }
    
    return history.reversed.toList(); // Return chronological order
  }

  // Simulate network delay
  static Future<void> simulateNetworkDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + (DateTime.now().millisecond % 1000)));
  }
}
