import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  List<String> chatHistory = [];

  @override
  void initState() {
    _connectToServer();
    super.initState();
  }

  void _connectToServer() {
    socket = IO.io('http://192.168.43.52:5999', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _setupCommunicationSystem();
  }

  void _setupCommunicationSystem() {
    socket.on('message', (data) {
      setState(() {
        chatHistory.add('Server: ${data.toString()}');
      });
    });
    //connect to the socket now
    socket.connect();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      socket.emit('message', _controller.text);
      chatHistory.add('You: ${_controller.text}');
      _controller.text = '';
      setState(() {});
    }
  }

  String convertTimeToIst(DateTime time) {
    DateTime utcTime = DateTime.now().toUtc();
    DateTime istTime = utcTime.add(Duration(hours: 5, minutes: 30));
    String formattedTime = DateFormat('HH:mm:ss').format(istTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatRoom'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final message = chatHistory[index];
                      final isServerMessage = message.startsWith('Server:');
                      return Align(
                          alignment: isServerMessage
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: isServerMessage
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: isServerMessage
                                        ? Colors.blue[100]
                                        : Colors.green[100],
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(message),
                              ),
                              Text(
                                convertTimeToIst(DateTime.now()),
                                style: TextStyle(fontSize: 10),
                              )
                            ],
                          ));
                    })),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      labelText: 'Send a message,server will respond to you.'),
                )),
                IconButton(
                    onPressed: _sendMessage, icon: const Icon(Icons.send))
              ],
            )
          ],
        ),
      ),
    );
  }
}
