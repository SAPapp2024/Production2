
import 'package:typesense/typesense.dart';

import 'enums/environment_enum.dart';

Future<Client> setupTypesense(Environment environment) async {
  String apiKey;
  String path;
  switch (environment) {
    case Environment.qa:
      apiKey = 'DAlc9CWJnS1dJnftX9QLJXTJKvKHIBQq';
      path = 'pxsfrz29jhiae1vup-1.a1.typesense.net';
      break;
    case Environment.prod:
      apiKey = 'luBmAgcbw461Bq0Y9p8C5EgDtOGDbj0o';
      path = 'g9bod5hiyxjf4rcpp-1.a1.typesense.net';
      break;
  }
  final config = Configuration(
    apiKey,
    nodes: {
      Node(
        Protocol.https,
        path,
        port: 443,
      ),
    },
    numRetries: 3, // A total of 4 tries (1 original try + 3 retries)
    connectionTimeout: const Duration(seconds: 5),
  );

  return Client(config);
}


DateTime? dateTimeFromTypesenseInt(int? date) {
return date != null
? DateTime.fromMillisecondsSinceEpoch(date * 1000)
    : null;
}