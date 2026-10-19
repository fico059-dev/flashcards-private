import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_bloc.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_event.dart';
import 'package:flashcards/bloc/pack/pack_searcher/pack_searcher_state.dart';
import 'package:flashcards/data/repositories/algolia_search/packs_searcher_repository.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/ui/widgets/search/core_widgets/custom_search_bar.dart';
import 'package:flashcards/ui/widgets/search/search_overlay/search_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PackSearchOverlay extends StatelessWidget {
  const PackSearchOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => PackSearcherBloc(
            packSearcherRepo: context.read<PacksSearcherRepository>(),
          ),
      child: _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchOverlay(
      searchBar: _SearchBar(),
      searchResults: SizedBox.shrink(),
      filterOptions: _FilterOptions(),
    );
  }
}

// class _SearchResults extends StatelessWidget {
//   const _SearchResults({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PackSearcherBloc, PackSearcherState>(
//       builder: (context, state) {
//         return ListView.separated(
//           itemBuilder: (context, index) {
//             return Text(state.searchResult.packs[index].name);
//           },
//           separatorBuilder: (context, index) => SizedBox(height: 15),
//           itemCount: state.searchResult.packs.length,
//         );
//       },
//     );
//   }
// }

class _SearchBar extends StatelessWidget {
  const _SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    void onChanged(String value) {
      context.read<PackSearcherBloc>().add(
        PackSearcherRequestSent(query: value),
      );
    }

    void onSubmit(String value) {
      context.read<PackSearcherBloc>().add(
        PackSearcherRequestSent(query: value),
      );
    }

    return CustomSearchBar(onChanged: onChanged, onSubmit: onSubmit);
  }
}

class _FilterOptions extends StatelessWidget {
  const _FilterOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text("وسم: مبتدئ")),
        ListTile(title: Text("وسم: متوسط")),
        ListTile(title: Text("اللغة: العربية")),
      ],
    );
  }
}
