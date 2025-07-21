import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

Future<bool> fetchStatus(String url) async {
  var parsedUrl = Uri.parse(url);
  final httpPackageResponse = await http.get(parsedUrl);
  // Parse the HTML response
  var document = html_parser.parse(httpPackageResponse.body);
  // Extract the text content
  var textContent = document.body?.text ?? 'Error parsing response';
  if (textContent.trim() == '1') {
    return true;
  }
  else {
    return false;
  }
}

Future<List<bool>> fetchStatusWithDelimiter(String url, String delimiter) async {
  try {
    var parsedUrl = Uri.parse(url);
    final httpPackageResponse = await http.get(parsedUrl).timeout(Duration(seconds: 10));
    // Parse the HTML response
    var document = html_parser.parse(httpPackageResponse.body);
    // Extract the text content
    var textContent = document.body?.text ?? 'Error parsing response';
    var output = <bool>[];
    if (!textContent.contains(delimiter)) {
      return output;
    }
    for (var status in textContent.split(delimiter)) {
      if (status.trim() == '1') {
        output.add(true);
      } else {
        output.add(false);
      }
    }
    return output;
  } catch (e) {
    return [];
  }
  
}
