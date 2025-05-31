
class NodeData {
  final int nodeId;
  final String nodeType;
  final double? temperature;
  final double? humidity;
  final double? tds;
  final bool relayState;
  final bool manualMode;
  final String timestamp;

  NodeData({
    required this.nodeId,
    required this.nodeType,
    this.temperature,
    this.humidity,
    this.tds,
    required this.relayState,
    required this.manualMode,
    required this.timestamp,
  });

  factory NodeData.fromJson(Map<String, dynamic> json) {
    return NodeData(
      nodeId: json['node_id'],
      nodeType: json['node_type'],
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      tds: json['tds']?.toDouble(),
      relayState: json['relay_state'] ?? false,
      manualMode: json['manual_mode'] ?? false,
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class DashboardSummary {
  final int totalNodes;
  final int activeRelays;
  final int manualNodes;
  final double avgTemperature;
  final double avgHumidity;
  final double avgTds;

  DashboardSummary({
    required this.totalNodes,
    required this.activeRelays,
    required this.manualNodes,
    required this.avgTemperature,
    required this.avgHumidity,
    required this.avgTds,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalNodes: json['total_nodes'] ?? 0,
      activeRelays: json['active_relays'] ?? 0,
      manualNodes: json['manual_nodes'] ?? 0,
      avgTemperature: (json['avg_temperature'] ?? 0).toDouble(),
      avgHumidity: (json['avg_humidity'] ?? 0).toDouble(),
      avgTds: (json['avg_tds'] ?? 0).toDouble(),
    );
  }
}

class HistoryData {
  final int id;
  final int nodeId;
  final String nodeType;
  final double? temperature;
  final double? humidity;
  final double? tds;
  final bool relayState;
  final String timestamp;

  HistoryData({
    required this.id,
    required this.nodeId,
    required this.nodeType,
    this.temperature,
    this.humidity,
    this.tds,
    required this.relayState,
    required this.timestamp,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    return HistoryData(
      id: json['id'],
      nodeId: json['node_id'],
      nodeType: json['node_type'],
      temperature: json['temperature']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      tds: json['tds']?.toDouble(),
      relayState: json['relay_state'] ?? false,
      timestamp: json['timestamp'] ?? '',
    );
  }
}