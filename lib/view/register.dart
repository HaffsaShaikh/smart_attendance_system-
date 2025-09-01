import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/controller/auth_controller.dart';
import 'package:smart_attendance_system/view/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthController authController = Get.put(AuthController());

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _designation = TextEditingController();
  final TextEditingController _dob = TextEditingController();

  String? _gender;
  bool isPasswordHidden = true;

  final Color blueSteel = const Color(0xFF4682B4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: blueSteel,
                ),
              ),
              const SizedBox(height: 25),

              // Full Name
              buildTextField("Full Name", _fullName, Icons.person, false),
              const SizedBox(height: 16),

              // Email
              buildTextField("Email Address", _email, Icons.email, false),
              const SizedBox(height: 16),

              // Password
              buildTextField("Password", _pass, Icons.lock, true),
              const SizedBox(height: 16),

              // Date of Birth
              TextField(
                controller: _dob,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Date of Birth",
                  prefixIcon:
                      const Icon(Icons.calendar_today, color: Colors.black54),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: blueSteel),
                  ),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dob.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Designation
              buildTextField("Designation", _designation, Icons.work, false),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField2<String>(
                value: _gender,
                items: ["Male", "Female"]
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _gender = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Gender",
                  prefixIcon: const Icon(Icons.people, color: Colors.black54),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: blueSteel),
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  isOverButton: true,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_email.text.isNotEmpty &&
                        _pass.text.isNotEmpty &&
                        _fullName.text.isNotEmpty &&
                        _dob.text.isNotEmpty &&
                        _gender != null &&
                        _designation.text.isNotEmpty) {
                      authController.registerUser(
                        email: _email.text,
                        pass: _pass.text,
                        fullName: _fullName.text,
                        dob: _dob.text,
                        gender: _gender!,
                        designation: _designation.text,
                      );
                    } else {
                      Get.snackbar("Error", "Please fill all fields");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueSteel,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- OR CONTINUE WITH ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "or continue with",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 15),

              // Google Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    //  authController.signInWithGoogle();
                  },
                  icon: Image.asset(
                    "images/google.JPG",
                    height: 22,
                  ),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Already have an account? Login
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: blueSteel,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller,
      IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
              )
            : null,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: blueSteel),
        ),
      ),
    );
  }
}
