import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_demo/src/rust/api/memory.dart';
import 'package:flutter_demo/src/rust/frb_generated.dart';
import 'package:flutter_demo/src/rust/memory.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MemoryInfoWidget();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.memory),
                    label: Text('Memory'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class MemoryInfoWidget extends StatefulWidget {
  @override
  State<MemoryInfoWidget> createState() => _MemoryInfoWidgetState();
}

class _MemoryInfoWidgetState extends State<MemoryInfoWidget> {
  Memory? _memory;
  List<(int, ProcessMemoryInfo)>? _processes;
  StreamSubscription<Memory>? _memorySubscription;
  StreamSubscription<List<(int, ProcessMemoryInfo)>>? _processesSubscription;

  @override
  void initState() {
    super.initState();

    // Load initial data immediately
    _loadData();

    // Then update every second
    _memorySubscription = Stream.periodic(
      const Duration(seconds: 1),
      (_) => getMemoryInfo(),
    ).asyncMap((future) => future).listen((memory) {
      if (mounted) {
        setState(() {
          _memory = memory;
        });
      }
    });

    _processesSubscription = Stream.periodic(
      const Duration(seconds: 1),
      (_) => getFirstProcessMemoryUsage(n: BigInt.from(10)),
    ).asyncMap((future) => future).listen((processes) {
      if (mounted) {
        setState(() {
          _processes = processes;
        });
      }
    });
  }

  Future<void> _loadData() async {
    final memory = await getMemoryInfo();
    final processes = await getFirstProcessMemoryUsage(n: BigInt.from(10));

    if (mounted) {
      setState(() {
        _memory = memory;
        _processes = processes;
      });
    }
  }

  @override
  void dispose() {
    _memorySubscription?.cancel();
    _processesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_memory == null) {
      return Center(child: CircularProgressIndicator());
    }

    final memory = _memory!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Memory: ${storageToFloat(storage: memory.usedMemory).toStringAsFixed(2)} ${unitToString(unit: memory.usedMemory.unit)} / ${storageToFloat(storage: memory.totalMemory)} ${unitToString(unit: memory.totalMemory.unit)}',
          ),
          SizedBox(height: 16),
          Text(
            'Swap: ${storageToFloat(storage: memory.usedSwap).toStringAsFixed(2)} ${unitToString(unit: memory.usedSwap.unit)} / ${storageToFloat(storage: memory.totalSwap)} ${unitToString(unit: memory.totalSwap.unit)}',
          ),
          SizedBox(height: 16),
          Expanded(
            child: ProcessMemoryInfoWidget(processes: _processes),
          ),
        ],
      ),
    );
  }
}

class ProcessMemoryInfoWidget extends StatelessWidget {
  const ProcessMemoryInfoWidget({
    super.key,
    required List<(int, ProcessMemoryInfo)>? processes,
  }) : _processes = processes;

  final List<(int, ProcessMemoryInfo)>? _processes;

  @override
  Widget build(BuildContext context) {
    if (_processes == null || _processes!.isEmpty) {
      return SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(120),
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Pid',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Name',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Exe',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Memory',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ..._processes!.map((process) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(process.$1.toString()),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(process.$2.name),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(process.$2.exe ?? 'Unknown'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${storageToFloat(storage: process.$2.memory).toStringAsFixed(2)} ${unitToString(unit: process.$2.memory.unit)}',
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
