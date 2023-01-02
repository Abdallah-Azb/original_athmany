import 'dart:convert';
import 'dart:developer';
import 'dart:io';

Socket socket;
Future<String> kitchenConfig({String ip, Map<String, dynamic> data}) {
  String _v = 'false';
  print("kitchenConfig data ============ ${data}");
  try {
    Socket.connect(ip, 4040).then((Socket sock) {
      print("🤖🤖 1 🤖🤖");
      socket = sock;
      print("🤖🤖 2 ${sock.address} , ${sock.port} 🤖🤖");
      socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
      print("🤖🤖 3 🤖🤖");
      // socket.encoding = utf8;
      socket.write(jsonEncode(data));
      print("🤖🤖 4 🤖🤖");
      _v = 'true';
    }).catchError((e) {
      print("Unable to connect: $e");

      _v = 'false';
    });

    stdin.listen((data) {
      print("===== Listen Data =======" + data.toString());
      // socket.encoding = utf8;
      socket.write(new String.fromCharCodes(data).trim() + '\n');
      socket.write("Writ to Socket");
      _v = 'true';
    });
  } catch (e) {
    _v = 'false';
  }
  return Future.value(_v);
}

var data;

void dataHandler(data) {
  log("===== data Habdler ====== $data");
  socket.write(jsonEncode(data));
}

void errorHandler(error, StackTrace trace) {
  print(error);
}

void doneHandler() {
  socket.destroy();
  exit(0);
}

// Map<String, dynamic> dataJson = {
//   "customer": "customer",
//   "table_number": "454545",
//   "pos_opening": "POS-OPE-2021-00608",
//   "casher": "77",
//   "order_status": "dinein",
//   "status": "New",
//   "time": "27-10-2021 11:47:19",
//   "order_number": "77",
//   "items": [
//     {
//       "item_code": "109000",
//       "item_name": "azab",
//       "is_sup": 0,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "1090",
//       "item_name": "azab1",
//       "is_sup": 0,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "234",
//       "item_name": "azab",
//       "is_sup": 0,
//       "is_custom": 1,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "1000",
//       "item_name": "azab",
//       "is_sup": 0,
//       "is_custom": 0,
//       "description": " withalipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "500",
//       "item_name": "azab",
//       "is_sup": 0,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "201",
//       "item_name": "azab",
//       "is_sup": 0,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "200",
//       "item_name": "azab2",
//       "is_sup": 0,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "400",
//       "item_name": "azab",
//       "is_sup": 1,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "98769",
//       "item_name": "azab",
//       "is_sup": 1,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     },
//     {
//       "item_code": "9876e9",
//       "item_name": "azab",
//       "is_sup": 1,
//       "is_custom": 0,
//       "description": " with alipeno ",
//       "qty": 1100,
//       "stock_uom": "Unit"
//     }
//
//   ]
// };
