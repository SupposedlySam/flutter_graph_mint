import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final HttpLink link = HttpLink(
    uri: 'https://api.thegraph.com/subgraphs/name/aave/protocol',
  );

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    ),
  );
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  const MyApp({Key key, this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  Widget build(BuildContext context) {
    final readRepositories = '''
    {
      lendingPoolConfigurationHistoryItems(first: 5) {
        id
        provider {
          id
        }
        lendingPool
        lendingPoolCore
      }
      lendingPoolConfigurations(first: 5) {
        id
        lendingPool
        lendingPoolCore
        lendingPoolParametersProvider
      }
    }
    ''';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Query(
          options: QueryOptions(
            documentNode: gql(readRepositories),
            variables: {
              'nRepositories': 50,
            },
            pollInterval: 10,
          ),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }

            if (result.loading) {
              return Text('Loading');
            }

            // it can be either Map or List
            List repositories =
                result.data['lendingPoolConfigurationHistoryItems'];

            return ListView.builder(
                itemCount: repositories.length,
                itemBuilder: (context, index) {
                  final repository = repositories[index];

                  return ListTile(
                    leading: FlutterLogo(),
                    title: Text(repository["id"]),
                  );
                });
          },
        ),
      ),
    );
  }
}
