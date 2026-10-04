import 'package:auto_route/auto_route.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/search/core_widgets/filter_drawer.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  final Widget searchBar;
  final Widget searchResults;
  final Widget filterOptions;
  final Widget? itemCount;
  final bool searchBarAsTitle;
  final Widget? title;

  // final String drawerTitle;
  // final String drawerSubtitle;

  const SearchPage({
    super.key,
    required this.searchBar,
    required this.searchResults,
    required this.filterOptions,
    this.itemCount,
    this.searchBarAsTitle = true,
    this.title,
    // required this.drawerTitle,
    // required this.drawerSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchBarAsTitle ? searchBar : title,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          Builder(
            builder: (scaffoldContext) {
              return IconButton(
                icon: const Icon(Icons.filter_alt),
                onPressed: Scaffold.of(scaffoldContext).openEndDrawer,
              );
            },
          ),
        ],
      ),
      body: ReadableWidth(
        maxWidth: 820,
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalScreenPadding,
            right: horizontalScreenPadding,
            top: searchBarAsTitle ? 16 : 0,
          ),
          child: CustomScrollView(
            slivers: [
              if (!searchBarAsTitle) SliverToBoxAdapter(child: searchBar),
              if (!searchBarAsTitle)
                SliverToBoxAdapter(child: SizedBox(height: 15)),
              if (itemCount != null) itemCount!,
              if (itemCount != null)
                SliverToBoxAdapter(child: SizedBox(height: 15)),
              searchResults,
            ],
          ),
        ),
      ),
      endDrawer: FilterDrawer(filterOptions: filterOptions),
      // endDrawer: Drawer(
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(color: Colors.indigoAccent.shade700),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           mainAxisAlignment: MainAxisAlignment.end,
      //           children: [
      //             Text(
      //               drawerTitle,
      //               style: TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 24,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //             SizedBox(height: 8),
      //             Text(
      //               drawerSubtitle,
      //               style: TextStyle(color: Colors.white70, fontSize: 14),
      //             ),
      //           ],
      //         ),
      //       ),
      //       Expanded(child: filterOptions),
      //     ],
      //   ),
      // ),
      endDrawerEnableOpenDragGesture: true,
    );
  }
}
