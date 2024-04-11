import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid_button/flutter_grid_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MathOperator { add, minus, multiply, divide, none }

final leftOperandReferenceProvider = StateProvider((ref) => -1);
final rightOperandReferenceProvider = StateProvider((ref) => -1);
final operatorReferenceProvider = StateProvider((ref) => MathOperator.none);
final solutionReferenceProvider = StateProvider((ref) => "");


void main() {
  runApp(
    // Adding ProviderScope enables Riverpod for the entire project
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends ConsumerWidget {
  Home({super.key});
  final _focusNode = FocusNode(canRequestFocus: false, skipTraversal: true);

  Text answerText = Text("");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printToConsole('$this: Build');
    const textStyle = TextStyle(fontSize: 26);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('GridButton'),
        ),
        body: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: GridButton(
              textStyle: textStyle,
              borderColor: Colors.grey[300],
              borderWidth: 2,
              onPressed: (dynamic val) {
                _focusNode.requestFocus();
                rememberValueTapped(val, ref);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(val.toString()),
                    duration: const Duration(milliseconds: 400),
                  ),
                );
              },
              items: [
                [
                  GridButtonItem(
                    title: "Black",
                    color: Colors.black,
                    textStyle: textStyle.copyWith(color: Colors.white),
                  ),
                  GridButtonItem(
                    title: "Red",
                    color: Colors.red,
                    textStyle: textStyle.copyWith(color: Colors.white),
                  ),
                ],
                [
                  GridButtonItem(
                      title: ref.watch(solutionReferenceProvider),
                      focusNode: _focusNode,
                      textStyle: textStyle.copyWith(color: Colors.white),
                      value: 'image',
                      color: Colors.blue,
                      shape: const BorderSide(width: 4),
                      borderRadius: 30)
                ],
                [
                  const GridButtonItem(title: "7"),
                  const GridButtonItem(title: "8"),
                  const GridButtonItem(title: "9"),
                  GridButtonItem(title: "x", color: Colors.grey[300]),
                ],
                [
                  const GridButtonItem(title: "4"),
                  const GridButtonItem(title: "5"),
                  const GridButtonItem(title: "6"),
                  GridButtonItem(title: "-", color: Colors.grey[300]),
                ],
                [
                  const GridButtonItem(title: "1"),
                  const GridButtonItem(title: "2"),
                  const GridButtonItem(title: "3"),
                  GridButtonItem(title: "+", color: Colors.grey[300]),
                ],
                [
                  const GridButtonItem(title: "0"),
                  const GridButtonItem(
                      title: "000", flex: 2, longPressValue: 400),
                  GridButtonItem(title: "=", color: Colors.grey[300]),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  int? getNumeric(String input) {
    String source = input.trim();
    return int.tryParse(source);
  }

  printToConsole(String str) {
    if (kDebugMode) {
      print(str);
    }
  }

  void doMathOperation(WidgetRef ref) {

    int rightOperand = ref.read(rightOperandReferenceProvider.notifier).state;
    int leftOperand = ref.read(leftOperandReferenceProvider.notifier).state;
    MathOperator op = ref.read(operatorReferenceProvider.notifier).state;
    
    String answerString = "";
    switch (op) {
      case MathOperator.multiply:
        answerString = "$leftOperand * $rightOperand = ${leftOperand * rightOperand}";
        printToConsole("leftOperand ($leftOperand) * rightOperand ($rightOperand) = ${leftOperand * rightOperand}");
        break;
      case MathOperator.divide:
        answerString = "$leftOperand / $rightOperand = ${leftOperand / rightOperand}";
        printToConsole("leftOperand ($leftOperand) / rightOperand ($rightOperand) = ${leftOperand / rightOperand}");
        break;
      case MathOperator.add:
        answerString = "$leftOperand + $rightOperand = ${leftOperand + rightOperand}";
        printToConsole("leftOperand ($leftOperand) + rightOperand ($rightOperand) = ${leftOperand + rightOperand}");
        break;
      case MathOperator.minus:
        answerString = "$leftOperand - $rightOperand = ${leftOperand - rightOperand}";
        printToConsole("leftOperand ($leftOperand) - rightOperand ($rightOperand) = ${leftOperand - rightOperand}");
        break;
      case MathOperator.none:
        printToConsole("MathOperator.none");
        return;
      default:
    }
    ref.read(solutionReferenceProvider.notifier).state = answerString;
    ref.read(rightOperandReferenceProvider.notifier).state = -1;
    ref.read(leftOperandReferenceProvider.notifier).state = -1;
    ref.read(operatorReferenceProvider.notifier).state = MathOperator.none;
  }

  void rememberValueTapped(String valueTapped, WidgetRef ref) {
    MathOperator op = ref.read(operatorReferenceProvider.notifier).state;
    int? numberTapped = getNumeric(valueTapped);

    if (numberTapped == null) {
      switch (valueTapped) {
        case "x":
          ref.read(operatorReferenceProvider.notifier).state =
              MathOperator.multiply;
          break;
        case "/":
          ref.read(operatorReferenceProvider.notifier).state =
              MathOperator.divide;
          break;
        case "-":
          ref.read(operatorReferenceProvider.notifier).state =
              MathOperator.minus;
          break;
        case "+":
          ref.read(operatorReferenceProvider.notifier).state = MathOperator.add;
          break;
        case "=":
          doMathOperation(ref);
          ref.read(operatorReferenceProvider.notifier).state = MathOperator.none;
          break;

        default:
          ref.read(operatorReferenceProvider.notifier).state = MathOperator.none;
          break;
      }
    } else {
      int prevValue=0;
      if(op == MathOperator.none) {
        prevValue = ref.read(leftOperandReferenceProvider.notifier).state;
        if(prevValue != -1) {
          String newValue = "$prevValue$numberTapped";
          ref.read(leftOperandReferenceProvider.notifier).state = int.parse(newValue);
        } else {
          ref.read(leftOperandReferenceProvider.notifier).state = numberTapped;
        }
      } else {
        prevValue = ref.read(rightOperandReferenceProvider.notifier).state;
        if(prevValue != -1) {
          String newValue = "$prevValue$numberTapped";
          ref.read(rightOperandReferenceProvider.notifier).state = int.parse(newValue);
        } else {
          ref.read(rightOperandReferenceProvider.notifier).state = numberTapped;
        }
      }
      
    } 
  }
}
