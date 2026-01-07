import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo/src/rust/api/memory.dart';
import 'package:flutter_demo/src/rust/frb_generated.dart';
import 'package:flutter_demo/src/rust/memory.dart';

void main() {
  setUpAll(() async {
    await RustLib.init();
  });

  test('getFirstProcessMemoryUsage returns data', () async {
    final processes = await getFirstProcessMemoryUsage(n: BigInt.from(10));

    expect(processes, isNotNull);
    expect(processes, isA<List<(int, ProcessMemoryInfo)>>());
    expect(processes.length, greaterThan(0));
    expect(processes.length, lessThanOrEqualTo(10));

    // Check first process structure
    final firstProcess = processes.first;
    expect(firstProcess.$1, isA<int>());
    expect(firstProcess.$2.name, isNotEmpty);
    expect(firstProcess.$2.memory, isNotNull);

    print(firstProcess.$1);
    print(firstProcess.$2.name);
    print(
        '${storageToFloat(storage: firstProcess.$2.memory)} ${unitToString(unit: firstProcess.$2.memory.unit)}');
    print(firstProcess.$2.exe);
  });

  test('getMemoryInfo returns data', () async {
    final memory = await getMemoryInfo();

    expect(memory, isNotNull);
    expect(memory.totalMemory, isNotNull);
    expect(memory.usedMemory, isNotNull);
    expect(memory.totalSwap, isNotNull);
    expect(memory.usedSwap, isNotNull);
  });
}
