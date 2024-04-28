import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemNote extends StatelessWidget {
  final Map<String, dynamic> noteContent;
  final VoidCallback onDelete;

  ItemNote({Key? key, required this.noteContent, required this.onDelete})
      : super(key: key);

  Future<void> _deleteNote() async {
    try {
      await FirebaseFirestore.instance
          .collection("notes")
          .doc(noteContent['id'])
          .delete();
      onDelete();
    } catch (e) {
      print("Error deleting note: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              noteContent["data"]["title"],
              style: TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
    );
  }
}
