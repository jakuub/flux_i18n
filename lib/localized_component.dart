library localized_component;

import 'package:flux/component.dart';
import 'package:vacuum_persistent/persistent.dart';

import 'common.dart';

class LocalizedComponent extends Component<PersistentIndexedCollection> {

  final String placeholderStart = "{{";
  final String placeholderEnd = "}}";

  @override
  PersistentIndexedCollection get data => lookupIn(super.data, [DATA]);

  PersistentIndexedCollection get locale => lookupIn(super.data, [LOCALE]);

  LocalizedComponent(Props<PersistentIndexedCollection> props, [children])
      : super(props, children);

  String locate(String key, {bool global: false, Map placeholders}) {
    String result = lookupIn(locale, [key]);

    if (result != null && !global) {
      return addPlaceholders(result, placeholders);
    }

    if (lookupIn(locale, [GLOBAL]) != null) {
      return addPlaceholders(lookupIn(locale, [GLOBAL, key]), placeholders);
    }

    return null;
  }

  addPlaceholders(String locale, Map placeholders) {
    if (placeholders == null || locale == null) {
      return locale;
    }

    return placeholders.keys.fold(locale, (previous, key) =>
        previous.replaceAll(
            placeholderStart + key + placeholderEnd, placeholders[key]));
  }

  /**
   * Helper for easier usage
   */
  String l(String key, {bool global: false, Map placeholders}) =>
      locate(key, global: global, placeholders: placeholders);

  @override
  Props createProps(PersistentIndexedCollection data, {String name}) {
    return super.createProps(persist({
      DATA: data,
      LOCALE: _chooseLocale(name),
    }));
  }

  @override
  Props cp(PersistentIndexedCollection data, {String name}) =>
      createProps(data, name: name);

  PersistentIndexedCollection _chooseLocale(String name) {
    if (name != null) {
      return insertIn(lookupIn(locale, [name], notFound: persist({})), [GLOBAL],
          lookupIn(locale, [GLOBAL], notFound: persist({})));
    }

    return locale;
  }

}
