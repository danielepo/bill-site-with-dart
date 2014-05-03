// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartiverse_search;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import "record.dart" as record;
import 'package:http_server/http_server.dart' as http_server;
import 'package:route/server.dart' show Router;
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import "dbinterface.dart" as db_interface;


final Logger log = new Logger('DartiverseSearch');

/*
// List of search-engines used.
final List<SearchEngine> searchEngines = [
  new StackOverflowSearchEngine(),
  new GithubSearchEngine()
];*/

void main() {
  // Set up logger.
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  var buildPath = Platform.script.resolve('./build').toFilePath();
  if (!new Directory(buildPath).existsSync()) {
    log.severe("The 'build/' directory was not found. Please run 'pub build'.");
    return;
  }

  int port = 2223;  // TODO use args from command line to set this

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
    log.info("Search server is running on "
             "'http://${server.address.address}:$port/'");
    var router = new Router(server);

    // The client will connect using a WebSocket. Upgrade requests to '/ws' and
    // forward them to 'handleWebSocket'.
    router.serve('/ws')
      .transform(new WebSocketTransformer())
      .listen(handleWebSocket);

    // Set up default handler. This will serve files from our 'build' directory.
    var virDir = new http_server.VirtualDirectory(buildPath);
    // Disable jail-root, as packages are local sym-links.
    virDir.jailRoot = false;
    virDir.allowDirectoryListing = true;
    virDir.directoryHandler = (dir, request) {
      // Redirect directory-requests to index.html files.
      var indexUri = new Uri.file(dir.path).resolve('index.html');
      virDir.serveFile(new File(indexUri.toFilePath()), request);
    };

    // Add an error page handler.
    virDir.errorPageHandler = (HttpRequest request) {
      log.warning("Resource not found ${request.uri.path}");
      request.response.statusCode = HttpStatus.NOT_FOUND;
      request.response.close();
    };

    // Serve everything not routed elsewhere through the virtual directory.
    virDir.serve(router.defaultStream);

    // Special handling of client.dart. Running 'pub build' generates
    // JavaScript files but does not copy the Dart files, which are
    // needed for the Dartium browser.
    router.serve("/client.dart").listen((request) {
      Uri clientScript = Platform.script.resolve("../web/client.dart");
      virDir.serveFile(new File(clientScript.toFilePath()), request);
    });
  });
}

/**
 * Handle an established [WebSocket] connection.
 *
 * The web-socket can send search requests as JSON-formatted messages,
 * that will be responded to with a series of results and finally a done
 * message.
 */
void handleWebSocket(WebSocket webSocket) {
  log.info('New web-socket connection');

  // Listen for incoming data. We expect the data to be a JSON-encoded String.
  webSocket
    .map((string) => JSON.decode(string))
    .listen((json) {
      // The JSON object should contains a 'request' entry.
      var request = json['request'];
      var collection = "outgoings";
      
      if (request == 'addIncoming'){
        collection = "incomings";
      }
      log.info("input new expence: $request");
      switch (request) {
        case 'addOutgoing':
        case 'addIncoming':
          // Initiate a new search.
          String category = json['value']['cathegory'];
          String subCategory = json['value']['subcathegory'];
          double cost = double.parse(json['value']['cost']);
          String date = json['value']['date'];
          
          List<String> splittedDate = date.split("-");
          
          int year = int.parse(splittedDate.elementAt(0));
          int month = int.parse(splittedDate.elementAt(1));
          int day = int.parse(splittedDate.elementAt(2));
          
          
          
          log.info("Cathegory: $category");
          log.info("Sub Cathegory: $subCategory");
          log.info("Date: $date");
          log.info("Cost: $cost");
          
          db_interface.DbInterface db = new db_interface.DbInterface("127.0.0.1","conti", collection);
          db.open()
              .then((_) => db.insert([new record.Record.setter(category, cost, new DateTime(year, month, day),subCategory)]))
              .then((_) => db.getByDate(new DateTime(year, month),true))
        .then((value){
          List<Map> valList = value;          
          Iterator i =  valList.iterator;
          List retList = [];
          
          while(i.moveNext()){
            var obj = {
                       "Cathegory" :i.current["Cathegory"] ,
                       "Date" :i.current["Date"].toString() ,
                       "Subcathegory" :i.current["Subcathegory"] ,
                       "Cost" :i.current["Cost"] };
            retList.add(obj);
                       
          }
          
          var encoded = JSON.encode(retList);
          var response = {
                          'response': 'itemAdded',
                          'recordType':collection,
                          'value' : retList
          };
          webSocket.add(JSON.encode(response));
          
        })        
              .then((_) => db.close());
          
          break;
        case 'getTable':
          collection = json['collection'];
          String date = json['date'];
          List<String> splittedDate = date.split("-");
          int year = int.parse(splittedDate.elementAt(0));
          int month = int.parse(splittedDate.elementAt(1));
          
          db_interface.DbInterface db = new db_interface.DbInterface("127.0.0.1","conti", collection);
          db.open()
            
              .then((_) => db.getByDate(new DateTime(year, month),true))
        .then((value){
          List<Map> valList = value;          
          Iterator i =  valList.iterator;
          List retList = [];
          
          while(i.moveNext()){
            var obj = {
                       "Cathegory" :i.current["Cathegory"] ,
                       "Date" :i.current["Date"].toString() ,
                       "Subcathegory" :i.current["Subcathegory"] ,
                       "Cost" :i.current["Cost"] };
            retList.add(obj);
                       
          }
          
          var encoded = JSON.encode(retList);
          var response = {
                          'response': 'getTable',
                          'recordType':collection,
                          'value' : retList
          };
          webSocket.add(JSON.encode(response));
          
        })        
              .then((_) => db.close());
          
          break;
        default:
          log.warning("Invalid request '$request'.");
      }
    }, onError: (error) {
      log.warning('Bad WebSocket request');
    });
}

