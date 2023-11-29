
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../data/model/list_story.dart';
import '../data/response/story_response.dart';

class CardStory extends StatelessWidget{

  final ListStory story;
  const CardStory({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4.0),
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10, left: 10, right: 10, top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  cacheKey: '${story?.photoUrl}',
                  imageUrl: '${story?.photoUrl}',
                  fit: BoxFit.contain,

                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  // Optional parameters:
                  cacheManager: CacheManager(
                    Config(
                      'photoUrl-cache',
                      stalePeriod: const Duration(days: 7),
                      maxNrOfCacheObjects: 200,

                    ),
                  ),
                  // maxHeightDiskCache: 100,
                  // maxWidthDiskCache: 100,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                '${story?.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20),
              child: Text(
                '${story?.description}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          ],
        ),
      ),
    );
  }

}