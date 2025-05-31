
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';
import '../models/node_model.dart';
import '../widgets/summary_card.dart';
import '../widgets/node_card.dart';
import '../theme/app_theme.dart';
import 'node_detail_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IoTProvider>().loadDashboardData();
    });

    // Auto refresh every 10 seconds
    _startAutoRefresh();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        context.read<IoTProvider>().loadDashboardData();
        _startAutoRefresh();
      }
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('MMM dd, HH:mm:ss').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IoT Monitor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<IoTProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.refresh),
                onPressed: provider.isLoading
                    ? null
                    : () => provider.refresh(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Dashboard'),
            Tab(text: 'Nodes'),
          ],
        ),
      ),
      body: Consumer<IoTProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return _buildErrorView(provider);
          }

          if (provider.isLoading && provider.nodes.isEmpty) {
            return _buildLoadingView();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(provider),
              _buildNodesTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorView(IoTProvider provider) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            SizedBox(height: 16),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(
              '${provider.error}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
                provider.loadDashboardData();
              },
              icon: Icon(Icons.refresh),
              label: Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          SizedBox(height: 24),
          Text(
            'Loading dashboard...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(IoTProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.primaryColor,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(provider),
            
            SizedBox(height: 24),
            
            // Summary cards
            if (provider.summary != null) ...[
              Text(
                'System Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              _buildSummaryGrid(provider.summary!),
              SizedBox(height: 24),
            ],
            
            // Recent activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            _buildRecentActivity(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildNodesTab(IoTProvider provider) {
    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: provider.nodes.length,
        itemBuilder: (context, index) {
          final node = provider.nodes[index];
          return NodeCard(
            node: node,
            onTap: () {
              provider.selectNode(node);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NodeDetailScreen(),
                ),
              );
            },
            onToggle: (bool value) {
              provider.controlNode(node.nodeId, node.manualMode, value);
            },
            onModeChange: (bool value) {
              provider.controlNode(node.nodeId, value, node.relayState);
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(IoTProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
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
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.cloud_done,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Status',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    provider.lastUpdate != null
                        ? 'Updated ${_formatTime(provider.lastUpdate!)}'
                        : 'Updating...',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(DashboardSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        SummaryCard(
          title: 'Nodes',
          value: '${summary.totalNodes}',
          icon: Icons.devices,
          color: AppTheme.primaryColor,
        ),
        SummaryCard(
          title: 'Active Relays',
          value: '${summary.activeRelays}',
          icon: Icons.power,
          color: AppTheme.successColor,
        ),
        SummaryCard(
          title: 'Manual Mode',
          value: '${summary.manualNodes}',
          icon: Icons.pan_tool,
          color: AppTheme.manualModeColor,
        ),
        SummaryCard(
          title: 'Avg. Temperature',
          value: '${summary.avgTemperature.toStringAsFixed(1)}°C',
          icon: Icons.thermostat,
          color: Colors.orange,
        ),
        SummaryCard(
          title: 'Avg. Humidity',
          value: '${summary.avgHumidity.toStringAsFixed(1)}%',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
        SummaryCard(
          title: 'Avg. TDS',
          value: '${summary.avgTds.toStringAsFixed(0)} ppm',
          icon: Icons.science,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(IoTProvider provider) {
    if (provider.nodes.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No recent activity'),
          ),
        ),
      );
    }

    // Show the 3 most recent nodes based on timestamp
    final recentNodes = List<NodeData>.from(provider.nodes)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return Column(
      children: recentNodes.take(3).map((node) {
        IconData statusIcon;
        Color statusColor;
        
        if (node.manualMode) {
          statusIcon = Icons.pan_tool;
          statusColor = AppTheme.manualModeColor;
        } else if (node.relayState) {
          statusIcon = Icons.power;
          statusColor = AppTheme.activeColor;
        } else {
          statusIcon = Icons.power_off;
          statusColor = AppTheme.inactiveColor;
        }
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
              ),
            ),
            title: Text(
              'Node ${node.nodeId} (${node.nodeType})',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                if (node.temperature != null)
                  Text('Temperature: ${node.temperature!.toStringAsFixed(1)}°C'),
                if (node.humidity != null)
                  Text('Humidity: ${node.humidity!.toStringAsFixed(1)}%'),
                if (node.tds != null)
                  Text('TDS: ${node.tds!.toStringAsFixed(0)} ppm'),
                SizedBox(height: 4),
                Text(
                  'Status: ${node.relayState ? "Active" : "Inactive"}${node.manualMode ? " (Manual)" : ""}',
                  style: TextStyle(
                    color: node.relayState ? AppTheme.activeColor : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              provider.selectNode(node);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NodeDetailScreen(),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
