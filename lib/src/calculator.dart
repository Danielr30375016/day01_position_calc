
enum Side { buy, sell }

enum InvalidReason {
  riskTooHigh,
  stopEqualsEntry,
  stopWrongSide,
  invalidInput,
  tpWrongSide,
}

sealed class CalcResult {
  const CalcResult();
}

final class Valid extends CalcResult {
  const Valid({required this.size, required this.riskAmount, this.rewardRisk});
  final double size;
  final double riskAmount;
  final double? rewardRisk;
}

final class Invalid extends CalcResult {
  const Invalid(this.reason);
  final InvalidReason reason;
}

class PositionCalculator {
  final double maxRiskPct;
  const PositionCalculator({this.maxRiskPct = 2});

  CalcResult calculate({
    required double balance,
    required double riskPct,
    required double entry,
    required double stop,
    required Side side,
    double? tp,
  }) {
    if (balance <= 0 ||
        riskPct <= 0 ||
        entry <= 0 ||
        stop <= 0 ||
        (tp != null && tp <= 0)) {
      return const Invalid(InvalidReason.invalidInput);
    }
    if (riskPct > maxRiskPct) return  const Invalid(InvalidReason.riskTooHigh);
    if (stop == entry) return const Invalid(InvalidReason.stopEqualsEntry);
    switch (side) {
      case Side.buy:
        if (entry < stop) return const Invalid(InvalidReason.stopWrongSide);
        if (tp != null && tp <= entry) {
          return const Invalid(InvalidReason.tpWrongSide);
        }
      case Side.sell:
        if (entry > stop) return const Invalid(InvalidReason.stopWrongSide);
        if (tp != null && tp >= entry) {
          return const Invalid(InvalidReason.tpWrongSide);
        }
    }
    final riskAmount = balance * riskPct / 100;
    final stopDistance = (entry - stop).abs();
    final size = riskAmount / stopDistance;
    double? rewardRisk;
    if (tp != null) rewardRisk = (tp - entry).abs() / stopDistance;
    return Valid(size: size, riskAmount: riskAmount, rewardRisk: rewardRisk);
  }
}
