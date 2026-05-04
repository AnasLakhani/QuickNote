import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/colors.dart';
import '../core/localization.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/note_list_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  Color _selectedColor = AppColors.noteRed;
  String? _editingNoteId;
  DateTime? _editingNoteCreatedAt;
  String? _titleError;
  String? _contentError;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': AppStrings.colorRed, 'color': AppColors.noteRed},
    {'name': AppStrings.colorBlue, 'color': AppColors.noteBlue},
    {'name': AppStrings.colorGreen, 'color': AppColors.noteGreen},
    {'name': AppStrings.colorYellow, 'color': AppColors.noteYellow},
  ];

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    setState(() {
      _titleError = title.isEmpty ? AppStrings.errorEmptyTitle : null;
      _contentError = content.isEmpty ? AppStrings.errorEmptyContent : null;
    });

    if (title.isEmpty || content.isEmpty) {
      return;
    }

    final isEditing = _editingNoteId != null;
    final note = Note(
      id: isEditing ? _editingNoteId! : DateTime.now().toIso8601String(),
      title: title,
      content: content,
      color: _selectedColor,
      createdAt: isEditing ? _editingNoteCreatedAt! : DateTime.now(),
    );

    if (isEditing) {
      ref.read(notesProvider.notifier).updateNote(note);
    } else {
      ref.read(notesProvider.notifier).addNote(note);
      _listKey.currentState?.insertItem(0);
    }

    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedColor = AppColors.noteRed;
      _editingNoteId = null;
      _editingNoteCreatedAt = null;
      _titleError = null;
      _contentError = null;
    });
    FocusScope.of(context).unfocus();
    _showSnackBar(isEditing ? AppStrings.successNoteUpdated : AppStrings.successNoteSaved, isError: false);
  }

  void _editNote(Note note) {
    setState(() {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedColor = note.color;
      _editingNoteId = note.id;
      _editingNoteCreatedAt = note.createdAt;
      _titleError = null;
      _contentError = null;
    });
  }

  void _deleteNote(Note note, int index) {
    ref.read(notesProvider.notifier).deleteNote(note.id);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(note, animation, index),
      duration: const Duration(milliseconds: 300),
    );

    if (_editingNoteId == note.id) {
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedColor = AppColors.noteRed;
        _editingNoteId = null;
        _editingNoteCreatedAt = null;
      });
    }
    _showSnackBar(AppStrings.successNoteDeleted, isError: false);
  }

  Widget _buildItem(Note note, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: NoteListItem(
          note: note,
          onEdit: () => _editNote(note),
          onDelete: () => _deleteNote(note, index),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(AppStrings.appTitle, style: TextStyle(color: AppColors.textPrimary(context))),
        backgroundColor: AppColors.cardBackground(context),
        elevation: 1,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Input Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      hintText: AppStrings.titleHint,
                      errorText: _titleError,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _contentController,
                      hintText: AppStrings.contentHint,
                      maxLines: 3,
                      errorText: _contentError,
                    ),
                    const SizedBox(height: 12),
                    // Color Selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _colorOptions.map((option) {
                          final color = option['color'] as Color;
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.textPrimary(context) : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _editingNoteId == null ? AppStrings.saveButton : AppStrings.updateButton,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cardBackground(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Notes List
              Expanded(
                child: notes.isEmpty
                    ? Center(
                        child: Text(
                          AppStrings.emptyNotesMessage,
                          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16),
                        ),
                      )
                    : AnimatedList(
                        key: _listKey,
                        initialItemCount: notes.length,
                        itemBuilder: (context, index, animation) {
                          if (index >= notes.length) return const SizedBox.shrink();
                          return _buildItem(notes[index], animation, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
