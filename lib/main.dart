import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  // Starts the application
  runApp(const BoxCalculatorApp());
}
//try this
class BoxCalculatorApp extends StatelessWidget {
  const BoxCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Forklift Developer\'s Box Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BoxCalculatorHomePage(title: 'Forklift.dev: Box Calculator'),
    );
  }
}

class BoxCalculatorHomePage extends StatefulWidget {
  const BoxCalculatorHomePage({super.key, required this.title});
  final String title;

  @override
  State<BoxCalculatorHomePage> createState() => _BoxCalculatorHomePageState();
}

class _BoxCalculatorHomePageState extends State<BoxCalculatorHomePage> {
  // --- Input Controllers ---
  final TextEditingController _totalPiecesController = TextEditingController();
  final TextEditingController _remainingPiecesController = TextEditingController();
  final TextEditingController _piecesPerBoxController = TextEditingController();

  // State for the 'New Order' checkbox: true if everything is still remaining
  bool _isNewOrder = false; 

  // --- Calculated Output Values ---
  int _boxesToPick = 0;
  int _totalOrderDelivered = 0;
  double _overagePercent = 0.0;
  
  // Flag for the partial box warning
  bool _requiresPartialBox = false;

  @override
  void initState() {
    super.initState();
    // Initialize Remaining Pieces to reflect a new order (Remaining = Total)
    _remainingPiecesController.text = _totalPiecesController.text;
    
    // Add listeners to immediately recalculate on input change
    _totalPiecesController.addListener(_calculateMetrics);
    _remainingPiecesController.addListener(_calculateMetrics);
    _piecesPerBoxController.addListener(_calculateMetrics);
  }

  @override
  void dispose() {
    _totalPiecesController.dispose();
    _remainingPiecesController.dispose();
    _piecesPerBoxController.dispose();
    super.dispose();
  }

  /// Calculates all output values based on the three inputs.
  void _calculateMetrics() {
    if (!mounted) return; 

    setState(() {
      // 1. INPUT HANDLING (Safely parse all inputs)
      final int totalRequired = int.tryParse(_totalPiecesController.text) ?? 0;
      
      // If new order, use totalRequired; otherwise, use input
      final int remainingPieces = _isNewOrder 
        ? totalRequired 
        : (int.tryParse(_remainingPiecesController.text) ?? 0);
        
      final int piecesPerBox = int.tryParse(_piecesPerBoxController.text) ?? 0;

      // Reset values if piecesPerBox is zero
      if (piecesPerBox <= 0) {
        _boxesToPick = 0;
        _totalOrderDelivered = 0;
        _overagePercent = 0.0;
        _requiresPartialBox = false;
        return;
      }
      
      // --- 2. CORE LOGIC (Using your defined relationships) ---
      
      // The pieces that were already pulled for the job.
      final int previouslyDelivered = max(0, totalRequired - remainingPieces);
      
      // The pieces still required to complete the job. 
      final int neededToComplete = max(0, totalRequired - previouslyDelivered);
      
      // a. Calculate Boxes to Pick (Always round up the pieces needed)
      _boxesToPick = (neededToComplete / piecesPerBox).ceil();
      
      // b. Calculate Total Pieces to Pick (The actual number pulled in full boxes)
      final int piecesToPick = _boxesToPick * piecesPerBox; 
      
      // c. Calculate Total Order Delivered (The grand total of the job)
      _totalOrderDelivered = previouslyDelivered + piecesToPick;

      // d. Check for Partial Box (Partial pick required if we don't need a perfect multiple of a box)
      _requiresPartialBox = (neededToComplete % piecesPerBox != 0);

      // e. Calculate Overage Percentage
      if (totalRequired > 0) {
        // (Delivered - Required) / Required * 100
        _overagePercent = ((_totalOrderDelivered - totalRequired) / totalRequired) * 100;
      } else {
        _overagePercent = 0.0;
      }
    });
  }
  
  /// Helper method to build the New Order checkbox.
  Widget _buildNewOrderCheckbox() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: _isNewOrder,
            onChanged: (bool? newValue) {
              setState(() {
                _isNewOrder = newValue ?? false;
                
                if (_isNewOrder) {
                    // Set Remaining Pieces = Total Pieces
                    _remainingPiecesController.text = _totalPiecesController.text;
                } else {
                    // If unchecked (partial pick), clear the Remaining Pieces field for user input
                    _remainingPiecesController.text = ''; 
                }
              });
            },
          ),
          const Text('Same as Total'), 
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title based on the image
            Text('Box Calculator', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Please enter info:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            
            // --- INPUT FIELDS ---
            Form(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      // Total Pieces Required
                      Expanded(
                        child: _buildInputField(
                          controller: _totalPiecesController,
                          labelText: 'Total pieces',
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Remaining Pieces (already picked)
                      Expanded(
                        child: _buildInputField(
                          controller: _remainingPiecesController,
                          labelText: 'Remaining pieces',
                          enabled: !_isNewOrder, // Disable if 'New Order' is checked
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Pieces Per Box
                      Expanded(
                        child: _buildInputField(
                          controller: _piecesPerBoxController,
                          labelText: 'pieces/box',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), 
                  // Checkbox below the Remaining Pieces field
                  Row(
                    children: [
                      const SizedBox(width: 16 + 8), 
                      Expanded(child: Container()), 
                      _buildNewOrderCheckbox(), // Checkbox widget
                      const SizedBox(width: 16),
                      Expanded(child: Container()), 
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  // Calculate Button
                  ElevatedButton(
                    onPressed: _calculateMetrics,
                    child: const Text('Calculate Box Run'),
                  ),
                ],
              ),
            ),

            const Divider(height: 48),

            // --- OUTPUT FIELDS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // # Boxes to Pick (Calculated)
                _buildOutputField(label: '#Boxes', value: _boxesToPick.toString()),
                
                // Total Pieces to Pick (Calculated) with Partial Box Warning
                _buildOutputField(
                  label: 'total pieces to pick', 
                  value: _boxesToPick * (int.tryParse(_piecesPerBoxController.text) ?? 0) == 0 ? "0" : (_boxesToPick * (int.tryParse(_piecesPerBoxController.text) ?? 0)).toString(),
                  requiresWarning: _requiresPartialBox,
                ),
                
                // Total Pieces Delivered (Calculated)
                _buildOutputField(label: 'total pieces per order', value: _totalOrderDelivered.toString()),
              ],
            ),

            const SizedBox(height: 48),

            // Overage Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'This is imp:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_overagePercent.toStringAsFixed(2)}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(width: 8),
                Text(
                  'over original',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to create a standardized input field
 Widget _buildInputField({
  required TextEditingController controller,
  required String labelText,
  String? description, // New parameter for the helper text. This made it nullable and optional
  bool enabled = true,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.number,
    enabled: enabled,
    decoration: InputDecoration(
      labelText: labelText, // Keep this short (e.g., "Width")
      
      // The description goes here, outside the box
      helperText: description,
      helperMaxLines: 3, // Allows wrapping up to 3 lines
      
      labelStyle: Theme.of(context).textTheme.titleMedium,
      border: const OutlineInputBorder(),
    ),
  );
}


  /// Helper method to create a standardized output display box, with optional warning
  Widget _buildOutputField({
    required String label,
    required String value,
    bool requiresWarning = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: requiresWarning ? Colors.red : Colors.grey, // RED border if partial box is needed
                width: requiresWarning ? 3.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                if (requiresWarning) // Add text warning above the value
                  const Text('PARTIAL PICK REQUIRED!', 
                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)
                  ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
