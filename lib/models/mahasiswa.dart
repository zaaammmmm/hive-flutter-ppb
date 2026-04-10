import 'package:hive_flutter/hive_flutter.dart';

part 'mahasiswa.g.dart';

@HiveType(typeId: 0)
class Mahasiswa extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String nim;

  @HiveField(2)
  final int prodiId;

  Mahasiswa({required this.name, required this.nim, required this.prodiId});
}
