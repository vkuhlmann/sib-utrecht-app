import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../view_model/event/annotated_event.dart';

class SignupIndicator extends StatefulWidget {
  final AnnotatedEvent event;
  final bool isFixedWidth;

  const SignupIndicator({Key? key, required this.event, required this.isFixedWidth}) : super(key: key);

  static SignupIndicator? Maybe(AnnotatedEvent event, {bool isFixedWidth = false}) {
    if (event.signupType == "none") {
      return null;
    }

    return SignupIndicator(event: event, isFixedWidth: isFixedWidth);
  }

  @override
  State<SignupIndicator> createState() => _SignupIndicatorState();
}

class _SignupIndicatorState extends State<SignupIndicator> {
  @override
  Widget build(BuildContext context) {
    var inner = buildInner(widget.event);
    if (inner == null) {
      if (!widget.isFixedWidth) {
        return const SizedBox();
      }

      inner = const SizedBox();
    }

    return SizedBox(
        width: 38, height: 38, child: Center(child: buildInner(widget.event)));
  }

  static Widget? buildInner(AnnotatedEvent event) {
    var signupType = event.signupType;

    if (signupType == "none") {
      return null;
    }

    if (signupType == "api") {
      var participation = event.participation;
      if (participation == null) {
        return const Icon(Icons.error);
      }
      if (participation.isDirty) {
        return const CircularProgressIndicator();
      }

      var setParticipating = participation.setParticipating;

      return Checkbox(
        value: participation.isParticipating,
        onChanged: setParticipating == null
            ? null
            : (value) {
                setParticipating(value ?? false);
              },
        // widget.event.placement?.isContinuation ?? false
        //     ? null
        //     : (value) {
        //         widget.event.participation?.setParticipating(value!);
        //       },
      );
    }

    final url = event.signupUrl;
    if (signupType == "url" && url != null) {
      // if (widget.isContinuation) {
      //   return const SizedBox();
      // }

      return
        Builder(
          builder: (context) =>
       IconButton(
          onPressed: () {
            launchUrl(Uri.parse(url)).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to open signup link: $url")));
              return false;
            });
          },
          icon: const Icon(Icons.open_in_browser)));
    }

    return const Icon(Icons.error);
    // return const SizedBox();
  }
}
