import "dbinterface.dart";
import 'dart:async' ;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http_server/http_server.dart' as http_server;
import 'package:route/server.dart' show Router;
import 'package:logging/logging.dart' show Logger, Level, LogRecord;

final Logger log = new Logger('DartiverseSearch');


/**
 * Handle an established [WebSocket] connection.
 *
 * The WebSocket can send search requests as JSON-formatted messages,
 * which will be responded to with a series of results and finally a done
 * message.
 */
void handleWebSocket(WebSocket webSocket) {
  log.info('New WebSocket connection');

  // Listen for incoming data. We expect the data to be a JSON-encoded String.
  webSocket
    .map((string) => JSON.decode(string))
    .listen((json) {
      // The JSON object should contains a 'request' entry.
      var request = json['request'];
      switch (request) {
        case 'search':

          break;

        default:
          log.warning("Invalid request: '$request'");
      }
    }, onError: (error) {
      log.warning('Bad WebSocket request');
    });
}
void setUpLogger(){
  Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
}
String getBuildPath(){
  return Platform.script.resolve('./build/web').toFilePath();
}
bool doesBuildPathExists(String buildPath){
  return new Directory(buildPath).existsSync();
}
void main() {
  // Set up logger.
  setUpLogger();

  var buildPath = getBuildPath();

  if (!doesBuildPathExists(buildPath)) {
    log.severe("The 'build/' directory was not found. Please run 'pub build'.");
    return;
  }

  int port = 9223;  // TODO use args from command line to set this

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port)
  .then((server) {
    log.info("Search server is running on 'http://${server.address.address}:$port/'");
    var router = new Router(server);

    // The client will connect using a WebSocket. Upgrade requests to '/ws' and
    // forward them to 'handleWebSocket'.
    router.serve('/ws')
      .transform(new WebSocketTransformer())
      .listen(handleWebSocket);

    // Set up default handler. This will serve files from our 'build' directory.
    var virutalDirectory = new http_server.VirtualDirectory(buildPath)
    // Disable jail root, as packages are local symlinks.
    ..jailRoot = false
    ..allowDirectoryListing = true;
    
    virutalDirectory.directoryHandler = (dir, request) {
      // Redirect directory requests to index.html files.
      var indexUri = new Uri.file(dir.path).resolve('index.html');
      virutalDirectory.serveFile(new File(indexUri.toFilePath()), request);
    };

    // Add an error page handler.
    virutalDirectory.errorPageHandler = (HttpRequest request) {
      log.warning("Resource not found: ${request.uri.path}");
      request.response.statusCode = HttpStatus.NOT_FOUND;
      request.response.close();
    };

    // Serve everything not routed elsewhere through the virtual directory.
    virutalDirectory.serve(router.defaultStream);

    // Special handling of client.dart. Running 'pub build' generates
    // JavaScript files but does not copy the Dart files, which are
    // needed for the Dartium browser.
    router.serve("/client.dart").listen((request) {
      Uri clientScript = Platform.script.resolve("../web/client.dart");
      virutalDirectory.serveFile(new File(clientScript.toFilePath()), request);
    });
  });
  
}
