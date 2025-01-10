import 'package:strumok/content/details/content_details_desktop.dart';
import 'package:strumok/content/details/content_details_mobile.dart';
import 'package:strumok/utils/visual.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:flutter/material.dart';

class ContentDetailsView extends StatelessWidget {
  final ContentDetails contentDetails;

  const ContentDetailsView(this.contentDetails, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final mobile = isMobile(context);

        if (mobile) {
          return ContentDetailsMobileView(contentDetails: contentDetails);
        } else {
          return ContentDetailsDesktopView(contentDetails: contentDetails);
        }
      },
    );
  }
}
