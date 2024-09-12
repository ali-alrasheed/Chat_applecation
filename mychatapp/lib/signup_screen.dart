import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mychatapp/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';




class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _image;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });}
    Future<String> _uploadeImage(File image) async {
      final ref = _storage
          .ref()
          .child('user_images')
          .child('${_auth.currentUser!.uid}.jpg');

      await ref.putFile(image);
      return await ref.getDownloadURL();
    }

    Future<void> _signUp() async {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
                email: _emailController.text, password: _passController.text);

        final imageurl = await _uploadeImage(_image!);
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': _nameController.text,
          'email': _emailController.text,
          'imageUrl': imageurl,
        });
        Fluttertoast.showToast(msg: "Sign Up success" ,webPosition: 55 );

        Navigator.pushReplacementNamed(context, "/HomeScreen");
      } catch (e) {
        print(e);
      }
    }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderr>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create new Account"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InkWell(
                onTap: _pickImage,
                child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(),
                    ),
                    child: _image == null
                        ? const Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 50,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          )),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Name";
                    }
                    return null;
                  }),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Email";
                    }
                    return null;
                  }),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                  controller: _passController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter Password";
                    }
                    return null;
                  }),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                height: 55,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                  child: const Text("Create Account"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("OR"),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/LoginScreen");
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(color: Colors.blue),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AutherProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create new Account"),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Column(
//             children: [
//               InkWell(
//                 onTap: _pickImage(),
//                 child: Container(
//                     height: 200,
//                     width: 200,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(),
//                     ),
//                     child: _image == null
//                         ? Center(
//                             child: Icon(
//                               Icons.camera_alt_rounded,
//                               size: 50,
//                             ),
//                           )
//                         : ClipRRect(
//                             borderRadius: BorderRadius.circular(100),
//                             child: Image.file(
//                               _image!,
//                               fit: BoxFit.cover,
//                             ),
//                           )),
//               ),
//               SizedBox(
//                 height: 30,
//               ),
//               TextFormField(
//                   controller: _nameController,
//                   keyboardType: TextInputType.name,
//                   decoration: InputDecoration(
//                     labelText: "Name",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please Enter Name";
//                     }
//                     return null;
//                   }),
//               SizedBox(
//                 height: 20,
//               ),
//               TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: "Email",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please Enter Email";
//                     }
//                     return null;
//                   }),
//               SizedBox(
//                 height: 20,
//               ),
//               TextFormField(
//                   controller: _passController,
//                   keyboardType: TextInputType.visiblePassword,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Please Enter Password";
//                     }
//                     return null;
//                   }),
//               SizedBox(
//                 height: 50,
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width / 1.5,
//                 height: 55,
//                 child: ElevatedButton(
//                   onPressed: _signUp,
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white),
//                   child: Text("Create Account"),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Text("OR"),
//               SizedBox(
//                 height: 20,
//               ),
//               TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, "/LoginScreen");
//                   },
//                   child: Text(
//                     "Sign In",
//                     style: TextStyle(color: Colors.blue),
//                   ))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
