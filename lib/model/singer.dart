import 'package:flutter/foundation.dart';
import 'package:karaoke/Constants.dart';

enum Category {
  all,
  pop,
  rock,
  rap,
  rnb,
  disco
}

class Singer {
  const Singer({
    @required this.category,
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.avatar,
    this.isFeatured,
    this.name,
    this.price,
  })  : assert(category != null),
        assert(id != null),
        assert(firstName != null),
        assert(lastName != null),
        assert(avatar != null);

  final Category category;
  final int id;
  final String firstName;
  final String lastName;
  final String avatar;
  final bool isFeatured;
  final String name;
  final int price;

  //String get assetName => '$id-0.jpg';
  String get assetName => Constants.SINGERS_PATH + '/$avatar';
  String get assetPackage => 'shrine_images';

  @override
  String toString() => '$name (id=$id)';

  factory Singer.fromJson(Map<String, dynamic> json) {

    return Singer(
      category: Category.all,
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      name: json['firstName'] + " " + json['lastName']
    );
  }
}