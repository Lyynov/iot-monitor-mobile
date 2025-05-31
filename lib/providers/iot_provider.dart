import 'package:flutter/foundation.dart';
import '../models/node_model.dart';
import '../services/api_service.dart';

class IoTProvider with ChangeNotifier {
  DashboardSummary? _summary;
  List<NodeData> _nodes = [];
  List<HistoryData> _historyData = [];
  NodeData? _selectedNode;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdate;

  // Getters
  DashboardSummary? get summary => _summary;
  List<NodeData> get nodes => _nodes;
  List<HistoryData> get historyData => _historyData;
  NodeData? get selectedNode => _selectedNode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdate => _lastUpdate;

  // Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getDashboardData();
      _summary = data['summary'];
      _nodes = data['nodes'];
      _lastUpdate = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select node and load history
  Future<void> selectNode(NodeData node) async {
    _selectedNode = node;
    notifyListeners();

    try {
      _historyData = await ApiService.getNodeHistory(node.nodeId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load history: $e';
      notifyListeners();
    }
  }

  // Control node
  Future<bool> controlNode(int nodeId, bool manualMode, bool relayCommand) async {
    try {
      final success = await ApiService.controlNode(nodeId, manualMode, relayCommand);
      if (success) {
        // Refresh data after successful control
        await loadDashboardData();
      }
      return success;
    } catch (e) {
      _error = 'Failed to control node: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadDashboardData();
    if (_selectedNode != null) {
      await selectNode(_selectedNode!);
    }
  }
}