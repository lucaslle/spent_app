import '../../../../technical/Charts/area_sparkline.dart';
import '../../domain/account_math.dart';
import '../../domain/entities/account.dart';

int _ms(String d) => DateTime.utc(int.parse(d.substring(0, 4)), int.parse(d.substring(5, 7)), int.parse(d.substring(8))).millisecondsSinceEpoch;

List<SparkPoint> sparkPointsOfSeries(List<SeriesPoint> series) => [for (final p in series) SparkPoint(_ms(p.date), p.value)];

List<SparkPoint> sparkPointsOfHistory(List<BalancePoint> history) => [for (final h in history) SparkPoint(_ms(h.date), h.balance)];
