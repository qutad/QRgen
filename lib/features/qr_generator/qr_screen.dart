import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/section_card.dart';
import 'qr_controller.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  late final TextEditingController _textController;
  var _isExporting = false;

  static const _colors = <Color>[
    Colors.black,
    Color(0xFF6E56B7),
    Color(0xFF2D68A5),
    Color(0xFF2F7D2F),
    Color(0xFFC93D32),
    Color(0xFF8A6C21),
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(qrControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2_rounded),
            SizedBox(width: 14),
            Text('QR Generator'),
          ],
        ),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (qrState) {
          if (_textController.text != qrState.text) {
            _textController.value = TextEditingValue(
              text: qrState.text,
              selection: TextSelection.collapsed(offset: qrState.text.length),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final layoutWidth =
                  constraints.maxWidth.clamp(500.0, double.infinity).toDouble();
              final layoutHeight = constraints.maxHeight;
              final compact = layoutWidth < 900 || layoutHeight < 900;
              final twoColumn = layoutWidth >= 760;
              final pagePadding = compact ? 12.0 : 24.0;
              final gap = compact ? 12.0 : 24.0;
              final cardPadding = compact ? 16.0 : 32.0;
              final contentWidth = layoutWidth - pagePadding * 2;
              final contentHeight = layoutHeight - pagePadding * 2;
              final appWidth = contentWidth
                  .clamp(500.0 - pagePadding * 2, twoColumn ? 1180.0 : 820.0)
                  .toDouble();
              final preferredHeight = twoColumn ? 700.0 : 750.0;
              final appHeight =
                  contentHeight.clamp(0.0, preferredHeight).toDouble();
              final previewWidth =
                  twoColumn ? (contentWidth - gap) * 0.42 : contentWidth;
              final previewHeight = twoColumn
                  ? appHeight - (qrState.hasGeneratedQr ? 54 : 0)
                  : appHeight * (qrState.hasGeneratedQr ? 0.32 : 0.24);
              final maxQrSize = [
                previewWidth - cardPadding * 2 - 32,
                previewHeight - cardPadding * 2 - 32,
                qrState.previewSize,
              ]
                  .reduce((value, element) => value < element ? value : element)
                  .clamp(88.0, qrState.previewSize)
                  .toDouble();

              final controls = SectionCard(
                padding: EdgeInsets.all(cardPadding),
                child: _Controls(
                  state: qrState,
                  textController: _textController,
                  compact: compact,
                ),
              );
              final preview = SectionCard(
                padding: EdgeInsets.all(cardPadding),
                child: _Preview(
                  state: qrState,
                  maxQrSize: maxQrSize,
                  compact: compact,
                ),
              );
              final exportButton = qrState.hasGeneratedQr
                  ? FilledButton.icon(
                      onPressed: _isExporting ? null : _exportPng,
                      icon: _isExporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded),
                      label: Text(_isExporting ? 'Exporting...' : 'Export PNG'),
                    )
                  : null;

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(pagePadding),
                  child: Center(
                    child: SizedBox(
                      width: appWidth,
                      height: appHeight,
                      child: twoColumn
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 6, child: controls),
                                SizedBox(width: gap),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(child: preview),
                                      if (exportButton != null) ...[
                                        SizedBox(height: gap),
                                        SizedBox(
                                            height: 44, child: exportButton),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(flex: 8, child: controls),
                                SizedBox(height: gap),
                                Expanded(
                                    flex: qrState.hasGeneratedQr ? 3 : 2,
                                    child: preview),
                                if (exportButton != null) ...[
                                  SizedBox(height: gap),
                                  SizedBox(height: 44, child: exportButton),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _exportPng() async {
    setState(() => _isExporting = true);
    try {
      final path = await ref.read(qrControllerProvider.notifier).exportPng();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved QR code to $path')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({
    required this.state,
    required this.textController,
    required this.compact,
  });

  final QrState state;
  final TextEditingController textController;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(qrControllerProvider.notifier);

    final titleSpacing = compact ? 12.0 : 28.0;
    final fieldSpacing = compact ? 8.0 : 12.0;
    final sectionSpacing = compact ? 14.0 : 28.0;
    final colorSize = compact ? 38.0 : 50.0;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CREATE QR CODE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.8,
                      ),
                ),
                SizedBox(height: titleSpacing),
                TextField(
                  controller: textController,
                  onChanged: controller.setText,
                  decoration: InputDecoration(
                    labelText: 'URL or text',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: compact ? 14 : 22,
                    ),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                  textInputAction: TextInputAction.done,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 22, top: fieldSpacing),
                  child:
                      const Text('Paste any URL, email, phone, or plain text'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: compact ? 10 : 28),
                  child: const Divider(),
                ),
                const _FieldLabel('Size'),
                SizedBox(height: fieldSpacing),
                _SegmentedOptions(
                  labels: const ['Small', 'Medium', 'Large'],
                  selectedIndex: state.sizeIndex,
                  onSelected: controller.setSizeIndex,
                  compact: compact,
                ),
                SizedBox(height: sectionSpacing),
                const _FieldLabel('Error correction'),
                SizedBox(height: fieldSpacing),
                _SegmentedOptions(
                  labels: const ['Low', 'Medium', 'High', 'Max'],
                  selectedIndex: state.errorCorrectionIndex,
                  onSelected: controller.setErrorCorrectionIndex,
                  compact: compact,
                ),
                SizedBox(height: sectionSpacing),
                const _FieldLabel('Color'),
                SizedBox(height: fieldSpacing),
                Wrap(
                  spacing: compact ? 10 : 16,
                  runSpacing: compact ? 10 : 16,
                  children: _QrScreenState._colors.map((color) {
                    final selected = color.toARGB32() == state.colorValue;
                    return InkResponse(
                      onTap: () => controller.setColor(color),
                      radius: 28,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: colorSize,
                        height: colorSize,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                SizedBox(height: compact ? 12 : 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: state.canGenerate ? controller.generate : null,
                    icon: const Icon(Icons.qr_code_rounded),
                    label: const Text('Generate'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({
    required this.state,
    required this.maxQrSize,
    required this.compact,
  });

  final QrState state;
  final double maxQrSize;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.hasGeneratedQr) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final showCaption = constraints.maxHeight >= 112;
          final iconSize = constraints.maxHeight
              .clamp(42.0, compact ? 58.0 : 76.0)
              .toDouble();

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  size: iconSize,
                  color: const Color(0xFF706C76),
                ),
                if (showCaption) ...[
                  SizedBox(height: compact ? 14 : 20),
                  const Text('Your QR code will appear here'),
                ],
              ],
            ),
          );
        },
      );
    }

    final service = ref.read(qrServiceProvider);
    final framePadding = compact ? 12.0 : 18.0;
    return Center(
      child: Container(
        padding: EdgeInsets.all(framePadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 16 : 22),
        ),
        child: QrImageView(
          data: state.generatedText,
          version: QrVersions.auto,
          size: maxQrSize,
          gapless: true,
          eyeStyle: QrEyeStyle(color: state.color, eyeShape: QrEyeShape.square),
          dataModuleStyle: QrDataModuleStyle(
            color: state.color,
            dataModuleShape: QrDataModuleShape.square,
          ),
          errorCorrectionLevel:
              service.errorCorrectionFromIndex(state.errorCorrectionIndex),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}

class _SegmentedOptions extends StatelessWidget {
  const _SegmentedOptions({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    required this.compact,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 12 : 10,
      runSpacing: compact ? 10 : 10,
      children: [
        for (final entry in labels.indexed)
          ChoiceChip(
            label: Text(entry.$2),
            selected: selectedIndex == entry.$1,
            showCheckmark: true,
            onSelected: (_) => onSelected(entry.$1),
          ),
      ],
    );
  }
}
