import 'package:auto_route/annotations.dart';
import 'package:flashcards/bloc/profile/admin_list/admin_list_cubit.dart';
import 'package:flashcards/bloc/profile/admin_list/admin_list_state.dart';
import 'package:flashcards/bloc/profile/manage_user_roles/manage_user_roles_cubit.dart';
import 'package:flashcards/bloc/profile/manage_user_roles/manage_user_roles_state.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
import 'package:flashcards/data/repositories/users/user_roles_repository.dart';
import 'package:flashcards/domain/models/profile/admin_user/admin_user.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/bloc_buttons/bloc_button.dart';
import 'package:flashcards/ui/widgets/core/bloc_text_field.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcards/l10n/app_localizations.dart';

@RoutePage()
class AssignAdminPage extends StatelessWidget {
  const AssignAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ManageUserRolesCubit(
                userRolesRepo: context.read<UserRolesRepository>(),
              ),
        ),
        BlocProvider(
          create:
              (context) => AdminListCubit(
                userRolesRepo: context.read<UserRolesRepository>(),
              )..loadAdmins(),
        ),
      ],
      child: _PageView(),
    );
  }
}

class _PageView extends StatefulWidget {
  const _PageView({super.key});

  @override
  State<_PageView> createState() => _PageViewState();
}

class _PageViewState extends State<_PageView> {
  late final TextEditingController _emailCont;

  @override
  void initState() {
    super.initState();
    _emailCont = TextEditingController();
  }

  @override
  void dispose() {
    _emailCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    void onAssignAdmin() {
      context.read<ManageUserRolesCubit>().setAdminRole(_emailCont.text);
    }

    return BlocListener<ManageUserRolesCubit, ManageUserRolesState>(
      listenWhen:
          (previous, current) =>
              current is ManageUserRolesSuccess ||
              current is ManageUserRolesError,
      listener: (context, state) {
        switch (state) {
          case ManageUserRolesSuccess():
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Successfully assigned admin role")),
            );
            _emailCont.clear();
            context.read<AdminListCubit>().loadAdmins();
            return;
          case ManageUserRolesError(:final error):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
            return;
          default:
        }
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () => context.read<AdminListCubit>().loadAdmins(),
          child: ListView(
            padding: EdgeInsets.only(
              top: 20,
              bottom: 40,
              left: horizontalScreenPadding,
              right: horizontalScreenPadding,
            ),
            children: [
              BlocTextField<ManageUserRolesCubit, ManageUserRolesState>(
                errorSelector:
                    (state) =>
                        state is ManageUserRolesFormInvalid
                            ? state.errors['email']
                            : null,
                textEditingController: _emailCont,
                labelText: l10n.basicText_email,
              ),
              const SizedBox(height: 25),
              Center(
                child: BlocButton<ManageUserRolesCubit, ManageUserRolesState>.small(
                textString: "Assign Admin",
                onPressed: (context) => onAssignAdmin(),
                  isLoadingState: (state) => state is ManageUserRolesLoading,
                  width: 150,
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              const _AdminList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminList extends StatelessWidget {
  const _AdminList();

  @override
  Widget build(BuildContext context) {
    final profileState = context.read<ProfileReaderCubit>().state;
    final myEmail =
        profileState is ProfileReaderIsLoaded
            ? profileState.profile.email.toLowerCase()
            : null;

    return BlocBuilder<AdminListCubit, AdminListState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    state is AdminListLoaded
                        ? "Current admins (${state.admins.length})"
                        : "Current admins",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: "Refresh",
                  icon: const Icon(Icons.refresh),
                  onPressed:
                      state is AdminListLoading
                          ? null
                          : () => context.read<AdminListCubit>().loadAdmins(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            switch (state) {
              AdminListLoading() => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              AdminListError(:final error) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Couldn't load admins: ${extractErrorMessage(error)}",
                  style: TextStyle(color: context.colors.error),
                ),
              ),
              AdminListLoaded(:final admins, :final removingUid) => Column(
                children: [
                  for (final admin in admins)
                    _AdminTile(
                      admin: admin,
                      isMe: admin.email?.toLowerCase() == myEmail,
                      isRemoving: admin.uid == removingUid,
                      removeEnabled: removingUid == null,
                    ),
                ],
              ),
            },
          ],
        );
      },
    );
  }
}

class _AdminTile extends StatelessWidget {
  final AdminUser admin;
  final bool isMe;
  final bool isRemoving;
  final bool removeEnabled;

  const _AdminTile({
    required this.admin,
    required this.isMe,
    required this.isRemoving,
    required this.removeEnabled,
  });

  Future<void> _confirmAndRemove(BuildContext context) async {
    final name = admin.email ?? admin.displayName ?? admin.uid;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Remove admin?"),
            content: Text(
              "$name will lose access to the admin dashboard. "
              "You can add them again at any time.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: dialogContext.colors.error,
                ),
                child: const Text("Remove"),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;

    final error = await context.read<AdminListCubit>().removeAdmin(admin);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null
              ? "$name is no longer an admin"
              : extractErrorMessage(error),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = admin.email ?? admin.displayName ?? admin.uid;
    final subtitle =
        admin.email != null && admin.displayName?.isNotEmpty == true
            ? admin.displayName
            : null;

    Widget? trailing;
    if (isMe) {
      trailing = const Chip(label: Text("You"));
    } else if (isRemoving) {
      trailing = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      trailing = IconButton(
        tooltip: "Remove admin",
        icon: Icon(Icons.person_remove, color: context.colors.error),
        onPressed: removeEnabled ? () => _confirmAndRemove(context) : null,
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: context.colors.primaryContainer,
        child: Icon(
          Icons.admin_panel_settings,
          color: context.colors.onPrimaryContainer,
        ),
      ),
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: trailing,
    );
  }
}
