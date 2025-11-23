import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PlaygroundServer {
  HttpServer? _server;
  final StreamController<Map<String, dynamic>> _updateController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get updateStream => _updateController.stream;

  Future<void> start() async {
    // FIX: Added second argument 'String? protocol' to match new package version
    var wsHandler = webSocketHandler((
      WebSocketChannel webSocket,
      String? protocol,
    ) {
      webSocket.stream.listen((message) {
        // ignore: avoid_print
        print('Playground: Received update: $message');

        try {
          final data = jsonDecode(message);
          if (data is Map<String, dynamic>) {
            _updateController.add(data);
          }
        } catch (e) {
          // ignore: avoid_print
          print('Error parsing JSON: $e');
        }
      });
    });

    var handler = const Pipeline().addMiddleware(logRequests()).addHandler((
      Request request,
    ) {
      if (request.url.path == 'ws') {
        return wsHandler(request);
      }
      return Response.ok(
        _dashboardHtml,
        headers: {'content-type': 'text/html'},
      );
    });

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);

    // ignore: avoid_print
    print('-------------------------------------------------------');
    // ignore: avoid_print
    print(
      '⚡️ Playground Server running on http://${_server!.address.host}:${_server!.port}',
    );
    // ignore: avoid_print
    print('⚡️ Access from laptop via: http://<PHONE_IP_ADDRESS>:8080');
    // ignore: avoid_print
    print('-------------------------------------------------------');
  }

  Future<void> stop() async {
    await _server?.close();
    await _updateController.close();
    // ignore: avoid_print
    print('Playground Server stopped.');
  }
}

// Minimal HTML for the MVP Dashboard
const String _dashboardHtml = '''
<!DOCTYPE html>
<html>
<head>
    <title>Flutter Playground</title>
    <style>
        body { font-family: sans-serif; padding: 20px; background: #f0f2f5; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { margin-top: 0; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🎛️ Control Panel</h1>
        <p>Status: <span id="status" style="color: orange">Connecting...</span></p>
        <label>Padding:</label>
        <input type="range" min="0" max="100" value="10" oninput="sendUpdate(this.value)">
        <span id="valDisplay">10</span>
    </div>

    <script>
        const ws = new WebSocket('ws://' + window.location.host + '/ws');
        
        ws.onopen = () => {
            document.getElementById('status').innerText = 'Connected 🟢';
            document.getElementById('status').style.color = 'green';
        };

        ws.onclose = () => {
            document.getElementById('status').innerText = 'Disconnected 🔴';
            document.getElementById('status').style.color = 'red';
        };

        function sendUpdate(val) {
            document.getElementById('valDisplay').innerText = val;
            ws.send(JSON.stringify({ 'padding': parseFloat(val) }));
        }
    </script>
</body>
</html>
''';
