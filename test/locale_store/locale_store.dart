library locale_store_test;

import 'package:unittest/unittest.dart';
import 'package:mock/mock.dart';
import 'package:flux_i18n/locale_store.dart';
import 'package:flux/helpers.dart';
import 'package:vacuum_persistent/persistent.dart';
import 'dart:async';
import '../utils/mocks.dart';
import 'package:flux_i18n/common.dart';

main() {
  group("(LocaleStore)", () {

    Cursor cursor = new Reference(persist({})).cursor;
    LocaleStore store;
    DispatcherMock dispatcher;
    StreamController controller;
    LoaderMock loader;
    String root = "root";
    List<String> paths = ["locales", "languages"];

    setUp(() {
      controller = new StreamController.broadcast();
      dispatcher = new DispatcherMock();
      dispatcher.when(callsTo("get stream")).alwaysReturn(controller.stream);
      loader = new LoaderMock();
      store = new LocaleStore(dispatcher, cursor, paths: paths, loader: loader, root: root);
    });

    test("should exists and have default constructor like Store", () {
      // test only setup
    });

    test("should accept defaultLocale and pathRoot in constructor", () {
      new LocaleStore(dispatcher, cursor, defaultLocale: "en", root: "/", paths: []);
    });

    test("should parse map with keys with . to nested map", () {
      PersistentMap nested = store.parseLocaleMap(persist({
        "key1.key2": "value",
        "key1.key3": "value2"
      }));

      expect(nested.keys, contains("key1"));
    });

    test("should add async event to dispatcher when loadLocale called", () {
      dispatcher.clearLogs();
      loader.clearLogs();

      store.loadLocale("en");

      dispatcher.getLogs(callsTo("dispatchAsync")).verify(happenedExactly(2));
      loader.getLogs(callsTo("getJson", "root/locales/en.json")).verify(happenedOnce);
      loader.getLogs(callsTo("getJson", "root/languages/en.json")).verify(happenedOnce);
    });

    test("should add locale when loaded", () {
      controller.stream.listen(expectAsync((_) {
        expect(store.data.get("key"), equals("value"));
        expect(store.data.get("key2"), equals("value2"));
        expect(lookupIn(store.data, ["nested", "key"]), equals("nestedValue"));
        expect(lookupIn(store.data, ["nested", "key2"]), equals("nestedValue2"));

      }));

      store.setData(persist({
        "key2": "value2",
        "key": "otherValue",
        "nested": {
          "key": "other",
          "key2": "nestedValue2"
        }
      }));

      controller.add(persist({
        TYPE: LOCALELOADED,
        DATA: {
          "key": "value",
          "nested.key": "nestedValue",
        }
      }));
    });

    test("should have en as default locale", () {
      expect(store.locale, equals("en"));
    });

    test("should set locale from constructor", () {
      store = new LocaleStore(dispatcher, cursor, defaultLocale: "sk");

      expect(store.locale, equals("sk"));
    });

    test("should have setter for locale which runs loadLocale", () {
      dispatcher.clearLogs();

      store.locale = "sk";

      dispatcher.getLogs(callsTo("dispatchAsync")).verify(happenedExactly(2));
      loader.getLogs(callsTo("getJson", "root/locales/sk.json")).verify(happenedOnce);
      loader.getLogs(callsTo("getJson", "root/languages/sk.json")).verify(happenedOnce);
    });

    test("should load default locale 'en' in constructor", () {
      loader.getLogs(callsTo("getJson", "root/locales/en.json")).verify(happenedOnce);
      loader.getLogs(callsTo("getJson", "root/languages/en.json")).verify(happenedOnce);
    });

    test("should change locale if event happened in dispatcher", () {
      controller.stream.listen(expectAsync((_) {
        expect(store.data.get(LOCALE), equals("sk"));
      }));

      controller.add(persist({
        TYPE: LOCALE_CHANGE,
        DATA: "sk"
      }));
    });

  });
}
