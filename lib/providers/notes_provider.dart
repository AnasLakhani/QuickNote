import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';

class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() {
    return [];
  }

  void addNote(Note note) {
    state = [note, ...state];
  }

  void updateNote(Note updatedNote) {
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note
    ];
  }

  void deleteNote(String id) {
    state = state.where((note) => note.id != id).toList();
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});
