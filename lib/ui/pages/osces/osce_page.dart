import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/osces/osce/osce_bloc.dart';
import 'package:flashcards/bloc/osces/osce/osce_event.dart';
import 'package:flashcards/bloc/osces/osce/osce_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/data/services/local/local_storage_service.dart';
import 'package:flashcards/domain/models/osce/simple_osce/simple_osce.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/osce/osce_bottom_action_buttons.dart';
import 'package:flashcards/ui/widgets/osce/osce_showcase_widget.dart';
import 'package:flashcards/ui/widgets/osce/osce_timer.dart';
import 'package:flashcards/ui/widgets/osce/osce_tutorial_seen_listener.dart';
import 'package:flashcards/ui/widgets/osce/question_context.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/osce/osce_checklist_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class OscePage extends StatelessWidget {
  final SimpleOsce simpleOsce;

  const OscePage({super.key, required this.simpleOsce});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OsceBloc(
            osceRepo: context.read<OsceRepository>(),
            localStorageService: context.read<LocalStorageService>(),
          ),
        ),
      ],
      child: _OsceView(simpleOsce: simpleOsce),
    );
  }
}

class _OsceView extends StatefulWidget {
  final SimpleOsce simpleOsce;

  const _OsceView({super.key, required this.simpleOsce});

  @override
  State<_OsceView> createState() => _OsceViewState();
}

class _OsceViewState extends State<_OsceView> {
  void _onStart() {
    context.read<OsceBloc>().add(OsceRequested(simpleOsce: widget.simpleOsce));
  }

  @override
  void initState() {
    super.initState();
    _onStart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.oscePage_title),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: OsceTutorialSeenListener(
          child: BlocListener<OsceBloc, OsceState>(
            listenWhen: (previous, current) =>
                current is OsceLoaded && current.status.isError,
            listener: (context, state) {
              if (state is! OsceLoaded) return;

              switch (state.status) {
                case OsceStatus.error:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(extractErrorMessage(state.error!))),
                  );
                  break;
                default:
                  break;
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: horizontalScreenPadding,
                right: horizontalScreenPadding,
                bottom: 40,
                top: 15,
              ),
              child: BlocBuilder<OsceBloc, OsceState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType,
                builder: (context, state) {
                  switch (state) {
                    case OsceInitial():
                    case OsceLoading():
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.colors.primary,
                        ),
                      );
                    case OsceShowcase(:final osce):
                      return OsceShowcaseWidget(osce: osce);
                    case OsceError(:final error):
                      return ErrorScreen(
                        errorMessage: extractErrorMessage(error),
                        onReload: _onStart,
                      );
                    case OsceLoaded():
                      return _LoadedContent(state: state);
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
  final OsceLoaded state;

  const _LoadedContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final reviewing = context.select<OsceBloc, bool>(
      (bloc) =>
          bloc.state is OsceLoaded &&
          (bloc.state as OsceLoaded).reviewingChecklist,
    );
    if (reviewing) return const OsceChecklistReview();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OsceTimer(),
                SizedBox(height: 20),

                QuestionContext(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(top: 15),
            child: OsceBottomActionButtons(),
          ),
        ),
      ],
    );
  }
}
