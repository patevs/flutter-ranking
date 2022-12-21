import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

Future<void> main(List<String> args) async {
  final Map<String, dynamic> latestMatrics = jsonDecode(
    File('matrics/__latest__.json').readAsStringSync(),
  );

  final notifiedOwnersFile = File('./history/notified_owners.json');
  final Map<String, dynamic> notifiedOwners = jsonDecode(
    notifiedOwnersFile.readAsStringSync(),
  );

  final latestMatricsEntries = latestMatrics.entries;
  for (int i = latestMatricsEntries.length - 1; i >= 0; i--) {
    final MapEntry<String, dynamic> ownerInfo =
        latestMatricsEntries.elementAt(i);

    if (notifiedOwners.containsKey(ownerInfo.key)) {
      //
    } else {
      final githubUserResponse = await get(
        Uri.https('api.github.com', '/users/${ownerInfo.key}'),
        headers: {
          'Authorization':
              'Bearer ${Platform.environment['GITHUB_BEARER_TOKEN']}'
        },
      );

      final githubUser = jsonDecode(githubUserResponse.body);
      final String? twitterUser = githubUser['twitter_username'];

      if (twitterUser != null) {
        final listedPackageNames = _getNewListedPackages(
          packages: latestMatrics[ownerInfo.key],
        );

        final tweet = await _twitter.tweets.createTweet(
          text: '''Congratulations @test! ${_getSentence(listedPackageNames)}
Thanks for your great work for #Flutter community!

github.com/myConsciousness/flutter-ranking
''',
        );

        print(tweet);

        notifiedOwners[ownerInfo.key] = listedPackageNames;

        break;
      }
    }
  }

  notifiedOwnersFile.writeAsStringSync(
    jsonEncode(notifiedOwners),
  );
}

TwitterApi get _twitter => TwitterApi(
      bearerToken: '',
      oauthTokens: OAuthTokens(
        consumerKey: Platform.environment['TWITTER_CONSUMER_KEY']!,
        consumerSecret: Platform.environment['TWITTER_CONSUMER_SECRET']!,
        accessToken: Platform.environment['TWITTER_ACCESS_TOKEN']!,
        accessTokenSecret: Platform.environment['TWITTER_ACCESS_TOKEN_SECRET']!,
      ),
      retryConfig: RetryConfig(
        maxAttempts: 10,
        onExecute: (event) => print(
          'Retry after ${event.intervalInSeconds} seconds... '
          '[${event.retryCount} times]',
        ),
      ),
    );

List<String> _getNewListedPackages({
  required Map<String, dynamic> packages,
  Map<String, dynamic> notifiedPackages = const {},
}) {
  final packageNames = <String>[];

  packages.forEach((key, value) {
    if (!notifiedPackages.containsKey(key)) {
      packageNames.add(key);
    }
  });

  return packageNames;
}

String _getSentence(final List<String> packageNames) {
  if (packageNames.length > 1) {
    if (packageNames.length > 3) {
      return 'Your packages ${packageNames[0]}, ${packageNames[1]}, ${packageNames[2]}, plus ${packageNames.length - 3} more are listed in #FlutterRanking! 👑✨';
    }

    return 'Your packages ${packageNames.join(', ')} are listed in #FlutterRanking! 👑✨';
  }

  return 'Your package ${packageNames[0]} is listed in #FlutterRanking! 👑✨';
}
