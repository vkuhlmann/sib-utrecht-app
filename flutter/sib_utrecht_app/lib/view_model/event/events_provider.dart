
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api/bookings.dart';
import 'package:sib_utrecht_app/model/event.dart';

// class EventsProvider with ChangeNotifier {
//   final CachedProvider<List<Event>> _eventsProvider =
//       CachedProvider<List<Event>>(obtain: (c) => Events(c).list());

//   final CachedProvider<Set<int>> _bookingsProvider =
//       CachedProvider<Set<int>>(obtain: (c) => Bookings(c).getMyBookings());

//   List<Event> events = [];

//   Future<APIConnector>? _apiConnector;
//   Set<int> _dirtyBookState = {};
//   int _dirtyStateSequence = 0;
//   Future<void>? loading;

//   final List<Future> _pendingMutations = [];

//   EventsProvider() {
//     _eventsProvider.addListener(_reprocessCached);
//     _bookingsProvider.addListener(_reprocessCached);
//   }

//   EventParticipation getMeParticipation(Event event,
//       {required ActionFeedback feedback}) {
//     return EventParticipation.fromEvent(event,
//         isParticipating: isMeParticipating(event.eventId) == true,
//         setParticipating: (value) =>
//             setMeParticipating(event, value, feedback: feedback),
//         isDirty: isMeBookingDirty(event.eventId));
//   }

//   bool? isMeParticipating(int eventId) {
//     return _bookingsProvider.cached?.value.contains(eventId);
//   }

//   bool isMeBookingDirty(int eventId) {
//     return _bookingsProvider.cached == null ||
//         _dirtyBookState.contains(eventId);
//   }

Future<void> setMeParticipation(
    {required Future<APIConnector> api,
    required Event event,
    required bool value,
    required ActionFeedback feedback}) async {
  String eventId = event.id;
  String eventName = event.name.long;

  final apiVal = await api;

  if (value) {
    try {
      await Bookings(apiVal).addMeBooking(eventId: eventId);
    } catch (e) {
      feedback.sendError("Failed to register for $eventName: \n$e");
      return;
    }

    feedback.sendConfirm("Registered for $eventName");
    return;
  }

  if (!value) {
    try {
      await Bookings(apiVal).removeMeBooking(eventId: eventId);
    } catch (e) {
      feedback.sendError("Failed to cancel registration for $eventName: $e");
      return;
    }
    feedback.sendConfirm("Cancelled registration for $eventName");
    return;
  }
}

//   void _reprocessCached() {
//     // log.fine("Reassembling data for events calendar list");
//     if (_bookingsProvider.cachedId > _dirtyStateSequence) {
//       _dirtyStateSequence = _bookingsProvider.cachedId;
//       _dirtyBookState = {};
//     }

//     var cachedEvents = _eventsProvider.cached;
//     if (cachedEvents == null) {
//       if (events.isNotEmpty) {
//         events = [];
//         notifyListeners();
//       }
//       return;
//     }

//     // log.fine("Bookings are: ${_bookingsProvider.cached}");

//     events = cachedEvents.value
//         // .map((v) => placeEvent(v, feedback))
//         // .flattened
//         // .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
//         // .map(buildItem)
//         .toList();

//     // log.fine("Events are now: ${events
//     // .where((e) => e.placement?.date.isAfter(DateTime(2023, 11, 10)) == true)
//     // .map((e) => e.participation?.isParticipating)}");

//     notifyListeners();
//   }

//   void setApiConnector(Future<CacherApiConnector> conn) {
//     if (_apiConnector == conn) {
//       return;
//     }
//     _apiConnector = conn;
//     // _eventsProvider.setConnector(conn);
//     // _bookingsProvider.setConnector(conn);
//     // if (conn != null) {
//     loading = _doLoad(conn);
//     // }
//   }

//   Future<void> _doLoad(Future<CacherApiConnector> conn) async {
//     await _eventsProvider.setConnector(conn);
//     await _bookingsProvider.setConnector(conn);

//     await Future.wait([_eventsProvider.loading, _bookingsProvider.loading]);
//   }

//   void refresh() {
//     _eventsProvider.invalidate(doRefresh: true);
//     _bookingsProvider.invalidate(doRefresh: true);

//     loading = Future.wait([_eventsProvider.loading, _bookingsProvider.loading]);
//     notifyListeners();
//   }

//   void loadEarlier() {}

  // void setMeParticipating(Event event, bool value,
  //     {bool initiateRefresh = true, required ActionFeedback feedback}) {
  //   int eventId = event.eventId;

  //   _dirtyStateSequence = _bookingsProvider.firstValidId;
  //   _dirtyBookState.add(eventId);

  //   var fut = Future.value(_apiConnector).then((conn) => _setMeParticipation(
  //       api: conn, event: event, value: value, feedback: feedback));
  //   _pendingMutations.add(fut);

  //   notifyListeners();

  //   if (!initiateRefresh) {
  //     fut.then((value) {
  //       _pendingMutations.remove(fut);
  //       _dirtyBookState.remove(eventId);
  //       notifyListeners();
  //     });
  //     return;
  //   }

  //   fut.whenComplete(() {
  //     // setState(() {
  //     _pendingMutations.remove(fut);
  //     _dirtyStateSequence = _bookingsProvider.firstValidId;

  //     _bookingsProvider.invalidate(doRefresh: true);
  //     // notifyListeners();
  //     // });
  //   });
  // }
// }
