import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';
import '../models/text_object.dart';

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({Key? key}) : super(key: key);

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;
  TextType _currentType = TextType.normal;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentType = _tabController.index == 0 ? TextType.normal : TextType.latex;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DrawingProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: provider.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with tabs
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '텍스트 입력',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            provider.cancelTextInput();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: '일반 텍스트'),
                      Tab(text: 'LaTeX 수식'),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Text input field
                  Container(
                    decoration: BoxDecoration(
                      color: provider.isDarkMode
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: provider.isDarkMode
                            ? const Color(0xFF404040)
                            : const Color(0xFFE0E0E0),
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: _currentType == TextType.latex ? 4 : 3,
                      style: TextStyle(
                        fontSize: 16,
                        color: provider.isDarkMode ? Colors.white : Colors.black,
                        fontFamily: _currentType == TextType.latex ? 'Courier' : null,
                      ),
                      decoration: InputDecoration(
                        hintText: _currentType == TextType.latex
                            ? 'LaTeX 수식을 입력하세요\n예: x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}'
                            : '텍스트를 입력하세요',
                        hintStyle: TextStyle(
                          color: provider.isDarkMode ? Colors.white38 : Colors.black38,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Preview
                  if (_controller.text.isNotEmpty) ...[
                    Text(
                      '미리보기:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: provider.isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: provider.isDarkMode
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: _currentType == TextType.latex
                          ? _buildLatexPreview()
                          : Text(
                              _controller.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: provider.isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // LaTeX quick insert buttons
                  if (_currentType == TextType.latex) ...[
                    Text(
                      '빠른 입력:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: provider.isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickButton(r'\frac{}{}', '분수'),
                        _buildQuickButton(r'\sqrt{}', '제곱근'),
                        _buildQuickButton(r'^{}', '지수'),
                        _buildQuickButton(r'_{}', '아래첨자'),
                        _buildQuickButton(r'\pi', 'π'),
                        _buildQuickButton(r'\pm', '±'),
                        _buildQuickButton(r'\times', '×'),
                        _buildQuickButton(r'\div', '÷'),
                        _buildQuickButton(r'\leq', '≤'),
                        _buildQuickButton(r'\geq', '≥'),
                        _buildQuickButton(r'\neq', '≠'),
                        _buildQuickButton(r'\sum', 'Σ'),
                        _buildQuickButton(r'\int', '∫'),
                        _buildQuickButton(r'\alpha', 'α'),
                        _buildQuickButton(r'\beta', 'β'),
                        _buildQuickButton(r'\theta', 'θ'),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            provider.cancelTextInput();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: provider.isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : const Color(0xFFF5F5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: provider.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _controller.text.trim().isEmpty
                              ? null
                              : () {
                                  provider.addTextObject(
                                    _controller.text.trim(),
                                    type: _currentType,
                                  );
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF667EEA),
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '추가',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatexPreview() {
    try {
      return Math.tex(
        _controller.text,
        textStyle: TextStyle(
          fontSize: 18,
          color: context.read<DrawingProvider>().isDarkMode ? Colors.white : Colors.black,
        ),
        mathStyle: MathStyle.display,
      );
    } catch (e) {
      return Text(
        '수식 오류: ${e.toString()}',
        style: const TextStyle(color: Colors.red, fontSize: 14),
      );
    }
  }

  Widget _buildQuickButton(String latex, String label) {
    return GestureDetector(
      onTap: () {
        final cursorPos = _controller.selection.baseOffset;
        final text = _controller.text;
        final newText = text.substring(0, cursorPos) + latex + text.substring(cursorPos);
        _controller.text = newText;
        _controller.selection = TextSelection.collapsed(
          offset: cursorPos + latex.length,
        );
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
