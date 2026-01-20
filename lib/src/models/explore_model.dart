class Restaurant {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final int ratingsCount;
  final String? discountTag;
  final String deliveryTime;
  final String deliveryFee;

  Restaurant({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.ratingsCount,
    this.discountTag,
    required this.deliveryTime,
    required this.deliveryFee,
  });
}

class ExploreSection {
  final String title;
  final String layout; // 'horizontal_slider' o 'vertical_list'
  final List<Restaurant> items;

  ExploreSection({
    required this.title,
    required this.layout,
    required this.items,
  });
}

// --- DATA DUMMY (La pegamos aquí mismo para simular una API) ---
final List<ExploreSection> dummySections = [
  ExploreSection(
    title: "Populares esta semana",
    layout: "horizontal_slider",
    items: [
      Restaurant(id: "1", title: "Burger King", subtitle: "Av. Abraham Lincoln", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.5, ratingsCount: 230, discountTag: "20% OFF", deliveryTime: "15-25 min", deliveryFee: "Free"),
      Restaurant(id: "2", title: "Pizza Hut", subtitle: "Plaza Central", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.2, ratingsCount: 150, discountTag: "2x1", deliveryTime: "30 min", deliveryFee: "\$50"),
      Restaurant(id: "3", title: "Taco Bell", subtitle: "BlueMall", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.7, ratingsCount: 500, discountTag: null, deliveryTime: "20 min", deliveryFee: "Free"),
    ],
  ),
  ExploreSection(
    title: "Descubre nuevos lugares",
    layout: "horizontal_slider",
    items: [
      Restaurant(id: "4", title: "Sushi Market", subtitle: "Piantini", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.9, ratingsCount: 50, discountTag: "NUEVO", deliveryTime: "45 min", deliveryFee: "\$100"),
      Restaurant(id: "5", title: "El Mesón", subtitle: "Mirador Sur", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.8, ratingsCount: 12, discountTag: null, deliveryTime: "60 min", deliveryFee: "\$150"),
    ],
  ),
  ExploreSection(
    title: "Todos los Restaurantes",
    layout: "vertical_list",
    items: [
      Restaurant(id: "6", title: "Chef Pepper", subtitle: "Av. 27 de Febrero", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.6, ratingsCount: 340, discountTag: null, deliveryTime: "35 min", deliveryFee: "Free"),
      Restaurant(id: "7", title: "Jade Teriyaki", subtitle: "Galería 360", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.3, ratingsCount: 120, discountTag: "Combo", deliveryTime: "25 min", deliveryFee: "\$75"),
      Restaurant(id: "8", title: "Green Bowl", subtitle: "Ágora Mall", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.8, ratingsCount: 85, discountTag: "Healthy", deliveryTime: "20 min", deliveryFee: "Free"),
      Restaurant(id: "9", title: "KFC", subtitle: "Máximo Gómez", imageUrl: "assets/delivery_screen/image_card_3.jpg", rating: 4.1, ratingsCount: 99, discountTag: null, deliveryTime: "15 min", deliveryFee: "\$45"),
    ],
  ),
];