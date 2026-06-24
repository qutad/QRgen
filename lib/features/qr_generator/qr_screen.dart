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

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 34, 20, 48),
                  children: [
                    SectionCard(
                        child: _Controls(
                            state: qrState, textController: _textController)),
                    const SizedBox(height: 22),
                    SectionCard(child: _Preview(state: qrState)),
                    if (qrState.hasGeneratedQr) ...[
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _isExporting ? null : _exportPng,
                        icon: _isExporting
                            ? const SizedBox.square(
                                dimension: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download_rounded),
                        label:
                            Text(_isExporting ? 'Exporting...' : 'Export PNG'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
  const _Controls({required this.state, required this.textController});

  final QrState state;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(qrControllerProvider.notifier);

    return Column(
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
        const SizedBox(height: 28),
        TextField(
          controller: textController,
          onChanged: controller.setText,
          decoration: const InputDecoration(labelText: 'URL or text'),
          style: Theme.of(context).textTheme.titleMedium,
          textInputAction: TextInputAction.done,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 22, top: 12),
          child: Text('Paste any URL, email, phone, or plain text'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Divider(),
        ),
        const _FieldLabel('Size'),
        const SizedBox(height: 12),
        _SegmentedOptions(
          labels: const ['Small', 'Medium', 'Large'],
          selectedIndex: state.sizeIndex,
          onSelected: controller.setSizeIndex,
        ),
        const SizedBox(height: 28),
        const _FieldLabel('Error correction'),
        const SizedBox(height: 12),
        _SegmentedOptions(
          labels: const ['Low', 'Medium', 'High', 'Max'],
          selectedIndex: state.errorCorrectionIndex,
          onSelected: controller.setErrorCorrectionIndex,
        ),
        const SizedBox(height: 28),
        const _FieldLabel('Color'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: _QrScreenState._colors.map((color) {
            final selected = color.toARGB32() == state.colorValue;
            return InkResponse(
              onTap: () => controller.setColor(color),
              radius: 28,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 48,
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
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: state.canGenerate ? controller.generate : null,
            icon: const Icon(Icons.qr_code_rounded),
            label: const Text('Generate'),
          ),
        ),
      ],
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({required this.state});

  final QrState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.hasGeneratedQr) {
      return const SizedBox(
        height: 210,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_rounded,
                size: 70, color: Color(0xFF706C76)),
            SizedBox(height: 18),
            Text('Your QR code will appear here'),
          ],
        ),
      );
    }

    final service = ref.read(qrServiceProvider);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: QrImageView(
          data: state.generatedText,
          version: QrVersions.auto,
          size: state.previewSize,
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
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
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
