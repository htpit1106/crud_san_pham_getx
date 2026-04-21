import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNotifier {
  static void showSuccess(String message) {
    _show(message, type: _Type.success);
  }

  static void showError(String message) {
    _show(message, type: _Type.error);
  }

  static void _show(String message, {required _Type type}) {
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(message: message, type: type),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final _Type type;

  const _ToastWidget({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: 16 + safeBottom + bottomInset,
      left: 16,
      right: 16,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 30, end: 0),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: Opacity(opacity: 1 - (value / 30), child: child),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDC2626), width: 1.2),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.12),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(_getIcon(), color: const Color(0xFFDC2626), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case _Type.success:
        return Icons.check_circle_outline_rounded;
      case _Type.error:
        return Icons.error_outline_rounded;
    }
  }
}

enum _Type { success, error }
