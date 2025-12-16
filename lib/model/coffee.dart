class Coffee {
  int id;
  String name;
  List<Map<String,double>> price;
  int dis;
  double rating;
  String sugar;
  String description;
  bool spacial;
  String img;
  String category;

  Coffee({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.dis,
    required this.rating,
    required this.sugar,
    required this.description,
    required this.spacial,
    required this.img
  });

}
List<Coffee> coffee = [
  Coffee(
    id: 1,
    name: "Classic coffee",
    category: "coffee",
    price: [
      {'S': 1.50},
      {'M': 1.75},
      {'L': 2.00}
    ],
    dis: 10,
    rating: 4.5,
    sugar: "20%",
    description: "Rich chocolate flavor with espresso",
    spacial: true,
    img: "asset/image/coffee.png",
  ),
 Coffee(
    id: 4,
    name: "Caramel Latte",
    category: "Latte",
    price: [
      {'S': 1.40},
      {'M': 1.65},
      {'L': 1.90}
    ],
    dis: 20,
    rating: 4.7,
    sugar: "30%",
    description: "Sweet caramel milk coffee",
    spacial: true,
    img: "asset/image/coffee2.png",
  ),
  Coffee(
    id: 2,
    name: "White coffee",
    category: "coffee",
    price: [
      {'S': 1.60},
      {'M': 1.85},
      {'L': 2.10}
    ],
    dis: 15,
    rating: 4.6,
    sugar: "25%",
    description: "Smooth white chocolate coffee",
    spacial: false,
    img: "asset/image/coffee1.png",
  ),

  Coffee(
    id: 3,
    name: "Hot Latte",
    category: "Latte",
    price: [
      {'S': 1.25},
      {'M': 1.50},
      {'L': 1.75}
    ],
    dis: 5,
    rating: 4.3,
    sugar: "15%",
    description: "Classic hot milk coffee",
    spacial: false,
    img: "asset/image/coffee.png",
  ),

 

  Coffee(
    id: 5,
    name: "Ice Latte",
    category: "Ice Latte",
    price: [
      {'S': 1.50},
      {'M': 1.75},
      {'L': 2.00}
    ],
    dis: 10,
    rating: 4.4,
    sugar: "20%",
    description: "Cold latte with ice",
    spacial: false,
    img: "asset/image/coffee.png",
  ),

  Coffee(
    id: 6,
    name: "Vanilla Ice Latte",
    category: "Ice Latte",
    price: [
      {'S': 1.60},
      {'M': 1.85},
      {'L': 2.10}
    ],
    dis: 15,
    rating: 4.6,
    sugar: "25%",
    description: "Cold vanilla flavored latte",
    spacial: true,
    img: "asset/image/coffee.png",
  ),

  Coffee(
    id: 7,
    name: "Hot Americano",
    category: "Hot Cofe",
    price: [
      {'S': 1.00},
      {'M': 1.20},
      {'L': 1.40}
    ],
    dis: 0,
    rating: 4.2,
    sugar: "0%",
    description: "Strong hot black coffee",
    spacial: false,
    img: "asset/image/coffee.png",
  ),

  Coffee(
    id: 8,
    name: "Hot Cappuccino",
    category: "Hot Cofe",
    price: [
      {'S': 1.30},
      {'M': 1.55},
      {'L': 1.80}
    ],
    dis: 10,
    rating: 4.5,
    sugar: "15%",
    description: "Hot coffee with milk foam",
    spacial: true,
    img: "asset/image/coffee.png",
  ),

  Coffee(
    id: 9,
    name: "Single Espresso",
    category: "Expresso",
    price: [
      {'S': 0.90}
    ],
    dis: 0,
    rating: 4.1,
    sugar: "0%",
    description: "Pure strong espresso shot",
    spacial: false,
    img: "asset/image/coffee.png",
  ),

  Coffee(
    id: 10,
    name: "Double Espresso",
    category: "Expresso",
    price: [
      {'S': 1.30}
    ],
    dis: 5,
    rating: 4.8,
    sugar: "0%",
    description: "Double shot espresso",
    spacial: true,
    img: "asset/image/coffee.png",
  ),
];
