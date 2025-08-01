import 'package:bbb/components/common_network_image.dart';
import 'package:bbb/models/collections.dart';
import 'package:bbb/utils/screen_util.dart';
import 'package:flutter/material.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({super.key, required this.collection});

  final Collections collection;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/collectionDetail',
              arguments: collection);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil.horizontalScale(1.5),
          ),
          child: appShimmerImage(
            height: media.height / 4,
            networkImageUrl:
                collection.photo.startsWith('https://storage.cloud.google.com/')
                    ? collection.photo.replaceFirst(
                        'https://storage.cloud.google.com/',
                        'https://storage.googleapis.com/')
                    : collection.photo,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil.verticalScale(5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: ScreenUtil.horizontalScale(5)),
                  child: Column(
                    children: [
                      Text(
                        collection.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.horizontalScale(5),
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
