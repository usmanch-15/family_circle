import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isNetwork;

  const CustomErrorWidget({
    super.key,
    this.message,
    this.onRetry,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetwork ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 40, color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isNetwork ? 'Internet nahi hai' : 'Kuch galat ho gaya',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? (isNetwork
                  ? 'Internet connection check karein aur dobara koshish karein'
                  : 'Ek masla aa gaya. Dobara koshish karein.'),
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Dobara Koshish Karein'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(180, 46),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) =>
      CustomErrorWidget(isNetwork: true, onRetry: onRetry);
}