import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingleProvider<T, U> extends StatelessWidget {
  final T query;
  // final CachedProvider<U> Function(T) obtainProvider;
    // final Future<FetchResult<U>> Function(T, APIConnector) obtain;
  final RetrievalRoute<U> Function(T, APIConnector) obtain;
  final Widget Function(BuildContext context, U data, FetchResult<void>) builder;
  final String Function(AppLocalizations) errorTitle;
  // final Listenable Function(ResourcePool)? changeListener;

  const SingleProvider(
      {Key? key, required this.query, required this.obtain,
      required this.builder, required this.errorTitle, 
      // this.changeListener
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiplexedProvider<T, U>(
      query: [query],
      obtain: obtain,
      errorTitle: errorTitle,
      builder: (context, data) => builder(context, data.first.value, data.first),
      // changeListener: changeListener,
    );
  }  
}
