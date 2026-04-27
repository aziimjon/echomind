import 'package:isar/isar.dart';
import '../../../../core/database/isar_data_source.dart';
import '../../../../core/models/insight.dart';

abstract class InsightRepository {
  Future<List<Insight>> getAllInsights();
  Future<void> saveInsight(Insight insight);
}

class InsightRepositoryImpl implements InsightRepository {
  final IsarDataSource _dataSource;

  InsightRepositoryImpl(this._dataSource);

  @override
  Future<List<Insight>> getAllInsights() async {
    return await _dataSource.db.insights
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<void> saveInsight(Insight insight) async {
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.insights.put(insight);
    });
  }
}
