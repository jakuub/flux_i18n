library browser_loader;
import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'package:flux_i18n/loader.dart';

class BrowserLoader extends Loader {
  Future getJson(String path) {
    return HttpRequest.getString(path).then((jsonString) {
      return JSON.decoder.convert(jsonString);
    });
  }
}