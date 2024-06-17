import 'package:web/web.dart' as web;
import 'package:path/path.dart' as path;

class JSImport {
  static List<String> importedSources = [];

  static Future<void> import({
    required String source,
    String? package,
    bool defer = false,
    bool async = false,
    String? type,
  }) async {
    print('################ JSImport()1  $importedSources');
    source = package == null
        ? source
        : path.normalize("assets/packages/$package/$source");
    print('#####@@@########### JSImport()2  $source ---');
    // if (isImported(source: source, package: package)) {
    //   print('#####@@@########### JSImport()  isImported: true ---');
    //   return;
    // }
    if (importedSources.contains(source)) {
      print('#####@@@########### JSImport()  isImported: true ---');
      return;
    }

    try {
      print('################ JSImport()3  ------');
      final web.Element head = _headElement();
      final web.HTMLScriptElement libraryElement = web.HTMLScriptElement()
        ..type = type ?? "text/javascript"
        ..charset = "utf-8"
        ..defer = async
        ..async = async
        ..src = source;
      print('################ JSImport()4');
      head.appendChild(libraryElement);
      print('################ JSImport()5');
      await libraryElement.onLoad.first;
      print('################ JSImport()5b');
      importedSources.add(source);
      print('################ JSImport()6  $importedSources');
    } catch (e) {
      print('################ JSImport() CATCH');
      final a = web.document;
      print('################ JSImport() CATCH  $a  ------');
    }
  }

  static bool isImported({
    required String source,
    String? package,
  }) {
    print('#####@@@########### JSImport()isImported-1  $source $package ---');
    source = package == null
        ? source
        : path.normalize("assets/packages/$package/$source");

    print('#####@@@########### JSImport()isImported-2');
    final web.Element head = _headElement();
    print('#####@@@########### JSImport()isImported-3');
    return head.querySelector('[src\$="$source"]') != null;
  }

  static web.Element _headElement() {
    print('#####@@@########### JSImport()_headElement-1');
    web.Element? head = web.document.querySelector("head");
    print('#####@@@########### JSImport()_headElement-2  $head');
    if (head == null) {
      print('#####@@@########### JSImport()_headElement-3');
      throw StateError("Could not fetch html head element!");
    }

    return head;
  }
}
