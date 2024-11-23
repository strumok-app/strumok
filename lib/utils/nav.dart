import 'package:auto_route/auto_route.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';
import 'package:strumok/app_router.gr.dart';

void navigateToContent(BuildContext context, ContentDetails contentDetails) {
  switch (contentDetails.mediaType) {
    case MediaType.video:
      context.router.push(VideoContentRoute(
          supplier: contentDetails.supplier, id: contentDetails.id));
    case MediaType.manga:
      context.router.push(MangaContentRoute(
          supplier: contentDetails.supplier, id: contentDetails.id));
  }
}

void navigateToContentDetails(BuildContext context, ContentInfo contentInfo) {
  context.router.push(
      ContentDetailsRoute(supplier: contentInfo.supplier, id: contentInfo.id));
}
