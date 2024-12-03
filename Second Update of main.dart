import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'node.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'algorithm.dart';

late Box<Node> box; // Declaring Hive box to store Node objects

Future<void> main() async { //Initialises Flutter bindings and Hive
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NodeAdapter()); //Registers the NodeAdapter to handle Node objects in Hive.
  box = await Hive.openBox<Node>('decisionMap');

  String csv = 'example_murder.csv';
  String fileData = await rootBundle.loadString(csv);

  List<String> rows = fileData.split("\n");
  for (String row in rows) {
    List<String> itemInRow = row.split(",");
    if (itemInRow.length >= 5) {
      String name = itemInRow[0];
      String? clue = itemInRow[1].isEmpty ? null : itemInRow[1];
      String location = itemInRow[2].trim(); // Trim the location
      String role = itemInRow[3];
      String dialogue = itemInRow[4];
      Node node = Node(name, clue!, location, role, dialogue);
      box.put(name, node);
    }
  }

  runApp(const MyApp());
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
  List<Node> nodes = [];
  List<String> filteredPeople = [];
  String result = '';
  String selectedRoom = '';
  String selectedPerson = '';
  String selectedAction = 'Question';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        nodes = box.values.toList();
      });
    });
  }

  void handleAction() {
    setState(() {
      if (selectedAction == 'Question') {
        result = questionPerson(selectedPerson);
      } else if (selectedAction == 'Accuse') {
        result = accusePerson(selectedPerson);
      } else if (selectedAction == 'Investigate Room') {
        result = 'Investigating $selectedRoom';
      }
    });
  }

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
