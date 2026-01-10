import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final List<String> labels;

  const CustomBottomNav({super.key, required this.currentIndex, required this.onTap, required this.icons,  required this.labels});

  @override
  State<CustomBottomNav> createState() => _CustomButtonNavState();
}

class _CustomButtonNavState extends State<CustomBottomNav> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82, // sedikit lebih tinggi untuk label bawah
      decoration: BoxDecoration(
        color: Colors.orange[600],
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.icons.length, (index) {
          final selected = index == widget.currentIndex;

          return GestureDetector(
            onTap: () => widget.onTap(index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border:
                    selected
                        ? Border.all(color: Colors.orange, width: 2)
                        : null,
              ),
              child: Column(
                // Ubah ke Column supaya label dibawah ikon
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icons[index],
                    color: selected ? Colors.orange : Colors.white70,
                    size: 24,
                  ),
                  SizedBox(height: 2),
                  AnimatedSize(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child:
                        selected
                            ? Text(
                              widget.labels[index],
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
