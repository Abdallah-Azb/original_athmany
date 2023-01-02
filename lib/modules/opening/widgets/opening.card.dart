import 'dart:convert';
import 'dart:math';

import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.customer.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/opening/pages/invalid.opening.page.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/services/db.service.dart';
import 'package:app/services/profile.service.refactor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:app/widget/provider/theme_provider.dart';
import '../../../res.dart';
import '../opening.dart';
import '../../../core/enums/type_mobile.dart';
import '../../../providers/type_mobile_provider.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:vector_math/vector_math.dart' as r;
import '../../../core/extensions/widget_extension.dart';


class OpeningCard extends StatefulWidget {
  final OpeningDetails openingDetails;
  final Function showLoadingOverlay;
  const OpeningCard({
    Key key,
    this.openingDetails,
    this.showLoadingOverlay,
  }) : super(key: key);

  @override
  State<OpeningCard> createState() => _OpeningCardState();
}

class _OpeningCardState extends State<OpeningCard> {
  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    DateTime periodStartDate =
        DateTime.parse(this.widget.openingDetails.periodStartDate);
    return typeMobile == TYPEMOBILE.TABLET
        ? InkWell(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                  color: isDarkMode ? darkContainerColor : lightGrayColor,
                  borderRadius: BorderRadius.all(Radius.circular(14))),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        StoreIcon(),
                        SizedBox(
                          width: 20,
                        ),
                        OpeningItem(
                            openingDetails: widget.openingDetails,
                            periodStartDate: periodStartDate),
                      ],
                    ),
                  ),
                  ResumeButton(
                    openingDetails: widget.openingDetails,
                  )
                ],
              ).paddingAll(20),
            ),
            onTap: () async {
              print("Hi ");
              print(_permissionGranted);
              print(locationData);

              ProfileServiceRefactor _profileServiceRefactor =
                  ProfileServiceRefactor();
              print(widget.openingDetails.profile);
              print(widget.openingDetails.company);

              Profile profile = Profile(
                  value: widget.openingDetails.profile, description: "");
              Company company = Company(
                  value: widget.openingDetails.company, description: "");
              try {
                double distance;
                widget.showLoadingOverlay(true);

                var dat = await _profileServiceRefactor.getProfileDetails2(
                    profile, company);
                if (dat['message']['location'] != null &&
                    dat['message']['location'] != '') {
                  print('===================== dat ================  ' +
                      dat['message']['location']);

                  var profileDetailsLocation = await _profileServiceRefactor
                      .getProfileDetailsLocation(dat['message']['location']);

                  print("==== Location ==== BOOODY " +
                      profileDetailsLocation.toString());

                  print("==== Location ====" +
                      (profileDetailsLocation['message']['location'])
                          .toString());
                  var data =
                      jsonDecode(profileDetailsLocation['message']['location']);
                  print(data['features'][0]['geometry']['coordinates'][0]);
                  double lng = double.parse(data['features'][0]['geometry']
                          ['coordinates'][0]
                      .toString());
                  double lat = double.parse(data['features'][0]['geometry']
                          ['coordinates'][1]
                      .toString());

                  print("=== lat ==== ${lat}");
                  print("=== lng ==== ${lng}");

                  distance = await getDistance(lat, lng) ?? 0.0;
                  if (distance > 1000) {
                    widget.showLoadingOverlay(false);

                    Fluttertoast.showToast(
                        msg: Localization.of(context).tr('out_border'),
                        backgroundColor: Colors.red,
                        fontSize: 20,
                        toastLength: Toast.LENGTH_LONG,
                        textColor: Colors.white);
                  } else {
                    widget.showLoadingOverlay(true);
                    try {
                      // DBCustomer().getAll();
                      // print("openDetails : ${openingDetails}");
                      // await OpeningRepositoryRefactor()
                      //     .handleOpening(widget.openingDetails);
                      await OpeningRepositoryRefactor().handleOpening(
                          widget.openingDetails,
                          cachItmesImages: true);
                      InvalidOpeningDetails invalidOpeningDetails =
                          await OpeningRepositoryRefactor()
                              .validateOpening(widget.openingDetails.profile);
                      if (invalidOpeningDetails.invalidData.firstWhere(
                              (e) => e.invalidItems.length > 0,
                              orElse: () => null) !=
                          null) {
                        await DBService()
                            .dropTablesForSync(db, deleteOpeningDetails: true);
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                InvalidOpeningPage(
                                    invalidOpeningDetails:
                                        invalidOpeningDetails),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        await OpeningRepositoryRefactor()
                            .getOpeningResumeData();
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                Home(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      }
                    } on Failure catch (e, stackTrace) {
                      await Sentry.captureException(
                        e,
                        stackTrace: stackTrace,
                      );
                      toast(e.message, Colors.red);
                    } finally {
                      widget.showLoadingOverlay(false);
                    }
                  }
                } else {
                  widget.showLoadingOverlay(true);

                  try {
                    // await OpeningRepositoryRefactor()
                    //     .handleOpening(widget.openingDetails);
                    await OpeningRepositoryRefactor().handleOpening(
                        widget.openingDetails,
                        cachItmesImages: true);
                    InvalidOpeningDetails invalidOpeningDetails =
                        await OpeningRepositoryRefactor()
                            .validateOpening(widget.openingDetails.profile);
                    if (invalidOpeningDetails.invalidData.firstWhere(
                            (e) => e.invalidItems.length > 0,
                            orElse: () => null) !=
                        null) {
                      await DBService()
                          .dropTablesForSync(db, deleteOpeningDetails: true);

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              InvalidOpeningPage(
                                  invalidOpeningDetails: invalidOpeningDetails),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      await OpeningRepositoryRefactor().getOpeningResumeData();

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              Home(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    }
                  } on Failure catch (e, stackTrace) {
                    print("e : ${e} & StackTrace : ${stackTrace}");
                    await Sentry.captureException(
                      e,
                      stackTrace: stackTrace,
                    );
                    toast(e.message, Colors.red);
                  } finally {
                    widget.showLoadingOverlay(false);
                  }
                }
              } catch (e, stackTrace) {
                print("e : ${e} & StackTrace : ${stackTrace}");
                await Sentry.captureException(
                  e,
                  stackTrace: stackTrace,
                );
                print("CATCH  " + e.toString());
              }
            },
          )
        : InkWell(
            onTap: () async {
              ProfileServiceRefactor _profileServiceRefactor =
                  ProfileServiceRefactor();
              print(widget.openingDetails.profile);
              print(widget.openingDetails.company);

              Profile profile = Profile(
                  value: widget.openingDetails.profile, description: "");
              Company company = Company(
                  value: widget.openingDetails.company, description: "");
              try {
                double distance;
                widget.showLoadingOverlay(true);

                var dat = await _profileServiceRefactor.getProfileDetails2(
                    profile, company);
                if (dat['message']['location'] != null &&
                    dat['message']['location'] != '') {
                  print('===================== dat ================  ' +
                      dat['message']['location']);

                  var profileDetailsLocation = await _profileServiceRefactor
                      .getProfileDetailsLocation(dat['message']['location']);

                  print("==== Location ==== BOOODY " +
                      profileDetailsLocation.toString());

                  print("==== Location ====" +
                      (profileDetailsLocation['message']['location'])
                          .toString());
                  var data =
                      jsonDecode(profileDetailsLocation['message']['location']);
                  print(data['features'][0]['geometry']['coordinates'][0]);
                  double lng = double.parse(data['features'][0]['geometry']
                          ['coordinates'][0]
                      .toString());
                  double lat = double.parse(data['features'][0]['geometry']
                          ['coordinates'][1]
                      .toString());

                  print("=== lat ==== ${lat}");
                  print("=== lng ==== ${lng}");

                  distance = await getDistance(lat, lng) ?? 0.0;

                  if (distance > 1000) {
                    widget.showLoadingOverlay(false);

                    Fluttertoast.showToast(
                        msg: Localization.of(context).tr('out_border'),
                        backgroundColor: Color(0xff6CBF9B),
                        textColor: Colors.white);
                  } else {
                    widget.showLoadingOverlay(true);
                    try {
                      // await OpeningRepositoryRefactor()
                      //     .handleOpening(widget.openingDetails);
                      await OpeningRepositoryRefactor().handleOpening(
                          widget.openingDetails,
                          cachItmesImages: true);
                      InvalidOpeningDetails invalidOpeningDetails =
                          await OpeningRepositoryRefactor()
                              .validateOpening(widget.openingDetails.profile);
                      if (invalidOpeningDetails.invalidData.firstWhere(
                              (e) => e.invalidItems.length > 0,
                              orElse: () => null) !=
                          null) {
                        await DBService()
                            .dropTablesForSync(db, deleteOpeningDetails: true);

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                InvalidOpeningPage(
                                    invalidOpeningDetails:
                                        invalidOpeningDetails),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        await OpeningRepositoryRefactor()
                            .getOpeningResumeData();

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                Home(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      }
                    } on Failure catch (e) {
                      toast(e.message, Colors.red);
                    } finally {
                      widget.showLoadingOverlay(false);
                    }
                  }
                } else {
                  widget.showLoadingOverlay(true);

                  try {
                    // await OpeningRepositoryRefactor()
                    // .handleOpening(widget.openingDetails);
                    await OpeningRepositoryRefactor().handleOpening(
                        widget.openingDetails,
                        cachItmesImages: true);
                    InvalidOpeningDetails invalidOpeningDetails =
                        await OpeningRepositoryRefactor()
                            .validateOpening(widget.openingDetails.profile);
                    if (invalidOpeningDetails.invalidData.firstWhere(
                            (e) => e.invalidItems.length > 0,
                            orElse: () => null) !=
                        null) {
                      await DBService()
                          .dropTablesForSync(db, deleteOpeningDetails: true);

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              InvalidOpeningPage(
                                  invalidOpeningDetails: invalidOpeningDetails),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      await OpeningRepositoryRefactor().getOpeningResumeData();

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              Home(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    }
                  } on Failure catch (e) {
                    toast(e.message, Colors.red);
                  } finally {
                    widget.showLoadingOverlay(false);
                  }
                }
              } catch (e, stackTrace) {
                print("mobile e : ${e} & mobile StackTrace : ${stackTrace}");
                await Sentry.captureException(
                  e,
                  stackTrace: stackTrace,
                );
                print("CATCH  " + e.toString());
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // color: isDarkMode ? greyColor : lightGrayColor,
                color: isDarkMode ? darkContainerColor : lightGrayColor,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // =-=- Logo -=-=-
                        Container(
                          width: 55,
                          height: 55,
                          child: Image.asset(
                            Res.store,
                          ),
                          decoration: BoxDecoration(
                            color: orangeColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(14)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: Text(
                                widget.openingDetails.profile,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: Text(
                                widget.openingDetails.company,
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black54,
                                    height: 1.5),
                              ),
                            ),
                            Text(
                              DateFormat(
                                      '${widget.openingDetails.name} - yyyy-MM-dd – kk:mm')
                                  .format(periodStartDate),
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ).paddingAll(10),
            ).paddingVertical(8),
          );
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  PermissionStatus _permissionGranted;
  LocationData locationData;

  Future<LocationData> getCurrentLocation() async {
    Location location = new Location();
    bool _serviceEnabled;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        // return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {
      locationData = _locationData;
    });
    print(locationData.latitude.toString() + "===== LOCATION =======");
    return locationData;
  }

  Future<double> getDistance(pLat, pLng) async {
    await getCurrentLocation();
    var dLat = r.radians(pLat - locationData.latitude);
    var dLng = r.radians(pLng - locationData.longitude);
    double earthRadius = 6371000;

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(r.radians(locationData.latitude)) *
            cos(r.radians(pLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = earthRadius * c;
    // double value = d/1000 ;
    print(d.toString() +
        "====== The Distance ======"); //d is the distance in meters
    return d;
  }
}

class ResumeButton extends StatelessWidget {
  final OpeningDetails openingDetails;
  const ResumeButton({
    Key key,
    this.openingDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return Row(
      children: [
        // Container(
        //     alignment: Alignment.center,
        //     width: 120,
        //     height: 50,
        //     decoration: BoxDecoration(
        //       color: isDarkMode ? appBarColor2 : Colors.white,
        //       borderRadius:
        //           Localization.of(context).locale == Locale('ar', 'SA')
        //               ? BorderRadius.only(
        //                   topLeft: Radius.circular(6),
        //                   bottomLeft: Radius.circular(6),
        //                 )
        //               : BorderRadius.only(
        //                   topLeft: Radius.circular(6),
        //                   bottomLeft: Radius.circular(6),
        //                 ),
        //     ),
        //     child: Text(Localization.of(context).tr('resume'),
        //         style: TextStyle(
        //           fontSize: 18,
        //           color: isDarkMode ? Colors.white : Colors.black,
        //         ))),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: themeColor,
              borderRadius:
                  Localization.of(context).locale == Locale('ar', 'SA')
                      ? BorderRadius.all(Radius.circular(6))
                      : BorderRadius.all(Radius.circular(6))),
          child: Image.asset(
              Localization.of(context).locale == Locale('ar', 'SA')
                  ? 'assets/resume-ar.png'
                  : 'assets/resume-en.png'),
        )
      ],
    );
  }
}

class OpeningItem extends StatelessWidget {
  const OpeningItem({
    Key key,
    @required this.openingDetails,
    @required this.periodStartDate,
  }) : super(key: key);

  final OpeningDetails openingDetails;
  final DateTime periodStartDate;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 400,
          child: Text(
            openingDetails.profile,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        Container(
          width: 300,
          child: Text(
            openingDetails.company,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
                height: 1.5),
          ),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          DateFormat('${openingDetails.name} - yyyy-MM-dd – kk:mm')
              .format(periodStartDate),
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class StoreIcon extends StatelessWidget {
  const StoreIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      child: Image.asset(
        'assets/store.png',
      ),
      decoration: BoxDecoration(
        color: orangeColor,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    );
  }
}
