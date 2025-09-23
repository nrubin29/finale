import 'package:finale/services/generic.dart';
import 'package:finale/services/lastfm/lastfm.dart';
import 'package:finale/util/formatters.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class LObsession extends Track {
  @override
  final String name;

  @override
  final String artistName;

  @override
  final String url;

  final DateTime date;

  final bool wasFirst;

  LObsession({
    required this.name,
    required this.artistName,
    required this.url,
    required this.date,
    required this.wasFirst,
  });

  @override
  ImageIdProvider get imageIdProvider =>
      () async => (await Lastfm.getTrack(this)).imageId;

  @override
  String? get albumName => null;

  @override
  String? get displayTrailing => dateFormatWithYear.format(date);
}

final _datePattern = RegExp(r'(.+) (\d{1,2}), (\d{4})');
final List<String> _months = [
  'Jan.',
  'Feb.',
  'March',
  'April',
  'May',
  'June',
  'July',
  'Aug.',
  'Sept.',
  'Oct.',
  'Nov.',
  'Dec.',
];

class LUserObsessions extends PagedRequest<LObsession> {
  final String username;

  const LUserObsessions({required this.username});

  @override
  Future<List<LObsession>> doRequest(int limit, int page) async {
    final lastfmResponse = await httpClient.get(
      Uri.https('last.fm', 'user/$username/obsessions', {'page': '$page'}),
    );
    if (lastfmResponse.statusCode != 200) return const <LObsession>[];

    try {
      final doc = parse(lastfmResponse.body);
      final items = doc.querySelectorAll('.obsession-history-item');
      return items.map(_obsessionFromHtml).toList(growable: false);
    } on Exception {
      return const <LObsession>[];
    }
  }

  LObsession _obsessionFromHtml(Element element) {
    final name = element
        .querySelector('.obsession-history-item-heading')!
        .text
        .trim();
    final artistName = element
        .querySelector('.obsession-history-item-artist')!
        .text
        .trim();
    final url = element
        .querySelector('.obsession-history-item-heading-link')!
        .attributes['href']!;
    final dateText = element
        .querySelector('.obsession-history-item-date')!
        .text
        .trim();
    final wasFirst = element.querySelector('.obsession-first') != null;
    return LObsession(
      name: name,
      artistName: artistName,
      url: url,
      date: _dateFromLastfmFormat(dateText),
      wasFirst: wasFirst,
    );
  }

  DateTime _dateFromLastfmFormat(String dateText) {
    final match = _datePattern.matchAsPrefix(dateText)!;
    final month = _months.indexOf(match.group(1)!);
    final day = int.parse(match.group(2)!);
    final int year = int.parse(match.group(3)!);
    return DateTime(year, month, day);
  }
}
