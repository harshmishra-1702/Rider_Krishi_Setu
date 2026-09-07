// lib/features/earnings/presentation/providers/earnings_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/earnings_repository.dart';
import '../../domain/models.dart';

final walletProvider = FutureProvider<EscrowWallet>((ref) async {
  return ref.watch(earningsRepositoryProvider).getWalletBalance();
});

final earningsHistoryProvider =
    FutureProvider<List<TripEarningsRecord>>((ref) async {
  return ref.watch(earningsRepositoryProvider).getEarningsHistory();
});

class PayoutState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const PayoutState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });
}

class PayoutNotifier extends StateNotifier<PayoutState> {
  final EarningsRepository _repo;
  final Ref _ref;

  PayoutNotifier(this._repo, this._ref) : super(const PayoutState());

  Future<bool> withdraw({
    required double amount,
    required String upiId,
  }) async {
    state = const PayoutState(isLoading: true);
    try {
      final success =
          await _repo.requestInstantPayout(amount: amount, upiId: upiId);
      if (success) {
        state = const PayoutState(isLoading: false, isSuccess: true);
        _ref.invalidate(walletProvider);
        return true;
      } else {
        state = const PayoutState(
            isLoading: false, errorMessage: 'Payout request failed');
        return false;
      }
    } catch (e) {
      state = PayoutState(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() => state = const PayoutState();
}

final payoutProvider =
    StateNotifierProvider<PayoutNotifier, PayoutState>((ref) {
  return PayoutNotifier(
    ref.watch(earningsRepositoryProvider),
    ref,
  );
});
