import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemNote extends StatefulWidget {
  final Map<String, dynamic> noteContent;
  final VoidCallback onDelete;
  final String docId;

  ItemNote({
    Key? key,
    required this.docId,
    required this.noteContent,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ItemNoteState createState() => _ItemNoteState();
}

class _ItemNoteState extends State<ItemNote> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.noteContent['data']['title']);
    _descriptionController =
        TextEditingController(text: widget.noteContent['data']['description']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _deleteNote() async {
    print('Deleting note: ${widget.noteContent['id']}');
    try {
      await FirebaseFirestore.instance
          .collection("notes")
          .doc(widget.noteContent['id'])
          .delete();
      widget.onDelete();
    } catch (e) {
      print("Error deleting note: $e");
    }
  }

  Future<void> _editNote() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        print(context);
        return AlertDialog(
          title: Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                print('Updating note: ${widget.docId}');
                try {
                  await FirebaseFirestore.instance
                      .collection("notes")
                      .doc(widget.docId)
                      .update({
                    'data.title': _titleController.text,
                    'data.description': _descriptionController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update Successful'),
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  print("Error updating note: $e");
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.noteContent["data"]["title"],
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  widget.noteContent["data"]["details"],
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editNote,
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
