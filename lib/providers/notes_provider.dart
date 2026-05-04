import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class NotesNotifier extends Notifier<List<Note>> {
  static const _key = 'notes';

  @override
  List<Note> build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final notesString = prefs.getString(_key);
    if (notesString != null) {
      final List<dynamic> decoded = jsonDecode(notesString);
      return decoded.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  void _save(List<Note> newNotes) {
    final prefs = ref.read(sharedPrefsProvider);
    prefs.setString(_key, jsonEncode(newNotes.map((e) => e.toJson()).toList()));
  }

  void addNote(Note note) {
    state = [note, ...state];
    _save(state);
  }

  void updateNote(Note updatedNote) {
    state = [
      for (final note in state)
        if (note.id == updatedNote.id) updatedNote else note
    ];
    _save(state);
  }

  void deleteNote(String id) {
    state = state.where((note) => note.id != id).toList();
    _save(state);
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});
