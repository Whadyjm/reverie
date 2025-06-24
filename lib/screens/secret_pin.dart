import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/style/text_style.dart';
import 'package:pillow/widgets/custom_button.dart';

import '../widgets/custom_textfield.dart';
import 'home_screen.dart';

class SecretPin extends StatefulWidget {
  SecretPin({super.key, required this.userUid, this.userHasPin, this.userPin, this.pinCreated});

  String userUid;
  bool? userHasPin;
  String? userPin;
  bool? pinCreated;

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

  void _onDigitEntered(int index, String value) async {
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

    if (_pin.length == 4 && widget.pinCreated == false){

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userUid)
            .update({'pin': _pin, 'pinCreatedAt': Timestamp.now(),});
      }catch(e){}
      finally{
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
              (route) => false,
        );
      }
    }

    if (_pin.length == 4) {
      _handlePinComplete();
    }
    setState(() {});
  }

  void _handlePinComplete() async {
    print('Complete pin: $_pin');

    if (widget.userHasPin == true) {
      if (_pin == widget.userPin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El pin ingresado es incorrecto.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
            (route) => false,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userUid)
          .update({'pin': _pin, 'pinCreatedAt': Timestamp.now(),});
    }
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
                widget.userHasPin == true
                    ? 'Ingresa tu pin'
                    : 'Establece un pin de seguridad',
                style: RobotoTextStyle.titleStyle(Colors.white),
              ),
              const SizedBox(height: 40),
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
              Visibility(
                visible: widget.userHasPin == true ? true:false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: CustomButton(text: 'Recuperar pin', onPressed: (){
                    _pin = '';
                    recoverPinDialog(context);
                  },),
                ),
              ),
              const SizedBox(height: 50,),
              Icon(Iconsax.lock_1, color: Colors.white70, size: 40),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Este pin mantiene tus sueños a salvo',
                    style: RobotoTextStyle.smallTextStyle(Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void recoverPinDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withAlpha(250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 80,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Recuperar pin',
                  style: RobotoTextStyle.titleStyle(Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                autofocus: true,
                hintText: 'Correo electrónico',
                icon: Icons.email,
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 20),
               CustomButton(
                text: 'Siguiente',
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user?.email == emailController.text.trim()) {
                    Navigator.pop(context);
                    setState(() {
                      widget.userHasPin = false;
                      widget.pinCreated = false;
                      _pin = '';
                    });

                  } else {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                        title: Text(
                          'Email no coincide.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
