import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class GridViewBuilder<T> extends StatelessWidget {
  GridViewBuilder({@required this.snapshot, @required this.itemBuilder});
  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;

  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data;

      if (items.isNotEmpty) {
        return _buildGrid(items, context);
      } else {
        return Container(
          child: Text('no artists'),
        );
      }
    } else if (snapshot.hasError)
      return Container(
        child: Text('error'),
      );
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildGrid(List<T> items, BuildContext context) {
    return GridView.builder(physics: BouncingScrollPhysics(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: items.length,
      itemBuilder: (context, index) => itemBuilder(
        context,
        items[index],
      ),
    );
  }
}
