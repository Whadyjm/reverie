import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillow/style/text_style.dart';

class SecretPin extends StatefulWidget {
  const SecretPin({super.key});

  @override
  State<SecretPin> createState() => _SecretPinState();
}

class _SecretPinState extends State<SecretPin> {
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
