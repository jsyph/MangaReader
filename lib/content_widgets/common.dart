import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:manga_reader/core/core.dart';

class LoadingScaffold extends StatelessWidget {
  const LoadingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
      ),
      body: const LoadingWidget(),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SpinKitFoldingCube(
      duration: const Duration(milliseconds: 1000),
      itemBuilder: (BuildContext context, int index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: index.isEven ? Colors.purple : Colors.purpleAccent,
          ),
        );
      },
    );
  }
}

class PipeSeparatorWidget extends StatelessWidget {
  const PipeSeparatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      child: Text('|'),
    );
  }
}

final mangaSourcesData = {
  'Asura Scans': AsuraScans(),
  'Cosmic Scans': CosmicScans(),
  'Flame Scans': FlameScans(),
  'Luminous Scans': LuminousScans(),
};
