import 'package:app/core/utils/utils.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/provider/new.opening.provider.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../../widget/widget/loading_animation_widget.dart';

class NewOpeningPage extends StatefulWidget {
  final bool goBack;
  NewOpeningPage(this.goBack);

  @override
  _NewOpeningPageState createState() => _NewOpeningPageState();
}

class _NewOpeningPageState extends State<NewOpeningPage> {
  Future companiesListFuture;
  OpeningRepositoryRefactor _openingRepositoryRefactor =
      OpeningRepositoryRefactor();

  @override
  void initState() {
    super.initState();
    companiesListFuture = _openingRepositoryRefactor.getCompaniesList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ChangeNotifierProvider<NewOpeningProvider>(
      create: (context) => NewOpeningProvider(),
      child: Consumer<NewOpeningProvider>(
        builder: (context, model, child) => LoadingOverlay(
          opacity: 0.3,
          color: themeColor,
          isLoading: model.loading,
          progressIndicator: LoadingAnimation(
            typeOfAnimation: "staggeredDotsWave",
            color: themeColor,
            size: 100,
          ),
          child: Scaffold(
            backgroundColor: isDarkMode == false ? Colors.white : appBarColor,
            body: Center(
              child: FutureBuilder(
                future: companiesListFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text("none");
                      break;
                    case ConnectionState.waiting:
                      return LoadingAnimation(
                        typeOfAnimation: "staggeredDotsWave",
                        color: themeColor,
                        size: 100,
                      );
                      break;
                    case ConnectionState.active:
                      return Text("active");
                      break;
                    case ConnectionState.done:
                      if (snapshot.hasError) return Text("error");
                      if (snapshot.data == null || snapshot.data == '')
                        // Bandar fix
                        return Text("NO COMPANIES FOUND");
                      else
                        return Container(
                          width: 720,
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              NewOpeningHeader(
                                goBack: widget.goBack,
                              ),
                              SelectCompany(
                                companiesList: snapshot.data,
                              ),
                              SizedBox(height: 20),
                              SelectProfile(),
                              SizedBox(height: 20),
                              OpeningBalanceList(),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(child: CreateOpeningButtion()),
                                  Expanded(child: CancelOpeningButton())
                                ],
                              ),
                            ],
                          ),
                        );
                      break;
                    default:
                      return LoadingAnimation(
                        typeOfAnimation: "staggeredDotsWave",
                        color: themeColor,
                        size: 100,
                      );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackButton extends StatelessWidget {
  const BackButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 80,
        width: 50,
        alignment: Alignment.center,
        // color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/back.png',
              scale: 2.5,
            ),
            SizedBox(
              width: 12,
            ),
            // Text('Back',
            //     style: TextStyle(
            //       fontSize: 22,
            //       height: 2,
            //     )),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushReplacementNamed(context, '/opening-list');
      },
    );
  }
}
