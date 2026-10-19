import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashcards/bloc/flashcards/anki_import/anki_import_cubit.dart';
import 'package:flashcards/bloc/flashcards/anki_import/anki_import_state.dart';
import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/data/services/anki/anki_import_models.dart';
import 'package:flashcards/data/services/anki/anki_import_service.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lets an admin import a whole Anki deck into a pack at once.
@RoutePage()
class AnkiImportPage extends StatelessWidget {
  final AdminPack pack;

  const AnkiImportPage({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnkiImportCubit(
        flashcardRepo: context.read<FlashcardRepository>(),
        ankiImportService: AnkiImportService(),
      ),
      child: _View(pack: pack),
    );
  }
}

class _View extends StatefulWidget {
  final AdminPack pack;

  const _View({required this.pack});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  bool _importTags = false;

  Future<void> _pickFile() async {
    // FileType.any: iOS doesn't know the .apkg type, so the extension is
    // checked after picking.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    final file = result?.files.singleOrNull;
    if (file == null || !mounted) return;

    final extension = file.name.split('.').last.toLowerCase();
    if (!ankiImportExtensions.contains(extension) || file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("اختر ملف Anki بصيغة .apkg أو .txt."),
        ),
      );
      return;
    }

    context.read<AnkiImportCubit>().readFile(
      fileName: file.name,
      bytes: file.bytes!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnkiImportCubit, AnkiImportState>(
      builder: (context, state) {
        final isImporting = state is AnkiImportImporting;
        return PopScope(
          // Leaving mid-import would stop it half way.
          canPop: !isImporting,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("استيراد من Anki"),
              automaticallyImplyLeading: !isImporting,
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalScreenPadding,
                ),
                child: switch (state) {
                  AnkiImportInitial() => _Instructions(
                    packName: widget.pack.packName,
                    onPickFile: _pickFile,
                  ),
                  AnkiImportReading(:final fileName) => _Loading(
                    message: "جارٍ قراءة $fileName…",
                  ),
                  AnkiImportPreview(:final fileName, :final result) => _Preview(
                    fileName: fileName,
                    result: result,
                    packName: widget.pack.packName,
                    importTags: _importTags,
                    onImportTagsChanged: (value) =>
                        setState(() => _importTags = value),
                    onImport: () => context.read<AnkiImportCubit>().importCards(
                      packId: widget.pack.packId,
                      importTags: _importTags,
                    ),
                    onPickAnother: _pickFile,
                  ),
                  AnkiImportImporting(:final processed, :final total) =>
                    _Progress(processed: processed, total: total),
                  AnkiImportDone(:final summary) => _Done(
                    summary: summary,
                    packName: widget.pack.packName,
                  ),
                  AnkiImportError(:final error) => _ReadError(
                    error: error,
                    onPickAnother: _pickFile,
                  ),
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Instructions extends StatelessWidget {
  final String packName;
  final VoidCallback onPickFile;

  const _Instructions({required this.packName, required this.onPickFile});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              Text("إضافة بطاقات إلى \"$packName\"", style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                "استورد حزمة Anki كاملة بدل إضافة البطاقات واحدة واحدة.",
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text("التصدير من Anki", style: textTheme.titleMedium),
                      const _Step(
                        number: 1,
                        text: "في Anki على جهازك: File ← Export.",
                      ),
                      const _Step(
                        number: 2,
                        text:
                            "اختر \"Anki Deck Package (.apkg)\" وفعّل "
                            "\"Include media\" و\"Support older Anki versions\".",
                      ),
                      const _Step(
                        number: 3,
                        text:
                            "أرسل الملف لهذا الجهاز (AirDrop أو الملفات أو البريد…) "
                            "واخترْه بالأسفل.",
                      ),
                      Text(
                        "تقدر أيضاً تصدّر \"Notes in Plain Text (.txt)\"، "
                        "لكن الصور ما راح تُضمَّن.",
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Text(
                        "كيف تُحوَّل البطاقات",
                        style: textTheme.titleMedium,
                      ),
                      const Text("• الوجه الأمامي ← السؤال، الخلفي ← الإجابة."),
                      const Text(
                        "• ملاحظات Cloze تصبح بطاقة لكل فراغ (c1, c2…)، "
                        "مثل Anki تماماً.",
                      ),
                      const Text(
                        "• تُحفظ صورة واحدة لكل وجه، والتنسيق يتحول لنص عادي "
                        "text.",
                      ),
                      const Text(
                        "• البطاقات الموجودة مسبقاً في الحزمة (نفس السؤال) تُتخطّى.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: FilledButton.icon(
            onPressed: onPickFile,
            icon: const Icon(Icons.upload_file),
            label: const Text("اختر ملف Anki"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: context.colors.primaryContainer,
          child: Text(
            "$number",
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onPrimaryContainer,
            ),
          ),
        ),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  final String message;

  const _Loading({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          const CircularProgressIndicator(),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  static const _sampleSize = 30;

  final String fileName;
  final AnkiParseResult result;
  final String packName;
  final bool importTags;
  final ValueChanged<bool> onImportTagsChanged;
  final VoidCallback onImport;
  final VoidCallback onPickAnother;

  const _Preview({
    required this.fileName,
    required this.result,
    required this.packName,
    required this.importTags,
    required this.onImportTagsChanged,
    required this.onImport,
    required this.onPickAnother,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cards = result.cards;
    final clozeCount = cards.where((c) => c.isCloze).length;
    final imageCount = cards
        .where((c) => c.questionImage != null || c.answerImage != null)
        .length;
    final hasTags = cards.any((c) => c.tags.isNotEmpty);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              Text(fileName, style: textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _StatTile(
                      icon: Icons.style,
                      label: "البطاقات للاستيراد",
                      value: cards.length,
                    ),
                    if (clozeCount > 0)
                      _StatTile(
                        icon: Icons.text_fields,
                        label: "بطاقات الفراغ (Cloze)",
                        value: clozeCount,
                      ),
                    if (imageCount > 0)
                      _StatTile(
                        icon: Icons.image,
                        label: "بطاقات فيها صور",
                        value: imageCount,
                      ),
                    if (result.skippedNotes > 0)
                      _StatTile(
                        icon: Icons.block,
                        label: "ملاحظات فارغة تم تخطيها",
                        value: result.skippedNotes,
                      ),
                    if (result.missingImages > 0)
                      _StatTile(
                        icon: Icons.broken_image,
                        label: "صور ناقصة من الملف",
                        value: result.missingImages,
                        isWarning: true,
                      ),
                    if (result.extraImagesDropped > 0)
                      _StatTile(
                        icon: Icons.photo_library,
                        label: "أوجه فيها صور زائدة (تم الاحتفاظ بالأولى)",
                        value: result.extraImagesDropped,
                        isWarning: true,
                      ),
                  ],
                ),
              ),
              if (hasTags)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("استيراد وسوم Anki"),
                  subtitle: const Text(
                    "يضيف وسوم الحزمة للبطاقات (آخر مستوى فقط، "
                    "مثال: Verbal::Analogy ← Analogy).",
                  ),
                  value: importTags,
                  onChanged: onImportTagsChanged,
                ),
              const SizedBox(height: 12),
              Text(
                cards.length > _sampleSize
                    ? "أول $_sampleSize بطاقات"
                    : "البطاقات",
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final card in cards.take(_sampleSize))
                _CardPreview(card: card),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 8),
          child: Column(
            spacing: 8,
            children: [
              FilledButton(
                onPressed: cards.isEmpty ? null : onImport,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text("استيراد ${cards.length} بطاقة إلى \"$packName\""),
              ),
              TextButton(
                onPressed: onPickAnother,
                child: const Text("اختر ملفاً آخر"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final bool isWarning;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? context.colors.error : context.colors.primary;
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(
        "$value",
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _CardPreview extends StatelessWidget {
  final AnkiCard card;

  const _CardPreview({required this.card});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    card.question,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (card.questionImage != null)
                  _ImageThumbnail(image: card.questionImage!),
              ],
            ),
            const Divider(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(
                  child: Text(
                    card.answer,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (card.answerImage != null)
                  _ImageThumbnail(image: card.answerImage!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final AnkiImage image;

  const _ImageThumbnail({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.memory(
        image.bytes,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        cacheWidth: 96,
        errorBuilder: (context, error, stackTrace) =>
            const SizedBox(width: 48, height: 48, child: Icon(Icons.image)),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final int processed;
  final int total;

  const _Progress({required this.processed, required this.total});

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? null : processed / total;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Text(
            "جارٍ استيراد البطاقات…",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          LinearProgressIndicator(value: value, minHeight: 8),
          Text("$processed من $total"),
          const Text(
            "اترك التطبيق مفتوحاً حتى ينتهي الاستيراد.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Done extends StatelessWidget {
  final FlashcardImportSummary summary;
  final String packName;

  const _Done({required this.summary, required this.packName});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final error = summary.error;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(
              error == null ? Icons.check_circle : Icons.error,
              size: 72,
              color: error == null ? Colors.green : context.colors.error,
            ),
            Text(
              error == null ? "اكتمل الاستيراد" : "توقّف الاستيراد",
              style: textTheme.headlineSmall,
            ),
            Text(
              "تمت إضافة ${summary.imported} بطاقة إلى \"$packName\".",
              textAlign: TextAlign.center,
            ),
            if (summary.skippedDuplicates > 0)
              Text(
                "${summary.skippedDuplicates} بطاقة كانت موجودة في الحزمة "
                "وتم تخطيها.",
                textAlign: TextAlign.center,
              ),
            if (summary.failedImages > 0)
              Text(
                "تعذّر رفع ${summary.failedImages} صورة، وتمت إضافة "
                "تلك البطاقات بدونها.",
                textAlign: TextAlign.center,
              ),
            if (error != null) ...[
              Text(
                extractErrorMessage(error),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.error),
              ),
              const Text(
                "استورد نفس الملف مرة ثانية لإضافة بقية البطاقات. "
                "البطاقات الموجودة بالحزمة ستُتخطّى.",
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.router.pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text("تم"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadError extends StatelessWidget {
  final Object error;
  final VoidCallback onPickAnother;

  const _ReadError({required this.error, required this.onPickAnother});

  @override
  Widget build(BuildContext context) {
    final message = error is AnkiImportException
        ? (error as AnkiImportException).message
        : extractErrorMessage(error);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          Icon(Icons.error_outline, size: 64, color: context.colors.error),
          Text(
            "تعذّر استيراد هذا الملف",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(message, textAlign: TextAlign.center),
          FilledButton(
            onPressed: onPickAnother,
            child: const Text("اختر ملفاً آخر"),
          ),
        ],
      ),
    );
  }
}
