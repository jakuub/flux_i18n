library loader;
import 'dart:async';

abstract class Loader {
  Future getJson(String path);
}