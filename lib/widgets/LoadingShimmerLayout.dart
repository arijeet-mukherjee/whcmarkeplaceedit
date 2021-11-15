import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmerLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              color: Theme.of(context).cardColor,
              child: ListView.builder(
                itemBuilder: (_, __) => Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor:
                          theme.isDarkTheme() ? Colors.grey : Colors.grey[300],
                      highlightColor: theme.isDarkTheme()
                          ? Colors.grey.shade300
                          : Colors.grey[100],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 25.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 220,
                              height: 10,
                              color: Colors.white,
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(maxRadius: 20),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 125,
                                        height: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                            Container(
                              width: 150,
                              height: 15,
                              color: Colors.white,
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                            Container(
                              width: double.infinity,
                              height: 20,
                              color: Colors.white,
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 30)),
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 20,
                                  color: Colors.white,
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4)),
                                Container(
                                  width: 40,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                      color: theme.isDarkTheme()
                          ? Colors.black54
                          : Colors.grey.shade200,
                    ),
                  ],
                ),
                itemCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
