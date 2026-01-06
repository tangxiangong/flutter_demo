import 'package:flutter/material.dart';

class AsyncWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final Widget? loading;
  final Widget Function(BuildContext, Object?)? errorBuilder;

  const AsyncWidget({
    super.key,
    required this.future,
    required this.builder,
    this.loading,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return builder(context, snapshot.data as T);
        }
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              Center(child: Text('Error: ${snapshot.error}'));
        }
        return loading ?? Center(child: CircularProgressIndicator());
      },
    );
  }
}

class StreamWidget<T> extends StatelessWidget {
  final Stream<T> stream;
  final Widget Function(BuildContext, T) builder;
  final Widget? loading;
  final Widget Function(BuildContext, Object?)? errorBuilder;

  const StreamWidget({
    super.key,
    required this.stream,
    required this.builder,
    this.loading,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return builder(context, snapshot.data as T);
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
