import 'package:finale/services/generic.dart';
import 'package:finale/services/image_id.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/services/lastfm/period.dart';
import 'package:finale/services/lastfm/track.dart';
import 'package:finale/util/formatters.dart';
import 'package:finale/util/theme.dart';
import 'package:finale/widgets/base/scaled_box.dart';
import 'package:finale/widgets/collage/src/collage_branding.dart';
import 'package:finale/widgets/entity/entity_image.dart';
import 'package:flutter/material.dart';

class WrappedCollage extends StatelessWidget {
  final ThemeColor themeColor;
  final bool includeBranding;
  final String username;
  final Period period;
  final List<Entity> items;
  final List<LTopArtistsResponseArtist> topArtists;
  final List<LTopTracksResponseTrack> topTracks;
  final int numScrobbles;
  final VoidCallback onImageLoaded;

  WrappedCollage(this.themeColor, this.includeBranding, this.username,
      this.period, this.items, List<Object> otherResults, this.onImageLoaded)
      : topArtists = otherResults[0] as List<LTopArtistsResponseArtist>,
        topTracks = otherResults[1] as List<LTopTracksResponseTrack>,
        numScrobbles = otherResults[2] as int;

  @override
  Widget build(BuildContext context) => ScaledBox(
        targetWidth: 400,
        builder: (context, scale) => Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scale,
            vertical: 16 * scale,
          ),
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
            spacing: 16 * scale,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16 * scale),
                child: Align(
                  child: EntityImage(
                    entity: items.single,
                    width: 200 * scale,
                    quality: ImageQuality.high,
                    onLoaded: onImageLoaded,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Artists',
                          style: TextStyle(
                            color: themeColor.foregroundColor,
                            fontSize: 12 * scale,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        for (final (i, topArtist) in topArtists.indexed)
                          Text(
                            '${i + 1}. ${topArtist.name}',
                            style: TextStyle(
                              color: themeColor.foregroundColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14 * scale,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Songs',
                          style: TextStyle(
                            color: themeColor.foregroundColor,
                            fontSize: 12 * scale,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        for (final (i, topTrack) in topTracks.indexed)
                          Text(
                            '${i + 1}. ${topTrack.name}',
                            style: TextStyle(
                              color: themeColor.foregroundColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14 * scale,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scrobbles',
                          style: TextStyle(
                            color: themeColor.foregroundColor,
                            fontSize: 12 * scale,
                          ),
                        ),
                        Text(
                          numberFormat.format(numScrobbles),
                          style: TextStyle(
                            color: themeColor.foregroundColor,
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Period',
                          style: TextStyle(
                            color: themeColor.foregroundColor,
                            fontSize: 12 * scale,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          period.display,
                          style: TextStyle(
                            color: themeColor.foregroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14 * scale,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (includeBranding)
                CollageBranding(
                  themeColor: themeColor,
                  scale: scale,
                )
              else
                SizedBox(height: 8 * scale),
            ],
          ),
        ),
      );
}
