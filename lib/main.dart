import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final HttpLink link = HttpLink(
    uri: 'https://api.thegraph.com/subgraphs/name/graphprotocol/compound-v2',
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
        title: 'The Graph on Flutter',
        theme: ThemeData(
            primaryColor: Color.fromARGB(255, 252, 80, 144),
            primaryColorBrightness: Brightness.dark,
            accentColor: Color.fromARGB(255, 61, 40, 107),
            accentColorBrightness: Brightness.dark),
        home: MyHomePage(title: 'THE GRAPH ON FLUTTER'),
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
      markets(orderBy: name, orderDirection: desc) {
        borrowRate
        cash
        collateralFactor
        exchangeRate
        interestRateModelAddress
        name
        reserves
        supplyRate
        symbol
        id
        totalBorrows
        totalSupply
        underlyingAddress
        underlyingName
        underlyingPrice
        underlyingSymbol
        reserveFactor
        underlyingPriceUSD
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
            List repositories = result.data['markets'];

            if (repositories == 'undefined') {
              return Text("no results found");
            }

            return ListView.builder(
                itemCount: repositories.length,
                itemBuilder: (context, index) {
                  final repository = repositories[index];

                  return ListTile(
                      leading: FlutterLogo(),
                      title: Text(repository["name"]),
                      subtitle: Text("Underlying ETH Price:" +
                          repository['underlyingPrice']));
                });
          },
        ),
      ),
    );
  }
}
