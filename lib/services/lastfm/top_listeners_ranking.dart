import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/artist.dart';
import 'package:finale/util/preferences.dart';
import 'package:html/parser.dart';

class TopListenersRanking {
  final int? position;

  const TopListenersRanking({required int this.position});

  const TopListenersRanking.notFound() : position = null;

  @override
  String toString() => position == null ? 'Not in top 250' : '#$position';
}

Future<TopListenersRanking?> fetchTopListenersRanking(LArtist artist) async {
  var page = 1;

  do {
    final lastfmResponse = await httpClient.get(
      Uri.parse('${artist.url}/+listeners?page=$page'),
    );
    if (lastfmResponse.statusCode != 200) return null;

    try {
      final doc = parse(lastfmResponse.body);
      final names = doc.querySelectorAll('.top-listeners-item-name');
      final index = names.indexWhere(
        (element) => element.text.trim() == Preferences.name.value!,
      );

      if (index != -1) {
        return TopListenersRanking(position: (page - 1) * 30 + index + 1);
      }

      page++;
    } on Exception {
      return null;
    }
  } while (page <= 9);

  return const TopListenersRanking.notFound();
}
