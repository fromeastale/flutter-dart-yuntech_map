import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_solver_generator/sudoku_solver_generator.dart';

class Game9 extends StatefulWidget {
  const Game9({super.key});

  @override
  State<Game9> createState() => _Game9State();
}

class _Game9State extends State<Game9> {
  late List<List<int?>> puzzle;
  late List<List<bool>> isInitial;
  late List<List<Set<int>>> notes;
  int? selectedRow, selectedCol;
  bool noteMode = false;

  late DateTime startTime;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    final board = SudokuGenerator(emptySquares: 40).newSudoku;

    puzzle = List.generate(9, (i) => List.generate(9, (j) {
      final val = board[i][j];
      return val == 0 ? null : val;
    }));

    isInitial = List.generate(9, (i) => List.generate(9, (j) => puzzle[i][j] != null));
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    startTime = DateTime.now();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool isValid(int row, int col, int value) {
    for (int i = 0; i < 9; i++) {
      if ((puzzle[row][i] == value && i != col) ||
          (puzzle[i][col] == value && i != row)) {
        return false;
      }
    }

    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;

    for (int i = startRow; i < startRow + 3; i++) {
      for (int j = startCol; j < startCol + 3; j++) {
        if (puzzle[i][j] == value && (i != row || j != col)) return false;
      }
    }

    return true;
  }

  bool isBoardCompleteAndCorrect() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        final value = puzzle[row][col];
        if (value == null || !isValid(row, col, value)) return false;
      }
    }
    return true;
  }

  void setValue(int value) {
    if (selectedRow == null || selectedCol == null || isInitial[selectedRow!][selectedCol!]) return;

    if (noteMode) {
      setState(() {
        puzzle[selectedRow!][selectedCol!] = null;
        notes[selectedRow!][selectedCol!].contains(value)
            ? notes[selectedRow!][selectedCol!].remove(value)
            : notes[selectedRow!][selectedCol!].add(value);
      });
      return;
    }

    if (isValid(selectedRow!, selectedCol!, value)) {
      setState(() {
        puzzle[selectedRow!][selectedCol!] = value;
        notes[selectedRow!][selectedCol!] = <int>{};
      });

      if (isBoardCompleteAndCorrect()) {
        final duration = DateTime.now().difference(startTime);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("🎉 恭喜完成！"),
            content: Text("你花了 ${duration.inSeconds} 秒完成數獨挑戰"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text("返回主畫面"),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $value 不符合規則')),
      );
    }
  }

  void clearSelectedCell() {
    if (selectedRow == null || selectedCol == null || isInitial[selectedRow!][selectedCol!]) return;
    setState(() {
      puzzle[selectedRow!][selectedCol!] = null;
      notes[selectedRow!][selectedCol!] = <int>{};
    });
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (event) {
          if (event is RawKeyDownEvent) {
            final keyLabel = event.logicalKey.keyLabel;
            if (RegExp(r'^[1-9]$').hasMatch(keyLabel)) {
              setValue(int.parse(keyLabel));
            } else if (keyLabel == 'Backspace') {
              clearSelectedCell();
            }
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                "🧠 數獨挑戰",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: noteMode,
                    onChanged: (value) {
                      setState(() {
                        noteMode = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    noteMode ? '📝 筆記模式' : '✍️ 作答模式',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: noteMode ? Colors.purple : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width < 500
                        ? MediaQuery.of(context).size.width - 24
                        : 500,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 9,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: 81,
                        itemBuilder: (context, index) {
                          final row = index ~/ 9;
                          final col = index % 9;
                          final value = puzzle[row][col];
                          final selected = selectedRow == row && selectedCol == col;
                          final isNote = notes[row][col].isNotEmpty && value == null;
                          final isInit = isInitial[row][col];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRow = row;
                                selectedCol = col;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selected ? Colors.deepPurple : Colors.grey,
                                  width: selected ? 2.5 : 0.5,
                                ),
                                color: selected
                                    ? (noteMode ? Colors.purple.shade100 : Colors.deepPurple.shade100)
                                    : (row ~/ 3 + col ~/ 3) % 2 == 0
                                        ? Colors.white
                                        : Colors.grey.shade100,
                              ),
                              child: Center(
                                child: isNote
                                    ? Text(
                                        notes[row][col].take(4).join(', '),
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      )
                                    : Text(
                                        value?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isInit ? FontWeight.bold : FontWeight.normal,
                                          color: isInit ? Colors.black : Colors.deepPurple,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              buildNumberPadWrap(),
              const SizedBox(height: 12),
              buildClearButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
    Widget buildNumberPadWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(9, (i) {
        return SizedBox(
          width: 56,
          height: 56,
          child: ElevatedButton(
            onPressed: () => setValue(i + 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: noteMode ? Colors.purple.shade200 : Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: Text(
              '${i + 1}',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        );
      }),
    );
  }

  Widget buildClearButton() {
    return SizedBox(
      width: 180,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        onPressed: clearSelectedCell,
        child: const Text(
          "❌ 清除格子",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}