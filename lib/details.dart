import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String title, subtitle, isbn, price, image, link;
  const Details({Key? key, required this.title, required this.subtitle, required this.isbn, required this.price, required this.image, required this.link}) : super(key: key);

  @override
  State<Details> createState(){
    return _DetailsState(title, subtitle, isbn, price, image, link); //presun udajov do buildera
  }
}

class _DetailsState extends State<Details> {
  //detaily
  late String title;
  late String subtitle;
  late String isbn;
  late String price;
  late String image;
  late String link;
  _DetailsState(this.title, this.subtitle, this.isbn, this.price, this.image, this.link);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.amber
      ),
      body:
      Center(
      child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.all(3.0),
                child: Image.network(image)
            ),
            Container(
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.all(0.5),
                child: Text('Subtitle: $subtitle')
            ),
            Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.all(0.5),
                child:  Text('ISBN: $isbn')
            ),
            Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.all(0.5),
                child: Text('Price: $price')
            ),
            Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.all(0.5),
                child: Text(link, style: TextStyle(fontStyle: FontStyle.italic))
            )
      ])));
  }
}
