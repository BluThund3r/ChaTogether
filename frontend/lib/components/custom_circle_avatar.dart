import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';

class CustomCircleAvatar extends StatefulWidget {
  final String name;
  final String imageUrl;
  final double radius;

  const CustomCircleAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 20.0,
  });

  @override
  State<CustomCircleAvatar> createState() => _CustomCircleAvatarState();
}

class _CustomCircleAvatarState extends State<CustomCircleAvatar> {
  Color _getUserColor(String name) {
    int red = 0;
    int green = 0;
    int blue = 0;

    for (int i = 0; i < name.length; i++) {
      int asciiCode = name.codeUnitAt(i);

      red = (red + asciiCode * 5) % 255;
      green = (green + asciiCode * 7) % 255;
      blue = (blue + asciiCode * 11) % 255;
    }

    return Color.fromRGBO(red, green, blue, 1);
  }

  @override
  void initState() {
    super.initState();
    initFToast(context);
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: _getUserColor(widget.name),
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: widget.radius,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => Text(
          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.radius,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
