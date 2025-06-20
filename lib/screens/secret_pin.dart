import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillow/style/text_style.dart';

import 'home_screen.dart';

class SecretPin extends StatefulWidget {
  SecretPin({super.key, required this.userUid});

  String userUid;

  @override
  State<SecretPin> createState() => _SecretPinState();
}

class _SecretPinState extends State<SecretPin> {

  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  String _pin = '';

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 4; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    _pin = _controllers.map((c) => c.text).join();

    if (_pin.length == 4) {
      _handlePinComplete();
    }
    setState(() {});
  }

  void _handlePinComplete() async {
    print('Complete pin: $_pin');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => MyHomePage()
      ),
          (route) => false,
    );

    await FirebaseFirestore.instance.collection('users').doc(widget.userUid).update({
      'userPin': _pin,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF1A003F),
              Color(0xFF2E1A5E),
              Color(0xFF4A3A7C),
              Color(0xFF6B5A9A),
              Color(0xFF8C53D6),
              Color(0xFFAD75F4),
            ],
          ),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Establece un pin de seguridad',
                style: RobotoTextStyle.titleStyle(Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                'Este pin mantendrá tus sueños a salvo',
                style: RobotoTextStyle.smallTextStyle(Colors.white),
              ),
              const SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                      (index) => Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        obscuringCharacter: '•',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => _onDigitEntered(index, value),
                      ),
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
}
