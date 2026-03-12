import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/active_package.dart';
import '../../data/models/package.dart';
import '../../data/services/package_service.dart';

final packageServiceProvider = Provider((ref) => PackageService());

final packagesProvider =
    StateNotifierProvider<PackagesNotifier, PackagesState>((ref) {
  return PackagesNotifier(ref.watch(packageServiceProvider));
});

class PackagesState {
  final List<Package> packages;
  final ActivePackage? activePackage;
  final bool isLoading;
  final bool isPurchasing;
  final String? purchasingStatus;
  final String? error;

  PackagesState({
    this.packages = const [],
    this.activePackage,
    this.isLoading = false,
    this.isPurchasing = false,
    this.purchasingStatus,
    this.error,
  });

  PackagesState copyWith({
    List<Package>? packages,
    ActivePackage? activePackage,
    bool? isLoading,
    bool? isPurchasing,
    String? purchasingStatus,
    String? error,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      activePackage: activePackage ?? this.activePackage,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      purchasingStatus: purchasingStatus ?? this.purchasingStatus,
      error: error ?? this.error,
    );
  }
}

class PackagesNotifier extends StateNotifier<PackagesState> {
  final PackageService _service;
  Timer? _pollingTimer;

  PackagesNotifier(this._service) : super(PackagesState());

  Future<void> fetchPackages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getPackages();
      final activeResp = await _service.getActivePackage();

      state = state.copyWith(
        packages: response.data ?? [],
        activePackage: activeResp.data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> purchasePackage(int packageId, String initialStatus) async {
    if (state.isPurchasing) return;

    state = state.copyWith(
      isPurchasing: true,
      purchasingStatus: initialStatus,
    );

    try {
      final response = await _service.createPayment(packageId);
      if (response.success && response.data != null) {
        final paymentId = response.data!.paymentId;
        await _startPolling(paymentId);
      } else {
        state = state.copyWith(
          isPurchasing: false,
          error: response.message ?? 'Payment failed',
        );
      }
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
    }
  }

  Future<void> _startPolling(String paymentId) async {
    int pollCount = 0;
    const maxPolls = 120; // 2 minutes

    while (state.isPurchasing && pollCount < maxPolls) {
      pollCount++;
      try {
        final statusResp = await _service.getPaymentStatus(paymentId);
        if (statusResp.success && statusResp.data != null) {
          final paymentStatus = statusResp.data!;

          if (paymentStatus.isPaid) {
            state =
                state.copyWith(isPurchasing: false, purchasingStatus: 'PAID');
            await fetchPackages();
            break;
          } else if (paymentStatus.isDeclined) {
            state = state.copyWith(
              isPurchasing: false,
              purchasingStatus: 'DECLINED',
            );
            break;
          } else if (paymentStatus.isError) {
            state = state.copyWith(
              isPurchasing: false,
              purchasingStatus: 'ERROR',
              error: paymentStatus.errorMessage,
            );
            break;
          }
          // If CREATED, continue polling
        }
      } catch (e) {
        // Continue on network errors
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    if (pollCount >= maxPolls && state.isPurchasing) {
      state = state.copyWith(
        isPurchasing: false,
        error: 'Timeout waiting for payment confirmation',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
