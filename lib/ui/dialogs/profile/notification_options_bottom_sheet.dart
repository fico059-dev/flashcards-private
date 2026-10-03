import 'package:flashcards/bloc/profile/notification_options/notification_options_cubit.dart';
import 'package:flashcards/bloc/profile/notification_options/notification_options_state.dart';
import 'package:flashcards/data/services/api/notifications/notification_service.dart';
import 'package:flashcards/data/services/local/local_storage_service.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/custom_drag_handle.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showNotificationOptionsBottomSheet({required BuildContext context}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: bottomSheetShape,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return BlocProvider(
            create: (context) => NotificationOptionsCubit(
              notificationService: context.read<NotificationService>(),
              localStorageService: context.read<LocalStorageService>(),
            ),
            child: _Content(),
          );
        },
      );
    },
  );
}

class _Content extends StatefulWidget {
  const _Content({super.key});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  void onLoad() {
    context.read<NotificationOptionsCubit>().loadFrequency();
  }

  @override
  void initState() {
    super.initState();
    onLoad();
  }

  void onSelectionChanged(NotificationFrequency? value) {
    context.read<NotificationOptionsCubit>().onChangeFrequency(
      value ?? NotificationFrequency.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: bottomSheetHorizontalPadding,
      child: Column(
        children: [
          CustomDragHandle(),
          Text(
            "Notification Settings",
            style: TextTheme.of(
              context,
            ).titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          BlocBuilder<NotificationOptionsCubit, NotificationOptionsState>(
            builder: (context, state) {
              final status = state.status;
              switch (status) {
                case OptionsStatus.loading:
                  return Center(child: CircularProgressIndicator());
                case OptionsStatus.error:
                  return ErrorScreen(
                    errorMessage: extractErrorMessage(state.error!),
                    onReload: onLoad,
                  );
                case OptionsStatus.loaded:
                  return Column(
                    children: [
                      Text(
                        "Select frequency that you want us to remind you "
                        "to come and solve flashcards",
                      ),

                      const SizedBox(height: 15),

                      RadioGroup<NotificationFrequency>(
                        groupValue: state.frequency,
                        onChanged: onSelectionChanged,
                        child: Column(
                          children: NotificationFrequency.values.map((freq) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Radio<NotificationFrequency>(
                                value: freq,
                              ),
                              title: Text(freq.displayName),
                              onTap: () => onSelectionChanged(freq),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
