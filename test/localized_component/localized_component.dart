library localized_component_test;

import 'package:unittest/unittest.dart';
import 'package:vacuum_persistent/persistent.dart';
import 'package:flux_i18n/localized_component.dart';
import 'package:flux/component.dart';
import '../utils/mocks.dart';
import 'package:flux_i18n/common.dart';

main() {
  group("(LocalizedComponent)", () {

    LocalizedComponent component;
    PersistentIndexedCollection innerData;
    PersistentIndexedCollection locale;
    PersistentIndexedCollection data;
    DispatcherMock dispatcher;

    setUp(() {
      dispatcher = new DispatcherMock();

      innerData = persist({
        "key": "value"
      });
      locale = persist({
        GLOBAL: {
          "globalkey": "globalvalue",
          "translationkey": "globaltranslationtext"
        },
        "translationkey": "translationtext",
        "child": {
          "childtranslationkey": "childtranslationtext",

        }
      });
      data = persist({
        DATA: innerData,
        LOCALE: locale,
      });

      component = new LocalizedComponent(new Props(data: data, dispatcher: dispatcher));
    });

    test("class should exist", () {
      expect(new LocalizedComponent(null) is Component, isTrue);
    });

    test("should have getted data which get data['data']", () {
      expect(component.data, equals(innerData));
    });

    test("should have getted locale which get data['locale']", () {
      expect(component.locale, equals(locale));
    });

    test("should have method locate which returns value from locale", () {
      expect(component.locate("translationkey"), equals("translationtext"));
      expect(component.locate("not existing"), isNull);
    });

    test("should have shortcut l for method locate", () {
      expect(component.l("translationkey"), equals(component.locate("translationkey")));
    });

    test("should have function createProps which work with inner data", () {
      Props props = component.createProps(innerData);
      expect(props.data.get(DATA), equals(innerData));
      expect(props.data.get(LOCALE), equals(component.locale));
    });

    test("should edit locale if passed name to createProps", () {
      Props props = component.createProps(innerData, name: "child");
      expect(props.data.get(DATA), equals(innerData));
      expect(props.data.get(LOCALE), isNot(equals(component.locale)));
      expect(props.data.get(LOCALE).get("childtranslationkey"), equals("childtranslationtext"));
      expect(props.data.get(LOCALE).get(GLOBAL).get("globalkey"), equals("globalvalue"));
    });

    test("should get locate also from global", () {
      expect(component.locate("globalkey"), equals("globalvalue"));
    });

    test("should get from global if global parameter is true", () {
      expect(component.locate("translationkey", global: true), equals("globaltranslationtext"));
    });

  });

}