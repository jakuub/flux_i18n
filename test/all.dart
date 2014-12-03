library test;

import 'package:unittest/unittest.dart';
import 'locale_store/locale_store.dart' as locale_store;
import 'localized_component/localized_component.dart' as localized_component;

main() {
  group("(flux_i18n)", () {
    locale_store.main();
    localized_component.main();
  });
}