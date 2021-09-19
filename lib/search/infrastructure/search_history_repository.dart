import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:sembast/sembast.dart';

class SearchHistoryRepository {
  final SembastDatabase sembastDatabase;
  final _store = StoreRef<int, String>('searchHistory');

  SearchHistoryRepository(this.sembastDatabase);

  static const historyLength = 10;

  Stream<List<String>> watchSearchTerms({String? filter}) {
    return _store
        .query(
          finder: filter != null && filter.isNotEmpty
              ? Finder(
                  filter: Filter.custom(
                    (record) => (record.value as String).startsWith(filter),
                  ),
                )
              : null,
        )
        .onSnapshots(sembastDatabase.instance)
        .map((records) => records.map((e) => e.value).toList());
  }
}
