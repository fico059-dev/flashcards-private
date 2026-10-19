import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flashcards/bloc/osces/update_osce/forms/question_form/question_form.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_cubit.dart';
import 'package:flashcards/bloc/osces/update_osce/update_osce_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/domain/models/osce/osce_text_format.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/osce_builder/osce_text_dialog.dart';
import 'package:flutter/services.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_listener.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/osce_builder/question_input_widget.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class QuestionEditorPage extends StatelessWidget {
  final String osceId;

  const QuestionEditorPage({super.key, required this.osceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UpdateOsceCubit(osceRepo: context.read<OsceRepository>()),
      child: _View(osceId: osceId),
    );
  }
}

class _View extends StatefulWidget {
  final String osceId;

  const _View({super.key, required this.osceId});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  void _loadQuestions() {
    context.read<UpdateOsceCubit>().loadQuestions(widget.osceId);
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit OSCE")),
      body: ReadableWidth(
        maxWidth: 820,
        child: BlocBuilder<UpdateOsceCubit, UpdateOsceState>(
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          builder: (context, state) {
            switch (state) {
              case UpdateOsceInitial():
              case UpdateOsceLoading():
                return Center(
                  child: CircularProgressIndicator(
                    color: context.colors.primary,
                  ),
                );
              case UpdateOsceError(:final error):
                return ErrorScreen(
                  errorMessage: extractErrorMessage(error),
                  onReload: _loadQuestions,
                );
              case UpdateOsceLoaded():
                return _LoadedContent(state: state);
            }
          },
        ),
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final UpdateOsceLoaded state;

  const _LoadedContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    void addQuestion() {
      context.read<UpdateOsceCubit>().addQuestionForm();
    }

    void removeQuestion(int index) async {
      context.read<UpdateOsceCubit>().deleteQuestion(index);
    }

    Future<void> onSubmit() async {
      context.read<UpdateOsceCubit>().submitOSCEQuestions();
    }

    Future<void> addFromText() async {
      final cubit = context.read<UpdateOsceCubit>();
      final text = await showOsceTextDialog(
        context: context,
        title: 'Add questions from text',
        actionLabel: 'Add questions',
        describe: describeOsceText,
        hint: osceTextExample,
      );
      if (text == null) return;
      final parsed = parseOsceText(text);
      cubit.addQuestionsFromText(parsed);
      if (!context.mounted || parsed.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${describeOsceText(text)}. Press Save Changes to keep them.',
          ),
        ),
      );
    }

    Future<void> copyAsText(List<QuestionForm> questions) async {
      final text = osceToText(questions.mapIndexed((i, q) => q.toQuestion(i)));
      await Clipboard.setData(ClipboardData(text: text));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Copied as text. Paste it into "Add from text" in another OSCE '
            'to reuse it.',
          ),
        ),
      );
    }

    return LoadingOverlayListener<UpdateOsceCubit, UpdateOsceState>(
      isLoading: (state) => state is UpdateOsceLoaded && state.status.isLoading,
      child: BlocListener<UpdateOsceCubit, UpdateOsceState>(
        listenWhen: (previous, current) {
          final isCurrentLoaded = current is UpdateOsceLoaded;
          if (!isCurrentLoaded) return false;

          return current.status.isError ||
              current.status.isDeleteSuccessful ||
              current.status.isUpdateSuccessful;
        },
        listener: (context, state) {
          if (state is! UpdateOsceLoaded) return;
          switch (state.status) {
            case UpdateOsceStatus.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 10),
                  content: Text(extractErrorMessage(state.error!)),
                ),
              );
              break;
            case UpdateOsceStatus.deleteSuccessful:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Successfully deleted question.")),
              );
              break;
            case UpdateOsceStatus.updateSuccessful:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Successfully saved changes.")),
              );
              context.router.pop();
              break;
            default:
          }
        },
        child:
            BlocSelector<UpdateOsceCubit, UpdateOsceState, List<QuestionForm>>(
              selector: (state) {
                if (state is! UpdateOsceLoaded) {
                  throw Exception("Osce state is not loaded");
                }

                return state.questionForms;
              },
              builder: (context, questions) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fastest way: write or paste the whole OSCE as '
                              'text. Start each question with "Q:", put one '
                              'check per line, end a heading with ":", and '
                              'add marks in brackets like (2).',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilledButton.tonalIcon(
                                  icon: const Icon(Icons.content_paste),
                                  label: const Text('Add from text'),
                                  onPressed: addFromText,
                                ),
                                if (questions.isNotEmpty)
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.copy),
                                    label: const Text('Copy as text'),
                                    onPressed: () => copyAsText(questions),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...questions.asMap().entries.mapIndexed((index, qEntry) {
                      final qIndex = qEntry.key;
                      final qForm = qEntry.value;
                      return Column(
                        children: [
                          QuestionInputWidget(
                            key: ObjectKey(qForm.id),
                            questionIndex: index,
                            questionCount: questions.length,
                            questionForm: qForm,
                            onRemoveQuestion: () => removeQuestion(qIndex),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                        onPressed: addQuestion,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: onSubmit,
                        child: Text("Save Changes"),
                      ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}
