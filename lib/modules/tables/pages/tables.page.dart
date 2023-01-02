import 'package:app/core/utils/utils.dart';
import 'package:app/modules/tables/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/widget/provider/theme_provider.dart';

import '../../../widget/widget/loading_animation_widget.dart';
import '../tables.dart';
import '../../../core/extensions/widget_extension.dart';
class TablesPage extends StatelessWidget {
  const TablesPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Page();
  }
}

class _Page extends StatefulWidget {
  @override
  __PageState createState() => __PageState();
}

class __PageState extends State<_Page> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TableModel>>(
      future: context
          .read<TablesProvider>()
          .getTables(context.read<TablesProvider>().selectedCategory),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Container();
        }
        if (snapshot.hasData) {
          return _PageLayout(tables: snapshot.data);
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
}

class _PageLayout extends StatelessWidget {
  const _PageLayout({
    Key key,
    @required this.tables,
  }) : super(key: key);

  final List tables;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      color: isDarkMode == false ? mainBlueColor : Color(0xff1F1F1F),
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: tables.map(_mapTables).toList(),
        ),
      ).paddingAll(20),
    );
  }

  TableContainer _mapTables(table) => TableContainer(table: table);
}
