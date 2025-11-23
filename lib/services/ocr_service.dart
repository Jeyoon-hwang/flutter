import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// Text block with position information for layout preservation
class TextBlock {
  final String text;
  final Offset position;
  final Size size;
  final double confidence;

  TextBlock({
    required this.text,
    required this.position,
    required this.size,
    required this.confidence,
  });
}

class OCRService {
  // Use Korean + Latin script for better recognition
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.korean,
  );

  // Fallback recognizer for Latin-only text
  final TextRecognizer _latinRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Pre-process image for better OCR accuracy
  /// Applies: contrast enhancement, noise reduction, and binarization
  Future<ui.Image> _preprocessImage(ui.Image image) async {
    try {
      // Convert ui.Image to image package format
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return image;

      final Uint8List bytes = byteData.buffer.asUint8List();
      img.Image? imgImage = img.decodeImage(bytes);
      if (imgImage == null) return image;

      // 1. Convert to grayscale for better text recognition
      imgImage = img.grayscale(imgImage);

      // 2. Increase contrast to make text clearer
      imgImage = img.adjustColor(imgImage, contrast: 1.3, brightness: 1.1);

      // 3. Apply slight sharpening to enhance edges
      imgImage = img.gaussianBlur(imgImage, radius: 1); // Reduce noise first
      imgImage = img.convolution(imgImage, [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0,
      ]); // Sharpen

      // 4. Adaptive thresholding (binarization) for cleaner text
      // Convert to black and white for better OCR
      imgImage = _adaptiveThreshold(imgImage);

      // Convert back to ui.Image
      final processedBytes = img.encodePng(imgImage);
      final codec = await ui.instantiateImageCodec(processedBytes);
      final frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      print('Error preprocessing image: $e');
      return image; // Return original if preprocessing fails
    }
  }

  /// Apply adaptive thresholding for binarization
  img.Image _adaptiveThreshold(img.Image image) {
    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    // Calculate local threshold for each pixel
    const blockSize = 15; // Size of local neighborhood
    const c = 10; // Constant subtracted from mean

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Calculate mean in local neighborhood
        int sum = 0;
        int count = 0;

        for (int dy = -blockSize ~/ 2; dy <= blockSize ~/ 2; dy++) {
          for (int dx = -blockSize ~/ 2; dx <= blockSize ~/ 2; dx++) {
            final nx = x + dx;
            final ny = y + dy;

            if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
              final pixel = image.getPixel(nx, ny);
              sum += pixel.r.toInt(); // Already grayscale, so r = g = b
              count++;
            }
          }
        }

        final mean = sum / count;
        final pixel = image.getPixel(x, y);
        final threshold = mean - c;

        // Binarize: white (255) if above threshold, black (0) otherwise
        final value = pixel.r > threshold ? 255 : 0;
        result.setPixelRgba(x, y, value, value, value, 255);
      }
    }

    return result;
  }

  Future<String> recognizeText(ui.Image image, {bool preprocess = true}) async {
    try {
      // Preprocess image for better accuracy
      final processedImage = preprocess ? await _preprocessImage(image) : image;

      // Convert ui.Image to InputImage
      final ByteData? byteData = await processedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return '';

      final Uint8List bytes = byteData.buffer.asUint8List();
      final InputImage inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(processedImage.width.toDouble(), processedImage.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: processedImage.width * 4,
        ),
      );

      // Try Korean recognizer first
      RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      String text = recognizedText.text;

      // If Korean recognizer doesn't find much, try Latin recognizer
      if (text.trim().isEmpty || text.length < 3) {
        recognizedText = await _latinRecognizer.processImage(inputImage);
        text = recognizedText.text;
      }

      // Post-processing: clean up common OCR errors
      text = _postProcessText(text);

      return text;
    } catch (e) {
      print('Error recognizing text: $e');
      return '';
    }
  }

  /// Post-process recognized text to fix common OCR errors
  String _postProcessText(String text) {
    String cleaned = text;

    // Fix common OCR confusions
    final corrections = {
      // Number/letter confusions
      r'\bO\b': '0',  // Letter O → Number 0 (in math contexts)
      r'\bl\b': '1',  // Lowercase L → Number 1 (in math contexts)
      r'\bS\b': '5',  // Letter S → Number 5 (in certain fonts)

      // Korean OCR common errors (if needed)
      '오': '0',  // Korean 오 sometimes confused with 0
      '일': '1',  // Korean 일 (one) to number

      // Math symbols
      'x': '×',  // Lowercase x might be multiplication
      '*': '×',  // Asterisk to proper multiplication symbol
    };

    // Apply corrections cautiously (only in math contexts)
    for (var entry in corrections.entries) {
      // Only apply if text looks like math
      if (isMathFormula(text)) {
        cleaned = cleaned.replaceAll(RegExp(entry.key), entry.value);
      }
    }

    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Recognize text with layout preservation
  /// Returns a list of text blocks with their positions in reading order
  Future<List<TextBlock>> recognizeTextWithLayout(
    ui.Image image,
    Rect selectionRect, {
    bool preprocess = true,
  }) async {
    try {
      // Preprocess image for better accuracy
      final processedImage = preprocess ? await _preprocessImage(image) : image;

      // Convert ui.Image to InputImage
      final ByteData? byteData = await processedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return [];

      final Uint8List bytes = byteData.buffer.asUint8List();
      final InputImage inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(processedImage.width.toDouble(), processedImage.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: processedImage.width * 4,
        ),
      );

      // Try both recognizers and merge results
      final recognizedTextKorean = await _textRecognizer.processImage(inputImage);
      final recognizedTextLatin = await _latinRecognizer.processImage(inputImage);

      final List<TextBlock> blocks = [];
      final Set<String> processedTexts = {}; // Avoid duplicates

      // Process Korean recognizer results
      for (final textBlock in recognizedTextKorean.blocks) {
        final blockRect = textBlock.boundingBox;

        // Check if text block is within selection
        if (blockRect.overlaps(selectionRect)) {
          final cleanedText = _postProcessText(textBlock.text);
          if (cleanedText.isNotEmpty && !processedTexts.contains(cleanedText)) {
            blocks.add(TextBlock(
              text: cleanedText,
              position: Offset(blockRect.left, blockRect.top),
              size: blockRect.size,
              confidence: _estimateConfidence(cleanedText),
            ));
            processedTexts.add(cleanedText);
          }
        }
      }

      // Add Latin results if they provide additional text
      for (final textBlock in recognizedTextLatin.blocks) {
        final blockRect = textBlock.boundingBox;

        if (blockRect.overlaps(selectionRect)) {
          final cleanedText = _postProcessText(textBlock.text);
          if (cleanedText.isNotEmpty && !processedTexts.contains(cleanedText)) {
            blocks.add(TextBlock(
              text: cleanedText,
              position: Offset(blockRect.left, blockRect.top),
              size: blockRect.size,
              confidence: _estimateConfidence(cleanedText),
            ));
            processedTexts.add(cleanedText);
          }
        }
      }

      // Sort blocks in reading order (top to bottom, left to right)
      blocks.sort((a, b) {
        // If roughly same vertical position (within 20px), sort by horizontal position
        if ((a.position.dy - b.position.dy).abs() < 20) {
          return a.position.dx.compareTo(b.position.dx);
        }
        // Otherwise sort by vertical position
        return a.position.dy.compareTo(b.position.dy);
      });

      return blocks;
    } catch (e) {
      print('Error recognizing text with layout: $e');
      return [];
    }
  }

  /// Estimate confidence score based on text characteristics
  double _estimateConfidence(String text) {
    double confidence = 0.8; // Base confidence

    // Higher confidence for longer text
    if (text.length > 10) confidence += 0.1;

    // Lower confidence for text with many special characters (likely errors)
    final specialCharCount = RegExp(r'[^a-zA-Z0-9가-힣\s\+\-\*\/\=\(\)]').allMatches(text).length;
    if (specialCharCount > text.length * 0.3) confidence -= 0.2;

    // Higher confidence for Korean text (script-specific recognizer)
    if (RegExp(r'[가-힣]').hasMatch(text)) confidence += 0.05;

    return confidence.clamp(0.0, 1.0);
  }

  bool isMathFormula(String text) {
    // Check if text contains mathematical symbols or patterns
    final mathPatterns = [
      r'\+', r'-', r'×', r'÷', r'/', r'=', r'\^',
      r'√', r'∫', r'∑', r'π', r'α', r'β', r'θ', r'γ', r'δ', r'ε',
      r'∞', r'≠', r'≤', r'≥', r'≈', r'≡',
      r'\d+\s*[+\-×÷*/=]\s*\d+', // Basic arithmetic
      r'[a-z]\s*[+\-×÷*/=]', // Variables
      r'\([^)]+\)', // Parentheses
      r'[a-z]\^[\d+]', // Exponents
      r'sin|cos|tan|log|ln|lim', // Functions
      r'\d+/\d+', // Fractions
      r'[a-z]_[0-9]', // Subscripts
    ];

    for (var pattern in mathPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  String convertToLaTeX(String text) {
    // Enhanced conversion to LaTeX format
    String latex = text;

    // Replace common symbols
    latex = latex.replaceAll('×', r'\times ');
    latex = latex.replaceAll('÷', r'\div ');
    latex = latex.replaceAll('≠', r'\neq ');
    latex = latex.replaceAll('≤', r'\leq ');
    latex = latex.replaceAll('≥', r'\geq ');
    latex = latex.replaceAll('≈', r'\approx ');
    latex = latex.replaceAll('≡', r'\equiv ');
    latex = latex.replaceAll('∞', r'\infty ');
    latex = latex.replaceAll('π', r'\pi ');
    latex = latex.replaceAll('√', r'\sqrt');
    latex = latex.replaceAll('∫', r'\int ');
    latex = latex.replaceAll('∑', r'\sum ');
    latex = latex.replaceAll('α', r'\alpha ');
    latex = latex.replaceAll('β', r'\beta ');
    latex = latex.replaceAll('γ', r'\gamma ');
    latex = latex.replaceAll('θ', r'\theta ');
    latex = latex.replaceAll('δ', r'\delta ');
    latex = latex.replaceAll('ε', r'\epsilon ');

    // Handle fractions (improved pattern)
    latex = latex.replaceAllMapped(
      RegExp(r'(\d+|\([^)]+\))\s*/\s*(\d+|\([^)]+\))'),
      (match) => r'\frac{' + match.group(1)! + '}{' + match.group(2)! + '}',
    );

    // Handle exponents (improved pattern with parentheses support)
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+|\([^)]+\))\^(\d+|\([^)]+\))'),
      (match) => match.group(1)! + '^{' + match.group(2)! + '}',
    );

    // Handle subscripts
    latex = latex.replaceAllMapped(
      RegExp(r'(\w+)_(\d+|\w+)'),
      (match) => match.group(1)! + '_{' + match.group(2)! + '}',
    );

    // Handle square root (improved pattern)
    latex = latex.replaceAllMapped(
      RegExp(r'sqrt\(([^)]+)\)'),
      (match) => r'\sqrt{' + match.group(1)! + '}',
    );

    // Handle trigonometric functions
    latex = latex.replaceAllMapped(
      RegExp(r'\b(sin|cos|tan|cot|sec|csc)\s*\(([^)]+)\)'),
      (match) => '\\' + match.group(1)! + '(' + match.group(2)! + ')',
    );

    // Handle logarithms
    latex = latex.replaceAllMapped(
      RegExp(r'\b(log|ln)\s*\(([^)]+)\)'),
      (match) => '\\' + match.group(1)! + '(' + match.group(2)! + ')',
    );

    // Handle limits
    latex = latex.replaceAllMapped(
      RegExp(r'lim\s*\(([^)]+)\)'),
      (match) => r'\lim_{' + match.group(1)! + '}',
    );

    // Handle summation with bounds
    latex = latex.replaceAllMapped(
      RegExp(r'sum\s*\(([^,]+),([^,]+),([^)]+)\)'),
      (match) => r'\sum_{' + match.group(1)! + '=' + match.group(2)! + '}^{' + match.group(3)! + '}',
    );

    // Clean up extra spaces
    latex = latex.replaceAll(RegExp(r'\s+'), ' ').trim();

    return latex;
  }

  Future<Map<String, dynamic>> processHandwriting(ui.Image image, {bool preprocess = true}) async {
    final text = await recognizeText(image, preprocess: preprocess);
    final isMath = isMathFormula(text);
    final latex = isMath ? convertToLaTeX(text) : '';

    return {
      'text': text,
      'isMath': isMath,
      'latex': latex,
      'confidence': _estimateConfidence(text),
      'language': _detectLanguage(text),
    };
  }

  /// Detect primary language of text
  String _detectLanguage(String text) {
    if (RegExp(r'[가-힣]').hasMatch(text)) {
      return 'ko'; // Korean
    } else if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      return 'en'; // English
    } else if (RegExp(r'[\d+\-*/=()]').hasMatch(text)) {
      return 'math'; // Mathematics
    }
    return 'unknown';
  }

  void dispose() {
    _textRecognizer.close();
    _latinRecognizer.close();
  }
}
