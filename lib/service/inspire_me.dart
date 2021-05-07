import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_flutter/amplify.dart';
import 'dart:math';

class InspireMeService {
  Future<String> inspireMe() async {
    Random random = Random();
    try {
      var picture = random.nextInt(7);
      GetUrlResult result =
          await Amplify.Storage.getUrl(key: picture.toString());
      return result.url;
    } on StorageException catch (e) {
      print(e.message);
      return ("https://i.pinimg.com/originals/e9/8c/ef/e98cefe47bb7fb372fb245bbf2f893b9.jpg");
    } on Exception catch (e) {
      print(e);
      return ("https://i.pinimg.com/originals/e9/8c/ef/e98cefe47bb7fb372fb245bbf2f893b9.jpg");
    }
  }
}
