import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'package:repo_viewer/search/shared/providers.dart';

class SearchBar extends ConsumerStatefulWidget {
  final Widget body;
  final String title;
  final String hint;
  final void Function(String searchTerm) onShouldNavigateToResultPage;
  final void Function() onSignOutButtonPressed;

  const SearchBar({
    Key? key,
    required this.body,
    required this.title,
    required this.hint,
    required this.onShouldNavigateToResultPage,
    required this.onSignOutButtonPressed,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late FloatingSearchBarController _controller;

  @override
  void initState() {
    super.initState();

    _controller = FloatingSearchBarController();

    Future.microtask(() {
      ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerms();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      controller: _controller,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Tap to search 👆',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      hint: widget.hint,
      body: FloatingSearchBarScrollNotifier(child: widget.body),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        FloatingSearchBarAction(
          child: IconButton(
            onPressed: () {
              // widget.onSignOutButtonPressed();
            },
            icon: const Icon(MdiIcons.loginVariant),
            splashRadius: 18.0,
          ),
        )
      ],
      onSubmitted: (query) {
        widget.onShouldNavigateToResultPage(query);
        ref.read(searchHistoryNotifierProvider.notifier).addSearchTerm(query);
        _controller.close(); // auto-close and clear the search bar
      },
      builder: (context, transition) {
        return Material(
          color: Theme.of(context).cardColor,
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          clipBehavior: Clip.hardEdge,
          child: Consumer(
            builder: (context, ref, child) {
              final searchHistoryState =
                  ref.watch(searchHistoryNotifierProvider);
              return searchHistoryState.map(
                data: (history) {
                  return Column(
                    children: history.value
                        .map(
                          (term) => ListTile(
                            title: Text(term),
                            onTap: () {},
                          ),
                        )
                        .toList(),
                  );
                },
                loading: (_) => const ListTile(
                  title: LinearProgressIndicator(),
                ),
                error: (_) => ListTile(
                  title: Text('Very unexpected error ${_.error}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
