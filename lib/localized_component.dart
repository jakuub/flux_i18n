library localized_component;

import 'package:flux/component.dart';
import 'package:vacuum_persistent/persistent.dart';
import 'common.dart';

class LocalizedComponent extends Component<PersistentMap> {

  @override
  PersistentMap get data => lookupIn(super.data, [DATA]);

  PersistentMap get locale => lookupIn(super.data, [LOCALE]);

  LocalizedComponent(Props<PersistentMap> props, [children]) : super(props, children);

  String locate(String key, {bool global: false}) {

    String result = lookupIn(locale, [key]);

    if (result != null && !global) {
      return result;
    }

    if (lookupIn(locale, [GLOBAL]) != null) {
      return lookupIn(locale, [GLOBAL, key]);
    }

    return null;
  }

  /**
   * Helper for easier usage
   */
  String _(String key, {bool global: false}) => locate(key, global: global);

  @override
  Props createProps(PersistentMap data, {String name}) {
    return super.createProps(persist({
      DATA: data,
      LOCALE: _chooseLocale(name),
    }));
  }

  @override
  Props cp(PersistentMap data, {String name}) => createProps(data, name: name);

  PersistentMap _chooseLocale(String name) {
    if (name != null) {
      return insertIn(lookupIn(locale, [name], notFound: persist({})), [GLOBAL], lookupIn(locale, [GLOBAL], notFound: persist({})));
    }

    return locale;
  }

}
