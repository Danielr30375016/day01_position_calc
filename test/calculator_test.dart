import 'package:position_calc/src/calculator.dart';
import 'package:test/test.dart';

void main() {
  const calc = PositionCalculator();
  test('1% de 100.000 con stop a 1.000 de distancia → tamaño 1', () {
    final result = calc.calculate(
      balance: 100000,
      riskPct: 1,
      entry: 65000,
      stop: 64000,
      side: Side.buy,
    );
    expect(result, isA<Valid>());
    final valid = result as Valid;
    expect(valid.size, closeTo(1, 1e-9));
    expect(valid.riskAmount, closeTo(1000, 1e-9));
  });
  test('1% de 100.000 con stop a 1.000 de distancia → tamaño 1 pero esta vez va ser invalido por la compra', () {
    final result = calc.calculate(
      balance: 100000,
      riskPct: 1,
      entry: 65000,
      stop: 66000,
      side: Side.buy,
    );
    expect(result, isA<Invalid>());
    final valid = result as Invalid;
    expect(valid.reason, equals(InvalidReason.stopWrongSide));
  });
  test('1% de 100.000 con stop a 1.000 de distancia → tamaño 1 pero esta vez va ser invalido por la venta', () {
    final result = calc.calculate(
      balance: 100000,
      riskPct: 1,
      entry: 65000,
      stop: 64000,
      side: Side.sell,
    );
    expect(result, isA<Invalid>());
    final valid = result as Invalid;
    expect(valid.reason, equals(InvalidReason.stopWrongSide));
  });
  test('1% de 100.000 con stop a 1.000 de distancia → tamaño 1 venta', () {
    final result = calc.calculate(
      balance: 100000,
      riskPct: 1,
      entry: 65000,
      stop: 66000,
      side: Side.sell,
    );
    expect(result, isA<Valid>());
    final valid = result as Valid;
    expect(valid.riskAmount, closeTo(1000, 1e-9));
    expect(valid.size, closeTo(1, 1e-9));
  });
  test('1% de 100.000 con stop a 0 de distancia → tamaño 1 venta', () {
    final result = calc.calculate(
      balance: 100000,
      riskPct: 1,
      entry: 65000,
      stop: 65000,
      side: Side.sell,
    );
    expect(result, isA<Invalid>());
    final valid = result as Invalid;
    expect(valid.reason, equals(InvalidReason.stopEqualsEntry));
  });
  test('riesgo de 2,5% supera el máximo → riskTooHigh', () {
    final result = calc.calculate(
      balance: 100000,
      riskPct: 2.5,
      entry: 65000,
      stop: 64000,
      side: Side.buy,
    );
    expect((result as Invalid).reason, InvalidReason.riskTooHigh);
  });

  test('riesgo exactamente en el límite (2%) es válido', () {
    final result = calc.calculate(
      balance: 100000,
      riskPct: 2,
      entry: 65000,
      stop: 64000,
      side: Side.buy,
    );
    expect(result, isA<Valid>());
  });

  group('take profit', () {
    test('compra con tp a 3.000 y stop a 1.000 → R:R 3', () {
      final result = calc.calculate(
        balance: 50000,
        riskPct: 1,
        entry: 65000,
        stop: 64000,
        tp: 68000,
        side: Side.buy,
      );
      expect(
        result,
        isA<Valid>().having(
          (v) => v.rewardRisk,
          'rewardRisk',
          closeTo(3, 1e-9),
        ),
      );
    });

    test('venta con tp a 3.000 y stop a 1.000 → R:R 3', () {
      final result = calc.calculate(
        balance: 100000,
        riskPct: 1,
        entry: 65000,
        stop: 66000,
        tp: 62000,
        side: Side.sell,
      );
      expect(
        result,
        isA<Valid>().having(
          (v) => v.rewardRisk,
          'rewardRisk',
          closeTo(3, 1e-9),
        ),
      );
    });
  });
}
