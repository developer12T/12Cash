import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class CampaignDetail extends StatefulWidget {
  final String filePath; // พาธของไฟล์ PDF

  const CampaignDetail({Key? key, required this.filePath}) : super(key: key);

  @override
  State<CampaignDetail> createState() => _CampaignDetailState();
}

class _CampaignDetailState extends State<CampaignDetail> {
  int? _totalPages = 0;
  int? _currentPage = 0;
  bool pdfReady = false;
  late PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview PDF'),
        actions: [
          if (pdfReady && _totalPages != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('${_currentPage! + 1} / $_totalPages'),
              ),
            ),
        ],
      ),
      body: PDFView(
        filePath: widget.filePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onRender: (_pages) {
          setState(() {
            _totalPages = _pages;
            pdfReady = true;
          });
        },
        onViewCreated: (PDFViewController vc) {
          _pdfViewController = vc;
        },
        onPageChanged: (int? page, int? total) {
          setState(() {
            _currentPage = page;
          });
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading PDF: $error')));
        },
        onPageError: (page, error) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error on page $page: $error')));
        },
      ),
      floatingActionButton: pdfReady
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: "prev",
                  child: Icon(Icons.chevron_left),
                  onPressed: () async {
                    int prevPage = (_currentPage ?? 0) - 1;
                    if (prevPage >= 0) {
                      await _pdfViewController.setPage(prevPage);
                    }
                  },
                ),
                SizedBox(width: 12),
                FloatingActionButton(
                  heroTag: "next",
                  child: Icon(Icons.chevron_right),
                  onPressed: () async {
                    int nextPage = (_currentPage ?? 0) + 1;
                    if (nextPage < (_totalPages ?? 0)) {
                      await _pdfViewController.setPage(nextPage);
                    }
                  },
                ),
              ],
            )
          : null,
    );
  }
}
