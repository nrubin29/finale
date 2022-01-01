import 'package:finale/services/generic.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

class ListCollage extends StatelessWidget {
  final ThemeColor themeColor;
  final bool includeBranding;
  final List<Entity> items;

  const ListCollage(this.themeColor, this.includeBranding, this.items);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeColor.color.shade500,
            themeColor.color.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: EdgeInsets.all(width / 20),
              child: Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: EntityImage(entity: item),
                  ),
                  SizedBox(width: width / 20),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width / 20,
                          ),
                        ),
                        if (item.displaySubtitle != null) ...[
                          SizedBox(height: width / 75),
                          Text(
                            item.displaySubtitle!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width / 25,
                            ),
                          ),
                        ],
                        if (item.displayTrailing != null) ...[
                          SizedBox(height: width / 75),
                          Text(
                            item.displayTrailing!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width / 30,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (includeBranding)
            Padding(
              padding: EdgeInsets.only(
                left: width / 20,
                right: width / 20,
                bottom: width / 50,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Created with Finale for Last.fm',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'https://finale.app',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Image.asset(
                    'assets/images/music_note.png',
                    width: 60,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
