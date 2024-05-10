import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final double height;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClear;
  const CustomSearchBar(
      {super.key,
      this.height = 45.0,
      required this.controller,
      required this.onSubmit,
      required this.onClear});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool showClear = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: SearchBar(
        controller: widget.controller,
        hintText: "Search...",
        shadowColor: null,
        onChanged: (value) => {
          setState(() {
            showClear = value.isNotEmpty;
          })
        },
        onSubmitted: (value) => widget.onSubmit(value),
        textInputAction: TextInputAction.search,
        elevation: MaterialStateProperty.all(0.0),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
        ),
        trailing: [
          if (showClear)
            IconButton(
              onPressed: () => setState(() {
                widget.controller.clear();
                showClear = false;
                widget.onClear();
              }),
              icon: const Icon(Icons.close_rounded),
            )
        ],
      ),
    );
  }
}
