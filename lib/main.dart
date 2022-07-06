import 'dart:convert';
import 'details.dart'; //import obrazovky s detailmi knihy
import 'package:flutter/material.dart';
import 'package:http/http.dart'; //package pre pracu s API volaniami


void main() => runApp(MaterialApp(
  home: const Home(),
  initialRoute: '/',
  routes: {
    '/home': (context) => const Home(),
  },
));


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

//trieda obsahujuca detaily knihy
class Books {
  String title;
  String subtitle;
  String isbn;
  String price;
  String image;
  String link;

  Books({required this.title, required this.subtitle,required this.isbn,required this.price,required this.image, required this.link}); //vsetky tieto polia su povinne
}

class _HomeState extends State<Home> {

  int pageCounter = 3;
  bool nextPage = true;
  bool loadNextAnimation = false;
  String searchValue = '';

  int allPages = 0;
  int remainingPages = 0;

  bool loadingAnimation = false;
  List<Books> entries = []; //zoznam vsetkych knih ziskanych cez API volanie

  late TextEditingController _controller; //ovladac vyhladavacieho pola
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController()..addListener(() {getMoreData();});
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(() {getMoreData();});
    super.dispose();
  }

  //funkcia na ziskanie dat z API endpointu, value je vyhladavany pojem
  Future getData(value) async {
    setState(() {loadingAnimation = true;});
    var url =  Uri.parse('https://api.itbook.store/1.0/search/$value');
    var response = await get(url);

    Map allData = jsonDecode(response.body);
    int pages = int.parse(allData['total']);

    allPages = pages ~/ 10; //zistenie poctu stran ktore musime prehladat
    remainingPages = pages % 10; //pocet zaznamov nad celu stranu, kazda strana ma 10 zaznamov
    if (remainingPages != 0) {allPages += 1;}

    List data = allData['books'];
    for (var element in data) {
      Map obj = element;
      entries.add(Books(title: obj['title'], subtitle: obj['subtitle'], isbn: obj['isbn13'], price: obj['price'], image: obj['image'], link: obj['url']));
    }
    //nacitanie jednej strany navyse aby sa naplnil zoznam, ale iba ak je zaznamov viac ako 10
    if (allPages > 1) {
      url = Uri.parse('https://api.itbook.store/1.0/search/$value/2');
      response = await get(url);

      allData = jsonDecode(response.body);

      data = allData['books'];
      for (var element in data) {
        Map obj = element;
        entries.add(Books(title: obj['title'],
            subtitle: obj['subtitle'],
            isbn: obj['isbn13'],
            price: obj['price'],
            image: obj['image'],
            link: obj['url']));
      }
    }
    setState((){loadingAnimation = false;});
  }

  Future getMoreData() async {
    if (nextPage == true && _scrollController.position.atEdge){
      setState(() {loadingAnimation = true;});
      var url =  Uri.parse('https://api.itbook.store/1.0/search/$searchValue/$pageCounter');
      pageCounter += 1;
      var response = await get(url);
      Map allData = jsonDecode(response.body);
      List data = allData['books'];
      for (var element in data) {
        Map obj = element;
        entries.add(Books(title: obj['title'],
            subtitle: obj['subtitle'],
            isbn: obj['isbn13'],
            price: obj['price'],
            image: obj['image'],
            link: obj['url']));
        }
      setState(() {loadingAnimation = false;});
      if (pageCounter == allPages) {nextPage = false;}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookstore'),
        backgroundColor: Colors.amber,
      ),
        body: Column(
              children: <Widget>[
                Container(
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.all(3.0),
                child: TextField(
                  controller: _controller,
                //ak sa zmeni vyhladavany pojem, premazu sa vysledky v zozname
                  onChanged: (String value) {
                    setState((){entries.clear(); searchValue = value;});
                  },
                  decoration: InputDecoration(
                    suffixIcon:
                      Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                          child: CircleAvatar(
                              backgroundColor: Colors.amber,
                              radius: 10,
                              child: IconButton(
                                onPressed: () async{await Future.wait([getData(_controller.text)]);},
                                icon: const Icon(Icons.search), color: Colors.white,),
                          )
                      ),
                      border: const OutlineInputBorder(),
                      labelText: 'Zadajte pojem'
                   ),
                  )
                ),
                //zoznam obsahujuci vysledky
                //po kliknuti sa dostavame na druhu obrazovku s detailmi
                if (loadingAnimation) const CircularProgressIndicator(),
                Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  itemCount: entries.length,
                  itemBuilder: (context, index){
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (context) => Details(title: entries[index].title, subtitle: entries[index].subtitle, isbn: entries[index].isbn, price: entries[index].price, image: entries[index].image, link: entries[index].link)));
                        },
                        title: Text(entries[index].title,style: const TextStyle(fontWeight: FontWeight.bold),),
                        leading: Image.network(entries[index].image), //karta obsahuje aj obrazok, ten sa nacitava podla URI
                      )
                    );
                  },
                  )
                ),
               ]
        )
    );
  }
}




