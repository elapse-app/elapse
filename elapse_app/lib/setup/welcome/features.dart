import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../screens/widgets/app_bar.dart';
import '../signup/login_or_signup.dart';

class Features extends StatefulWidget {
  const Features({super.key});

  @override
  State<Features> createState() => _FeaturesState();
}

class _FeaturesState extends State<Features> {
  int currIndex = 0;
  late CarouselSliderController carouselController;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> featurePages = [
      Column(children: [
        Text(
          'At a glance',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upcoming matches & info',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          width: MediaQuery.of(context).size.height * 0.50 / (452 / 240),
          child: Image.asset('assets/onboardingHome.png'),
        ),
      ]),
      Column(children: [
        Text(
          'Find matches',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'See scores and live timing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          width: MediaQuery.of(context).size.height * 0.50 / (452 / 240),
          child: Image.asset('assets/onboardingSchedule.png'),
        ),
      ]),
      Column(children: [
        Text(
          'Check rankings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Find teams and stats',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          width: MediaQuery.of(context).size.height * 0.50 / (452 / 240),
          child: Image.asset('assets/onboardingRankings.png'),
        ),
      ]),
      Column(children: [
        Text(
          'Dive deeper',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get stats about your team',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          width: MediaQuery.of(context).size.height * 0.50 / (452 / 240),
          child: Image.asset('assets/onboardingMyTeam.png'),
        ),
      ]),
    ];

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,

        // child: AppBar(
        //   automaticallyImplyLeading: false,
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   title: GestureDetector(
        //     onTap: () {
        //       if (currIndex == 0) {
        //         Navigator.pop(context);
        //       } else {
        //         carouselController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
        //       }
        //     },
        //     child: Row(
        //       children: [
        //         const Icon(Icons.arrow_back),
        //         const SizedBox(width: 12),
        //         Text('Welcome',
        //           style: TextStyle(
        //         fontSize: 24,
        //         fontFamily: 'Manrope',
        //         fontWeight: FontWeight.w600,
        //         color: Theme.of(context).colorScheme.onSurface,
        //       ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            ElapseAppBar(
                title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (currIndex == 0) {
                                Navigator.pop(context);
                              } else {
                                carouselController.previousPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn);
                              }
                            },
                            child: const Icon(Icons.arrow_back),
                          ),
                          const SizedBox(width: 12),
                          Text('Welcome',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              )),
                        ]),
              maxHeight: 60,
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                // height: double.infinity,
                // width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: CarouselSlider(
                          items: featurePages,
                          carouselController: carouselController,
                          options: CarouselOptions(
                              height: 560,
                              enableInfiniteScroll: false,
                              autoPlay: false,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currIndex = index;
                                });
                              })),
                    ),
                    DotsIndicator(
                      dotsCount: featurePages.length,
                      position: currIndex.toDouble(),
                      mainAxisSize: MainAxisSize.min,
                      decorator: DotsDecorator(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceDim, // Inactive color
                        size: const Size.fromRadius(3.0),
                        activeSize: const Size.fromRadius(3.0),
                        activeColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 23),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(23.0, 0, 23.0, 23.0),
                        child: SizedBox(
                          height: 59.0,
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: "Manrope",
                                  fontWeight: FontWeight.w400,
                                ),
                                side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 1.0,
                                )),
                            onPressed: () {
                              // Navigate to the next page
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ThemeSetup(
                              //       prefs: widget.prefs,
                              //     ),
                              //   ),
                              // );
                              // Navigator.push(
                              //   context,
                              //   PageRouteBuilder(
                              //     pageBuilder: (_, __, ___) => SecondFeature(),
                              //     transitionDuration: Duration(milliseconds: 100),
                              //     transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                              //   ),
                              // );
                              if (currIndex == 3) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage(),
                                  ),
                                );
                              } else {
                                carouselController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn);
                              }
                            },
                            child: Text(
                              'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 12, 77, 86),
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
