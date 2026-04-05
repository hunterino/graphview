import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

/// Demonstrates per-edge coloring based on edge type.
///
/// Models a software architecture where different relationship types
/// (dependency, inheritance, data flow, optional) are shown as
/// distinct colors with a legend.
class ColoredEdgesPage extends StatefulWidget {
  @override
  _ColoredEdgesPageState createState() => _ColoredEdgesPageState();
}

enum EdgeType { dependency, inheritance, dataFlow, optional }

class _ColoredEdgesPageState extends State<ColoredEdgesPage> {
  final GraphViewController _controller = GraphViewController();

  static const _edgeColors = {
    EdgeType.dependency: Colors.blue,
    EdgeType.inheritance: Colors.green,
    EdgeType.dataFlow: Colors.orange,
    EdgeType.optional: Colors.grey,
  };

  static const _edgeLabels = {
    EdgeType.dependency: 'Dependency',
    EdgeType.inheritance: 'Inheritance',
    EdgeType.dataFlow: 'Data Flow',
    EdgeType.optional: 'Optional',
  };

  Paint _paintFor(EdgeType type) {
    return Paint()
      ..color = _edgeColors[type]!
      ..strokeWidth = 2;
  }

  final Graph graph = Graph();
  final builder = SugiyamaConfiguration();

  @override
  void initState() {
    super.initState();

    // Nodes representing services in a system architecture
    final api = Node.Id('API Gateway');
    final auth = Node.Id('Auth Service');
    final users = Node.Id('User Service');
    final orders = Node.Id('Order Service');
    final payments = Node.Id('Payment Service');
    final notifications = Node.Id('Notification Service');
    final db = Node.Id('Database');
    final cache = Node.Id('Cache');
    final queue = Node.Id('Message Queue');
    final analytics = Node.Id('Analytics');

    // Dependencies (blue) — service A requires service B
    graph.addEdge(api, auth, paint: _paintFor(EdgeType.dependency));
    graph.addEdge(api, users, paint: _paintFor(EdgeType.dependency));
    graph.addEdge(api, orders, paint: _paintFor(EdgeType.dependency));
    graph.addEdge(orders, payments, paint: _paintFor(EdgeType.dependency));

    // Inheritance (green) — service A extends/implements service B
    graph.addEdge(users, auth, paint: _paintFor(EdgeType.inheritance));

    // Data flow (orange) — data moves from A to B
    graph.addEdge(orders, queue, paint: _paintFor(EdgeType.dataFlow));
    graph.addEdge(queue, notifications, paint: _paintFor(EdgeType.dataFlow));
    graph.addEdge(queue, analytics, paint: _paintFor(EdgeType.dataFlow));
    graph.addEdge(users, db, paint: _paintFor(EdgeType.dataFlow));
    graph.addEdge(orders, db, paint: _paintFor(EdgeType.dataFlow));
    graph.addEdge(payments, db, paint: _paintFor(EdgeType.dataFlow));

    // Optional (grey) — soft dependency, used if available
    graph.addEdge(users, cache, paint: _paintFor(EdgeType.optional));
    graph.addEdge(orders, cache, paint: _paintFor(EdgeType.optional));

    builder
      ..nodeSeparation = 30
      ..levelSeparation = 30
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Colored Edges by Type')),
      body: Column(
        children: [
          _buildLegendAndControls(),
          Expanded(
            child: GraphView.builder(
              controller: _controller,
              graph: graph,
              algorithm: SugiyamaAlgorithm(builder),
              paint: Paint()
                ..color = Colors.black
                ..strokeWidth = 1
                ..style = PaintingStyle.stroke,
              builder: (Node node) {
                return _nodeWidget(node.key!.value as String);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendAndControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...EdgeType.values.map((t) => _legendItem(_edgeColors[t]!, _edgeLabels[t]!)),
          ElevatedButton(
            onPressed: () => _controller.zoomToFit(),
            child: Text('Zoom to fit'),
          ),
          ElevatedButton(
            onPressed: () => _controller.resetView(),
            child: Text('Reset View'),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 24, height: 3, color: color),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _nodeWidget(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}
