import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

// 1. Root Widget of the Application
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData.dark(), // Uses a clean built-in dark theme
      home: const CalculatorScreen(),
    );
  }
}

// 2. Stateful Screen to Manage Changing Numbers
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // App State variables
  String _display = '0';      // What the user sees on screen
  double _firstNumber = 0;    // Stores the first number typed
  String _operator = '';      // Stores +, -, *, or /
  bool _shouldReset = false;  // Flags if next number should clear screen

  // 3. Logic to handle button taps
  void _onButtonPress(String value) {
    setState(() {
      if (value == 'C') {
        // Clear all states
        _display = '0';
        _firstNumber = 0;
        _operator = '';
        _shouldReset = false;
      } else if (value == '+' || value == '-' || value == '*' || value == '/') {
        // Save first number and chosen operation
        _firstNumber = double.tryParse(_display) ?? 0;
        _operator = value;
        _shouldReset = true;
      } else if (value == '=') {
        // Perform calculation
        if (_operator.isEmpty) return;
        double secondNumber = double.tryParse(_display) ?? 0;
        double result = 0;

        switch (_operator) {
          case '+': result = _firstNumber + secondNumber; break;
          case '-': result = _firstNumber - secondNumber; break;
          case '*': result = _firstNumber * secondNumber; break;
          case '/': result = secondNumber != 0 ? _firstNumber / secondNumber : 0; break;
        }

        // Format result: remove decimal point if it is a whole number
        _display = result % 1 == 0 ? result.toInt().toString() : result.toString();
        _operator = '';
        _shouldReset = true;
      } else {
        // Handle inputting numbers
        if (_display == '0' || _shouldReset) {
          _display = value;
          _shouldReset = false;
        } else {
          _display += value;
        }
      }
    });
  }

  // Helper helper function to build uniform buttons easily
  Widget _buildButton(String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _onButtonPress(label),
          child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  // 4. Building the Layout Architecture
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Calculator')),
      body: Column(
        children: [
          // The Calculator Display Screen
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                _display,
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
            ),
          ),
          // The Grid of Input Buttons
          Column(
            children: [
              Row(children: [
                _buildButton('7', Colors.grey[800]!),
                _buildButton('8', Colors.grey[800]!),
                _buildButton('9', Colors.grey[800]!),
                _buildButton('/', Colors.orange),
              ]),
              Row(children: [
                _buildButton('4', Colors.grey[800]!),
                _buildButton('5', Colors.grey[800]!),
                _buildButton('6', Colors.grey[800]!),
                _buildButton('*', Colors.orange),
              ]),
              Row(children: [
                _buildButton('1', Colors.grey[800]!),
                _buildButton('2', Colors.grey[800]!),
                _buildButton('3', Colors.grey[800]!),
                _buildButton('-', Colors.orange),
              ]),
              Row(children: [
                _buildButton('C', Colors.redAccent),
                _buildButton('0', Colors.grey[800]!),
                _buildButton('=', Colors.green),
                _buildButton('+', Colors.orange),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
