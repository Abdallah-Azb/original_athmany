import 'dart:async';
import 'dart:io' as Io;
import 'package:image/image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

class CacheItemImageService {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static const key = 'customCacheKey';

  Future<Io.File> getImageFromNetwork(String url) async {
    CacheManager cacheManager = CacheManager(Config(
      key,
      stalePeriod: const Duration(days: 300),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ));

    Io.File file = await cacheManager.getSingleFile(url);
    return file;
  }

  Future<Io.File> cacheImage(String url, String itemCode,
      {String directory}) async {
    // print(url);

    try {
      final file = await getImageFromNetwork(url);
      if (file == null) return null;
      var path = await localPath;

      var image = decodeImage(file.readAsBytesSync());

      var thumbnail = copyResize(image, width: 450);

      // Save the thumbnail as a PNG.
      return new Io.File('$path/$itemCode.png')
      // return new Io.File('$path/$directory/$itemCode.png')
        ..writeAsBytesSync(encodePng(thumbnail));
    } catch (e) {
      print("cacheImage Error :::::: $e");
    }

    // if(directory != null){
    //   Io.Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    //   await Io.Directory(appDocumentsDirectory.path+'/$directory').create(recursive: true);
    // }

  }
}
