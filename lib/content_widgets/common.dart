import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:manga_reader/core/core.dart';

final scaffoldLoadingNoProgressWidget = Scaffold(
    appBar: AppBar(
      title: const Text('Loading...'),
    ),
    body: loadingWidget);

final loadingWidget = SpinKitFoldingCube(
  duration: const Duration(milliseconds: 1000),
  itemBuilder: (BuildContext context, int index) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.purple : Colors.purpleAccent,
      ),
    );
  },
);

const pipeSeperatorWidget = Padding(
  padding: EdgeInsets.symmetric(horizontal: 5.0),
  child: Text('|'),
);

final mangaSourcesData = {
  'Asura Scans': AsuraScans(),
  'Cosmic Scans': CosmicScans(),
  'Flame Scans': FlameScans(),
  'Luminous Scans': LuminousScans(),
};
