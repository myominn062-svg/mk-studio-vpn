import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/theme/mk_studio_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScannerDialog extends ConsumerStatefulWidget {
  const QrCodeScannerDialog({super.key});

  @override
  ConsumerState<QrCodeScannerDialog> createState() => _QrCodeScannerDialogState();
}

class _QrCodeScannerDialogState extends ConsumerState<QrCodeScannerDialog> {
  final MobileScannerController _controller = MobileScannerController();
  bool _pickingImage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    if (_pickingImage) return;

    setState(() => _pickingImage = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final path = result.files.single.path;
      if (path == null) return;

      final capture = await _controller.analyzeImage(path);
      if (!mounted) return;

      final rawData = capture?.barcodes.firstOrNull?.rawValue;
      if (rawData != null) {
        context.pop(rawData);
        return;
      }

      final t = ref.read(translationsProvider).requireValue;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.common.qrNotFoundInImage),
          backgroundColor: MkStudioColors.tealDeep,
        ),
      );
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Widget _galleryButton(String label, {bool compact = false}) {
    return FilledButton.icon(
      onPressed: _pickingImage ? null : _pickFromGallery,
      style: FilledButton.styleFrom(
        backgroundColor: MkStudioColors.teal,
        foregroundColor: Colors.white,
        disabledBackgroundColor: MkStudioColors.teal.withValues(alpha: 0.6),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 20,
          vertical: compact ? 10 : 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(compact ? 12 : 16)),
        elevation: 4,
        shadowColor: MkStudioColors.tealDeep.withValues(alpha: 0.45),
      ),
      icon: _pickingImage
          ? SizedBox(
              width: compact ? 18 : 22,
              height: compact ? 18 : 22,
              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(compact ? Icons.photo_library : Icons.photo_library_outlined, size: compact ? 20 : 24),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: compact ? 13 : 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.read(translationsProvider).requireValue;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: MkStudioColors.teal,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      splashRadius: 24,
                      tooltip: t.common.close,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      t.common.scanQr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: MkStudioColors.teal,
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: IconButton(
                      onPressed: _pickingImage ? null : _pickFromGallery,
                      icon: _pickingImage
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.photo_library, color: Colors.white),
                      splashRadius: 24,
                      tooltip: t.common.pickFromGallery,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MkStudioColors.tealDeep.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MkStudioColors.teal.withValues(alpha: 0.55)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.common.qrScanHint,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: _controller,
                    placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
                    overlayBuilder: (context, constraints) => Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MkStudioColors.teal, width: 4),
                      ),
                    ),
                    errorBuilder: (context, error) => Center(child: Text(t.common.msg.permission.denied)),
                    onDetect: (barcodes) {
                      final rawData = barcodes.barcodes.firstOrNull?.rawValue;
                      if (rawData != null) context.pop(rawData);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomInset),
              child: Center(child: _galleryButton(t.common.pickFromGallery)),
            ),
          ],
        ),
      ),
    );
  }
}
