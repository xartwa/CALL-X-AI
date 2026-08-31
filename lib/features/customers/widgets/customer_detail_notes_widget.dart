import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/core/constants/theme_constants.dart';
import 'package:callx_ai/core/widgets/confirmation_dialog.dart';
import 'package:callx_ai/features/customers/cubit/customers_cubit.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/utils/app_date_time.dart';

class CustomerDetailNotesWidget extends StatefulWidget {
  final User user;

  const CustomerDetailNotesWidget({
    super.key,
    required this.user,
  });

  @override
  State<CustomerDetailNotesWidget> createState() =>
      _CustomerDetailNotesWidgetState();
}

class _CustomerDetailNotesWidgetState extends State<CustomerDetailNotesWidget> {
  final _newNoteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _editingNoteId;
  final _editNoteCtrl = TextEditingController();

  String _formatNoteDate(DateTime value) => AppDateTime.displayDateTime(value);

  @override
  void dispose() {
    _newNoteCtrl.dispose();
    _searchCtrl.dispose();
    _editNoteCtrl.dispose();
    super.dispose();
  }

  void _saveNote() {
    final text = _newNoteCtrl.text.trim();
    if (text.isEmpty) return;

    context.read<CustomersCubit>().addNote(widget.user.id, text);
    _newNoteCtrl.clear();
  }

  void _saveEdit(String noteId) {
    final text = _editNoteCtrl.text.trim();
    if (text.isEmpty) return;

    context.read<CustomersCubit>().updateNote(
          widget.user.id,
          noteId,
          text,
        );

    setState(() {
      _editingNoteId = null;
      _editNoteCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter notes by search query
    final filteredNotes = widget.user.notesList.where((note) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return note.content.toLowerCase().contains(q) ||
          _formatNoteDate(note.date).toLowerCase().contains(q) ||
          note.author.toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.square_list,
                    size: 20,
                    color: context.colors.primaryLightColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'NOTES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.primaryLightColor
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.user.notesList.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: context.colors.primaryLightColor,
                      ),
                    ),
                  ),
                ],
              ),
              // Search Input Box
              SizedBox(
                width: 220,
                height: 38,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle: TextStyle(
                      fontSize: 11,
                      color:
                          context.colors.darkGreyColor.withValues(alpha: 0.7),
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      size: 15,
                      color: context.colors.darkGreyColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(CupertinoIcons.clear_thick,
                                size: 14),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(ThemeConstants.buttonRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add Note Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A).withAlpha(150)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(ThemeConstants.boxRadius),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _newNoteCtrl,
                  maxLines: 2,
                  minLines: 2,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'Write a new note here...',
                    hintStyle: TextStyle(
                      color:
                          context.colors.darkGreyColor.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Submit Button
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: _saveNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primaryLightColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Note',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notes List
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.doc_text,
                          size: 36,
                          color: context.colors.darkGreyColor
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No notes found for "$_searchQuery".'
                              : 'No notes added for this customer yet.',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.darkGreyColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      final isEditing = _editingNoteId == note.id;
                      final noteNumber = widget.user.notesList.length - index;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withAlpha(100)
                              : const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : const Color(0xFFF1F5F9),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Note Header with actions & date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.colors.primaryLightColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Note $noteNumber',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Timestamp
                                    Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.clock,
                                          size: 11,
                                          color: context.colors.darkGreyColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatNoteDate(note.date),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: context.colors.darkGreyColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    // Edit action
                                    IconButton(
                                      splashRadius: 14,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        CupertinoIcons.pencil,
                                        size: 14,
                                        color: context.colors.primaryLightColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _editingNoteId = note.id;
                                          _editNoteCtrl.text = note.content;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    // Delete action
                                    IconButton(
                                      splashRadius: 14,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        CupertinoIcons.trash,
                                        size: 14,
                                        color: context.colors.errorColor,
                                      ),
                                      onPressed: () {
                                        ConfirmationDialog.show(
                                          context,
                                          title: 'Delete Note',
                                          message:
                                              'Are you sure you want to delete this note?',
                                          confirmLabel: 'Delete',
                                          onConfirm: () {
                                            context
                                                .read<CustomersCubit>()
                                                .deleteNote(
                                                    widget.user.id, note.id);
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Note Content / In-place Editor
                            if (isEditing) ...[
                              TextField(
                                controller: _editNoteCtrl,
                                maxLines: 3,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF0F172A)
                                      : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.all(8),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _editingNoteId = null;
                                      });
                                    },
                                    child: const Text('Cancel',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton(
                                    onPressed: () => _saveEdit(note.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          context.colors.primaryLightColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                    ),
                                    child: const Text('Save',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.white)),
                                  ),
                                ],
                              ),
                            ] else ...[
                              Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: isDark
                                      ? Colors.grey[200]
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
