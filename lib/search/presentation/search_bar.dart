import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/search/shared/providers.dart';

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
