import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_home_system/utils/ui_helper/app_colors.dart';
import 'package:flutter/animation.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

/// An animated background widget that continuously transitions between two colors.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(
      begin: Colors.blue.shade200,
      end: Colors.purple.shade200,
    ).animate(_bgController);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_colorAnimation.value!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// An animated AppBar title that shows a rotating home icon alongside animated text.
class AnimatedAppBarTitle extends StatefulWidget {
  final String title;
  final TextStyle textStyle;
  const AnimatedAppBarTitle({
    Key? key,
    required this.title,
    required this.textStyle,
  }) : super(key: key);

  @override
  _AnimatedAppBarTitleState createState() => _AnimatedAppBarTitleState();
}

class _AnimatedAppBarTitleState extends State<AnimatedAppBarTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _rotationAnimation,
          child: Image.asset('assets/images/logo.png', height: 28),
        ),
        const SizedBox(width: 8),
        AnimatedText(
          widget.title,
          duration: const Duration(seconds: 2),
          style: widget.textStyle,
        ),
      ],
    );
  }
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedCountry = "India";
  String? selectedState;
  String? selectedCity;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<FocusNode> _focusNodes = List.generate(5, (index) => FocusNode());

  // Example data for states and cities
  final Map<String, List<String>> statesAndCities = {
    "Andhra Pradesh": [
      "Visakhapatnam",
      "Vijayawada",
      "Guntur",
      "Tirupati",
      "Kakinada",
      "Rajahmundry",
      "Anantapur",
      "Nellore",
      "Kadapa",
      "Chittoor",
      "Eluru",
      "Machilipatnam",
      "Srikakulam",
      "Vizianagaram",
      "Nandyal",
      "Ongole",
      "Hindupur",
      "Proddatur",
      "Tenali",
      "Madanapalle"
    ],
    "Arunachal Pradesh": [
      "Itanagar",
      "Naharlagun",
      "Tawang",
      "Ziro",
      "Bomdila",
      "Pasighat",
      "Roing",
      "Tezu",
      "Along",
      "Daporijo",
      "Khonsa",
      "Changlang",
      "Yingkiong",
      "Koloriang",
      "Seppa",
      "Mechuka",
      "Dirang",
      "Longding",
      "Anini",
      "Bhalukpong"
    ],
    "Assam": [
      "Guwahati",
      "Dibrugarh",
      "Silchar",
      "Jorhat",
      "Tezpur",
      "Tinsukia",
      "Nagaon",
      "Bongaigaon",
      "Diphu",
      "Golaghat",
      "Sivasagar",
      "Lakhimpur",
      "Karimganj",
      "Haflong",
      "Barpeta",
      "Dhubri",
      "Kokrajhar",
      "North Lakhimpur",
      "Morigaon",
      "Hailakandi"
    ],
    "Bihar": [
      "Patna",
      "Gaya",
      "Bhagalpur",
      "Muzaffarpur",
      "Darbhanga",
      "Bihar Sharif",
      "Purnia",
      "Arrah",
      "Begusarai",
      "Katihar",
      "Munger",
      "Chhapra",
      "Hajipur",
      "Samastipur",
      "Motihari",
      "Sasaram",
      "Siwan",
      "Bettiah",
      "Dehri",
      "Jehanabad"
    ],
    "Chhattisgarh": [
      "Raipur",
      "Bhilai",
      "Bilaspur",
      "Korba",
      "Durg",
      "Rajnandgaon",
      "Jagdalpur",
      "Raigarh",
      "Ambikapur",
      "Dhamtari",
      "Mahasamund",
      "Kanker",
      "Kawardha",
      "Baikunthpur",
      "Chirmiri",
      "Dongargarh",
      "Jashpur",
      "Sakti",
      "Surajpur",
      "Mungeli"
    ],
    "Goa": [
      "Panaji",
      "Margao",
      "Vasco da Gama",
      "Mapusa",
      "Ponda",
      "Bicholim",
      "Curchorem",
      "Sanquelim",
      "Canacona",
      "Valpoi",
      "Quepem",
      "Sanguem",
      "Pernem",
      "Colva",
      "Candolim",
      "Calangute",
      "Agonda",
      "Arambol",
      "Dabolim",
      "Chapora"
    ],
    "Gujarat": [
      "Ahmedabad",
      "Surat",
      "Vadodara",
      "Rajkot",
      "Bhavnagar",
      "Jamnagar",
      "Junagadh",
      "Gandhinagar",
      "Gandhidham",
      "Anand",
      "Navsari",
      "Morbi",
      "Nadiad",
      "Bharuch",
      "Mehsana",
      "Bhuj",
      "Porbandar",
      "Palanpur",
      "Surendranagar",
      "Godhra"
    ],
    "Haryana": [
      "Faridabad",
      "Gurgaon",
      "Panipat",
      "Ambala",
      "Yamunanagar",
      "Rohtak",
      "Hisar",
      "Karnal",
      "Sonipat",
      "Panchkula",
      "Bhiwani",
      "Rewari",
      "Jhajjar",
      "Jind",
      "Kaithal",
      "Kurukshetra",
      "Sirsa",
      "Mahendragarh",
      "Fatehabad",
      "Palwal"
    ],
    "Himachal Pradesh": [
      "Shimla",
      "Manali",
      "Dharamshala",
      "Solan",
      "Mandi",
      "Bilaspur",
      "Chamba",
      "Hamirpur",
      "Kullu",
      "Kangra",
      "Una",
      "Nahan",
      "Paonta Sahib",
      "Keylong",
      "Reckong Peo",
      "Sundarnagar",
      "Joginder Nagar",
      "Karsog",
      "Theog",
      "Dalhousie"
    ],
    "Jharkhand": [
      "Ranchi",
      "Jamshedpur",
      "Dhanbad",
      "Bokaro",
      "Hazaribagh",
      "Deoghar",
      "Giridih",
      "Ramgarh",
      "Medininagar",
      "Chaibasa",
      "Gumla",
      "Lohardaga",
      "Dumka",
      "Sahibganj",
      "Chakradharpur",
      "Latehar",
      "Chatra",
      "Jhumri Tilaiya",
      "Godda",
      "Pakur"
    ],
    "Karnataka": [
      "Bangalore",
      "Mysore",
      "Hubli",
      "Belgaum",
      "Mangalore",
      "Davanagere",
      "Bellary",
      "Tumkur",
      "Bijapur",
      "Shimoga",
      "Gulbarga",
      "Hassan",
      "Udupi",
      "Chitradurga",
      "Raichur",
      "Bagalkot",
      "Mandya",
      "Chikmagalur",
      "Kolar",
      "Karwar"
    ],
    "Kerala": [
      "Thiruvananthapuram",
      "Kochi",
      "Kozhikode",
      "Kollam",
      "Thrissur",
      "Palakkad",
      "Alappuzha",
      "Kannur",
      "Kottayam",
      "Malappuram",
      "Pathanamthitta",
      "Idukki",
      "Wayanad",
      "Kasargod",
      "Varkala",
      "Muvattupuzha",
      "Attingal",
      "Changanassery",
      "Kayamkulam",
      "Thalassery"
    ],
    "Madhya Pradesh": [
      "Indore",
      "Bhopal",
      "Jabalpur",
      "Gwalior",
      "Ujjain",
      "Sagar",
      "Dewas",
      "Satna",
      "Ratlam",
      "Rewa",
      "Chhindwara",
      "Shivpuri",
      "Vidisha",
      "Bhind",
      "Guna",
      "Khandwa",
      "Sehore",
      "Hoshangabad",
      "Betul",
      "Mandsaur"
    ],
    "Maharashtra": [
      "Mumbai",
      "Pune",
      "Nagpur",
      "Nashik",
      "Aurangabad",
      "Solapur",
      "Amravati",
      "Thane",
      "Kolhapur",
      "Latur",
      "Akola",
      "Nanded",
      "Chandrapur",
      "Dhule",
      "Jalgaon",
      "Ahmednagar",
      "Ratnagiri",
      "Wardha",
      "Beed",
      "Parbhani"
    ],
    "Manipur": [
      "Imphal",
      "Thoubal",
      "Bishnupur",
      "Churachandpur",
      "Ukhrul",
      "Senapati",
      "Tamenglong",
      "Jiribam",
      "Kakching",
      "Moirang",
      "Noney",
      "Kangpokpi",
      "Moreh",
      "Tengnoupal",
      "Kamjong",
      "Pherzawl",
      "Chandel",
      "Saikul",
      "Lilong",
      "Sugnu"
    ],
    "Meghalaya": [
      "Shillong",
      "Tura",
      "Jowai",
      "Nongpoh",
      "Baghmara",
      "Williamnagar",
      "Resubelpara",
      "Mairang",
      "Khliehriat",
      "Nongstoin",
      "Mawkyrwat",
      "Ranikor",
      "Umsning",
      "Chokpot",
      "Patharkhmah",
      "Raliang",
      "Mawlai",
      "Sohra",
      "Smit",
      "Nartiang"
    ],
    "Mizoram": [
      "Aizawl",
      "Lunglei",
      "Saiha",
      "Champhai",
      "Kolasib",
      "Serchhip",
      "Lawngtlai",
      "Mamit",
      "Khawzawl",
      "Saitual",
      "Tlabung",
      "Ngopa",
      "Hnahthial",
      "Nghalasari",
      "Bairabi",
      "Thingsulthliah",
      "Sangau",
      "Zawlnuam",
      "Lungdai",
      "Darlawn"
    ],
    "Nagaland": [
      "Kohima",
      "Dimapur",
      "Mokokchung",
      "Tuensang",
      "Wokha",
      "Zunheboto",
      "Mon",
      "Phek",
      "Kiphire",
      "Longleng",
      "Peren",
      "Chumukedima",
      "Tuli",
      "Medziphema",
      "Tseminyu",
      "Shamator",
      "Pfutsero",
      "Meluri",
      "Noklak",
      "Aboi"
    ],
    "Odisha": [
      "Bhubaneswar",
      "Cuttack",
      "Rourkela",
      "Sambalpur",
      "Brahmapur",
      "Balasore",
      "Puri",
      "Bhadrak",
      "Baripada",
      "Jharsuguda",
      "Anugul",
      "Dhenkanal",
      "Koraput",
      "Bargarh",
      "Rayagada",
      "Jajpur",
      "Kendrapara",
      "Sundargarh",
      "Nabarangpur",
      "Jagatsinghpur"
    ],
  };


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Add focus listeners for field animations
    for (var node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'uid': user.uid,
          'photoUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _openCustomDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: ${e.toString()}")),
      );
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          await _firestore.collection('Users').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'country': selectedCountry,
            'state': selectedState ?? '',
            'city': selectedCity ?? '',
            'uid': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User Registered Successfully!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  Widget _buildAnimatedField({
    required Widget child,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value * (index + 1),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  void _openCustomDialog() {
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: a1,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeIn,
          ),
          child: FadeTransition(
            opacity: a1,
            child: AlertDialog(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Column(
                children: [
                  Lottie.asset(
                    'assets/check-animation.json',
                    width: 100,
                    height: 100,
                  ),
                  const Text(
                    'Success!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'You Signed In Successfully!',
                style: TextStyle(color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
      barrierDismissible: true,
      context: context,
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required Widget child,
    Color? color,
  }) {
    return ScaleTransition(
      scale: Tween(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 1, curve: Curves.easeOut),
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: _focusNodes.any((node) => node.hasFocus)
              ? [
            BoxShadow(
              color: color?.withOpacity(0.4) ?? Colors.blue,
              blurRadius: 10,
            )
          ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const AnimatedAppBarTitle(
            title: "EcoHome",
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.successColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),
                _buildAnimatedField(
                  index: 0,
                  child: TextFormField(
                    controller: _nameController,
                    focusNode: _focusNodes[0],
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(
                        color: _focusNodes[0].hasFocus
                            ? Colors.blue
                            : Colors.grey,
                        fontSize:
                        _focusNodes[0].hasFocus ? 16 : 14,
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedField(
                  index: 1,
                  child: TextFormField(
                    controller: _emailController,
                    focusNode: _focusNodes[1],
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(
                        color: _focusNodes[1].hasFocus
                            ? Colors.blue
                            : Colors.grey,
                        fontSize:
                        _focusNodes[1].hasFocus ? 16 : 14,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      } else if (!RegExp(
                          r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedField(
                  index: 2,
                  child: TextFormField(
                    controller: _passwordController,
                    focusNode: _focusNodes[2],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(
                        color: _focusNodes[2].hasFocus
                            ? Colors.blue
                            : Colors.grey,
                        fontSize:
                        _focusNodes[2].hasFocus ? 16 : 14,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your password' : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedField(
                  index: 3,
                  child: DropdownButtonFormField<String>(
                    value: selectedCountry,
                    focusNode: _focusNodes[3],
                    decoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items: ["India"]
                        .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedField(
                  index: 4,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedState,
                        focusNode: _focusNodes[4],
                        decoration: InputDecoration(
                          labelText: 'State',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        items: statesAndCities.keys
                            .map((state) => DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedState = value;
                            selectedCity = null;
                          });
                        },
                      ),
                      if (selectedState != null)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              value: selectedCity,
                              decoration: InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              items: statesAndCities[selectedState]!
                                  .map((city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCity = value;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildAnimatedButton(
                  onPressed: _registerUser,
                  child: const Text(
                    'Sign Up with Email',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedButton(
                  onPressed: _signInWithGoogle,
                  color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/Google.png', height: 24),
                      const SizedBox(width: 10),
                      const Text(
                        'Sign In with Google',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The existing animated text widget.
class AnimatedText extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle style;

  const AnimatedText(
      this.text, {
        required this.duration,
        required this.style,
        Key? key,
      }) : super(key: key);

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: FadeTransition(
        opacity: _controller,
        child: Text(
          widget.text,
          style: widget.style,
        ),
      ),
    );
  }
}
