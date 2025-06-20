// models/product.dart
class Product {
  final int? id;
  final String? code;
  final String? name;
  final double? price;
  final double? oldPrice;
  final String? imageBanner;
  final String? description;
  final String? createdDate;
  final String? createdTime;
  final int? quantitySold;
  final bool? deleted;
  final TradeMark? tradeMark;
  final Category? category;
  final List<ProductImage>? productImages;
  final List<ProductStorage>? productStorages;

  Product({
    this.id,
    this.code,
    this.name,
    this.price,
    this.oldPrice,
    this.imageBanner,
    this.description,
    this.createdDate,
    this.createdTime,
    this.quantitySold,
    this.deleted,
    this.tradeMark,
    this.category,
    this.productImages,
    this.productStorages,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      price: json['price']?.toDouble(),
      oldPrice: json['oldPrice']?.toDouble(),
      imageBanner: json['imageBanner'],
      description: json['description'],
      createdDate: json['createdDate'],
      createdTime: json['createdTime'],
      quantitySold: json['quantitySold'],
      deleted: json['deleted'],
      tradeMark: json['tradeMark'] != null ? TradeMark.fromJson(json['tradeMark']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      productImages: json['productImages'] != null
          ? (json['productImages'] as List).map((e) => ProductImage.fromJson(e)).toList()
          : null,
      productStorages: json['productStorages'] != null
          ? (json['productStorages'] as List).map((e) => ProductStorage.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'price': price,
      'oldPrice': oldPrice,
      'imageBanner': imageBanner,
      'description': description,
      'createdDate': createdDate,
      'createdTime': createdTime,
      'quantitySold': quantitySold,
      'deleted': deleted,
      'tradeMark': tradeMark?.toJson(),
      'category': category?.toJson(),
      'productImages': productImages?.map((e) => e.toJson()).toList(),
      'productStorages': productStorages?.map((e) => e.toJson()).toList(),
    };
  }
}

class TradeMark {
  final int? id;
  final String? name;

  TradeMark({this.id, this.name});

  factory TradeMark.fromJson(Map<String, dynamic> json) {
    return TradeMark(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Category {
  final int? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ProductImage {
  final int? id;
  final String? linkImage;

  ProductImage({this.id, this.linkImage});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'],
      linkImage: json['linkImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linkImage': linkImage,
    };
  }
}

class ProductStorage {
  final int? id;
  final String? ram;
  final String? rom;
  final List<ProductColor>? productColors;

  ProductStorage({this.id, this.ram, this.rom, this.productColors});

  factory ProductStorage.fromJson(Map<String, dynamic> json) {
    return ProductStorage(
      id: json['id'],
      ram: json['ram'],
      rom: json['rom'],
      productColors: json['productColors'] != null
          ? (json['productColors'] as List).map((e) => ProductColor.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ram': ram,
      'rom': rom,
      'productColors': productColors?.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductColor {
  final int? id;
  final String? name;
  final String? image;
  final double? price;
  final int? quantity;

  ProductColor({this.id, this.name, this.image, this.price, this.quantity});

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: json['price']?.toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }
}

class ProductComment {
  final int? id;
  final double? star;
  final String? content;
  final String? createdDate;
  final String? createdTime;
  final User? user;
  final List<ProductCommentImage>? productCommentImages;

  ProductComment({
    this.id,
    this.star,
    this.content,
    this.createdDate,
    this.createdTime,
    this.user,
    this.productCommentImages,
  });

  factory ProductComment.fromJson(Map<String, dynamic> json) {
    return ProductComment(
      id: json['id'],
      star: json['star']?.toDouble(),
      content: json['content'],
      createdDate: json['createdDate'],
      createdTime: json['createdTime'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      productCommentImages: json['productCommentImages'] != null
          ? (json['productCommentImages'] as List).map((e) => ProductCommentImage.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'star': star,
      'content': content,
      'createdDate': createdDate,
      'createdTime': createdTime,
      'user': user?.toJson(),
      'productCommentImages': productCommentImages?.map((e) => e.toJson()).toList(),
    };
  }
}

class User {
  final int? id;
  final String? fullname;
  final String? avatar;

  User({this.id, this.fullname, this.avatar});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'avatar': avatar,
    };
  }
}

class ProductCommentImage {
  final int? id;
  final String? linkImage;

  ProductCommentImage({this.id, this.linkImage});

  factory ProductCommentImage.fromJson(Map<String, dynamic> json) {
    return ProductCommentImage(
      id: json['id'],
      linkImage: json['linkImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'linkImage': linkImage,
    };
  }
}