import 'package:flux_i18n/localized_component.dart';
import 'package:flux_i18n/locale_store.dart';
import 'package:flux_i18n/browser_loader.dart';
import 'package:flux_i18n/common.dart';
import 'package:flux/dispatcher.dart';
import 'package:flux/component.dart';
import 'package:vacuum_persistent/persistent.dart';
import 'package:tiles/tiles.dart' as tiles;
import 'package:tiles/tiles_browser.dart' as tiles;
import 'dart:html';
import 'dart:async';



main() {
  print("start");
  Element element = querySelector("#text");

  BrowserLoader loader = new BrowserLoader();
  Dispatcher dispatcher = new Dispatcher();
  Reference ref = new Reference(persist({}));

  LocaleStore store = new LocaleStore(dispatcher, ref.cursor, loader: loader, root: ".", paths: [""], defaultLocale: "en");

  tiles.initTilesBrowserConfiguration();

  ref.onChange.listen((_) {
    PersistentMap data = persist({
      LOCALE: ref.deref(),
      DATA: {}
    });
    tiles.mountComponent(helloWorld(props: new Props(data: data, dispatcher: dispatcher)), element);
    print("change");
  });

  new Timer(new Duration(seconds: 2), () {
    store.locale = "phrase";
  });

}

class HelloWorld extends LocalizedComponent {
  HelloWorld(props, child) : super(props, child);

  render() {
    return tiles.div(children: locate("nieco"));
  }
}

var helloWorld = tiles.registerComponent(({props, children}) => new HelloWorld(props, children));
