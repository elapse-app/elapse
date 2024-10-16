import 'package:dots_indicator/dots_indicator.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
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
    bool isDarkMode = false;
    if (Theme.of(context).brightness == Brightness.dark) {
      isDarkMode = true;
    }

    String imageStringAddition = "";
    if (isDarkMode) {
      imageStringAddition = "Dark";
    }
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
        PhotoPreview(imageLocation: 'assets/onboardingHome$imageStringAddition.png')
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
        PhotoPreview(imageLocation: "assets/onboardingSchedule$imageStringAddition.png")
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
        PhotoPreview(imageLocation: 'assets/onboardingRankings$imageStringAddition.png')
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
        PhotoPreview(imageLocation: 'assets/onboardingMyTeam$imageStringAddition.png')
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
              title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                GestureDetector(
                  onTap: () {
                    if (currIndex == 0) {
                      Navigator.pop(context);
                    } else {
                      carouselController.previousPage(
                          duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: CarouselSlider(
                          items: featurePages,
                          carouselController: carouselController,
                          options: CarouselOptions(
                              height: MediaQuery.of(context).size.height * 0.625,
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
                      position: currIndex,
                      mainAxisSize: MainAxisSize.min,
                      decorator: DotsDecorator(
                        color: Theme.of(context).colorScheme.surfaceDim, // Inactive color
                        size: const Size.fromRadius(3.0),
                        activeSize: const Size.fromRadius(3.0),
                        activeColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Spacer(),
                    Container(
                      margin: EdgeInsets.fromLTRB(23, 15, 23, 50),
                      child: LongButton(
                          centerAlign: true,
                          useForwardArrow: false,
                          onPressed: () {
                            if (currIndex == 3) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            } else {
                              carouselController.nextPage(
                                  duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                            }
                          },
                          text: "Next"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class PhotoPreview extends StatelessWidget {
  const PhotoPreview({super.key, required this.imageLocation});
  final String imageLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.57,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.onSurface)),
      child: ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.asset(imageLocation)),
    );
  }
}
