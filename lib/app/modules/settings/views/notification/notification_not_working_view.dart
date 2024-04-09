import 'package:flutter/material.dart';

import '../../../../common/constants.dart';
class NotificationNotWorkingView extends StatefulWidget {
  const NotificationNotWorkingView({super.key,this.enableAppBar=true});
  final bool enableAppBar;
  @override
  State<NotificationNotWorkingView> createState() => _NotificationNotWorkingViewState();
}

class _NotificationNotWorkingViewState extends State<NotificationNotWorkingView> {
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.enableAppBar ? AppBar(
          title: const Text('Notification Not Working?'),
          automaticallyImplyLeading: true,
        ) : null,
        body: SafeArea(
          child: Expanded(
            child: Stack(
              children: [
                /*InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(notificationNotWorkingURL)),
                  onLoadStart: (controller, url) async {

                  },
                  onLoadStop: (controller, url) async {

                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                ),*/
                progress < 1.0
                    ? LinearProgressIndicator(value: progress,valueColor: const AlwaysStoppedAnimation<Color>(buttonBgColor),backgroundColor: Colors.white,)
                    : Container(),
              ],
            ),
          ),
        )
    );
  }
}
