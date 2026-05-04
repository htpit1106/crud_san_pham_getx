import 'package:flutter/material.dart';

class CartButton extends StatelessWidget {
  const CartButton({
    super.key,
    required this.cartKey,
    this.onPressed,
    this.badgeCount = 0,
    this.isActive = false,
  });

  final GlobalKey cartKey;
  final VoidCallback? onPressed;
  final int badgeCount;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.14)
              : Colors.transparent,
          shape: const CircleBorder(),
          child: IconButton(
            key: cartKey,
            onPressed: onPressed,
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: isActive ? colorScheme.primary : null,
            ),
            tooltip: 'Giỏ hàng',
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(999),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
