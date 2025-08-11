import 'package:flutter/cupertino.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

postPropertySuccessDialogue() {
  return buildPostPropertySuccessLoader();
}

Widget buildPostPropertySuccessLoader() {
  return Center(
    child: Image.asset(
      Assets.images.loader.path,
      width: AppSize.appSize150,
    ),
  );
}
