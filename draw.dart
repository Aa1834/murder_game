import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Settings'),
          ),
          ListTile(
            title: Text('How to Play'),
            onTap: () {
              Navigator.pushNamed(context, '/howToPlay');
            },
          ),
          ListTile(
            title: Text('Back'),
            onTap: () {
              Navigator.pop(context); // This will close the drawer
              Navigator.pop(context); // This will navigate back to the previous page
            },
          ),
        ],
      ),
    );
  }
}
