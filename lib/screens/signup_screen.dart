import "dart:typed_data";

import "package:connect_it/resources/auth_methods.dart";
import "package:connect_it/responsive/mobile_screen_layout.dart";
import "package:connect_it/responsive/responsive_layout.dart";
import "package:connect_it/screens/login_screen.dart";
import "package:connect_it/utils/colors.dart";
import "package:connect_it/utils/utils.dart";
import "package:connect_it/widgets/text_field_input.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  //final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;
  //String? _passwordMatchError;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    //_confirmPasswordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

void selectImage() async {
  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedImage != null) {
    final imageBytes = await pickedImage.readAsBytes();
    if (mounted) {
      setState(() {
        _image = Uint8List.fromList(imageBytes);
      });
    }
  }
}



void signUpUser() async {
  setState(() {
    _isLoading = true;
  });
  String res = await AuthMethods().signUpUser(
    email: _emailController.text,
    password: _passwordController.text,
    username: _usernameController.text,
    bio: _bioController.text,
    file: _image!,
  );

  if (mounted) { 
    setState(() {
      _isLoading = false;
    });
  }
  
  if (mounted && res != 'success') { 
    // ignore: use_build_context_synchronously
    showSnackBar(res, context);
  } else if (mounted) { 
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
        ),
      ),
    );
  }
}

  void navigateToLogin() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            'https://secure.gravatar.com/avatar/754bedf31b83f3f65ab5c0f7642f67a6/?s=48&d=https://images.binaryfortress.com/General/UnknownUser1024.png',
                          ),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.blueAccent,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                  textEditingController: _usernameController,
                  hintText: 'Create your username',
                  textInputType: TextInputType.text,
                  ),
              const SizedBox(
                height: 64,
              ),

              TextFieldInput(
                  textEditingController: _emailController,
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                textEditingController: _passwordController,
                hintText: 'Enter your password',
                textInputType: TextInputType.text,
                isPass: true,
              ),
              const SizedBox(
                height: 24,
              ),
              //text field for confirming my password
              //  TextFieldInput(
              //   textEditingController: _confirmPasswordController,
              //   hintText: 'Confirm your password',
              //   textInputType: TextInputType.text,
              //   isPass: true,
              // ),
              // const SizedBox(
              //   height: 24,
              // ),
              TextFieldInput(
                  textEditingController: _bioController,
                  hintText: 'What makes you an IT enthusiast?',
                  textInputType: TextInputType.text),
              const SizedBox(
                height: 24,
              ),

              InkWell(
                onTap: signUpUser,
                child: Container(
                  width: 85,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          4,
                        ),
                      ),
                    ),
                    color: Color.fromARGB(255, 45, 130, 200),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Sign in'),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: const Text("Already have an account?"),
                  ),
                  GestureDetector(
                    onTap: navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: const Text(
                        " Log in!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
