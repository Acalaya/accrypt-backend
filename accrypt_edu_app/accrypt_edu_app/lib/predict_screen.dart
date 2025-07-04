import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // Clipboard

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _result = '';
  bool _isLoading = false;
  bool _isConnected = false;
  List<Map<String, String>> _history = [];

  final String backendUrl = 'http://192.168.1.21:5000'; // Update your backend IP if needed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    checkBackendConnection();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> checkBackendConnection() async {
    final url = Uri.parse('$backendUrl/ping');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isConnected = data['status'] == 'ok';
        });
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    } catch (_) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _predictText() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter some text")),
      );
      return;
    }
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Backend is not reachable. Check your connection.")),
      );
      return;
    }

    final url = Uri.parse('$backendUrl/predict');

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": _controller.text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data['prediction'];
          _history.insert(0, {
            "text": _controller.text,
            "result": _result,
          });
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _result = "Endpoint not found on server.";
        });
      } else if (response.statusCode == 500) {
        setState(() {
          _result = "Server error. Please try again later.";
        });
      } else {
        setState(() {
          _result = "Server error: ${response.statusCode}";
        });
      }
    } catch (e) {
      String message = "Connection failed: $e";
      if (e.toString().contains("SocketException")) {
        message = "No internet connection.";
      }
      setState(() {
        _result = message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Result copied to clipboard!")),
      );
    }
  }

  void _shareResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Share feature coming soon!")),
    );
  }

  void _clearInput() {
    _controller.clear();
    setState(() {
      _result = '';
    });
    FocusScope.of(context).requestFocus(_focusNode);
  }

  Widget _buildHistory() {
    if (_history.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: const Text("Scan History", style: TextStyle(color: Colors.tealAccent)),
      children: _history.map((entry) {
        return ListTile(
          title: Text(
            entry["text"] ?? "",
            style: const TextStyle(color: Colors.white70),
          ),
          subtitle: Text(
            entry["result"] ?? "",
            style: TextStyle(
              color: (entry["result"] == "Sensitive") ? Colors.redAccent : Colors.greenAccent,
            ),
          ),
          isThreeLine: true,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Sensitive Data Detector"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.tealAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Check backend connection",
            onPressed: () async {
              await checkBackendConnection();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isConnected ? "Backend reachable ✅" : "Backend NOT reachable ❌"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: "Clear input and result",
            onPressed: _clearInput,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isConnected)
              Card(
                color: Colors.redAccent.withValues(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: const [
                      Icon(Icons.error, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Warning: Backend is not reachable. Please check your network or backend server.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              "Paste or write any text to scan for sensitive info:",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your text here...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _isLoading ? null : _predictText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent[400],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                    )
                  : const Text("Check", style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 24),

            if (_result.isNotEmpty)
              Card(
                elevation: 5,
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _result == "Sensitive" ? Icons.warning_amber_rounded : Icons.verified_user,
                            color: _result == "Sensitive" ? Colors.redAccent : Colors.greenAccent,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _result,
                              style: TextStyle(
                                fontSize: 18,
                                color: _result == "Sensitive" ? Colors.redAccent : Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.tealAccent),
                            tooltip: "Copy Result",
                            onPressed: _copyResult,
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.tealAccent),
                            tooltip: "Share Result",
                            onPressed: _shareResult,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            _buildHistory(),
          ],
        ),
      ),
    );
  }
}
