import 'dart:io';

import 'package:app/services/cache.item.image.service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/const.dart';
import '../../widget/widget/loading_animation_widget.dart';

class CacheImaegsPage extends StatefulWidget {
  @override
  _CacheImaegsPageState createState() => _CacheImaegsPageState();
}

class _CacheImaegsPageState extends State<CacheImaegsPage> {
  Future cacheImages() async {
    await CacheItemImageService().cacheImage(
        "https://www.seriouseats.com/thmb/lJzVhOHzO1eTyzKK9SBVhqqGzv0=/1500x1125/filters:fill(auto,1)/__opt__aboutcom__coeus__resources__content_migration__serious_eats__seriouseats.com__recipes__images__2014__09__20140918-jamie-olivers-comfort-food-insanity-burger-david-loftus-f7d9042bdc2a468fbbd50b10d467dafd.jpg",
        'burger',
        directory: 'new-directory');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: cacheImages(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasError) {
            return Center(
                child: TextButton(
              child: Text('delete directory'),
              onPressed: () async {
                Directory appDocumentsDirectory =
                    await getApplicationDocumentsDirectory();
                await Directory(appDocumentsDirectory.path + '/new-directory')
                    .delete(recursive: true);
              },
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error));
          }
          return Center(
            child: LoadingAnimation(
              typeOfAnimation: "staggeredDotsWave",
              color: themeColor,
              size: 100,
            ),
          );
        },
      ),
    );
  }
}
