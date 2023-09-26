part of '../main.dart';

class SignupIndicator extends StatefulWidget {
  final AnnotatedEvent event;

  const SignupIndicator({Key? key, required this.event}) : super(key: key);

  @override
  State<SignupIndicator> createState() => _SignupIndicatorState();
}

class _SignupIndicatorState extends State<SignupIndicator> {
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 40, height: 40, child: Center(child: buildInner(context)));

  Widget buildInner(BuildContext context) {
    var signupType = widget.event.data["signup"]?["type"];
    if (signupType == null && widget.event.data["signup"]?["url"] != null) {
      signupType = "url";
    }

    if (widget.event.data["event_rsvp"] == 0) {
      signupType = "none";
    }

    signupType = signupType ?? "api";

    if (signupType == "none") {
      return const SizedBox();
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

    if (signupType == "url") {
      var url = widget.event.data["signup"]?["url"];
      // if (widget.isContinuation) {
      //   return const SizedBox();
      // }

      return IconButton(
          onPressed: () {
            launchUrl(Uri.parse(url)).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      "Failed to open signup link: ${widget.event.data["signup"]["url"]}")));
              return false;
            });
          },
          icon: const Icon(Icons.open_in_browser));
    }

    return const Icon(Icons.error);
    // return const SizedBox();
  }
}
