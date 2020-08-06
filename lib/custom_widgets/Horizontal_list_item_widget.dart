import 'package:flutter/material.dart';

typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class HorizontalListItemsBuilder<T> extends StatelessWidget {
  const HorizontalListItemsBuilder({Key key, this.snapshot, this.itemBuilder})
      : super(key: key);
  @required
  final AsyncSnapshot<List<T>> snapshot;
  @required
  final ItemWidgetBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data;
      

      if (items.isNotEmpty) {
        return _buildList(items, context);
      } else {
        return Container(
          child: Text('no albums'),
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

  Widget _buildList(List<T> items, BuildContext context) {
    return Container(
      height: 240,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }
}
