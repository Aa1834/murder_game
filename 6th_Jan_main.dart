import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'node.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'story.dart';
import 'drawer.dart';

late Box<Person> personBox;
late Box<Clue> clueBox;
late Box<Room> roomBox;

class GameLogic {
  List<Person> people = [];
  List<Clue> clues = [];
  List<Room> rooms = [];

  GameStory story = GameStory();

  GameLogic() {
    _loadData();
  }

  void _loadData() {
    people = personBox.values.toList();
    clues = clueBox.values.toList();
    rooms = roomBox.values.toList();
    story.loadLists(people, clues, rooms);
  }

  /*void printLists() {
    print('People:');
    for (var person in people) {
      print('ID: ${person.personiD}, Name: ${person.name}');
    }

    print('Clues:');
    for (var clue in clues) {
      print('ID: ${clue.clueID}, Name: ${clue.clueName}');
    }

    print('Rooms:');
    for (var room in rooms) {
      print('ID: ${room.roomID}, Name: ${room.roomName}, Capacity: ${room.capacity}');
    }
  } */
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(ClueAdapter());
  Hive.registerAdapter(RoomAdapter());

  personBox = await Hive.openBox<Person>('personBox');
  roomBox = await Hive.openBox<Room>('roomBox');
  clueBox = await Hive.openBox<Clue>('clueBox');

  String csv = 'people.csv';
  String csv2 = 'rooms.csv';
  String csv3 = 'clues.csv';
  String fileData = await rootBundle.loadString(csv);
  String fileData2 = await rootBundle.loadString(csv2);
  String filedata3 = await rootBundle.loadString(csv3);

  List<String> rows = fileData.split("\n");
  for (String row in rows) {
    List<String> itemInRow = row.split(",");
    if (itemInRow.length >= 2) {
      int personID = int.parse(itemInRow[0]);
      String name = itemInRow[1];
      Person person = Person(personID, name);
      personBox.put(name, person);
    }
  }

  List<String> rows1 = fileData2.split("\n");
  for (String row in rows1) {
    List<String> itemInRow = row.split(",");
    if (itemInRow.length >= 3) {
      int roomID = int.parse(itemInRow[0]);
      String roomName = itemInRow[1];
      int capacity = int.parse(itemInRow[2]);
      Room room = Room(roomID, roomName, capacity);
      roomBox.put(roomName, room);
    }
  }

  List<String> rows2 = filedata3.split("\n");
  for (String row in rows2) {
    List<String> itemInRow = row.split(",");
    if (itemInRow.length >= 2) {
      int clueID = int.parse(itemInRow[0]);
      String clueName = itemInRow[1];
      Clue clue = Clue(clueID, clueName);
      clueBox.put(clueName, clue);
    }
  }

  GameLogic gameLogic = GameLogic();
  //gameLogic.printLists();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/howToPlay': (context) => HowToPlayScreen(),
        '/startGame': (context) => GameScreen(),
        '/kitchen': (context) => Rooms('Kitchen'),
        '/livingRoom': (context) => Rooms('LivingRoom'),
        '/hallway': (context) => Rooms('Hallway'),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Murder Mystery Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/startGame');
              },
              child: Text('Start Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/howToPlay');
              },
              child: Text('How to Play'),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Screen'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: 100, // Adjust the left position
              top: 200, // Adjust the top position
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Adjust the radius to match the button shape
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/kitchen');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Image.asset(
                    'assets/kitchen_screen.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 440, // Adjust the left position
              top: 200, // Adjust the top position
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Adjust the radius to match the button shape
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/livingRoom');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Image.asset(
                    'assets/living_room_screen_pic.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 770, // Adjust the left position
              top: 200, // Adjust the top position
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Adjust the radius to match the button shape
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/hallway');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Image.asset(
                    'assets/hallway_screen.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }
}

class Rooms extends StatelessWidget {
  final dynamic roomName; // Final datatype selected instead of String, for this class (or a class that this class inherits from) is marked as '@immutable', but one or more of its instance fields aren't final: KitchenScreen.roomName.
  Rooms(this.roomName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              left: 100, // Adjust the left position
              top: 100,
              child: ClipOval(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/livingRoom');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  child: Image.asset(
                    'assets/kitchen_screen.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }
}

class HowToPlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How to Play'),
      ),
      drawer: CustomDrawer(),
    );
  }
}
