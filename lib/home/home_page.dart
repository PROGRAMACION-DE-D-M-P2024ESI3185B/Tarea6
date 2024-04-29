import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_notes_app/content/fs_admin_table.dart';
import 'package:fire_notes_app/content/notes/item_note.dart';
import 'package:fire_notes_app/create_form/new_note_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _fabKey = GlobalKey<ExpandableFabState>();
  String _searchText = "";
  String _orderBy = "";

  Future<void> _deleteNote(String noteId) async {
    try {
      await FirebaseFirestore.instance.collection("notes").doc(noteId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error deleting note: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete note'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => FsAdminTable(),
                ),
              );
            },
            icon: Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: 250.0, // Adjust width as needed
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Implement search functionality here
                // Update the query parameter based on value
                print(value);
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          SizedBox(
            width: 250.0, // Adjust width as needed
            child: ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_orderBy == "up") {
                        _orderBy = "down";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order changed to descending'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (_orderBy == "down" || _orderBy == "") {
                        _orderBy = "up";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order changed to ascending'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                  },
                  child: Text("Order by date"),
                ),
              ],
            ),
          ),
          Flexible(
            child: FirestoreListView(
              padding: EdgeInsets.symmetric(horizontal: 18),
              pageSize: 15,
              query: getNotesQuery(FirebaseAuth.instance.currentUser!.uid,
                  order: _orderBy, name: _searchText),
              itemBuilder: (BuildContext context,
                  QueryDocumentSnapshot<Map<String, dynamic>> document) {
                return ItemNote(
                    docId: document.id,
                    noteContent: document.data(),
                    onDelete: () {
                      print('Delete note: $document');
                      _deleteNote(document.id);
                    });
              },
            ),
          )
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _fabKey,
        // type: ExpandableFabType.up,
        children: [
          FloatingActionButton.small(
            heroTag: null,
            tooltip: "New note",
            child: Icon(Icons.file_copy),
            onPressed: () {
              print("New note button");
              _fabKey.currentState?.toggle();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewNoteForm(),
                ),
              );
            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            tooltip: "New folder",
            child: Icon(Icons.folder),
            onPressed: () {
              _fabKey.currentState?.toggle();
            },
          ),
        ],
      ),
    );
  }
}

// Separated function for building the query
Query<Map<String, dynamic>> getNotesQuery(String userId,
    {String order = "up", String name = ""}) {
  String collection = "notes";

  print('${FirebaseAuth.instance.currentUser!.uid}, $order, $name');

  if (name == "") {
    if (order == "up") {
      return FirebaseFirestore.instance
          .collection(collection)
          .where("userId", isEqualTo: userId)
          .orderBy("createdAt");
    } else if (order == "down") {
      return FirebaseFirestore.instance
          .collection(collection)
          .where("userId", isEqualTo: userId)
          .orderBy("createdAt", descending: true);
    }
    return FirebaseFirestore.instance
        .collection(collection)
        .where("userId", isEqualTo: userId);
  }

  if (order == "up") {
    return FirebaseFirestore.instance
        .collection(collection)
        .where("userId", isEqualTo: userId)
        .where("data.title", isGreaterThanOrEqualTo: name)
        .where("data.title", isLessThanOrEqualTo: '${name!}\uf8ff')
        .orderBy("createdAt");
  } else if (order == "down") {
    return FirebaseFirestore.instance
        .collection(collection)
        .where("userId", isEqualTo: userId)
        .where("data.title", isGreaterThanOrEqualTo: name)
        .where("data.title", isLessThanOrEqualTo: '${name!}\uf8ff')
        .orderBy("createdAt", descending: true);
  }
  return FirebaseFirestore.instance
      .collection(collection)
      .where("userId", isEqualTo: userId)
      .where("data.title", isGreaterThanOrEqualTo: name)
      .where("data.title", isLessThanOrEqualTo: '${name!}\uf8ff');
}
