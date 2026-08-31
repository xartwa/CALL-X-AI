import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callx_ai/theme/app_colors.dart';
import 'package:callx_ai/core/widgets/spaced_text.dart';
import '../cubit/todo_cubit.dart';

class TodoListCard extends StatefulWidget {
  const TodoListCard({super.key});

  @override
  State<TodoListCard> createState() => _TodoListCardState();
}

class _TodoListCardState extends State<TodoListCard> {
  final TextEditingController _todoController = TextEditingController();

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _handleAddTodo() {
    final text = _todoController.text.trim();
    if (text.isNotEmpty) {
      context.read<TodoCubit>().addTodo(text);
      _todoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with completion badge
          BlocBuilder<TodoCubit, TodoState>(
            builder: (context, state) {
              final done = state.completedCount;
              final total = state.totalCount;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SpacedText(
                    text: "To-Do List",
                    color: context.colors.blackColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  if (total > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: done == total && total > 0
                            ? context.colors.successColor
                                .withValues(alpha: 0.12)
                            : context.colors.primaryLightColor
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        done == total
                            ? "All Done 🎉"
                            : "$done / $total Completed",
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: done == total && total > 0
                              ? context.colors.successColor
                              : context.colors.primaryLightColor,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Add Todo Input Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : context.colors.mediumGreyColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          context.colors.mediumGreyColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: TextField(
                    controller: _todoController,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.colors.blackColor,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Add a new task...",
                      hintStyle: TextStyle(
                        color: context.colors.darkGreyColor,
                        fontSize: 12.5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleAddTodo(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _handleAddTodo,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.colors.primaryLightColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Reactive Task List
          BlocBuilder<TodoCubit, TodoState>(
            builder: (context, state) {
              if (state.todos.isEmpty) {
                return const SizedBox(
                  height: 92,
                  child: Center(
                    child: Text('All caught up!'),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return _TodoItemTile(
                      todo: todo,
                      onToggle: () =>
                          context.read<TodoCubit>().toggleTodo(todo.id),
                      onDelete: () =>
                          context.read<TodoCubit>().deleteTodo(todo.id),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodoItemTile extends StatelessWidget {
  final TodoItemModel todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TodoItemTile({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.02)
            : context.colors.milkyColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.mediumGreyColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Icon(
                todo.isCompleted
                    ? CupertinoIcons.checkmark_square_fill
                    : CupertinoIcons.square,
                size: 19,
                color: todo.isCompleted
                    ? context.colors.successColor
                    : context.colors.darkGreyColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              todo.text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight:
                    todo.isCompleted ? FontWeight.normal : FontWeight.w500,
                color: todo.isCompleted
                    ? context.colors.darkGreyColor
                    : context.colors.blackColor,
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: context.colors.darkGreyColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                CupertinoIcons.trash,
                color: context.colors.errorColor.withValues(alpha: 0.7),
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
