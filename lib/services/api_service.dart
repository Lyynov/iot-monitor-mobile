import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/node_model.dart';
import 'demo_data_service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.100:5000/api';
  static const Duration timeout = Duration(seconds: 10);
  
  // Demo mode flag - set to true to use demo data
  static bool isDemoMode = true;

  // Get dashboard data
  static Future<Map<String, dynamic>> getDashboardData() async {
    if (isDemoMode) {
      await DemoDataService.simulateNetworkDelay();
      return {
        'summary': DemoDataService.getDemoSummary(),
        'nodes': DemoDataService.getDemoNodes(),
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'summary': DashboardSummary.fromJson(data['summary']),
          'nodes': (data['nodes'] as List)
              .map((node) => NodeData.fromJson(node))
              .toList(),
        };
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      // Fallback to demo data if real API fails
      print('API Error: $e - Falling back to demo data');
      await DemoDataService.simulateNetworkDelay();
      return {
        'summary': DemoDataService.getDemoSummary(),
        'nodes': DemoDataService.getDemoNodes(),
      };
    }
  }

  // Get node history
  static Future<List<HistoryData>> getNodeHistory(int nodeId, {int hours = 24}) async {
    if (isDemoMode) {
      await DemoDataService.simulateNetworkDelay();
      return DemoDataService.getDemoHistory(nodeId, hours: hours);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$nodeId?hours=$hours'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => HistoryData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load history data');
      }
    } catch (e) {
      // Fallback to demo data if real API fails
      print('API Error: $e - Falling back to demo data');
      await DemoDataService.simulateNetworkDelay();
      return DemoDataService.getDemoHistory(nodeId, hours: hours);
    }
  }

  // Control node
  static Future<bool> controlNode(int nodeId, bool manualMode, bool relayCommand) async {
    if (isDemoMode) {
      await DemoDataService.simulateNetworkDelay();
      // Simulate successful control in demo mode
      print('Demo: Controlling node $nodeId - Manual: $manualMode, Relay: $relayCommand');
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/control/$nodeId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'manual_mode': manualMode,
          'relay_command': relayCommand,
        }),
      ).timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Control Error: $e');
      return false;
    }
  }

  // Health check
  static Future<bool> healthCheck() async {
    if (isDemoMode) {
      await DemoDataService.simulateNetworkDelay();
      return true; // Always healthy in demo mode
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/../health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Save server IP
  static Future<void> saveServerIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
  }

  // Get saved server IP
  static Future<String> getSavedServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? '192.168.1.100';
  }

  // Toggle demo mode
  static void setDemoMode(bool enabled) {
    isDemoMode = enabled;
    print('Demo mode ${enabled ? 'enabled' : 'disabled'}');
  }
}
