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

const String _dashboardHtml = '''
<!DOCTYPE html>
<html>
<head>
    <title>Flutter Playground</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 20px; background: #f0f2f5; }
        .card { background: white; padding: 24px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); max-width: 400px; margin: 0 auto; }
        h1 { margin-top: 0; font-size: 20px; color: #333; }
        
        .section { margin-bottom: 24px; }
        label { display: block; font-weight: 500; margin-bottom: 8px; color: #666; font-size: 14px; }
        
        /* Range Slider */
        input[type="range"] { width: 100%; accent-color: #3b82f6; }
        
        /* Button Group for Layout */
        .btn-group { display: flex; gap: 10px; }
        button {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            color: #555;
            transition: all 0.2s;
        }
        button.active {
            background: #3b82f6;
            color: white;
            border-color: #3b82f6;
        }
        
        #status { font-size: 12px; color: #888; margin-top: 20px; text-align: center; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🎛️ Playground Controls</h1>

        <div class="section">
            <label>Padding: <span id="valDisplay">10.0</span></label>
            <input type="range" min="0" max="100" value="10" oninput="sendPadding(this.value)">
        </div>

        <div class="section">
            <label>Preview Mode</label>
            <div class="btn-group">
                <button id="btnSingle" class="active" onclick="sendLayout('single')">📱 Single</button>
                <button id="btnGrid" onclick="sendLayout('grid')">🖥️ Grid</button>
            </div>
        </div>

        <div id="status">Connecting...</div>
    </div>

    <script>
        const ws = new WebSocket('ws://' + window.location.host + '/ws');
        
        // State
        let currentLayout = 'single';

        ws.onopen = () => {
            const status = document.getElementById('status');
            status.innerText = '🟢 Connected to Device';
            status.style.color = '#22c55e';
        };

        ws.onclose = () => {
             const status = document.getElementById('status');
            status.innerText = '🔴 Disconnected';
            status.style.color = '#ef4444';
        };

        function sendPadding(val) {
            document.getElementById('valDisplay').innerText = parseFloat(val).toFixed(1);
            ws.send(JSON.stringify({ 
                'type': 'update',
                'padding': parseFloat(val) 
            }));
        }

        function sendLayout(mode) {
            // Update UI
            document.getElementById('btnSingle').className = mode === 'single' ? 'active' : '';
            document.getElementById('btnGrid').className = mode === 'grid' ? 'active' : '';
            
            // Send Command
            ws.send(JSON.stringify({ 
                'type': 'layout',
                'layout': mode 
            }));
        }
    </script>
</body>
</html>
''';
