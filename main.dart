import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'node.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'algorithm.dart';

late Box<Node> box;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NodeAdapter());
  box = await Hive.openBox<Node>('decisionMap');

  String csv = 'example_murder.csv';
  String fileData = await rootBundle.loadString(csv);

  List<String> rows = fileData.split("\n");
  for (String row in rows) {
    List<String> itemInRow = row.split(",");
    if (itemInRow.length >= 5) {
      String name = itemInRow[0];
      String? clue = itemInRow[1].isEmpty ? null : itemInRow[1];
      String location = itemInRow[2];
      String role = itemInRow[3];
      String dialogue = itemInRow[4];
      Node node = Node(name, clue!, location, role, dialogue);
      box.put(name, node);
    }
  }
  for (var key in box.keys){
    Node? node = box.get(key);
    if (node != null) {
      print('Name: ${node.name}, Clue: ${node.clue ?? "None"}, Location: ${node.location}');
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
  String result = '';
  String selectedPerson = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        nodes = box.values.toList();
      });
    });
  }

  /* void handleQuestion() {
    setState(() {
      result = questionPerson(selectedPerson);
    });
  }

  void handleAccuse() {
    setState(() {
      result = accusePerson(selectedPerson);
    });
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nodes List"),
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final node = nodes[index];
            return ListTile(
              title: Text(node.name),
              subtitle: Text(
                  'Clue: ${node.clue ?? "None"}, Location: ${node.location}'),
              onTap: () {
                setState(() {
                  selectedPerson = node.name;
                });
                Navigator.pop(context); // Close the drawer
              },
            );
          },
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              children: [
              if (selectedPerson.isNotEmpty)
          Text('Selected Person: $selectedPerson'),
      Row(
          children: [
      ElevatedButton(
      onPressed: (){},
      child: const Text('Question'),
    ),
    const SizedBox(width: 16),
    ElevatedButton(
    onPressed:(){},
    child: const Text('Accuse'),
    ),
    ],
    ),
    const SizedBox(height: 16),
    if (result.isNotEmpty)
    Text(result),
    ],
    ),
    )
    ,
    );
  }
}
