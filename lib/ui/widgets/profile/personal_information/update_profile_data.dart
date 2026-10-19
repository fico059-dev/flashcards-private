// import 'package:flashcards/bloc/authorization/auth/auth_bloc.dart';
// import 'package:flashcards/bloc/authorization/auth/auth_event.dart';
// import 'package:flashcards/bloc/authorization/auth/auth_state.dart';
// import 'package:flashcards/bloc/profile/profile_reader/profile_reader_cubit.dart';
// import 'package:flashcards/bloc/profile/profile_reader/profile_reader_state.dart';
// import 'package:flashcards/domain/dto/profile/profile.dart';
// import 'package:flashcards/ui/widgets/core/bloc_button.dart';
// import 'package:flashcards/ui/widgets/core/my_text_field.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class UpdateProfileData extends StatelessWidget {
//   final Profile profile;
//   final TextEditingController _nameController;
//   final TextEditingController _surnameController;
//   final TextEditingController _phoneNumberController;
//
//   const UpdateProfileData({
//     super.key,
//     required this.profile,
//     required TextEditingController nameController,
//     required TextEditingController surnameController,
//     required TextEditingController phoneNumberController,
//     required TextEditingController oldPasswordController,
//     required TextEditingController newPasswordController,
//   }) : _nameController = nameController,
//        _surnameController = surnameController,
//        _phoneNumberController = phoneNumberController;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         print("State changed $state");
//       },
//       child: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               Stack(
//                 children: [
//                   SizedBox(
//                     width: 120,
//                     height: 120,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(100),
//                       child: Icon(CupertinoIcons.profile_circled, size: 120),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       width: 35,
//                       height: 35,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(100),
//                         color: Colors.indigo,
//                       ),
//                       child: const Icon(
//                         Icons.edit,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Text(
//                 "${profile.name} ${profile.surname}",
//                 style: Theme.of(context).textTheme.headlineMedium,
//               ),
//               const SizedBox(height: 50),
//               Form(
//                 child: Column(
//                   children: [
//                     MyTextField(
//                       hintText: profile.name,
//                       labelText: "Name",
//                       textEditingController: _nameController,
//                     ),
//                     SizedBox(height: 20),
//                     MyTextField(
//                       hintText: profile.surname,
//                       labelText: "Surname",
//                       textEditingController: _surnameController,
//                     ),
//                     SizedBox(height: 20),
//                     MyTextField(
//                       hintText: profile.phoneNumber,
//                       labelText: "Phone number",
//                       textEditingController: _phoneNumberController,
//                     ),
//                     SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 50),
//               BlocButton<ProfileReaderCubit, ProfileReaderState>(
//                 textString: "Save changes",
//                 onPressed: () {
//                   final profileState = context.read<ProfileReaderCubit>().state;
//                   if (profileState is ProfileReaderIsLoaded) {
//                     context.read<ProfileReader>().add(
//                       UpdateProfile(
//                         profile: Profile(
//                           name:
//                               _nameController.text.isNotEmpty
//                                   ? _nameController.text
//                                   : profile.name,
//                           surname:
//                               _surnameController.text.isNotEmpty
//                                   ? _surnameController.text
//                                   : profile.surname,
//                           username: profile.username,
//                           email: profile.email,
//                           phoneNumber:
//                               _phoneNumberController.text.isNotEmpty
//                                   ? _phoneNumberController.text
//                                   : profile.phoneNumber,
//                           educationLevel: profile.educationLevel,
//                         ),
//                       ),
//                     );
//                     _nameController.text = "";
//                     _surnameController.text = "";
//                     _phoneNumberController.text = "";
//                   }
//                 },
//                 isLoadingState: (state) => state is ProfileLoading,
//               ),
//               SizedBox(height: 20),
//               BlocButton<AuthBloc, AuthState>(
//                 textString: "Delete account",
//                 onPressed: () {
//                   final profileState = context.read<ProfileBloc>().state;
//                   if (profileState is ProfileIsLoaded) {
//                     showDialog(
//                       context: context,
//                       builder:
//                           (context) => AlertDialog(
//                             title: Text("Confirm Deletion"),
//                             content: Text(
//                               "Are you sure you want to delete your account? This action cannot be undone.",
//                             ),
//                             actions: [
//                               OutlinedButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 style: OutlinedButton.styleFrom(
//                                   side: BorderSide(color: Colors.indigo),
//                                   foregroundColor: Colors.indigo,
//                                   backgroundColor: Colors.white,
//                                 ),
//                                 child: Text("إلغاء"),
//                               ),
//                               OutlinedButton(
//                                 onPressed:
//                                     () => context.read<AuthBloc>().add(
//                                       AuthDeleteAccount(),
//                                     ),
//                                 style: OutlinedButton.styleFrom(
//                                   side: BorderSide(color: Colors.red),
//                                   foregroundColor: Colors.red,
//                                   backgroundColor: Colors.white,
//                                 ),
//                                 child: Text("Delete account"),
//                               ),
//                             ],
//                           ),
//                     );
//                   }
//                 },
//                 isLoadingState: (state) => state is AuthLoading,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
