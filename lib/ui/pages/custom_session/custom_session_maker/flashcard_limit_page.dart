import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/custom_session/session_limit/session_limit_cubit.dart';
import 'package:flashcards/bloc/custom_session/session_limit/session_limit_state.dart';
import 'package:flashcards/domain/enums/pack_selected_filter.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/domain/models/flashcards/tag/tag.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_listener.dart';
import 'package:flashcards/ui/widgets/core/tag_chip.dart';
import 'package:flashcards/ui/widgets/core/tag_chip.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FlashcardLimitPage extends StatefulWidget {
  final List<SimplePack> selectedPacks;
  final PackSelectedFilter filter;
  final int packFilterCount;
  final List<Tag> selectedTags;
  final bool areAllTagsSelected;

  const FlashcardLimitPage({
    super.key,
    required this.selectedPacks,
    required this.filter,
    required this.selectedTags,
    required this.packFilterCount,
    required this.areAllTagsSelected,
  });

  @override
  State<FlashcardLimitPage> createState() => _FlashcardLimitPageState();
}

class _FlashcardLimitPageState extends State<FlashcardLimitPage> {
  late final TextEditingController _countCont;

  void _countFlashcards() {
    context.read<SessionLimitCubit>().loadData(
      packFilterCount: widget.packFilterCount,
      areAllTagsSelected: widget.areAllTagsSelected,
      selectedTags: widget.selectedTags,
      filter: widget.filter,
      selectedPackNames: widget.selectedPacks.packNames,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _countFlashcards());
    _countCont = TextEditingController(text: widget.packFilterCount.toString());
  }

  @override
  void dispose() {
    _countCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayListener<SessionLimitCubit, SessionLimitState>(
      isLoading: (state) =>
          state is SessionLimitLoaded && state.status.isLoading,
      loadingText:
          "جارٍ إنشاء الجلسة. قد يأخذ وقتاً حسب "
          "حجم الجلسة",
      child: BlocListener<SessionLimitCubit, SessionLimitState>(
        listenWhen: (previous, current) =>
            current is SessionLimitLoaded && current.status.isSuccess ||
            current is SessionLimitLoaded && current.status.isError,
        listener: (context, state) {
          if (state is! SessionLimitLoaded) return;
          switch (state.status) {
            case SessionLimitStatus.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(extractErrorMessage(state.error!))),
              );
              return;
            case SessionLimitStatus.success:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم إنشاء الجلسة")),
              );
              context.router.parent()?.pop();
              return;
            default:
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalScreenPadding,
              ),
              child: BlocBuilder<SessionLimitCubit, SessionLimitState>(
                builder: (context, state) {
                  switch (state) {
                    case SessionLimitLoaded(
                      :final flashcardsCount,
                      :final isEstimatePrecise,
                    ):
                      return _LoadedContent(
                        flashcardsCount: flashcardsCount,
                        isEstimatePrecise: isEstimatePrecise,
                        filter: widget.filter,
                        selectedPacks: widget.selectedPacks,
                        selectedTags: widget.selectedTags,
                        countCont: _countCont,
                        packFilterCount: widget.packFilterCount,
                      );
                    default:
                      return SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final List<SimplePack> selectedPacks;
  final PackSelectedFilter filter;
  final List<Tag> selectedTags;
  final int flashcardsCount;
  final bool isEstimatePrecise;
  final TextEditingController countCont;
  final int packFilterCount;

  const _LoadedContent({
    super.key,
    required this.flashcardsCount,
    required this.isEstimatePrecise,
    required this.filter,
    required this.selectedTags,
    required this.selectedPacks,
    required this.countCont,
    required this.packFilterCount,
  });

  @override
  Widget build(BuildContext context) {
    void onSubmit() {
      context.read<SessionLimitCubit>().submitCustomSession(
        flashcardsCount: countCont.text,
        packFilterCount: packFilterCount,
        filter: filter,
        packIds: selectedPacks.packIds,
        selectedTags: selectedTags.toIdList(),
      );
    }

    final countText = isEstimatePrecise
        ? "المتاح $flashcardsCount بطاقة. كم بطاقة "
              "تبي في جلستك؟"
        : "نقدّر أن المتاح $flashcardsCount بطاقة،"
              " كم بطاقة تبي في جلستك؟";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Text(countText),
        if (!isEstimatePrecise)
          CardFactory.warning(
            isThreeLine: true,
            title: Text("اخترت جزءاً من الوسوم فقط."),
            subtitle: Text(
              "بما أنك اخترت بعض الوسوم فقط، فعدد البطاقات المطابقة الفعلي"
              " قد يكون أقل من المقدَّر.",
            ),
          ),

        BlocTextField<SessionLimitCubit, SessionLimitState>(
          errorSelector: (state) =>
              state is SessionLimitLoaded && state.status.isFormInvalid
              ? state.formErrors['flashcardsCount']
              : null,
          labelText: "عدد بطاقات الجلسة",
          textEditingController: countCont,
        ),

        _buildSectionTitle('الحزم المختارة'),
        Wrap(
          spacing: 3,
          runSpacing: 3,
          children: selectedPacks
              .map((pack) => TagChip(label: pack.packName))
              .toList(),
        ),
        SizedBox(),
        _buildSectionTitle('فلتر الحزم'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            filter.label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SizedBox(),
        _buildSectionTitle('الوسوم المختارة'),
        selectedTags.isEmpty
            ? Text(
                'لم تختر وسوماً',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : Wrap(
                spacing: 3,
                runSpacing: 3,
                children: selectedTags
                    .map((tag) => TagChip(label: tag.name))
                    .toList(),
              ),

        SizedBox(height: 5),
        Center(
          child: BlocButton<SessionLimitCubit, SessionLimitState>(
            showSpinner: false,
            textString: "إنشاء الجلسة",
            onPressed: (context) => onSubmit(),
            isLoadingState: (state) =>
                state is SessionLimitLoaded && state.status.isLoading,
          ),
        ),
      ],
    );
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}
