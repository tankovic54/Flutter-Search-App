import 'dart:convert';
import 'details.dart'; //import obrazovky s detailmi knihy
import 'package:flutter/material.dart';
import 'package:http/http.dart'; //package pre pracu s API volaniami

void main() => runApp(MaterialApp(
  home: Home(),
  initialRoute: '/',
  routes: {
    '/home': (context) => Home(),
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
  List<Books> entries = []; //zoznam vsetkych knih ziskanych cez API volanie

  late TextEditingController _controller; //ovladac vyhladavacieho pola

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //funkcia na ziskanie dat z API endpointu, value je vyhladavany pojem
  void getData(value) async {
    var url =  Uri.parse('https://api.itbook.store/1.0/search/$value');
    var response = await get(url);

    Map allData = jsonDecode(response.body);
    int strany = int.parse(allData['total']);

    int celeStrany = strany ~/ 10; //zistenie poctu stran ktore musime prehladat
    int zvysneStrany = strany % 10; //pocet zaznamov nad celu stranu, kazda strana ma 10 zaznamov

    List data = allData['books'];
    data.forEach((element) {
      Map obj = element;
      entries.add(Books(title: obj['title'], subtitle: obj['subtitle'], isbn: obj['isbn13'], price: obj['price'], image: obj['image'], link: obj['url']));
    });
    //podmienka, ak je viac nez jedna strana tak sa postupne zavolaju vsetky strany databazy
    if (celeStrany > 0){
      if (zvysneStrany > 0) {celeStrany++;} //ak je zaznamov viac ako nasobok 10 tak sa prehlada este jedna strana
      for (int page = 2; page <= celeStrany; page++){
        url =  Uri.parse('https://api.itbook.store/1.0/search/$value/$page');
        var response = await get(url);
        allData = jsonDecode(response.body);
        List data = allData['books'];
        data.forEach((element) {
          Map obj = element;
          entries.add(Books(title: obj['title'], subtitle: obj['subtitle'], isbn: obj['isbn13'], price: obj['price'], image: obj['image'], link: obj['url']));
        });
      }
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
            padding: EdgeInsets.all(20.0),
            margin: EdgeInsets.all(3.0),
            child: TextField(
              controller: _controller,
              //ak sa zmeni vyhladavany pojem, premazu sa vysledky v zozname
              onChanged: (String value) {
                setState((){entries.clear();});
                },
              decoration: const InputDecoration(
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                labelText: 'Zadajte pojem'
                ),
              )),
              //zoznam obsahujuci vysledky
              //po kliknuti sa dostavame na druhu obrazovku s detailmi
              Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
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
              Container(
                padding: EdgeInsets.all(20.0),
                margin: EdgeInsets.all(3.0),
                //floating button, ktory spusta hladanie, mimo focusu na textfield je treba kliknut dvakrat, nevyrieseny bug
                child: FloatingActionButton(onPressed: () async{
                  getData(_controller.text);
                  setState((){});
                  },
                  backgroundColor: Colors.amber,
                  child: const Icon(Icons.search),),
              )]
        )
    );
  }
}




