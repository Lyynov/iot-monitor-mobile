
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/iot_provider.dart';
import '../theme/app_theme.dart';
import '../models/node_model.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class NodeDetailScreen extends StatefulWidget {
  @override
  _NodeDetailScreenState createState() => _NodeDetailScreenState();
}

class _NodeDetailScreenState extends State<NodeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeRange = 24; // Default 24 hours
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IoTProvider>(
      builder: (context, provider, child) {
        final node = provider.selectedNode;
        
        if (node == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Node Detail')),
            body: Center(child: Text('No node selected')),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Node ${node.nodeId} (${node.nodeType})'),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Charts'),
                Tab(text: 'Control'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(node),
              _buildChartsTab(provider),
              _buildControlTab(node, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(NodeData node) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(node),
          SizedBox(height: 24),
          Text(
            'Sensor Readings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          _buildSensorReadings(node),
          SizedBox(height: 24),
          Text(
            'Node Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          _buildNodeInfo(node),
        ],
      ),
    );
  }

  Widget _buildStatusCard(NodeData node) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(node).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(node),
                color: _getStatusColor(node),
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusText(node),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    node.manualMode ? 'Manual Control Mode' : 'Automatic Control Mode',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Last updated: ${_formatTimestamp(node.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorReadings(NodeData node) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (node.temperature != null)
              _buildReadingItem(
                'Temperature',
                '${node.temperature!.toStringAsFixed(1)}°C',
                Icons.thermostat,
                Colors.orange,
              ),
            if (node.humidity != null)
              _buildReadingItem(
                'Humidity',
                '${node.humidity!.toStringAsFixed(1)}%',
                Icons.water_drop,
                Colors.blue,
              ),
            if (node.tds != null)
              _buildReadingItem(
                'TDS',
                '${node.tds!.toStringAsFixed(0)} ppm',
                Icons.science,
                Colors.purple,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNodeInfo(NodeData node) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoItem('Node ID', '${node.nodeId}', Icons.tag),
            _buildInfoItem('Node Type', node.nodeType, Icons.category),
            _buildInfoItem(
              'Relay State',
              node.relayState ? 'Active' : 'Inactive',
              Icons.power,
              valueColor: node.relayState ? AppTheme.activeColor : Colors.grey,
            ),
            _buildInfoItem(
              'Control Mode',
              node.manualMode ? 'Manual' : 'Automatic',
              node.manualMode ? Icons.pan_tool : Icons.auto_mode,
              valueColor: node.manualMode ? AppTheme.manualModeColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab(IoTProvider provider) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historical Data',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              _buildTimeRangeSelector(),
            ],
          ),
        ),
        Expanded(
          child: provider.historyData.isEmpty
              ? Center(child: Text('No historical data available'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (_hasTemperatureData(provider)) ...[
                        _buildChartCard(
                          'Temperature (°C)',
                          _buildTemperatureChart(provider),
                          Colors.orange,
                        ),
                        SizedBox(height: 16),
                      ],
                      if (_hasHumidityData(provider)) ...[
                        _buildChartCard(
                          'Humidity (%)',
                          _buildHumidityChart(provider),
                          Colors.blue,
                        ),
                        SizedBox(height: 16),
                      ],
                      if (_hasTdsData(provider)) ...[
                        _buildChartCard(
                          'TDS (ppm)',
                          _buildTdsChart(provider),
                          Colors.purple,
                        ),
                        SizedBox(height: 16),
                      ],
                      _buildChartCard(
                        'Relay State',
                        _buildRelayStateChart(provider),
                        AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: _selectedTimeRange,
        underline: SizedBox(),
        padding: EdgeInsets.symmetric(horizontal: 12),
        icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
        items: [
          DropdownMenuItem(value: 6, child: Text('Last 6 hours')),
          DropdownMenuItem(value: 12, child: Text('Last 12 hours')),
          DropdownMenuItem(value: 24, child: Text('Last 24 hours')),
          DropdownMenuItem(value: 48, child: Text('Last 48 hours')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedTimeRange = value;
            });
            // Reload history data with new time range
            final provider = Provider.of<IoTProvider>(context, listen: false);
            if (provider.selectedNode != null) {
              ApiService.getNodeHistory(provider.selectedNode!.nodeId, hours: value)
                  .then((data) {
                // Update history data
                provider.selectNode(provider.selectedNode!);
              });
            }
          }
        },
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(IoTProvider provider) {
    final data = provider.historyData
        .where((item) => item.temperature != null)
        .map((item) {
          final time = DateTime.parse(item.timestamp);
          return FlSpot(
            time.millisecondsSinceEpoch.toDouble(),
            item.temperature!,
          );
        })
        .toList();

    return _buildLineChart(data, Colors.orange);
  }

  Widget _buildHumidityChart(IoTProvider provider) {
    final data = provider.historyData
        .where((item) => item.humidity != null)
        .map((item) {
          final time = DateTime.parse(item.timestamp);
          return FlSpot(
            time.millisecondsSinceEpoch.toDouble(),
            item.humidity!,
          );
        })
        .toList();

    return _buildLineChart(data, Colors.blue);
  }

  Widget _buildTdsChart(IoTProvider provider) {
    final data = provider.historyData
        .where((item) => item.tds != null)
        .map((item) {
          final time = DateTime.parse(item.timestamp);
          return FlSpot(
            time.millisecondsSinceEpoch.toDouble(),
            item.tds!,
          );
        })
        .toList();

    return _buildLineChart(data, Colors.purple);
  }

  Widget _buildRelayStateChart(IoTProvider provider) {
    final data = provider.historyData.map((item) {
      final time = DateTime.parse(item.timestamp);
      return FlSpot(
        time.millisecondsSinceEpoch.toDouble(),
        item.relayState ? 1 : 0,
      );
    }).toList();

    return _buildLineChart(data, AppTheme.primaryColor, isRelayChart: true);
  }

  Widget _buildLineChart(List<FlSpot> spots, Color color, {bool isRelayChart = false}) {
    if (spots.isEmpty) {
      return Center(child: Text('No data available'));
    }

    // Sort spots by x value (time)
    spots.sort((a, b) => a.x.compareTo(b.x));

    final minX = spots.first.x;
    final maxX = spots.last.x;
    
    double minY, maxY;
    if (isRelayChart) {
      minY = 0;
      maxY = 1;
    } else {
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      
      // Add some padding
      final range = maxY - minY;
      minY = minY - range * 0.1;
      maxY = maxY + range * 0.1;
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: isRelayChart ? 0.5 : null,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('HH:mm').format(date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                );
              },
              interval: (maxX - minX) / 5,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                String text;
                if (isRelayChart) {
                  text = value == 0 ? 'OFF' : value == 1 ? 'ON' : '';
                } else {
                  text = value.toStringAsFixed(1);
                }
                return Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTab(NodeData node, IoTProvider provider) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control Mode',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildControlModeCard(
                          'Automatic',
                          Icons.auto_mode,
                          !node.manualMode,
                          () => provider.controlNode(node.nodeId, false, node.relayState),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildControlModeCard(
                          'Manual',
                          Icons.pan_tool,
                          node.manualMode,
                          () => provider.controlNode(node.nodeId, true, node.relayState),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Relay Control',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: node.relayState
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.grey[200],
                            border: Border.all(
                              color: node.relayState
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.power_settings_new,
                              size: 64,
                              color: node.relayState
                                  ? AppTheme.primaryColor
                                  : Colors.grey[400],
                            ),
                            onPressed: node.manualMode
                                ? () => provider.controlNode(
                                    node.nodeId, true, !node.relayState)
                                : null,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          node.relayState ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: node.relayState
                                ? AppTheme.primaryColor
                                : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          node.manualMode
                              ? 'Tap to toggle relay state'
                              : 'Switch to manual mode to control',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlModeCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasTemperatureData(IoTProvider provider) {
    return provider.historyData.any((item) => item.temperature != null);
  }

  bool _hasHumidityData(IoTProvider provider) {
    return provider.historyData.any((item) => item.humidity != null);
  }

  bool _hasTdsData(IoTProvider provider) {
    return provider.historyData.any((item) => item.tds != null);
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return DateFormat('MMM dd, HH:mm:ss').format(dateTime);
  }

  IconData _getStatusIcon(NodeData node) {
    if (node.manualMode) {
      return Icons.pan_tool;
    } else if (node.relayState) {
      return Icons.power;
    } else {
      return Icons.power_off;
    }
  }

  Color _getStatusColor(NodeData node) {
    if (node.manualMode) {
      return AppTheme.manualModeColor;
    } else if (node.relayState) {
      return AppTheme.activeColor;
    } else {
      return AppTheme.textSecondary;
    }
  }

  String _getStatusText(NodeData node) {
    if (node.manualMode) {
      return node.relayState ? 'Manually Activated' : 'Manually Deactivated';
    } else {
      return node.relayState ? 'Automatically Activated' : 'Automatically Deactivated';
    }
  }
}
