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
  StreamSubscription<Memory>? _subscription;

  @override
  void initState() {
    super.initState();
    getMemoryInfo().then((memory) {
      if (mounted) {
        setState(() {
          _memory = memory;
        });
      }
    });

    _subscription = Stream.periodic(
      const Duration(seconds: 1),
      (_) => getMemoryInfo(),
    ).asyncMap((future) => future).listen((memory) {
      if (mounted) {
        setState(() {
          _memory = memory;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_memory == null) {
      return Center(child: CircularProgressIndicator());
    }

    final memory = _memory!;
    return Center(
      child: Text(
        'Memory: ${storageToFloat(storage: memory.usedMemory).toStringAsFixed(2)} ${unitToString(unit: memory.usedMemory.unit)} / ${storageToFloat(storage: memory.totalMemory)} ${unitToString(unit: memory.totalMemory.unit)}',
      ),
    );
  }
}
