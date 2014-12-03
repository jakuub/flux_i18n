import 'package:flux_i18n/browser_loader.dart';
import 'package:unittest/unittest.dart';

main() {
  group("(BrowserLoader)", () {
    BrowserLoader loader = new BrowserLoader();

    testContent() {
      return expectAsync((data) {
        expect(data is Map, isTrue);
        expect(data["key"], equals("value"));
      });
    }

    test("should load based on absolute path", () {
      loader.getJson("/browser_loader/data.json").then(testContent());
    });

  });

}
