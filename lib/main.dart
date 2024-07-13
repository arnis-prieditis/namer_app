import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFromFavorites(word) {
    if (favorites.contains(word)) {
      favorites.remove(word);
    }
    // else throw smth;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text("Home"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text("Favorites"),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  // print("selected: $value");
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigName(pair: pair),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text("Like"),
              ),
              SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text("Next"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BigName extends StatelessWidget {
  const BigName({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );

    return Card(
      color: theme.colorScheme.primary,
      shadowColor: theme.colorScheme.surface,
      elevation: 15,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favoritesList = appState.favorites;
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.bold,
    );

    if (favoritesList.isEmpty) {
      return Center(
        child: Text(
          "No favorites to show :(",
          style: style,
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "You have ${favoritesList.length} favorites:",
            style: style,
          ),
        ),
        for (var word in favoritesList)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                appState.removeFromFavorites(word);
              },
            ),
            title: Text(
              word.asLowerCase,
              style: style,
            ),
          ),
      ],
    );
  }
}
