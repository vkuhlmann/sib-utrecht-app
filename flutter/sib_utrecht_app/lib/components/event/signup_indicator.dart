import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../view_model/event/annotated_event.dart';

class SignupIndicator extends StatefulWidget {
  final AnnotatedEvent event;
  final bool isFixedWidth;

  const SignupIndicator({Key? key, required this.event, required this.isFixedWidth}) : super(key: key);

  @override
  State<SignupIndicator> createState() => _SignupIndicatorState();
}

class _SignupIndicatorState extends State<SignupIndicator> {
  @override
  Widget build(BuildContext context) {
    var inner = buildInner(context);
    if (inner == null) {
      if (!widget.isFixedWidth) {
        return const SizedBox();
      }

      inner = const SizedBox();
    }

    return SizedBox(
        width: 40, height: 40, child: Center(child: buildInner(context)));
  }

  Widget? buildInner(BuildContext context) {
    var signupType = widget.event.signupType;

    if (signupType == "none") {
      return null;
    }

    if (signupType == "api") {
      var participation = widget.event.participation;
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

    final url = widget.event.signupUrl;
    if (signupType == "url" && url != null) {
      // if (widget.isContinuation) {
      //   return const SizedBox();
      // }

      return IconButton(
          onPressed: () {
            launchUrl(Uri.parse(url)).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to open signup link: $url")));
              return false;
            });
          },
          icon: const Icon(Icons.open_in_browser));
    }

    return const Icon(Icons.error);
    // return const SizedBox();
  }
}
