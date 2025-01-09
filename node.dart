import 'package:hive/hive.dart';
part 'node.g.dart';

@HiveType(typeId: 0)
class Person{
  @HiveField(0)
  int personiD;
  @HiveField(1)
  String name;
  Person(this.personiD, this.name);

}
@HiveType(typeId: 1)
class Room{
  @HiveField(0)
  int roomID;
  @HiveField(1)
  String roomName;
  @HiveField(3)
  int capacity;
  Room(this.roomID, this.roomName, this.capacity);
}


@HiveType(typeId: 2)
class Clue{
  @HiveField(0)
  int clueID;
  @HiveField(1)
  String clueName;
  Clue(this.clueID, this.clueName);
}
@HiveType(typeId: 3)
class Dialogue{
  @HiveField(0)
  int personID;
  @HiveField(1)
  int roomID;
  @HiveField(2)
  int clueID;
  @HiveField(3)
  int sequenceOfDialogue;
  @HiveField(4)
  String dialogue;
  Dialogue(this.personID,this.roomID,this.clueID,this.sequenceOfDialogue, this.dialogue);
}

