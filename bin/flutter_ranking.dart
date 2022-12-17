import 'dart:io';

import 'package:flutter_ranking/ranking.dart' as ranking;
import 'package:flutter_ranking/package.dart';
import 'package:flutter_ranking/record.dart';
import 'package:flutter_ranking/table_record.dart';
import 'package:flutter_ranking/tsv_record.dart';

void main(List<String> arguments) async {
  final packages = await ranking.getListedPackages();
  final now = DateTime.now();

  await _writeHistoryFile(packages, now);
  await _writeReadmeFile(packages, now);
}

Future<void> _writeHistoryFile(
  final List<Package> packages,
  final DateTime now,
) async {
  final historyFile = File('./history/${now.toUtc().toIso8601String()}.tsv');

  _write(
    historyFile,
    TsvRecord()
      ..addValue('No.')
      ..addValue('Name')
      ..addValue('Description')
      ..addValue('Version')
      ..addValue('Popularity')
      ..addValue('Likes')
      ..addValue('Stars')
      ..addValue('Forks')
      ..addValue('Issues')
      ..addValue('Owner')
      ..addValue('Publisher')
      ..addValue('License')
      ..addValue('Last Commit'),
  );

  int rank = 1;
  for (final package in packages) {
    _write(
      historyFile,
      TsvRecord()
        ..addValue('$rank')
        ..addValue(package.name)
        ..addValue(package.description)
        ..addValue(package.version)
        ..addValue('${package.popularity}')
        ..addValue('${package.likeCount}')
        ..addValue('${package.starCount}')
        ..addValue('${package.forkCount}')
        ..addValue('${package.issueCount}')
        ..addValue(package.owner)
        ..addValue(package.publisher)
        ..addValue(package.license)
        ..addValue(package.updatedAt.toIso8601String()),
    );

    rank++;
  }
}

void _write(final File file, final Record record) =>
    file.writeAsStringSync(record.toString(), mode: FileMode.append);

Future<void> _writeReadmeFile(
  final List<Package> packages,
  final DateTime now,
) async {
  final readmeFile = File('README.md')..writeAsStringSync('');

  readmeFile.writeAsStringSync(
      '''[![GitHub Sponsor](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=ff69b4)](https://github.com/sponsors/myConsciousness)
[![GitHub Sponsor](https://img.shields.io/static/v1?label=Maintainer&message=myConsciousness&logo=GitHub&color=00acee)](https://github.com/myConsciousness)

# Flutter Ranking 👑✨

I respect all OSS developers who are developing great packages! 🫡

This project aims to visualize the ranking of OSS packages published on [pub.dev](https://pub.dev) to further invigorate the community and promote competition.

Currently, the top 3,000 packages are listed in this ranking, sorted by popularity index as evaluated by pub.dev. This process is fully automated and is recalculated daily at 12:00 and 24:00 UTC time.

**Show some ❤️ and star the repo to support the project!**

## Last Updated (UTC): ${now.toUtc().toIso8601String()}

''');

  _write(
    readmeFile,
    TableRecord()
      ..addValue('No.')
      ..addValue('Name')
      ..addValue('Description')
      ..addValue('Version')
      ..addValue('Popularity')
      ..addValue('Likes')
      ..addValue('Stars')
      ..addValue('Forks')
      ..addValue('Issues')
      ..addValue('Owner')
      ..addValue('Publisher')
      ..addValue('License')
      ..addValue('Last Commit'),
  );

  _write(
    readmeFile,
    TableRecord()
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---')
      ..addValue('---'),
  );

  int rank = 1;
  for (final package in packages) {
    _write(
      readmeFile,
      TableRecord()
        ..addValue('**$rank**')
        ..addValue(
            '[${package.name}](https://pub.dev/packages/${package.name})')
        ..addValue(package.description)
        ..addValue(
            '[${package.version}](https://pub.dev/packages/${package.name}/versions)')
        ..addValue(
            '![Popularity](https://img.shields.io/pub/popularity/${package.name}?label=Pub%20Popularity&style=fflat-squaree)')
        ..addValue(
            '![Likes](https://img.shields.io/pub/likes/${package.name}?label=Pub%20Likes&style=fflat-squaree)')
        ..addValue(
            '[![Stars](https://img.shields.io/github/stars/${package.owner}/${package.name}?logo=github&logoColor=white)](https://github.com/${package.owner}/${package.name})')
        ..addValue(
            '[![Forks](https://img.shields.io/github/forks/${package.owner}/${package.name}?logo=github&logoColor=white)](https://github.com/${package.owner}/${package.name})')
        ..addValue(
            '[![Issues](https://img.shields.io/github/issues/${package.owner}/${package.name}?logo=github&logoColor=white)](https://github.com/${package.owner}/${package.name})')
        ..addValue('[@${package.owner}](https://github.com/${package.owner})')
        ..addValue(
            '[${package.publisher}](https://pub.dev/publishers/${package.publisher}/packages)')
        ..addValue(
            '[![License](https://img.shields.io/github/license/${package.owner}/${package.name}?logo=open-source-initiative&logoColor=green)](https://github.com/${package.owner}/${package.name}/blob/main/LICENSE)')
        ..addValue(
            '[![Last Commits](https://img.shields.io/github/last-commit/${package.owner}/${package.name}?logo=git&logoColor=white)](https://github.com/${package.owner}/${package.name}/commits/main)'),
    );

    rank++;
  }
}
