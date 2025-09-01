import 'package:_12sale_app/core/page/stock/StockDetail.dart';
import 'package:flutter/material.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:intl/intl.dart';

class ReusableTable extends StatefulWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final List<List<String>>? itemCodes;
  final List<String>? footer;
  final List<String>? footer2;

  const ReusableTable({
    super.key,
    required this.columns,
    required this.rows,
    this.itemCodes,
    this.footer,
    this.footer2,
  });

  @override
  State<ReusableTable> createState() => _ReusableTableState();
}

class _ReusableTableState extends State<ReusableTable> {
  // Vertical
  final ScrollController _vLeft = ScrollController();
  final ScrollController _vRight = ScrollController();

  // Horizontal
  final ScrollController _hHeader = ScrollController();
  final ScrollController _hBody = ScrollController();
  final ScrollController _hFooter1 = ScrollController();
  final ScrollController _hFooter2 = ScrollController();

  bool _syncingV = false;
  bool _syncingH = false;

  @override
  void initState() {
    super.initState();

    // Sync vertical (left <-> right)
    _vRight.addListener(() {
      if (_syncingV) return;
      _syncingV = true;
      if (_vLeft.hasClients && _vLeft.offset != _vRight.offset) {
        _vLeft.jumpTo(_vRight.offset);
      }
      _syncingV = false;
    });
    _vLeft.addListener(() {
      if (_syncingV) return;
      _syncingV = true;
      if (_vRight.hasClients && _vRight.offset != _vLeft.offset) {
        _vRight.jumpTo(_vLeft.offset);
      }
      _syncingV = false;
    });

    // Sync horizontal (whoever moves drives others)
    void syncFrom(ScrollController src) {
      if (_syncingH) return;
      _syncingH = true;
      for (final c in [_hHeader, _hBody, _hFooter1, _hFooter2]) {
        if (c == src) continue;
        if (c.hasClients && src.hasClients && c.offset != src.offset) {
          c.jumpTo(src.offset);
        }
      }
      _syncingH = false;
    }

    _hBody.addListener(() => syncFrom(_hBody)); // main driver (has X scrollbar)
    _hHeader.addListener(() => syncFrom(_hHeader));
    _hFooter1.addListener(() => syncFrom(_hFooter1));
    _hFooter2.addListener(() => syncFrom(_hFooter2));
  }

  @override
  void dispose() {
    _vLeft.dispose();
    _vRight.dispose();
    _hHeader.dispose();
    _hBody.dispose();
    _hFooter1.dispose();
    _hFooter2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    // กำหนดความกว้างคอลัมน์ตามต้องการ
    final col0Width = screenW * 0.30; // คอลัมน์ที่ 1 (กว้างหน่อย)
    final col1Width = screenW * 0.15; // คอลัมน์ที่ 2 (ใหม่: ถูกล็อคด้วย)
    final otherColWidth = screenW * 0.18; // คอลัมน์ถัด ๆ ไป

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================== HEADER (sticky) =====================
        Row(
          children: [
            // Header ซ้าย (คอลัมน์ที่ 1 และ 2) — ไม่เลื่อนแกน X
            Row(
              children: [
                _buildHeaderCell(_safeCol(0), col0Width, context),
                if (widget.columns.length > 1)
                  _buildHeaderCell(_safeCol(1), col1Width, context),
              ],
            ),

            // Header ขวา (คอลัมน์ที่ 3 เป็นต้นไป) — เลื่อนแกน X
            Expanded(
              child: SingleChildScrollView(
                controller: _hHeader,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.columns
                      .skip(2)
                      .map((c) => _buildHeaderCell(c, otherColWidth, context))
                      .toList(),
                ),
              ),
            ),
          ],
        ),

        const Divider(height: 1, color: Colors.black12),

        // ===================== BODY =====================
        Flexible(
          child: Row(
            children: [
              // ------- Frozen left (2 columns) — Y only -------
              // ไม่มี Scrollbar เพื่อลดปัญหา controller หลายตำแหน่ง
              SingleChildScrollView(
                controller: _vLeft,
                child: Column(
                  children: widget.rows.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = entry.value;
                    return InkWell(
                      onTap: () => _goToDetail(context, i),
                      child: Row(
                        children: [
                          _buildBodyCell(
                              _safeRowCell(row, 0), col0Width, context),
                          _buildBodyCell(
                              _safeRowCell(row, 1), col1Width, context),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ------- Scrollable right (X & Y) -------
              Expanded(
                child: Scrollbar(
                  controller: _hBody,
                  thumbVisibility: true, // แสดง X scrollbar ตรงนี้จุดเดียว
                  notificationPredicate: (n) =>
                      n.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _hBody,
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      controller: _vRight,
                      thumbVisibility: true, // แสดง Y scrollbar ตรงนี้จุดเดียว
                      notificationPredicate: (n) =>
                          n.metrics.axis == Axis.vertical,
                      child: SingleChildScrollView(
                        controller: _vRight,
                        child: Column(
                          children: widget.rows.asMap().entries.map((entry) {
                            final i = entry.key;
                            final row = entry.value;
                            return InkWell(
                              onTap: () => _goToDetail(context, i),
                              child: Row(
                                children: row
                                    .skip(2) // <<<<<<<< คอลัมน์ที่ 3 เป็นต้นไป
                                    .map((cell) => _buildBodyCell(
                                          cell,
                                          otherColWidth,
                                          context,
                                        ))
                                    .toList(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ===================== FOOTERS (optional, sync กับ X) =====================
        if (widget.footer != null)
          _buildFooterRow(
            widget.footer!,
            col0Width,
            col1Width,
            otherColWidth,
            context,
            controller: _hFooter1,
          ),
        if (widget.footer2 != null)
          _buildFooterRow(
            widget.footer2!,
            col0Width,
            col1Width,
            otherColWidth,
            context,
            controller: _hFooter2,
          ),
      ],
    );
  }

  // ---------- Helpers ----------
  String _safeCol(int idx) =>
      idx < widget.columns.length ? widget.columns[idx] : '';

  String _safeRowCell(List<String> row, int idx) =>
      idx < row.length ? row[idx] : '';

  void _goToDetail(BuildContext context, int rowIndex) {
    if (widget.itemCodes == null ||
        rowIndex < 0 ||
        rowIndex >= widget.itemCodes!.length ||
        widget.itemCodes![rowIndex].isEmpty) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetail(
          itemCode: widget.itemCodes![rowIndex][0],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.primaryColor,
        border: Border.all(color: Colors.black),
      ),
      width: width,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: Styles.white18(context).copyWith(fontWeight: FontWeight.bold),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBodyCell(String text, double width, BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.black)),
      ),
      width: width,
      height: 95,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        style: Styles.black18(context),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooterRow(
    List<String> cells,
    double col0Width,
    double col1Width,
    double otherColWidth,
    BuildContext context, {
    required ScrollController controller,
  }) {
    return Row(
      children: [
        _buildFooterCell(cells.isNotEmpty ? cells[0] : '', col0Width, context),
        _buildFooterCell(cells.length > 1 ? cells[1] : '', col1Width, context),
        Expanded(
          child: SingleChildScrollView(
            controller: controller, // sync กับ _hBody
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cells
                  .skip(2)
                  .map((cell) => _buildFooterCell(cell, otherColWidth, context))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterCell(String? text, double width, BuildContext context) {
    // แปลง text -> double อย่างปลอดภัย
    final number = double.tryParse(text ?? '');

    // ถ้า number != null แปลว่าเป็นตัวเลข => ฟอร์แมตเป็น "10,000"
    final formatted = number != null
        ? NumberFormat('#,##0', 'th_TH').format(
            number,
          )
        : text ?? '';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.grey[200],
      ),
      width: width,
      height: 56,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        formatted,
        style: Styles.black16(context).copyWith(fontWeight: FontWeight.bold),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
