import 'package:connect_it/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget mobileScreenLayout;
  const ResponsiveLayout({Key? key, required this.mobileScreenLayout})
      : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    addData();
  }

  addData() async {
    try {
      UserProvider userProvider = Provider.of(context, listen: false);
      await userProvider.refreshUser();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text("Error loading data: $_error"),
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return widget.mobileScreenLayout;
        },
      );
    }
  }
}
