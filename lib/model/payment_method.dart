class PaymentMethod {
  String name;
  String image;
  PaymentMethod({required this.name,required this.image});
}
List<PaymentMethod>paymentMethod=[
  PaymentMethod(name: "Bakong", image: "asset/image/bakong.png"),
  PaymentMethod(name: "ABA Bank", image: "asset/image/aba.png"),
  PaymentMethod(name: "Aceleda bank", image: "asset/image/ac.png"),
  PaymentMethod(name: "Canadia Bank", image: "asset/image/canadia.png")
];