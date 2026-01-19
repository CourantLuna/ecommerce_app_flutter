import 'package:ecommerce_app/src/views/components/header_text.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExploreScreen());

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    //Cuadro de búsqueda
                    _topBar(context),
                    //titulo principal
                    _slideCards(),
                    //Productos populares de la semana
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.centerLeft,
                      child: HeaderText(
                        color: Colors.black,
                        fontSize: 30,
                        text: "Explorar",
                      ),
                    ),
                    //Categorías
                    // _slideCard(),
                  ],
                ),
              );
            }, childCount: 1),
          ),
        ],
      ), //Para aplicaciones profesionales
    );
  }
}

Widget _topBar(BuildContext context) {
  return Row(
    children: [
      Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Text("Search..."),
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.15,
        height: MediaQuery.of(context).size.width * 0.12,
        child: GestureDetector(
          onTap: () {
            // movernos a la busqueda
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade400,
            child: Icon(Icons.filter_list, color: Colors.white, size: 40),
          ),
        ),
      ),
    ],
  );
}

// Tarjetas deslizables principales

Widget _slideCards() {
  return SizedBox(
    height: 350,
    child: ListView.builder(
      itemCount: 5,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return _slideCardContent(context);
      },
    ),
  );
}

//Contenido de las tarjetas deslizables para el metodo _slideCards

Widget _slideCardContent(BuildContext context) {
  return Container(
    margin: EdgeInsets.all(5),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/delivery_screen/image_card_3.jpg',
            width: 210,
            height: 250,
            fit: BoxFit.cover,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Jorge y Adela's Dinner",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              "Av Bolívar 1004, D. N",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow),
                Text(
                  ' 4.5',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  ' (233 ratings)',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: 80,
                  height: 18,

                  child: Text("Delivery", style: TextStyle(fontSize: 11, color: Colors.white), textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
