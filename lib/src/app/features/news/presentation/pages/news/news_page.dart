import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsapp/src/app/di/injector.dart';
import 'package:newsapp/src/app/extensions/context.dart';
import 'package:newsapp/src/app/features/news/presentation/pages/news/store/news_state.dart';
import 'package:newsapp/src/app/features/news/presentation/pages/news/store/news_store.dart';
import 'package:newsapp/src/app/features/news/presentation/pages/news/widgets/highlight_list.dart';
import 'package:newsapp/src/app/features/news/presentation/pages/news/widgets/news_categories_header_delegate.dart';
import 'package:newsapp/src/app/features/news/presentation/pages/news/widgets/news_list.dart';
import 'package:newsapp/src/app/features/news/presentation/pages/news/widgets/shimmer_news_loading.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final NewsStore _newsStore = NewsStore(getTreadingNews: getIt());

  @override
  void initState() {
    super.initState();
    _newsStore.getTreadingNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder(
          bloc: _newsStore,
          builder: (context, state) {
            if (state is NewsLoadingState) {
              return const AnimatedSwitcher(
                duration: Duration(milliseconds: 350),
                child: ShimmerNewsLoading(),
              );
            }
            if (state is NewsFailureState) {
              return const Center(
                child: Text("Something went wrong..."),
              );
            }
            if (state is NewsLoadedState) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      expandedHeight: context.deviceHeight * .35,
                      flexibleSpace: HighlightNews(
                        news: state.news,
                        onTap: (news) {},
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: NewsCategoriesHeaderPersistentDelegate(),
                    ),
                    SliverToBoxAdapter(
                      child: NewsList(
                        onRefresh: () => _newsStore.getTreadingNews(),
                        news: state.news,
                        onTap: (news) {},
                      ),
                    )
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
