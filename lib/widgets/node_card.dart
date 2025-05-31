import 'package:flutter/material.dart';
import '../models/node_model.dart';
import '../theme/app_theme.dart';

class NodeCard extends StatelessWidget {
  final NodeData node;
  final Function() onTap;
  final Function(bool) onToggle;
  final Function(bool) onModeChange;

  const NodeCard({
    required this.node,
    required this.onTap,
    required this.onToggle,
    required this.onModeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getNodeColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getNodeIcon(),
                          color: _getNodeColor(),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Node ${node.nodeId}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            node.nodeType,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: node.relayState,
                    onChanged: node.manualMode ? onToggle : null,
                    activeColor: AppTheme.primaryColor,
                    activeTrackColor: AppTheme.primaryColor.withOpacity(0.4),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildSensorData(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        node.manualMode ? Icons.pan_tool : Icons.auto_mode,
                        size: 16,
                        color: node.manualMode ? AppTheme.manualModeColor : Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        node.manualMode ? 'Manual Mode' : 'Auto Mode',
                        style: TextStyle(
                          color: node.manualMode ? AppTheme.manualModeColor : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => onModeChange(!node.manualMode),
                    icon: Icon(
                      node.manualMode ? Icons.auto_mode : Icons.pan_tool,
                      size: 16,
                    ),
                    label: Text(
                      node.manualMode ? 'Switch to Auto' : 'Switch to Manual',
                      style: TextStyle(fontSize: 14),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorData() {
    List<Widget> sensorWidgets = [];
    
    if (node.temperature != null) {
      sensorWidgets.add(_buildSensorItem(
        Icons.thermostat,
        Colors.orange,
        '${node.temperature!.toStringAsFixed(1)}°C',
        'Temperature',
      ));
    }
    
    if (node.humidity != null) {
      sensorWidgets.add(_buildSensorItem(
        Icons.water_drop,
        Colors.blue,
        '${node.humidity!.toStringAsFixed(1)}%',
        'Humidity',
      ));
    }
    
    if (node.tds != null) {
      sensorWidgets.add(_buildSensorItem(
        Icons.science,
        Colors.purple,
        '${node.tds!.toStringAsFixed(0)} ppm',
        'TDS',
      ));
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: sensorWidgets,
    );
  }

  Widget _buildSensorItem(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getNodeIcon() {
    switch (node.nodeType.toLowerCase()) {
      case 'sensor':
        return Icons.sensors;
      case 'relay':
        return Icons.power;
      case 'controller':
        return Icons.settings_remote;
      default:
        return Icons.devices;
    }
  }

  Color _getNodeColor() {
    if (node.manualMode) {
      return AppTheme.manualModeColor;
    } else if (node.relayState) {
      return AppTheme.activeColor;
    } else {
      return AppTheme.textSecondary;
    }
  }
}
