import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mahasiswa_app/models/mahasiswa.dart';
import 'package:mahasiswa_app/models/prodi.dart';

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  final Box<Mahasiswa> _box = Hive.box<Mahasiswa>('mahasiswaBox');
  final Box<Prodi> _prodiBox = Hive.box<Prodi>('prodiBox');

  late TextEditingController nameController;
  late TextEditingController nimController;

  int? editIndex;
  int? selectedProdiId;

  void saveData() {
    if (selectedProdiId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Prodi tidak boleh kosong!")));
      return;
    }
    final Mahasiswa mahasiswa = Mahasiswa(
      name: nameController.text,
      nim: nimController.text,
      prodiId: selectedProdiId!,
    );
    if (editIndex == null) {
      _box.add(mahasiswa);
    } else {
      _box.putAt(editIndex!, mahasiswa);
      editIndex = null;
    }

    clearForm();
  }

  void editData(int index) {
    final data = _box.getAt(index)!;

    nameController.text = data.name;
    nimController.text = data.nim;
    selectedProdiId = data.prodiId;

    setState(() {
      editIndex = index;
    });
  }

  void deleteData(int index) {
    _box.deleteAt(index);
  }

  void clearForm() {
    nameController.clear();
    nimController.clear();
    selectedProdiId = null;

    setState(() {
      editIndex = null;
    });
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    nimController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD Mahasiswa - Hive")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: nimController,
              decoration: InputDecoration(labelText: "NIM"),
            ),
            DropdownButtonFormField<int>(
              key: ValueKey(selectedProdiId),
              initialValue: selectedProdiId,
              hint: Text("Pilih Prodi"),
              items: List.generate(_prodiBox.length, (index) {
                final prodi = _prodiBox.getAt(index);
                return DropdownMenuItem(
                  value: index,
                  child: Text(prodi!.namaProdi),
                );
              }),
              onChanged: (value) {
                setState(() {
                  selectedProdiId = value;
                });
              },
            ),

            SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton(
                  onPressed: saveData,
                  child: Text(editIndex == null ? "Simpan" : "Update"),
                ),
                SizedBox(width: 10),
                if (editIndex != null)
                  ElevatedButton(onPressed: clearForm, child: Text("Batal")),
              ],
            ),

            SizedBox(height: 20),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _box.listenable(),
                builder: (context, Box<Mahasiswa> box, _) {
                  if (box.isEmpty) {
                    return Center(child: Text("Belum ada data"));
                  }

                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final data = box.getAt(index)!;
                      final prodi = _prodiBox.getAt(data.prodiId);

                      return Card(
                        child: ListTile(
                          title: Text(data.name),
                          subtitle: Text(
                            "NIM: ${data.nim} | ${prodi?.namaProdi ?? "-"}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => editData(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteData(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
