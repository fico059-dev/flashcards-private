import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/fc_review_getter/fc_review_getter_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/flashcard_builder/manage_flashcards/update_flashcard_bottom_sheet.dart';
import 'package:flashcards/ui/dialogs/profile/admin_dashboard/reports/user_reports_bottom_sheet.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/delete_flashcard_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class FcReviewSheetAdminFloatingButton extends StatefulWidget {
  final FcReviewGetterLoaded state;

  const FcReviewSheetAdminFloatingButton({super.key, required this.state});

  @override
  State<FcReviewSheetAdminFloatingButton> createState() =>
      _FcReviewSheetAdminFloatingButtonState();
}

class _FcReviewSheetAdminFloatingButtonState
    extends State<FcReviewSheetAdminFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );

    _colorAnimation = ColorTween(
      begin: context.colors.primary,
      end: context.colors.primary.withValues(alpha: 0.7),
    ).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPreview() {
    context.router.push(
      FlashcardPreviewRoute(flashcard: widget.state.fcReview.record.flashcard!),
    );
  }

  void _onDelete() async {
    final result = await showDeleteFlashcardDialog(
      context,
      widget.state.fcReview.record.flashcard!,
    );
    if (result == null) return;

    if (!mounted) return;
    context.router.pop(result);
  }

  void _onUpdate() async {
    final result = await showUpdateFlashcardBottomSheet(
      context,
      widget.state.fcReview.record.flashcard!,
    );
    if (result == null) return;

    if (!mounted) return;
    context.router.pop(result);
  }

  void _onViewReports() {
    showUserReportsBottomSheet(
      context: context,
      flashcard: widget.state.fcReview.record.flashcard!,
      simpleFloatingButton: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color surfaceColor = context.colors.primaryContainer;
    final Color onSurfaceColor = context.colors.onPrimaryContainer;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SpeedDial(
          tooltip: "المزيد من الخيارات",
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: _colorAnimation.value ?? context.colors.primary,
          renderOverlay: false,
          useRotationAnimation: true,
          animationDuration: const Duration(milliseconds: 150),
          spacing: 8,
          spaceBetweenChildren: 4,
          children: [
            SpeedDialChild(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: surfaceColor,
              child: Icon(Icons.edit, color: onSurfaceColor),
              label: "تعديل",
              labelBackgroundColor: surfaceColor,
              labelStyle: TextStyle(color: onSurfaceColor),
              onTap: _onUpdate,
            ),
            SpeedDialChild(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: surfaceColor,
              child: Icon(Icons.bar_chart, color: onSurfaceColor),
              label: "عرض البلاغات",
              labelBackgroundColor: surfaceColor,
              labelStyle: TextStyle(color: onSurfaceColor),
              onTap: _onViewReports,
            ),
            SpeedDialChild(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: surfaceColor,
              child: Icon(Icons.remove_red_eye, color: onSurfaceColor),
              label: "معاينة",
              labelBackgroundColor: surfaceColor,
              labelStyle: TextStyle(color: onSurfaceColor),
              onTap: _onPreview,
            ),
            SpeedDialChild(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: context.colors.errorContainer,
              child: Icon(Icons.delete, color: context.colors.onErrorContainer),
              label: "حذف",
              labelBackgroundColor: context.colors.errorContainer,
              labelStyle: TextStyle(color: context.colors.onErrorContainer),
              onTap: _onDelete,
            ),
          ],
          onOpen: () => _controller.forward(),
          onClose: () => _controller.reverse(),
          icon: Icons.add,
          iconTheme: IconThemeData(color: context.colors.onPrimary),
          activeIcon: Icons.close,
        );
      },
    );
  }
}
