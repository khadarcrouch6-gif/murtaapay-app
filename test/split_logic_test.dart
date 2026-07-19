import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Split Bill Logic Tests', () {
    test('Basic even split', () {
      double total = 100.0;
      int count = 4;
      
      int baseAmount = (total / count).floor();
      int remainder = (total - (baseAmount * count)).toInt();

      List<double> shares = List.generate(count, (index) {
        return (index < remainder) ? (baseAmount + 1).toDouble() : baseAmount.toDouble();
      });

      double sum = shares.fold(0, (a, b) => a + b);
      if (sum < total) {
        shares[shares.length - 1] += (total - sum);
      }

      expect(shares, [25.0, 25.0, 25.0, 25.0]);
      expect(shares.fold(0.0, (a, b) => a + b), 100.0);
    });

    test('Uneven split with remainder', () {
      double total = 100.0;
      int count = 3;
      
      int baseAmount = (total / count).floor();
      int remainder = (total - (baseAmount * count)).toInt();

      List<double> shares = List.generate(count, (index) {
        return (index < remainder) ? (baseAmount + 1).toDouble() : baseAmount.toDouble();
      });

      double sum = shares.fold(0, (a, b) => a + b);
      if (sum < total) {
        shares[shares.length - 1] += (total - sum);
      }

      expect(shares, [34.0, 33.0, 33.0]);
      expect(shares.fold(0.0, (a, b) => a + b), 100.0);
    });

    test('Decimal total split', () {
      double total = 100.50;
      int count = 3;
      
      int baseAmount = (total / count).floor();
      int remainder = (total.toInt() - (baseAmount * count));

      List<double> shares = List.generate(count, (index) {
        return (index < remainder) ? (baseAmount + 1).toDouble() : baseAmount.toDouble();
      });

      double sum = shares.fold(0, (a, b) => a + b);
      if (sum < total) {
        shares[shares.length - 1] = double.parse((shares[shares.length - 1] + (total - sum)).toStringAsFixed(2));
      }

      expect(shares, [34.0, 33.0, 33.5]);
      expect(shares.fold(0.0, (a, b) => a + b), 100.50);
    });

    test('Large number of participants with remainder', () {
      double total = 10.0;
      int count = 7;
      
      int baseAmount = (total / count).floor();
      int remainder = (total.toInt() - (baseAmount * count));

      List<double> shares = List.generate(count, (index) {
        return (index < remainder) ? (baseAmount + 1).toDouble() : baseAmount.toDouble();
      });

      double sum = shares.fold(0, (a, b) => a + b);
      if (sum < total) {
        shares[shares.length - 1] = double.parse((shares[shares.length - 1] + (total - sum)).toStringAsFixed(2));
      }

      expect(shares.length, 7);
      expect(shares.fold(0.0, (a, b) => a + b), 10.0);
      expect(shares.every((s) => s >= 1.0), true);
    });
  });
}
