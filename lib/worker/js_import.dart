import 'package:web/web.dart' as web;
import 'package:path/path.dart' as path;

class JSImport {
  static Future<void> import({
    required String source,
    String? package,
    bool defer = false,
    bool async = true,
    String? type,
  }) async {
    source = package == null 
      ? source 
      : path.normalize("assets/packages/$package/$source");
    if (isImported(source: source)) {
      return;
    }
    final web.Element head = _headElement();
    final web.HTMLScriptElement libraryElement = web.HTMLScriptElement()
        ..type = type ?? "text/javascript"
        ..charset = "utf-8"
        ..defer = async
        ..async = async
        ..src = source;
    head.appendChild(libraryElement);
    await libraryElement.onLoad.first;
  }

  static bool isImported({
    required String source,
    String? package,
  }) {
    // source = _packageUrl(source, package);

    source = package == null 
      ? source 
      : path.normalize("assets/packages/$package/$source");

    final web.Element head = _headElement();
    return head.querySelector('[src\$="$source"]') != null;
  }

  static web.Element _headElement() {
    web.Element? head = web.document.querySelector("head");
    if (head == null) {
      throw StateError("Could not fetch html head element!");
    }

    return head;
  }


}
