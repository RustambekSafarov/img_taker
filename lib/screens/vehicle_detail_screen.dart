import 'dart:io';

import 'package:flutter/material.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    List images = args['data']!;
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Details'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            return _buildImageSection(
              context,
              title: 'Front Image',
              imageUrl: images[index]['image'],
            );
          },
          // children: [
          //   // DateTime Title

          //   // Front Image
          //   ,

          //   // Rear Image
          //   _buildImageSection(
          //     context,
          //     title: 'Rear Image',
          //     imageUrl: images[1]['image'],
          //   ),

          //   // Invoice Image
          //   _buildImageSection(
          //     context,
          //     title: 'Invoice Image',
          //     imageUrl: images[2]['image'],
          //   ),
          // ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width / 60,
          0,
          MediaQuery.of(context).size.width / 60,
          MediaQuery.of(context).size.width / 60,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 8,
          width: MediaQuery.of(context).size.width / 2.1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(2),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: MediaQuery.of(context).size.width / 15,
                  color: Colors.white,
                ),
                Text(
                  'Bosh sahifa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context, {
    required String title,
    required String imageUrl,
  }) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            height: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(imageUrl), fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }
}
