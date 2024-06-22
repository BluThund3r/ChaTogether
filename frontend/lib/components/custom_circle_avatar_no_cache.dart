import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/utils/fetch_with_token.dart';
import 'package:http/http.dart' as http;

class CustomCircleAvatarNoCache extends StatefulWidget {
  final String name;
  final double radius;
  final String imageUrl;
  final bool isGroupConversation;
  const CustomCircleAvatarNoCache({
    super.key,
    required this.name,
    required this.imageUrl,
    this.radius = 20.0,
    this.isGroupConversation = false,
  });

  @override
  State<CustomCircleAvatarNoCache> createState() =>
      _CustomCircleAvatarNoCacheState();
}

class _CustomCircleAvatarNoCacheState extends State<CustomCircleAvatarNoCache> {
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

  Future<Uint8List?> fetchImage() async {
    print("Fetching image: ${widget.imageUrl}");
    final response = await HttpWithToken.get(url: widget.imageUrl);
    print("Image response fetched: ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: fetchImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (widget.isGroupConversation) {
          final groupIcon = CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.group_rounded,
              color: Colors.white,
              size: widget.radius * 1.3,
            ),
          );

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == null) {
            return groupIcon;
          }

          if (snapshot.hasData) {
            return CircleAvatar(
              radius: widget.radius,
              backgroundImage: MemoryImage(snapshot.data!),
            );
          }

          return groupIcon;
        } else {
          final avatarWithInitial = CircleAvatar(
            radius: widget.radius,
            backgroundColor: _getUserColor(widget.name),
            child: Text(
              widget.name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.radius,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == null) {
            return avatarWithInitial;
          }

          if (snapshot.hasData) {
            return CircleAvatar(
              radius: widget.radius,
              backgroundImage: MemoryImage(snapshot.data!),
            );
          }

          return avatarWithInitial;
        }
      },
    );
  }
}
