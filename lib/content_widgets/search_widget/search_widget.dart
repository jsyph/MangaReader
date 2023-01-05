import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/search_widget/floating_search_bar_widget.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // This is handled by the search bar itself.
      resizeToAvoidBottomInset: false,
      body: FloatingSearchBarWidget(),
    );
  }
}
