import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';

import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/tables/models/table.dart';
import 'package:app/modules/tables/provider/tables.provider.dart';
import 'package:app/providers/home.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../res.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../../../core/extensions/widget_extension.dart';
class TablesCategoryPage extends StatefulWidget {
  const TablesCategoryPage({Key key}) : super(key: key);

  @override
  _TablesCategoryPageState createState() => _TablesCategoryPageState();
}

class _TablesCategoryPageState extends State<TablesCategoryPage> {
  Future tablesCategoryFuture;
  DBDineInTables _dbDineInTables = DBDineInTables();

  Future<List<TableCategory>> getTablesCategories() async {
    List<TableCategory> tableCategoryList = [];
    List<TableModel> tables = await _dbDineInTables.getAllTables();
    List<String> allCategories = [];
    for (TableModel table in tables) {
      allCategories.add(table.category);
    }
    List<String> uniqueCategores = allCategories.toSet().toList();
    for (String category in uniqueCategores) {
      TableCategory tableCategory = TableCategory();
      tableCategory.category = category;
      tableCategory.totalOfTables =
          tables.where((e) => e.category == category).length;
      tableCategory.reservedTables =
          tables.where((e) => e.category == category && e.reserved == 1).length;
      tableCategoryList.add(tableCategory);
    }
    print("🍟🍟 total of Tables is 🍟🍟 ${tables.length}");
    return tableCategoryList;
  }

  @override
  void initState() {
    super.initState();
    this.tablesCategoryFuture = this.getTablesCategories();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return FutureBuilder<List<TableCategory>>(
      future: this.tablesCategoryFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<TableCategory>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          return Container(
              alignment: Alignment.center,
              color: isDarkMode == false ? lightGrayColor : Color(0xff1F1F1F),
              child: items(snapshot.data));
        }
        return Center(
          child: LoadingAnimation(
            typeOfAnimation: "staggeredDotsWave",
            color: themeColor,
            size: 100,
          ),
        );
      },
    );
  }

  // items menu
  Widget items(List<TableCategory> tableCategoryList) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 10 / 10,
            scrollDirection: Axis.vertical,
            children: List.generate(tableCategoryList.length, (index) {
              return Center(
                child: Column(
                  children: [categoryContainer(tableCategoryList[index])],
                ),
              );
            }),
          )

        // ==== Mobile ===
        : GridView.count(
            crossAxisCount: 3,
            // childAspectRatio: 10 / 20,
            scrollDirection: Axis.vertical,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            children: List.generate(tableCategoryList.length, (index) {
              return Center(
                child: Column(
                  children: [categoryContainer(tableCategoryList[index])],
                ),
              );
            }) ,
          ).paddingAllNormal();
  }

  Widget categoryContainer(TableCategory tableCategory) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color:
                      tableCategory.reservedTables < tableCategory.totalOfTables
                          ? themeColor
                          : Colors.black54,
                  borderRadius: BorderRadius.circular(16)),
              width: 300,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tableCategory.category,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: Image.asset(
                      'assets/table.png',
                      scale: 0.4,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "${tableCategory.reservedTables.toString()}/${tableCategory.totalOfTables.toString()}",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))
                    ],
                  )
                ],
              ),
              // child: ,
            ),
            onTap: () {
              context
                  .read<TablesProvider>()
                  .setSelectedCategory(tableCategory.category);
              context.read<HomeProvider>().setMainIndex(3);
            },
          )
        // ==== mobile ===
        : InkWell(
            child: Container(
              decoration: BoxDecoration(
                  color:
                      tableCategory.reservedTables < tableCategory.totalOfTables
                          ? themeColor
                          : Colors.black54,
                  borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    tableCategory.category,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Container(
                    child: Image.asset(
                      Res.table,
                      scale: 1,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "${tableCategory.reservedTables.toString()}/${tableCategory.totalOfTables.toString()}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white))
                    ],
                  )
                ],
              ),
              // child: ,
            ),
            onTap: () {
              context
                  .read<TablesProvider>()
                  .setSelectedCategory(tableCategory.category);
              context.read<HomeProvider>().setMainIndex(3);
            },
          );
  }
}

class TableCategory {
  String category;
  int totalOfTables;
  int reservedTables;

  TableCategory({this.category, this.totalOfTables, this.reservedTables});
}
