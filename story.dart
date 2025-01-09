import 'main.dart';
import 'dart:math';
import 'node.dart';
class GameStory {
  List<Person> people = [];
  List<Clue> clues = [];
  List<Room> rooms = [];
  List<Dialogue> dialogues = [];
  Map<String, String> personLocationMap = {};

  void loadLists(List<Person> valPerson, List<Clue> valClue, List<Room> valRoom,
      List<Dialogue> valDialogue) {
    people = valPerson;
    clues = valClue;
    rooms = valRoom;
    dialogues = valDialogue;
    allocatePeopleToRooms();
    printAllocations();
    displayDialogues();
  }

  List<List<String>> nodeAllocations = [
    []
  ]; // List of lists of people allocated to each room (2d array/matrix).

  void allocatePeopleToRooms() {
    nodeAllocations = List.generate(rooms.length, (_) => []);
    Random random = Random();
    List<int> personIndices = List.generate(people.length, (index) => index);
    personIndices.shuffle(random);


    for (int i = 0; i < people.length; i++) {
      int roomIndex = i % rooms.length;
      nodeAllocations[roomIndex].add(people[personIndices[i]].name);

      //print('Allocated ${people[personIndices[i]].name} to ${rooms[roomIndex].roomName} with key $personKey'); // Debug print

    }

    for (int i = 0; i < rooms.length; i++) {
      var n = 0;
      for (var person in nodeAllocations[i]) {
        String personKey = '${rooms[i].roomName}Person$n';
        print(personKey);
        personLocationMap[personKey] = person;
        n = n + 1;
      }
    }


    print(personLocationMap.keys);
    print(personLocationMap['HallwayPerson1']);
  }

  void printAllocations() {
    //print("HOOO HOOO HOO");
    for (int i = 0; i < rooms.length; i++) {
      print('Room: ${rooms[i].roomName}');
      for (var person in nodeAllocations[i]) {
        print('  Person: $person');
      }
    }
    //print("NEW NEW NEW");
    //print(personLocationMap);
  }

  void displayDialogues() {
    for (var dialogue in dialogues) {
      String s = populateNameInDialogue(dialogue);
      //String d=populateNameInDialogue(s);

      print(s);
      print("**********");
    }
  }

  /*String populateNameInDialogue(var dialogue)
  {
    //var person = people.firstWhere((p) => p.personiD == dialogue.personID);
    String processedDialogue='';
    String singleDialogue=dialogue.dialogue.toString();
    if(singleDialogue.indexOf('(')>0) {
      String personField = singleDialogue.substring(
          singleDialogue.indexOf('(')+1, singleDialogue.indexOf(')'));
      String firstPersonName = personLocationMap[personField]!;
      processedDialogue=dialogue.dialogue.replaceAll('('+personField+')', firstPersonName);
    }
    else
      {
        processedDialogue = dialogue.dialogue;
      }
    return processedDialogue;
  }
} */
  String populateNameInDialogue(var dialogue) {
    String processedDialogue = dialogue.dialogue.toString();
    RegExp regExp = RegExp(r'\(([^)]+)\)');
    Iterable<Match> matches = regExp.allMatches(processedDialogue);

    for (var match in matches) {
      String personField = match.group(1)!;
      if (personLocationMap.containsKey(personField)) {
        String personName = personLocationMap[personField]!;
        processedDialogue = processedDialogue.replaceFirst('($personField)', personName);
      }
    }

    return processedDialogue;
  }
}




