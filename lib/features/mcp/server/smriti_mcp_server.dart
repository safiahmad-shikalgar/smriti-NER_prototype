import 'dart:convert';
import '../models/mcp_tool.dart';

class SmritiMcpServer {
  final Map<String, McpTool> _tools = {};

  void registerTool(McpTool tool) {
    _tools[tool.name] = tool;
  }

  Future<Map<String, dynamic>> handleRequest(Map<String, dynamic> request) async {
    final id = request['id'];
    final method = request['method'];
    final params = request['params'] as Map<String, dynamic>? ?? {};

    try {
      if (method == 'tools/list') {
        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'tools': _tools.values.map((t) => t.toJson()).toList(),
          },
        };
      } else if (method == 'tools/call') {
        final name = params['name'] as String?;
        final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

        if (name == null || !_tools.containsKey(name)) {
          throw Exception('Tool not found: $name');
        }

        final tool = _tools[name]!;
        final result = await tool.handler(arguments);

        return {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'content': [
              {
                'type': 'text',
                'text': result is String ? result : jsonEncode(result),
              }
            ],
            'isError': false,
          },
        };
      } else {
        throw Exception('Method not found: $method');
      }
    } catch (e) {
      return {
        'jsonrpc': '2.0',
        'id': id,
        'error': {
          'code': -32000,
          'message': e.toString(),
        }
      };
    }
  }
}
