import '../server/smriti_mcp_server.dart';

class McpClient {
  final SmritiMcpServer _server;
  int _requestId = 0;

  McpClient(this._server);

  Future<List<Map<String, dynamic>>> listTools() async {
    final response = await _sendRequest('tools/list', {});
    if (response.containsKey('error')) {
      throw Exception(response['error']['message']);
    }
    final tools = response['result']['tools'] as List<dynamic>;
    return tools.cast<Map<String, dynamic>>();
  }

  Future<String> callTool(String name, [Map<String, dynamic> arguments = const {}]) async {
    final response = await _sendRequest('tools/call', {
      'name': name,
      'arguments': arguments,
    });

    if (response.containsKey('error')) {
      throw Exception(response['error']['message']);
    }

    final content = response['result']['content'] as List<dynamic>;
    if (content.isNotEmpty) {
      return content.first['text'] as String;
    }
    return '';
  }

  Future<Map<String, dynamic>> _sendRequest(String method, Map<String, dynamic> params) async {
    _requestId++;
    final request = {
      'jsonrpc': '2.0',
      'id': _requestId,
      'method': method,
      'params': params,
    };
    return await _server.handleRequest(request);
  }
}
