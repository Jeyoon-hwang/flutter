import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';

/// PDF 뷰어 화면 with progressive rendering
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({Key? key}) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _pdfPath;
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = false;

  Future<void> _pickPdfFile() async {
    setState(() => _isLoading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pdfPath = result.files.single.path!;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF 파일을 불러올 수 없습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 뷰어'),
        actions: [
          if (_pdfPath != null) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _currentPage > 1
                  ? () => _pdfViewerController.previousPage()
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Center(
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _currentPage < _totalPages
                  ? () => _pdfViewerController.nextPage()
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () => _pdfViewerController.zoomLevel += 0.25,
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () => _pdfViewerController.zoomLevel -= 0.25,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _pickPdfFile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfPath == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.picture_as_pdf,
                        size: 100,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'PDF 파일을 선택하세요',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickPdfFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('PDF 열기'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SfPdfViewer.file(
                      _pdfPath!,
                      controller: _pdfViewerController,
                      // Progressive rendering with page load callback
                      onPageChanged: (PdfPageChangedDetails details) {
                        setState(() {
                          _currentPage = details.newPageNumber;
                        });
                      },
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        setState(() {
                          _totalPages = details.document.pages.count;
                        });
                      },
                      // Enable progressive loading
                      enableDoubleTapZooming: true,
                      enableTextSelection: true,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      pageSpacing: 4,
                    ),
                    // Loading indicator for page transitions
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
      floatingActionButton: _pdfPath != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Return PDF path to use as background
                Navigator.pop(context, _pdfPath);
              },
              icon: const Icon(Icons.check),
              label: const Text('배경으로 사용'),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
