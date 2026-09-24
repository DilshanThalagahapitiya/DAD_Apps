// ============================================================
// Simple HTML view
// ============================================================
// Renders the small, sanitized HTML subset the Terms & Conditions backend
// produces (src/lib/terms.ts allows h1-h6, p, br, hr, div, span, section,
// strong/b, em/i, u, s, blockquote, ul/ol/li and a). No third-party package:
// the tag set is fixed and small, so a focused parser keeps the app light.
//
// Anything unknown is rendered as plain text, so nothing is ever lost.
// ============================================================

import 'package:flutter/material.dart';

/// Block-level kinds the parser understands.
enum _BlockType { heading1, heading2, heading3, paragraph, listItem, quote, divider }

class _Block {
  final _BlockType type;
  final List<TextSpan> spans;
  final bool ordered;
  final int index;

  _Block(this.type, this.spans, {this.ordered = false, this.index = 0});
}

/// Renders [html] as a scrollable-agnostic column of Flutter text.
class SimpleHtmlView extends StatelessWidget {
  final String html;
  /// Extra style applied to every block (e.g. a smaller font in a preview box).
  final TextStyle? baseStyle;
  /// Caps how many blocks are shown (used by the compact signup preview).
  final int? maxBlocks;

  const SimpleHtmlView({
    super.key,
    required this.html,
    this.baseStyle,
    this.maxBlocks,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final blocks = _parseSimpleHtml(html, scheme.primary);
    final shown = maxBlocks == null ? blocks : blocks.take(maxBlocks!).toList();

    if (shown.isEmpty) {
      return Text('—', style: baseStyle);
    }

    final children = <Widget>[];
    for (var i = 0; i < shown.length; i++) {
      final block = shown[i];
      if (i > 0) children.add(SizedBox(height: _gapBefore(block)));

      switch (block.type) {
        case _BlockType.divider:
          children.add(Divider(color: scheme.outlineVariant));
        case _BlockType.heading1:
        case _BlockType.heading2:
        case _BlockType.heading3:
          children.add(Text.rich(
            TextSpan(children: block.spans),
            style: (_headingStyle(block.type)).merge(baseStyle),
          ));
        case _BlockType.quote:
          children.add(Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: scheme.outlineVariant, width: 3)),
            ),
            child: Text.rich(
              TextSpan(children: block.spans),
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ));
        case _BlockType.listItem:
          children.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  block.ordered ? '${block.index}.' : '•',
                  style: TextStyle(fontSize: 13.5, height: 1.5, color: scheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: block.spans),
                  style: const TextStyle(fontSize: 13.5, height: 1.5),
                ),
              ),
            ],
          ));
        case _BlockType.paragraph:
          children.add(Text.rich(
            TextSpan(children: block.spans),
            style: const TextStyle(fontSize: 13.5, height: 1.5),
          ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  double _gapBefore(_Block block) {
    switch (block.type) {
      case _BlockType.heading1:
      case _BlockType.heading2:
      case _BlockType.heading3:
        return 16;
      case _BlockType.listItem:
        return 4;
      default:
        return 10;
    }
  }

  TextStyle _headingStyle(_BlockType type) {
    switch (type) {
      case _BlockType.heading1:
        return const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.3);
      case _BlockType.heading2:
        return const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, height: 1.3);
      default:
        return const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.3);
    }
  }
}

// ============================================================
// Minimal HTML parser (sanitized terms subset)
// ============================================================

class _ListCtx {
  final bool ordered;
  int counter = 0;
  _ListCtx(this.ordered);
}

class _Run {
  final StringBuffer text;
  final TextStyle style;
  _Run(String initial, this.style) : text = StringBuffer(initial);
}

/// Parses the sanitized HTML subset into renderable blocks.
List<_Block> _parseSimpleHtml(String html, Color linkColor) {
  final blocks = <_Block>[];
  final runs = <_Run>[]; // inline runs of the block being built
  var blockType = _BlockType.paragraph;
  final listStack = <_ListCtx>[];

  // Inline style state (nested tags add up)
  var bold = 0, italic = 0, underline = 0, strike = 0, link = 0;

  TextStyle runStyle() => TextStyle(
        fontWeight: bold > 0 ? FontWeight.w700 : null,
        fontStyle: italic > 0 ? FontStyle.italic : null,
        decoration: _decoration(underline > 0, strike > 0),
        color: link > 0 ? linkColor : null,
      );

  void addText(String raw) {
    if (raw.isEmpty) return;
    var text = _decodeEntities(raw);
    // HTML collapses runs of whitespace
    text = text.replaceAll(RegExp(r'[ \t\r\n]+'), ' ');
    // Leading whitespace at the start of a block is dropped
    if (runs.isEmpty) text = text.replaceFirst(RegExp(r'^ +'), '');
    if (text.isEmpty) return;

    final last = runs.isEmpty ? null : runs.last;
    final style = runStyle();
    if (last != null && last.style == style) {
      last.text.write(text);
    } else {
      runs.add(_Run(text, style));
    }
  }

  void addLineBreak() {
    if (runs.isEmpty) runs.add(_Run('', runStyle()));
    runs.last.text.write('\n');
  }

  void flushBlock() {
    if (runs.isEmpty) return;
    // Trim the trailing space and drop empty runs
    final cleaned = <TextSpan>[];
    for (var i = 0; i < runs.length; i++) {
      var text = runs[i].text.toString();
      if (i == runs.length - 1) text = text.replaceFirst(RegExp(r' +$'), '');
      if (text.isEmpty) continue;
      cleaned.add(TextSpan(text: text, style: runs[i].style));
    }
    runs.clear();
    if (cleaned.isNotEmpty) {
      final ctx = blockType == _BlockType.listItem && listStack.isNotEmpty ? listStack.last : null;
      blocks.add(_Block(
        blockType,
        cleaned,
        ordered: ctx?.ordered ?? false,
        index: ctx?.counter ?? 0,
      ));
    }
  }

  void startBlock(_BlockType type) {
    flushBlock();
    blockType = type;
  }

  void handleTag(String rawTag) {
    if (rawTag.startsWith('<!--')) return;
    final closing = rawTag.startsWith('</');
    final name = RegExp(r'^</?\s*([a-zA-Z0-9]+)').firstMatch(rawTag)?.group(1)?.toLowerCase();
    if (name == null) return;

    switch (name) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        if (closing) {
          flushBlock();
        } else {
          startBlock(switch (name) {
            'h1' => _BlockType.heading1,
            'h2' => _BlockType.heading2,
            _ => _BlockType.heading3,
          });
        }
      case 'p':
      case 'div':
      case 'section':
        if (closing) {
          flushBlock();
        } else {
          startBlock(_BlockType.paragraph);
        }
      case 'blockquote':
        if (closing) {
          flushBlock();
        } else {
          startBlock(_BlockType.quote);
        }
      case 'ul':
      case 'ol':
        flushBlock();
        if (closing) {
          if (listStack.isNotEmpty) listStack.removeLast();
        } else {
          listStack.add(_ListCtx(name == 'ol'));
        }
      case 'li':
        if (closing) {
          flushBlock();
        } else {
          if (listStack.isEmpty) listStack.add(_ListCtx(false));
          listStack.last.counter++;
          startBlock(_BlockType.listItem);
        }
      case 'br':
        addLineBreak();
      case 'hr':
        flushBlock();
        blocks.add(_Block(_BlockType.divider, const []));
      case 'strong':
      case 'b':
        bold += closing ? -1 : 1;
      case 'em':
      case 'i':
        italic += closing ? -1 : 1;
      case 'u':
        underline += closing ? -1 : 1;
      case 's':
      case 'strike':
      case 'del':
        strike += closing ? -1 : 1;
      case 'a':
        link += closing ? -1 : 1;
      default:
        // Unknown tag: ignore it — its text still renders
        break;
    }
  }

  final tagRe = RegExp(r'<[^>]*>');
  var cursor = 0;
  for (final match in tagRe.allMatches(html)) {
    if (match.start > cursor) addText(html.substring(cursor, match.start));
    handleTag(match.group(0)!);
    cursor = match.end;
  }
  if (cursor < html.length) addText(html.substring(cursor));
  flushBlock();

  return blocks;
}

TextDecoration? _decoration(bool underline, bool strike) {
  if (underline && strike) {
    return TextDecoration.combine([TextDecoration.underline, TextDecoration.lineThrough]);
  }
  if (underline) return TextDecoration.underline;
  if (strike) return TextDecoration.lineThrough;
  return null;
}

const Map<String, String> _entities = {
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'nbsp': ' ',
  'ndash': '–',
  'mdash': '—',
  'lsquo': '\u2018',
  'rsquo': '\u2019',
  'ldquo': '\u201C',
  'rdquo': '\u201D',
  'hellip': '…',
  'bull': '•',
  'middot': '·',
  'copy': '©',
  'reg': '®',
  'trade': '™',
  'deg': '°',
  'times': '×',
  'euro': '€',
  'pound': '£',
  'rupee': '₹',
};

/// Turns HTML entities (&amp;, &#39;, &#x27;, …) into real characters.
String _decodeEntities(String input) => input.replaceAllMapped(
      RegExp(r'&(#x?[0-9a-fA-F]+|[a-zA-Z]+);'),
      (m) {
        final entity = m.group(1)!;
        if (entity.startsWith('#x') || entity.startsWith('#X')) {
          final code = int.tryParse(entity.substring(2), radix: 16);
          return code == null ? m.group(0)! : String.fromCharCode(code);
        }
        if (entity.startsWith('#')) {
          final code = int.tryParse(entity.substring(1));
          return code == null ? m.group(0)! : String.fromCharCode(code);
        }
        return _entities[entity.toLowerCase()] ?? m.group(0)!;
      },
    );
