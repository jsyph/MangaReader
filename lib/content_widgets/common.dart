
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final scaffoldLoadingNoProgress = Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: SpinKitFoldingCube(
          duration: const Duration(milliseconds: 1000),
          itemBuilder: (BuildContext context, int index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: index.isEven ? Colors.purple : Colors.purpleAccent,
              ),
            );
          },
        ),
      );