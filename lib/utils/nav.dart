import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:strumok/utils/visual.dart';

void navigateToContent(BuildContext context, ContentDetails contentDetails) {
  final location =
      "/${contentDetails.mediaType.name}/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}";
  if (isDesktopDevice()) {
    context.go(location);
  } else {
    context.push(location);
  }
}

void backToContentDetails(BuildContext context, ContentDetails contentDetails) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(
        "/content/${contentDetails.supplier}/${Uri.encodeComponent(contentDetails.id)}");
  }
}
