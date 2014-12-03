library locale_sore;

import "package:flux/store.dart";
import "package:vacuum_persistent/persistent.dart";
import 'loader.dart';
import 'common.dart';

class LocaleStore extends Store<PersistentMap> {

  final Loader loader;
  final List<String> paths;
  final String root;
  String get locale => data.get("locale", null);
  set locale(loc) {
    loadLocale(loc);
    insert(["locale"], loc);
  }

  LocaleStore(dispatcher, cursor, {this.root, String defaultLocale: "en", List<String> paths, this.loader})
      : super(dispatcher, cursor),
        this.paths = paths != null ? paths : [] {
    insert(["locale"], defaultLocale);
    listen({
      LOCALELOADED: localeLoaded
    });
    loadLocale(defaultLocale);
  }

  PersistentMap parseLocaleMap(PersistentMap localeMap) {
    PersistentMap result = persist({});

    localeMap.asTransient().forEach((Pair pair) {
      String key = pair.first;
      List path = key.split(".");
      for (num i = 0; i < path.length; ++i) {
        if (lookupIn(result, path.sublist(0, i), notFound: null) == null) {
          result = insertIn(result, path.sublist(0, i), persist({}));
        }
      }
      result = insertIn(result, path, pair.second);
    });

    return result;
  }

  loadLocale(String locale) {
    paths.forEach((String path) {
      dispatcher.dispatchAsync(loader.getJson("$root/$path/$locale.json"), LOCALELOADED, DATA);
    });
  }

  localeLoaded(PersistentMap event) {

    this.setData(_merge(data, parseLocaleMap(event.get(DATA))));
  }

}

dynamic _merge(dynamic data, dynamic newData) {
  if (!(newData is PersistentMap) || data == null || !(data is PersistentMap)) {

    return newData;

  }

  PersistentMap result = data;

  newData.forEach((Pair pair) {
    result = insertIn(result, [pair.first], _merge(result.get(pair.first, null), pair.second));
  });


  return result;
}
