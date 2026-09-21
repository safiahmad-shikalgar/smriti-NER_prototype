class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;
  final Future<dynamic> Function(Map<String, dynamic> arguments) handler;

  const McpTool({
    required this.name,
    required this.description,
    required this.inputSchema,
    required this.handler,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'inputSchema': inputSchema,
      };
}
