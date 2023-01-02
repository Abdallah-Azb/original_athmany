import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/models/models.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.old.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as Localization;
import 'package:app/core/enums/doc.status.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io' as Io;
import 'package:auto_size_text/auto_size_text.dart';
import '../../core/extensions/widget_extension.dart';

class PrintInvoiceElements {
  Future<Widget> logoForPrint(ProfileDetails posProfileDetails) async {
    if (posProfileDetails.posLogo == null) {
      return logo('assets/pos-black-logo.jpg');
    } else {
      if (posProfileDetails.posLogo != null &&
          posProfileDetails.posLogo != '') {
        String localPath = await CacheItemImageService().localPath;
        print('local path' + localPath);

        Io.File file = Io.File('$localPath/invoice-logo.png');
        return logoFromFile(file);
      } else {
        return logo('assets/pos-black-logo.jpg');
      }
    }
  }

  Widget logo(String url) {
    return Container(
      color: Colors.white,
      child: Image.asset(
        url,
        scale: 0.6,
        width: 100,
        height: 100,
      ),
    );
  }

  Widget logoFromFile(Io.File imageFile) {
    return Container(
      height: 100,
      width: 420,
      color: Colors.white,
      child: Image.file(
        imageFile,
        // scale: 1,
        height: 100,
        width: 420,
        // height: 200,
      ),
    );
  }

// company name
  Widget compnayNameAndBranchName(String companyName, String branchName) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText('$companyName',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          AutoSizeText('$branchName',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// branch name
  Widget branchName(String branchName) {
    return Text(branchName,
        style: TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold));
  }

// branch name
  Widget address(String address) {
    return Container(
      width: 380,
      color: Colors.white,
      child: Text(address,
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold))
          .paddingHorizontally(20),
    );
  }

// vat no
  Widget vatNo(String taxId, {double width}) {
    return Text('رقم تسجيل ضريبة القيمة المضافة: $taxId',
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget offlineInvoice(String offlineInvoice,
      {bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Column(
        children: [
          Text('رقم الفاتورة',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text('$offlineInvoice',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }

  Widget title() {
    return Text("فاتورة ضريبية مبسطة",
        style: TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold));
  }

  Widget ClosingTitle() {
    return Text("Z REPORT",
        style: TextStyle(
            color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold));
  }

  Widget StockTitle() {
    return Text("تقرير الأصناف",
        style: TextStyle(
            color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold));
  }

  Widget PaymentsTitle() {
    return Text("المبيعات حسب طرق الدفع",
        style: TextStyle(
            color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold));
  }

// cashier name & posting date
  Widget cashierNameAndPostingDate(String fullName, String dateTime) {
    return Container(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text('تاريخ اصدار الفاتورة: ',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(
                "${Localization.DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.parse(dateTime))}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ).paddingAll(6);
  }

  Widget cashierNameAndPostingDateClosing(String fullName, String dateTime) {
    return Container(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text('تاريخ اصدار التقرير: ',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(
                "${Localization.DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.parse(dateTime))}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ).paddingAll(6),
    );
  }

// invoice status & order type
  Widget invoiceStatusAndOrderType(DOCSTATUS docstatus, int tableNo) {
    String invoiceStatus = docstatus == DOCSTATUS.SAVED ? 'UnPaid' : 'Paid';
    String orderType = tableNo == null ? 'Takeaway' : 'Dine in $tableNo';
    return Container(
      color: Colors.white,
      child: Text('$invoiceStatus | $orderType',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold))
          .paddingAll(6),
    );
  }

// customer name
  Widget customerName(String customerName) {
    return Container(
      color: Colors.white,
      child: Text(customerName,
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  Widget closingInvoice() {
    return Container(
      color: Colors.white,
      child: Text('ـــــــــ اغلاق الفاتورة ـــــــــ',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget RateTitleAR() {
    return Container(
        color: Colors.white,
        child: Text('يسعدنا تقييمك عبر مسح الرمز:',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)));
  }

  Widget RateTitleEN() {
    return Container(
      color: Colors.white,
      child: Text('Kindly rate us by scanning the following barcode',
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget eInvoice() {
    return Container(
      color: Colors.white,
      child: Text('الفاتورة الإلكترونية',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

// order no
  Widget orderNo(int orderNo) {
    return Container(
      color: Colors.white,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 10),
        width: 200,
        height: 50,
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
        child: Text('#$orderNo',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold))
            .paddingAll(6),
      ),
    );
  }

// table header
  Widget tableHeader(
      {bool price: true, bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 2,
              child: Text('الكمية',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          Flexible(
            flex: 6,
            fit: FlexFit.tight,
            child: Text(
              'الصنف',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              maxLines: 10,
              textAlign: TextAlign.start,
            ),
          ),
          Flexible(
              flex: 2,
              child: Text(
                price ? 'السعر' : '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget ClosingTableHeader(
      {bool price: true, bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Text(
              'اسم العميل',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              maxLines: 10,
              textAlign: TextAlign.start,
            ),
          ),
          Flexible(
              flex: 5,
              child: Text('رقم الفاتورة',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          Flexible(
              flex: 2,
              child: Text(
                price ? 'الاجمالي' : '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget StockTableHeader(
      {bool price: true, bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
              flex: 4,
              child: Text('اسم الصنف',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          Flexible(
              flex: 4,
              child: Text(
                price ? 'الكمية' : '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
          Flexible(
              flex: 2,
              child: Text(
                price ? 'الاجمالي' : '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget stockGroupTableHeader(
      {bool price: true, bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
              flex: 4,
              child: Text('اسم الفئة',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          Flexible(
              flex: 4,
              child: Text(
                price ? 'الكمية' : '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
          Flexible(
              flex: 2,
              child: Text(
                price ? 'الاجمالي' : '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget TableClosingItem(String itemName, String customer, double amount,
      {bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      // padding: EdgeInsets.symmetric(vertical: 6),
      width: smallPrinter ? 230 : 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Text(customer,
                    maxLines: 10,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              Flexible(
                  flex: 6,
                  child: Text("X${itemName}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: smallPrinter ? 20 : 18,
                          fontWeight: FontWeight.bold))),
              Flexible(
                  flex: 2,
                  child: Text(amount == null ? '' : amount.toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  Widget modeOfPaymentTableHeader(
      {bool price: true, bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
              flex: 4,
              child: Text('طريفة الدفع',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          Flexible(
              flex: 4,
              child: Text(
                price ? 'الاجمالي' : '',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget closeParamsDetails(String title, String value,
      {bool price: true, bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
              flex: 4,
              // ND => No Data
              child: Text('$title' ?? "ND",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
          Flexible(
              flex: 4,
              child: Text(
                // ND => No Data
                '$value' ?? "ND",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  Widget TableModeOfPaymentsItem(String type, double amount,
      {bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      // padding: EdgeInsets.symmetric(vertical: 6),
      width: smallPrinter ? 230 : 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 4,
                  child: Text("${type}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: smallPrinter ? 20 : 18,
                          fontWeight: FontWeight.bold))),
              Flexible(
                  flex: 4,
                  child: Text("${amount}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: smallPrinter ? 20 : 18,
                          fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  Widget TableStockItem(String itemName, double qty, double baseTotal,
      {bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      // padding: EdgeInsets.symmetric(vertical: 6),
      width: smallPrinter ? 230 : 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 4,
                  child: Text("${itemName}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: smallPrinter ? 20 : 18,
                          fontWeight: FontWeight.bold))),
              Flexible(
                  flex: 4,
                  child: Text("${qty}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: smallPrinter ? 20 : 18,
                          fontWeight: FontWeight.bold))),
              Flexible(
                  flex: 2,
                  child: Text(
                      baseTotal == null ? '' : baseTotal.toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

// table item row
  Widget tableItemRow(String itemName, int qty,
      {double price,
      bool smallPrinter: false,
      List<ItemOption> itemOptions,
      double width}) {
    return Container(
      color: Colors.white,
      // padding: EdgeInsets.symmetric(vertical: 6),
      width: smallPrinter ? 230 : width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 2,
                  child: Text("X${qty}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: smallPrinter ? 20 : 18,
                          fontWeight: FontWeight.bold))),
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: Text(itemName,
                    maxLines: 10,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              Flexible(
                  flex: 2,
                  child: Text(price == null ? '' : price.toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ],
          ),
          for (ItemOption itemOptoin in itemOptions)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 2,
                    child: Text('',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ))),
                Flexible(
                  flex: 6,
                  fit: FlexFit.tight,
                  child: Text(
                      itemOptoin.optionWith == 1
                          ? "إضافة ${itemOptoin.itemName}"
                          : "بدون ${itemOptoin.itemName}",
                      maxLines: 10,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      )),
                ),
                price == null
                    ? Container()
                    : Flexible(
                        flex: 2,
                        child: Text(
                            itemOptoin.optionWith == 1
                                ? (itemOptoin.priceListRate * qty)
                                    .toStringAsFixed(2)
                                : '0.00',
                            style: TextStyle(
                              color: itemOptoin.optionWith == 1
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 16,
                            ))),
              ],
            ),
        ],
      ),
    );
  }

// table fotter
  Widget tableFotter(
      bool includedInPrintRate, InvoiceTotal invoiceTotal, int totalOfItems,
      {bool smallPrinter: false, double width}) {
    return Container(
      color: Colors.white,
      width: smallPrinter ? 230 : width,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 5,
                    child: Text('الإجمالي بدون الضريبة',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                Flexible(
                    flex: 5,
                    child: Text(
                      (invoiceTotal.total - invoiceTotal.vat)
                          .toStringAsFixed(2),
                      // invoiceTotal.total.toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 5,
                    child: Text('ضريبة القيمة المضافة 15%',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                Flexible(
                    flex: 5,
                    child: Text(
                      invoiceTotal.vat.toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            includedInPrintRate
                ? Container()

                // Commented for now , requested by abu mohammad - 9 Jan
                // ? Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Flexible(
                //           flex: 7,
                //           child: Text('* السعر شامل الضريبة',
                //               style: TextStyle(
                //                   color: Colors.black,
                //                   fontSize: 18,
                //                   fontWeight: FontWeight.bold))),
                //       Flexible(
                //           flex: 3,
                //           child: Text(
                //             '',
                //             style: TextStyle(
                //                 color: Colors.black,
                //                 fontSize: 20,
                //                 fontWeight: FontWeight.bold),
                //           )),
                //     ],
                //   )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 7,
                    child: Text('الاجمالي شامل ضريبة القيمة المضافة',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                Flexible(
                    flex: 3,
                    child: Text(
                      invoiceTotal.totalWithVat.toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            Divider(
              thickness: 2,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 3,
                    child: Text('عدد الأصناف',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold))),
                Flexible(
                    flex: 7,
                    child: Text(
                      totalOfItems.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            // Container(
            //   color: Colors.white,
            //   child: Text(
            //       'ـــــــــــــــــــ اغلاق الفاتورة ـــــــــــــــــــ',
            //       style: TextStyle(
            //           color: Colors.black,
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold)),
            // ),
            // 'ــــــــــــــــــــــــــــــــــ اغلاق الفاتورة ــــــــــــــــــــــــــــــــــ',
            // Divider(
            //   thickness: 2,
            //   color: Colors.black,
            // ),
          ],
        ),
      ),
    );
  }

// invoice refernce no
  Widget referenceNoAndPrintTime(String refNo, {bool smallPrinter: false}) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'وقت الطباعة',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
              Localization.DateFormat('yyyy-MM-dd – kk:mm:ss')
                  .format(DateTime.now()),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: 5,
          ),
          // Row(
          //   children: [Text(">>>>>>>> اغلاق الفاتورة <<<<<<<<")],
          // )
        ],
      ),
    );
  }

  Widget ClosingGrandTotal(double grandTotal, {bool smallPrinter: false}) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الإجمالي',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            grandTotal.toStringAsFixed(2),
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget StockTotalDetails(ClosingData closingData,
      {bool smallPrinter: false}) {
    return Container(
      // grandTotal, netTotal, posTransaction
      width: smallPrinter ? 230 : 420,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: Text(
                  'اجمالي عدد الفواتير',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  closingData.posTransactions.length.toString(),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: Text(
                  'اجمالي المبيعات',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  closingData.grandTotal.toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: Text(
                  'اجمالي الضريبة',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${(closingData.grandTotal - closingData.netTotal).toStringAsFixed(2)}' ??
                      '',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 8,
                child: Text(
                  'صافي المبيعات',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  closingData.netTotal.toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget cashierName(String name, {bool smallPrinter: false}) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الكاشير',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            '$name',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // cashier name & posting date
  Widget kitchenNameAndPostingDate(String fullName, String dateTime) {
    return Container(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Text('تاريخ اصدار الفاتورة: ',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(
                "$fullName | ${Localization.DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.parse(dateTime))}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ).paddingAll(6),
    );
  }

// divider
  Widget divider() {
    return Container(
      color: Colors.white,
      width: 420,
      height: 10,
      child: Divider(
        thickness: 1.5,
        color: Colors.black,
      ),
    );
  }

  // divider
  Widget QrDivider() {
    return Container(
      color: Colors.white,
      width: 420,
      height: 10,
      child: Divider(
        thickness: 14,
        color: Colors.black,
      ),
    );
  }

// qr code
  Widget qrCode(String invoiceRef, {String baseUrl, String data}) {
    return Container(
      // width: 200,
      // height: 200,
      child: Container(
        color: Colors.white,
        child: CustomPaint(
          size: Size.square(200.0),
          painter: QrPainter(
            data: data == null
                ? "$baseUrl/invoice?invoice_re=$invoiceRef&type=pos"
                : data,
            version: QrVersions.auto,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xff128760),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Color(0xff1a5441),
            ),
            embeddedImageStyle: QrEmbeddedImageStyle(
              size: Size.square(60),
            ),
          ),
        ),
      ),
    );
  }

  String tlvData(
    String company,
    String taxId,
    String invoicePostingDate,
    InvoiceTotal invoiceTotal,
  ) {
    BytesBuilder bytesBuilder = BytesBuilder();

    bytesBuilder.addByte(1);
    List<int> sellerNameBytes = utf8.encode(company);
    bytesBuilder.addByte(sellerNameBytes.length);
    bytesBuilder.add(sellerNameBytes);

    bytesBuilder.addByte(2);
    List<int> vatReg = utf8.encode(taxId);
    bytesBuilder.addByte(vatReg.length);
    bytesBuilder.add(vatReg);

    bytesBuilder.addByte(3);
    List<int> timeStamp = utf8.encode(invoicePostingDate);
    bytesBuilder.addByte(timeStamp.length);
    bytesBuilder.add(timeStamp);

    bytesBuilder.addByte(4);
    List<int> invoiceTotalVat =
        utf8.encode(invoiceTotal.totalWithVat.toStringAsFixed(2));
    bytesBuilder.addByte(invoiceTotalVat.length);
    bytesBuilder.add(invoiceTotalVat);

    bytesBuilder.addByte(5);
    List<int> vatTotal = utf8.encode(invoiceTotal.vat.toStringAsFixed(2));
    bytesBuilder.addByte(vatTotal.length);
    bytesBuilder.add(vatTotal);

    Uint8List qrCodeAsBytes = bytesBuilder.toBytes();
    print("bites ${bytesBuilder}");
    final Base64Codec base64Codec = Base64Codec();

    return base64Codec.encode(qrCodeAsBytes);
  }
}
