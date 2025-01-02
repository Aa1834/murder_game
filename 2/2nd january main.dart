import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'node.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'story.dart';
//import 'algorithm.dart';

late Box<Person> personBox; // Declaring Hive box to store Node objects
late Box<Clue> clueBox;
late Box<Room> roomBox;

// printing the contents of each Hive box. Remove printBoxContents method after it is no longer of use.

/*void printBoxContents() {
  print('Persons:');
  for (var value in personBox.values) {
    print('ID: ${value.personiD}, name ${value.name}');
  }

  print('Rooms:');
  for (var key in roomBox.keys) {
    var room = roomBox.get(key);
    print('ID: ${room?.roomID}, Name: ${room?.roomName}, Capacity: ${room?.capacity}');
  }

  print('Clues:');
  for (var key in clueBox.keys) {
    var clue = clueBox.get(key);
    print('ID: ${clue?.clueID}, Name: ${clue?.clueName}');
  }
} */

//Map <String, String> personToLocationMap = {};

class GameLogic {
  List<Person> people = []; // Empty arrays/lists for people, clue and room which will later be populated.
  List<Clue> clues = [];
  List<Room> rooms = [];

  GameStory story = GameStory();


  GameLogic() {
    _loadData();
  }

  void _loadData() {
    print("YOOO");
    print(people);
    people = personBox.values.toList(); // The personBox, clueBox and roomBox are currently populated with the data desired.
    clues = clueBox.values.toList();
    rooms = roomBox.values.toList();
    story.loadLists(people, clues, rooms);
  }

  void printLists() { //Redundant method; used to show whether the people, clue and rooms lists are populated or not
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
  }
}

// Main function to initialize Hive, register adapters, open boxes, and load data from CSV files.
Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
  print("HI THERE 1");
 await Hive.initFlutter();
 Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(ClueAdapter());
  Hive.registerAdapter(RoomAdapter());
  print("HI THERE 1");
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

  print("HI THERE");
  //printBoxContents();
  GameLogic gameLogic = GameLogic();
  gameLogic.printLists();

  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyFlutterApp(),
    );
  }
}

class MyFlutterApp extends StatefulWidget {
  const MyFlutterApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyFlutterState();
  }
}

class MyFlutterState extends State<MyFlutterApp> {
  /** List<Person> nodes = [];
  List<String> filteredPeople = [];
  String result = '';
  String selectedRoom = '';
  String selectedPerson = '';
  String selectedAction = 'Question'; **/

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        nodes = personBox.values.toList();
      });
    });
  }

  /** void handleAction() {
    setState(() {
      if (selectedAction == 'Question') {
        Node? node = nodes.firstWhere((node) => node.name == selectedPerson, orElse: () => Node('', '', '', '', ''));
        if (node.name.isNotEmpty) {
          result = 'Questioning ${node.name}: ${node.dialogue}';
        } else {
          result = 'Person not found.';
        }
      } else if (selectedAction == 'Accuse') {
        result = accusePerson(selectedPerson);
      } else if (selectedAction == 'Investigate Room') {
        result = 'Investigating $selectedRoom';
      }
    });
  } **/

  @override
  Widget build(BuildContext context) {
    List<String> rooms = nodes.map((node) => node.location.trim()).toSet().toList(); // Ensure unique rooms

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nodes List"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedRoom.isEmpty ? null : selectedRoom,
                hint: const Text('Select Room'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRoom = newValue!;
                    filteredPeople = nodes
                        .where((node) => node.location.trim() == selectedRoom)
                        .map((node) => node.name)
                        .toList();
                    selectedPerson = ''; // Reset selected person when room changes
                  });
                },
                items: rooms.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedPerson.isEmpty ? null : selectedPerson,
                hint: const Text('Select Person'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPerson = newValue!;
                  });
                },
                items: filteredPeople.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedAction,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedAction = newValue!;
                  });
                },
                items: <String>['Question', 'Accuse', 'Investigate Room']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: handleAction,
              child: const Text('Perform Action'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (selectedPerson.isNotEmpty)
              Text('Selected Person: $selectedPerson'),
            if (selectedRoom.isNotEmpty)
              Text('Selected Room: $selectedRoom'),
            const SizedBox(height: 16),
            if (result.isNotEmpty)
              Text(result),
          ],
        ),
      ),
    );
  }
} 
