library locale_sore;

import "package:flux/store.dart";
import "package:vacuum_persistent/persistent.dart";
import 'loader.dart';
import 'common.dart';

class LocaleStore extends Store<PersistentIndexedCollection> {

  final Loader loader;
  final List<String> paths;
  final String root;
  String get locale => lookupIn(data, ["locale"]);
  set locale(loc) {
    loadLocale(loc);
    insert(["locale"], loc);
  }

  LocaleStore(dispatcher, cursor, {this.root, String defaultLocale: "en", List<String> paths, this.loader})
      : super(dispatcher, cursor),
        this.paths = paths != null ? paths : [] {
    insert(["locale"], defaultLocale);
    listen({
      LOCALELOADED: localeLoaded,
      LOCALE_CHANGE: localeChange
    });
    loadLocale(defaultLocale);
  }

  PersistentIndexedCollection parseLocaleMap(PersistentIndexedCollection localeMap) {
    PersistentIndexedCollection result = persist({});

    localeMap.forEach((Pair pair) {
      String key = pair.fst;
      List path = key.split(".");
      for (num i = 0; i < path.length; ++i) {
        if (lookupIn(result, path.sublist(0, i), notFound: null) == null) {
          result = insertIn(result, path.sublist(0, i), persist({}));
        }
      }
      result = insertIn(result, path, pair.snd);
    });

    return result;
  }

  loadLocale(String locale) {
    paths.forEach((String path) {
      dispatcher.dispatchAsync(loader.getJson("$root/$path/$locale.json"), LOCALELOADED, DATA);
    });
  }

  localeLoaded(PersistentIndexedCollection event) {

    this.setData(_merge(data, parseLocaleMap(event.get(DATA))));
  }
  
  localeChange(PersistentIndexedCollection event) {
    this.locale = lookupIn(event, [DATA]);
  }

  getLocale(String path) {
    List pathList = path.split(".");
    PersistentIndexedCollection locale = null; 
    
    for (num i = 0; i <= pathList.length; ++i) {
      if (lookupIn(data, pathList.sublist(0, i), notFound: null) == null) {
        locale = per({}); //found null on path, create empty locale
      }
    }
    
    if (locale == null) {
      locale = lookupIn(data, pathList);
    }
    
    return insertIn(locale, [GLOBAL], lookupIn(data, [GLOBAL], notFound: null));
  }
}

dynamic _merge(dynamic data, dynamic newData) {
  if (!(newData is PersistentIndexedCollection) || data == null || !(data is PersistentIndexedCollection)) {

    return newData;

  }

  PersistentIndexedCollection result = data;

  newData.forEach((Pair pair) {
    result = insertIn(result, [pair.fst], _merge(lookupIn(result, [pair.fst]), pair.snd));
  });


  return result;
}
