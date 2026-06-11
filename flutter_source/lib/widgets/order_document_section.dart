import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../models/order.dart';
import '../utils/order_pdf_generator.dart';

class OrderDocumentSection extends StatefulWidget {
  final OrderModel order;
  final List<LineItemModel> lineItems;

  const OrderDocumentSection({
    super.key,
    required this.order,
    required this.lineItems,
  });

  @override
  State<OrderDocumentSection> createState() => _OrderDocumentSectionState();
}

class _OrderDocumentSectionState extends State<OrderDocumentSection> {
  static const _attachmentName = 'purchase_order_6642.pdf';
  static const _previewName = 'PO_M30_Ref.pdf';

  final _previewKey = GlobalKey();
  PdfController? _pdfController;
  Uint8List? _pdfBytes;
  bool _loading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  double _zoom = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      final supplier = widget.order.id == '2323135'
          ? "James O' Malley Global Sourcing Ltd."
          : widget.order.supplierName;

      final bytes = await generateOrderPdf(
        orderId: widget.order.id,
        projectId: widget.order.projectIdFull,
        supplier: supplier,
      );

      final controller = PdfController(
        document: PdfDocument.openData(bytes),
        initialPage: 1,
      );

      if (!mounted) return;
      setState(() {
        _pdfBytes = bytes;
        _pdfController = controller;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load document preview';
        _loading = false;
      });
    }
  }

  double get _subtotal =>
      widget.lineItems.fold(0.0, (sum, item) => sum + item.extendedCost);

  double get _tax => _subtotal * 0.05;

  double get _total => _subtotal + _tax;

  Future<void> _downloadPdf() async {
    if (_pdfBytes == null) return;

    try {
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              _pdfBytes!,
              name: _previewName,
              mimeType: 'application/pdf',
            ),
          ],
          subject: 'Purchase Order ${widget.order.id}',
          text: 'Purchase order document for Order #${widget.order.id}',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download failed. Please try again.'),
          backgroundColor: JLWColors.buttonReject,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _scrollToPreview() {
    final context = _previewKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }

  void _goToPage(int page) {
    final controller = _pdfController;
    if (controller == null) return;
    controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        _sectionLabel('ATTACHMENTS'),
        const SizedBox(height: 10),
        _buildAttachmentCard(),
        const SizedBox(height: 20),
        _sectionLabel('DOCUMENT PREVIEW'),
        const SizedBox(height: 10),
        Container(
          key: _previewKey,
          decoration: BoxDecoration(
            color: JLWColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: JLWColors.borderColor),
          ),
          child: Column(
            children: [
              _buildPreviewToolbar(),
              Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: JLWColors.inputBg,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: _buildPreviewBody(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // const Divider(color: JLWColors.borderColor, height: 1),
        // const SizedBox(height: 16),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.end,
        //   children: [
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           const Text(
        //             'TAX (5.0%)',
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 11,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //           const SizedBox(height: 4),
        //           Text(
        //             '${fmt.format(_tax)} AED',
        //             style: const TextStyle(
        //               color: Colors.white,
        //               fontSize: 16,
        //               fontWeight: FontWeight.w800,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //     Expanded(
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.end,
        //         children: [
        //           const Text(
        //             'TOTAL PAYABLE AMOUNT',
        //             style: TextStyle(
        //               color: JLWColors.mintAccent,
        //               fontSize: 9,
        //               fontWeight: FontWeight.w700,
        //               letterSpacing: 0.5,
        //             ),
        //           ),
        //           const SizedBox(height: 6),
        //           Container(
        //             width: double.infinity,
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 12,
        //               vertical: 10,
        //             ),
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(8),
        //               border: Border.all(color: JLWColors.mintAccent, width: 1.5),
        //             ),
        //             child: Text(
        //               '${fmt.format(_total)} AED',
        //               textAlign: TextAlign.center,
        //               style: const TextStyle(
        //                 color: JLWColors.mintAccent,
        //                 fontSize: 20,
        //                 fontWeight: FontWeight.w800,
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: JLWColors.slateText,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildAttachmentCard() {
    final sizeLabel =
        _pdfBytes != null ? formatFileSize(_pdfBytes!.length) : '428 KB';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: JLWColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: JLWColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3D1515),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Color(0xFFE57373),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _attachmentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sizeLabel • PDF Document',
                  style: const TextStyle(
                    color: JLWColors.slateText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: JLWColors.inputBg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _scrollToPreview,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: JLWColors.borderColor),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: JLWColors.borderColor)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.picture_as_pdf,
            color: Color(0xFFE57373),
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _previewName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: JLWColors.inputBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: JLWColors.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toolbarIconButton(
                  icon: Icons.chevron_left,
                  onTap: _currentPage > 1
                      ? () => _goToPage(_currentPage - 1)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '$_currentPage / $_totalPages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _toolbarIconButton(
                  icon: Icons.chevron_right,
                  onTap: _currentPage < _totalPages
                      ? () => _goToPage(_currentPage + 1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _toolbarIconButton(
            icon: Icons.zoom_in,
            onTap: () {
              setState(() {
                _zoom = (_zoom + 0.25).clamp(1.0, 2.5);
              });
            },
          ),
          _toolbarIconButton(
            icon: Icons.download_outlined,
            onTap: _pdfBytes != null ? _downloadPdf : null,
          ),
        ],
      ),
    );
  }

  Widget _toolbarIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: onTap != null ? Colors.white70 : JLWColors.slateText,
        ),
      ),
    );
  }

  Widget _buildPreviewBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: JLWColors.mintAccent,
          strokeWidth: 2,
        ),
      );
    }

    if (_error != null || _pdfController == null) {
      return Center(
        child: Text(
          _error ?? 'Preview unavailable',
          style: const TextStyle(color: JLWColors.slateText, fontSize: 13),
        ),
      );
    }

    return Transform.scale(
      scale: _zoom,
      alignment: Alignment.topCenter,
      child: PdfView(
        controller: _pdfController!,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
        },
        onDocumentLoaded: (document) {
          setState(() => _totalPages = document.pagesCount);
        },
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(
              color: JLWColors.mintAccent,
              strokeWidth: 2,
            ),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(
              color: JLWColors.mintAccent,
              strokeWidth: 2,
            ),
          ),
          errorBuilder: (_, __) => const Center(
            child: Text(
              'Failed to render page',
              style: TextStyle(color: JLWColors.slateText),
            ),
          ),
        ),
        scrollDirection: Axis.vertical,
        backgroundDecoration: const BoxDecoration(color: JLWColors.inputBg),
      ),
    );
  }
}
