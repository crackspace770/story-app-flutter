
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/model/list_story.dart';
import '../provider/auth_provider.dart';
import '../provider/story_provider.dart';
import '../widget/card_story.dart';

class StoryListPage extends StatefulWidget {
  final Function() onLogout;
  final Function(ListStory) onTapped;
  final List<ListStory>? provider;
  final Function() onPressed;

  const StoryListPage({
    Key? key,
    required this.onLogout,
    required this.onTapped,
    required this.onPressed,
    this.provider,
  }) : super(key: key);

  @override
  State<StoryListPage> createState() => _StoryListPageState();
}

class _StoryListPageState extends State<StoryListPage> {

  Future<void> _onRefresh() async {
    Provider.of<StoryProvider>(
      context,
      listen: false,
    ).resetPagination(); // Add this line to reset pagination

    await Provider.of<StoryProvider>(
      context,
      listen: false,
    ).fetchStory(); // Fetch the data again after resetting pagination
  }

  @override
  Widget build(BuildContext context) {
    final authWatch = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Story Apps'),
        actions: [
          IconButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final authRead = context.read<AuthProvider>();
              final result = await authRead.logout();
              if (result) {
                widget.onLogout();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Logout"),
                  ),
                );
              }
            },
            icon: authWatch.isLoadingLogout
                ? const CircularProgressIndicator(
              color: Colors.lightBlue,
            )
                : const Icon(
              Icons.logout,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          backgroundColor: Colors.lightBlue,
          onRefresh: _onRefresh,
          child: _buildList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => widget.onPressed(),
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  Widget _buildList() {
    return Consumer<StoryProvider>(
      builder: (context, provider, child) {
        if (provider.state == ResultState.loading && provider.listStory.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        if (provider.state == ResultState.error) {
          return Center(
            child: Material(
              child: Text(
                provider.storiesResults?.message ?? 'Something wrong, please check your connection',
              ),
            ),
          );
        }
        if (provider.state == ResultState.hasData) {
          return Stack(
            children: [
              ListView.builder(
                controller: provider.scrollController,
                itemCount: provider.listStory.length + (provider.isScrollLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < provider.listStory.length) {
                    var stories = provider.listStory[index];
                    return GestureDetector(
                      onTap: () => widget.onTapped(stories),
                      child: CardStory(
                        story: stories,
                      ),
                    );
                  } else {
                    // Loading indicator for the next page
                    return const Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        } else {
          return Center(
            child: Material(
              child: Text(provider.storiesResults?.message ?? ''),
            ),
          );
        }
      },
    );
  }

}



