import 'package:Bloomee/services/db/global_db.dart';
import 'package:isar_community/isar.dart';

/// DAO for search-history CRUD.
///
/// All queries are scoped by [userTag] so each user profile's history
/// is fully isolated. Defaults to `'default'` for single-user installs.
class SearchHistoryDAO {
  final Future<Isar> _db;

  const SearchHistoryDAO(this._db);

  Future<void> putSearchHistory(String searchQuery,
      {String userTag = 'default'}) async {
    Isar isarDB = await _db;
    SearchHistoryDB? existing = isarDB.searchHistoryDBs
        .filter()
        .queryEqualTo(searchQuery)
        .and()
        .userTagEqualTo(userTag)
        .findFirstSync();
    if (existing != null) {
      await isarDB.writeTxn(() =>
          isarDB.searchHistoryDBs.put(existing..lastSearched = DateTime.now()));
    } else {
      await isarDB.writeTxn(() => isarDB.searchHistoryDBs.put(SearchHistoryDB(
            query: searchQuery,
            lastSearched: DateTime.now(),
            userTag: userTag,
          )));
    }
  }

  Future<List<Map<String, String>>> getLastSearches(
      {int limit = 10, String userTag = 'default'}) async {
    Isar isarDB = await _db;
    List<Map<String, String>> searchHistory = [];
    List<SearchHistoryDB> searchHistoryDB = isarDB.searchHistoryDBs
        .filter()
        .userTagEqualTo(userTag)
        .sortByLastSearchedDesc()
        .limit(limit)
        .findAllSync();
    for (var element in searchHistoryDB) {
      searchHistory.add({
        "query": element.query,
        "id": element.id.toString(),
      });
    }
    return searchHistory;
  }

  Future<List<Map<String, String>>> getSimilarSearches(String query,
      {String userTag = 'default'}) async {
    Isar isarDB = await _db;
    List<Map<String, String>> searchHistory = [];
    List<SearchHistoryDB> searchHistoryDB = isarDB.searchHistoryDBs
        .filter()
        .userTagEqualTo(userTag)
        .and()
        .queryContains(query)
        .sortByLastSearchedDesc()
        .limit(3)
        .findAllSync();
    for (var element in searchHistoryDB) {
      searchHistory.add({
        "query": element.query,
        "id": element.id.toString(),
      });
    }
    return searchHistory;
  }

  Future<void> limitSearchHistory({String userTag = 'default'}) async {
    Isar isarDB = await _db;
    List<SearchHistoryDB> searchHistoryDB = isarDB.searchHistoryDBs
        .filter()
        .userTagEqualTo(userTag)
        .sortByLastSearchedDesc()
        .findAllSync();
    if (searchHistoryDB.length > 100) {
      final idsToDelete =
          searchHistoryDB.sublist(100).map((e) => e.id).toList();
      await isarDB
          .writeTxn(() => isarDB.searchHistoryDBs.deleteAll(idsToDelete));
    }
  }

  Future<void> removeSearchHistory(String id) async {
    Isar isarDB = await _db;
    await isarDB.writeTxn(() => isarDB.searchHistoryDBs.delete(int.parse(id)));
  }

  Future<void> clearAllSearchHistory({String userTag = 'default'}) async {
    Isar isarDB = await _db;
    final entries = isarDB.searchHistoryDBs
        .filter()
        .userTagEqualTo(userTag)
        .findAllSync();
    final ids = entries.map((e) => e.id).toList();
    if (ids.isNotEmpty) {
      await isarDB.writeTxn(() => isarDB.searchHistoryDBs.deleteAll(ids));
    }
  }
}
