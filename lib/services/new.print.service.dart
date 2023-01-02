import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

Future<Uint8List> createImageFromWidget(Widget widget,
    {Duration wait, Size logicalSize, Size imageSize}) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
  imageSize ??= ui.window.physicalSize;

  assert(logicalSize.aspectRatio == imageSize.aspectRatio);

  final RenderView renderView = RenderView(
    window: null,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: logicalSize,
      devicePixelRatio: 1.0,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();

  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(textDirection: TextDirection.rtl, child: widget),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

  if (wait != null) {
    await Future.delayed(wait);
  }

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width);
  final ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData.buffer.asUint8List();
}
