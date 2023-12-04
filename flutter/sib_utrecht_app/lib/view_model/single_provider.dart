import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingleProvider<T, U> extends StatelessWidget {
  final T query;
  final CachedProvider<U> Function(T) obtainProvider;
  final Widget Function(BuildContext context, U data) builder;
  final String Function(AppLocalizations) errorTitle;

  const SingleProvider(
      {Key? key, required this.query, required this.obtainProvider,
      required this.builder, required this.errorTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiplexedProvider<T, U>(
      query: [query],
      obtainProvider: obtainProvider,
      errorTitle: errorTitle,
      builder: (context, data) => builder(context, data.first),
    );
  }  
}
