import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('mahasiswaBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MahasiswaPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MahasiswaPage extends StatefulWidget {
  @override
  _MahasiswaPageState createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State {
  final box = Hive.box('mahasiswaBox');

  final namaController = TextEditingController();
  final nimController = TextEditingController();
  final prodiController = TextEditingController();

  int? editIndex; // null = tambah, ada nilai = edit

  void saveData() {
    final data = {
      'nama': namaController.text,
      'nim': nimController.text,
      'prodi': prodiController.text,
    };

    if (editIndex == null) {
      box.add(data);
    } else {
      box.putAt(editIndex!, data);
      editIndex = null;
    }

    clearForm();
  }

  void editData(int index) {
    final data = box.getAt(index);

    namaController.text = data['nama'];
    nimController.text = data['nim'];
    prodiController.text = data['prodi'];

    setState(() {
      editIndex = index;
    });
  }

  void deleteData(int index) {
    box.deleteAt(index);
  }

  void clearForm() {
    namaController.clear();
    nimController.clear();
    prodiController.clear();

    setState(() {
      editIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD Mahasiswa - Hive")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // FORM INPUT
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: "Nama"),
            ),
            TextField(
              controller: nimController,
              decoration: InputDecoration(labelText: "NIM"),
            ),
            TextField(
              controller: prodiController,
              decoration: InputDecoration(labelText: "Prodi"),
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

            // LIST DATA
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return Center(child: Text("Belum ada data"));
                  }

                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final data = box.getAt(index);

                      return Card(
                        child: ListTile(
                          title: Text(data['nama']),
                          subtitle: Text(
                            "NIM: ${data['nim']} | ${data['prodi']}",
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
