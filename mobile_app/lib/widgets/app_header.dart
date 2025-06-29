import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final void Function(String)? onSearch;
  final void Function()? onCartPressed;
  final int cartItemCount;
  final List<String> categories;

  const AppHeader({
    Key? key,
    this.onSearch,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.categories = const [
      'Apple','Samsung','Xiaomi','Oppo','Huawei','Vivo',
      'Realme','Motorola','Tai nghe','Ốp lưng','Cường lực','Sạc cáp'
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _searchCtrl = TextEditingController();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // — Logo + Search + Cart —
        Container(
          color: const Color(0xFF004d40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 40, height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Hôm nay bạn cần tìm gì?',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: onSearch,
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: onCartPressed,
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // — Danh sách Categories —
        Container(
          color: const Color(0xFF004d40),
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) => TextButton(
              onPressed: () {
                // TODO: chuyển sang screen category[i]
              },
              child: Text(
                categories[i],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
