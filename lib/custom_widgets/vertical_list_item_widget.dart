import 'package:flutter/material.dart';


typedef ItemWidgetBuilder<T> = Widget Function(BuildContext context, T item);

class VerticalListItemBuilder<T> extends StatelessWidget {
  VerticalListItemBuilder(
      {Key key, @required this.snapshot, @required this.itemBuilder})
      : super(key: key);
  final AsyncSnapshot<List<T>> snapshot;
  final ItemWidgetBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData) {
      final List<T> items = snapshot.data;
    

      if (items.isNotEmpty) {
        return _buildList(items, context);
      } else {
        return Container(
          child: Text('no data'),
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
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: items.length ,
     /* separatorBuilder: (context, index) => Divider(
        height: 0.5,
        color: Colors.grey[300],
      ),*/
      itemBuilder: (context, index) {
       /* if (index == 0 || index == items.length + 1) {
          return Container();
        }*/
       // if(index==items.length)return Container();
        return itemBuilder(context, items[index ]);
      },
    );
  }
}
