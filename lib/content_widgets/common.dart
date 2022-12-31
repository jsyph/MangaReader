import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final scaffoldLoadingNoProgressWidget = Scaffold(
  appBar: AppBar(
    title: const Text('Loading...'),
  ),
  body: loadingWidget
);

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