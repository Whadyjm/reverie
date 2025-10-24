import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reverie/screens/favorite_screen.dart';
import 'package:reverie/screens/login_screen.dart';
import 'package:reverie/screens/profile_screen.dart';
import 'package:reverie/widgets/dialogs/analysis_options.dart';
import 'package:reverie/widgets/drawer_head.dart';
import 'package:reverie/widgets/select_gender_dialog.dart';
import 'package:reverie/widgets/threedotsloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/button_provider.dart';
import '../provider/calendar_provider.dart';
import '../provider/dream_provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';
import '../style/gradients.dart';
import '../style/text_style.dart';
import '../widgets/calendar_timeline.dart';
import '../widgets/dialogs/pricing_dialog.dart';
import '../widgets/dream_by_date.dart';
import '../widgets/select_analysis_style.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late FirebaseService firebaseService;
  String apiKey = '';
  final TextEditingController _dreamController = TextEditingController();
  bool isLoading = false;
  String analysisStyle = '';
  String name = '';
  String? selectedGender = '';
  String? suscription = '';
  bool dontShowAgain = false;
  bool shouldShowDialog = false;
  int dreamCount = 0;
  String emotionResult = "";

  @override
  void initState() {
    super.initState();
    firebaseService = FirebaseService();

    _checkPreferences();
    initializeButtonState();

    _initUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ButtonProvider>(context, listen: false).loadPinStatus();
      Provider.of<DreamProvider>(context, listen: false).loadAnalysisStyle();
    });
  }

  /// Maneja todas las llamadas a Firebase de manera centralizada
  Future<void> _initUserData() async {
    try {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final isLastDayOfMonth = now.month != tomorrow.month;

      final results = await Future.wait([
        firebaseService.getDreamCountByUser(),
        firebaseService.getUserSelectedGender(),
        firebaseService.getUserSuscription(),
        firebaseService.getUserName(),
        firebaseService.getAnalysisStyle(),
        firebaseService.getAPIKeyFromFirestore(),
        if (isLastDayOfMonth) firebaseService.generateMonthlyEmotion(),
      ]);

      if (!mounted) return;

      setState(() {
        dreamCount = results[0] as int;
        selectedGender = results[1] as String?;
        suscription = results[2] as String?;
        name = results[3] as String;
        analysisStyle = results[4] as String;
        apiKey = results[5] as String;
        if (isLastDayOfMonth) {
          emotionResult = results[6] as String;
        }
      });

      debugPrint('-----------------User Data Loaded-----------------');
      debugPrint('Dream count: $dreamCount');
      debugPrint('Selected gender: $selectedGender');
      debugPrint('Subscription: $suscription');
      debugPrint('Name: $name');
      debugPrint('Analysis style: $analysisStyle');
      debugPrint('ApiKey: $apiKey');
      if (isLastDayOfMonth) {
        debugPrint('Monthly Emotion: $emotionResult');
      }
      debugPrint('--------------------------------------------------');
    } catch (e, st) {
      debugPrint('Error loading user data: $e\n$st');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> _checkPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        dontShowAgain = prefs.getBool('dontShowGenderDialog') ?? false;
        shouldShowDialog = !dontShowAgain;
      });
    }
  }

  Future<void> initializeButtonState() async {
    final prefs = await SharedPreferences.getInstance();
    final isButtonEnabled = prefs.getBool('isButtonEnabled') ?? false;
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    if (!mounted) return;
    if (isButtonEnabled) {
      btnProvider.enableButton();
    } else {
      btnProvider.disableButton();
    }
  }

  void _dragAction(details) {
    final calendarProvider = Provider.of<CalendarProvider>(
      context,
      listen: false,
    );
    final currentDate = calendarProvider.selectedDate;
    final currentDay = calendarProvider.selectedDate.day;
    final today = DateTime.now().day;
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! < 0 && currentDay != today) {
        calendarProvider.setSelectedDate(
          currentDate.add(const Duration(days: 1)),
        );
      } else if (details.primaryVelocity! > 0) {
        calendarProvider.setSelectedDate(
          currentDate.subtract(const Duration(days: 1)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().userChanges;
    final btnProvider = Provider.of<ButtonProvider>(context);
    final pinProvider = Provider.of<ButtonProvider>(context);
    final analysisSelected =
        Provider.of<DreamProvider>(context).analysisSelected;
    final _selectedDate = Provider.of<CalendarProvider>(context).selectedDate;
    final userName = FirebaseAuth.instance.currentUser?.displayName;

    final analysisStyleProvider = Provider.of<DreamProvider>(context);
    //analysisStyleProvider.analysisStyle = analysisStyle;
    return WillPopScope(
      onWillPop: () async {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
          return false;
        }
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          endDrawerEnableOpenDragGesture: false,
          endDrawer: _drawer(
            context,
            dreamCount,
            dontShowAgain,
            btnProvider,
            setState,
            pinProvider,
            analysisStyle,
            analysisStyleProvider,
          ),
          body: GestureDetector(
            onHorizontalDragEnd: (details) => _dragAction(details),
            child: Container(
              decoration: BoxDecoration(
                gradient:
                    btnProvider.isButtonEnabled
                        ? LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: Gradients.homeScreenDarkMode,
                        )
                        : LinearGradient(
                          colors: Gradients.homeScreenLightMode,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 12),
                  _homeScreenHeader(
                    context,
                    suscription,
                    user,
                    setState,
                    btnProvider,
                  ),
                  CalendarTimeline(emotionResult: emotionResult),
                  DreamByDate(suscription: suscription),
                  //TextAudioInput(apiKey: apiKey),
                ],
              ),
            ),
          ),
          floatingActionButton: Pulse(
            duration: Duration(milliseconds: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    btnProvider.toggleTextBlur();
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade600,
                          Colors.indigo.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: Icon(
                      btnProvider.isTextBlurred
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                StreamBuilder(
                  stream: FirebaseService().fetchDreamCountByDate(
                    _selectedDate,
                  ),
                  builder: (context, snapshot) {
                    final dreamCount = snapshot.data ?? 0;
                    return FloatingActionButton(
                      onPressed: () async {
                        if (dreamCount == 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Solo puedes registrar hasta 4 sueños por día.',
                                style: RobotoTextStyle.smallTextStyle(
                                  Colors.white,
                                ),
                              ),
                              backgroundColor: const Color.fromARGB(
                                255,
                                58,
                                42,
                                106,
                              ),
                            ),
                          );
                          return;
                        }

                        if (selectedGender == '' && shouldShowDialog) {
                          await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return SelectGenderDialog(
                                selectedGender: selectedGender!,
                                dontShowAgain: dontShowAgain,
                              );
                            },
                          );
                        }
                        if (analysisStyle == '' && analysisSelected == false) {
                          await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return SelectAnalysisStyle();
                            },
                          );
                          analysisStyle = analysisStyleProvider.analysisStyle;
                          await Future.delayed(Duration(milliseconds: 300));
                          showModalBottomSheet(
                            //TODO: corregir seleccion de estilo de analisis al iniciar sesion con usuario registrado y al agregar un sueño
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            backgroundColor:
                                btnProvider.isButtonEnabled
                                    ? Colors.grey.shade900
                                    : Colors.white,
                            builder: (BuildContext context) {
                              return _dreamTextField(
                                context,
                                btnProvider,
                                analysisStyleProvider,
                                analysisStyle,
                                isLoading,
                                _dreamController,
                                _selectedDate,
                                selectedGender,
                                userName,
                                suscription,
                                apiKey,
                              );
                            },
                          );
                        } else if (analysisStyleProvider
                                .analysisStyle
                                .isNotEmpty ||
                            analysisSelected == true) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            backgroundColor:
                                btnProvider.isButtonEnabled
                                    ? Colors.grey.shade900
                                    : Colors.white,
                            builder: (BuildContext context) {
                              return _dreamTextField(
                                context,
                                btnProvider,
                                analysisStyleProvider,
                                analysisStyle,
                                isLoading,
                                _dreamController,
                                _selectedDate,
                                selectedGender,
                                userName,
                                suscription,
                                apiKey,
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade600,
                              Colors.indigo.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                        child: Icon(
                          Iconsax.add_copy,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void settings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final btnProvider = Provider.of<ButtonProvider>(context);

        return SwitchDarkMode(btnProvider);
      },
    );
  }

  StatefulBuilder SwitchDarkMode(ButtonProvider btnProvider) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cerrar sesión',
                    style: RobotoTextStyle.subtitleStyle(Colors.grey.shade700),
                  ),
                  IconButton(
                    onPressed: () {
                      AuthService().signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: Icon(Iconsax.logout_copy),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

void _feedback(BuildContext context) {
  final TextEditingController feedbackController = TextEditingController();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.message, color: Colors.purple, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    '¡Queremos escucharte!',
                    style: RobotoTextStyle.subtitleStyle(Colors.grey.shade800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '¿Tienes sugerencias, comentarios o encontraste un problema?\nTu opinión nos ayuda a mejorar.',
                style: RobotoTextStyle.smallTextStyle(Colors.grey.shade700),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: feedbackController,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe tu feedback aquí...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.purple.shade100),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.purple.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.purple.shade300,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.purple.shade100),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: RobotoTextStyle.smallTextStyle(
                          Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.purple.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (feedbackController.text.trim().isEmpty) {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  title: Text(
                                    'Campo vacío',
                                    style: TextStyle(
                                      color: Colors.purple.shade400,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    'Por favor, escribe tu feedback.',
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Colors.purple.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          return;
                        }
                        try {
                          FirebaseService().sendFeedback(
                            feedbackController.text.trim(),
                          );
                        } catch (e) {}
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  '¡Gracias!',
                                  style: TextStyle(
                                    color: Colors.purple.shade400,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  '¡Gracias por tu feedback!',
                                  style: TextStyle(color: Colors.grey.shade800),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cerrar',
                                      style: TextStyle(
                                        color: Colors.purple.shade400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Text(
                        'Enviar',
                        style: RobotoTextStyle.smallTextStyle(Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDrawerItem({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  Color? color,
}) {
  return ListTile(
    leading: Icon(icon, color: color ?? Colors.deepPurple),
    title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    minLeadingWidth: 24,
  );
}

void _logout(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cerrar sesión',
                  style: RobotoTextStyle.titleStyle(Colors.grey.shade800),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Estás seguro de que quieres cerrar tu sesión?',
                  textAlign: TextAlign.center,
                  style: RobotoTextStyle.smallTextStyle(Colors.grey.shade700),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Cancelar',
                          style: RobotoTextStyle.smallTextStyle(
                            Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                          AuthService().signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Salir',
                          style: RobotoTextStyle.smallTextStyle(Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}

Widget _analysisStyleContainer(
  String title,
  String description,
  String analysisStyle,
  BuildContext context,
  void Function()? onTap,
  DreamProvider analysisStyleProvider,
  bool isPlus,
  AlignmentGeometry alignment,
) {
  return Stack(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Card(
          color:
              analysisStyleProvider.analysisStyle == analysisStyle
                  ? Colors.purple.shade100
                  : Colors.white,
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ),
      ),
      isPlus
          ? Align(
            alignment: Alignment.topRight,
            child: Container(
              height: 30,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.purple,
              ),
              child: Center(
                child: Text(
                  'PRO',
                  style: RobotoTextStyle.smallTextStyle(Colors.white),
                ),
              ),
            ),
          )
          : const SizedBox.shrink(),
    ],
  );
}

Widget _dreamTextField(
  context,
  ButtonProvider btnProvider,
  DreamProvider analysisStyleProvider,
  String analysisStyle,
  bool isLoading,
  TextEditingController _dreamController,
  DateTime _selectedDate,
  String? selectedGender,
  String? userName,
  String? suscription,
  String apiKey,
) {
  return Padding(
    padding: EdgeInsets.only(
      left: 16.0,
      right: 16.0,
      top: 16.0,
      bottom: MediaQuery.of(context).viewInsets.bottom + 40,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '¿Qué soñaste hoy?',
                style: AppTextStyle.subtitleStyle(
                  btnProvider.isButtonEnabled
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
              Text(
                analysisStyleProvider.analysisStyle.isEmpty
                    ? ''
                    : analysisStyleProvider.analysisStyle == 'cientifico'
                    ? '🧬'
                    : analysisStyleProvider.analysisStyle == 'psicologico'
                    ? '🧠'
                    : analysisStyleProvider.analysisStyle == 'mistico'
                    ? '🔮'
                    : analysisStyleProvider.analysisStyle == 'hibrido'
                    ? '🌀'
                    : '',
                style: TextStyle(
                  fontSize: 25,
                  color:
                      btnProvider.isButtonEnabled
                          ? Colors.white
                          : Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              fontFamily: 'roboto',
              color:
                  btnProvider.isButtonEnabled
                      ? Colors.white
                      : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            controller: _dreamController,
            decoration: InputDecoration(
              hintText: 'Escribe tu sueño...',
              hintStyle: TextStyle(
                color:
                    btnProvider.isButtonEnabled
                        ? Colors.white70
                        : Colors.grey.shade500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Iconsax.lock_1,
                color:
                    btnProvider.isButtonEnabled
                        ? Colors.white38
                        : Colors.grey.shade500,
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                'Tus sueños se encuentran a salvo.',
                style: RobotoTextStyle.small2TextStyle(
                  btnProvider.isButtonEnabled
                      ? Colors.white38
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () async {
                      final btnProvider = Provider.of<ButtonProvider>(
                        context,
                        listen: false,
                      );
                      FocusScope.of(context).unfocus();
                      if (_dreamController.text.trim().isEmpty) {
                        return;
                      }
                      try {
                        btnProvider.setLoading(true);
                        final title = await GeminiService().generateTitle(
                          _dreamController.text,
                          apiKey,
                        );
                        final analysis = await GeminiService().generateAnalysis(
                          _dreamController.text,
                          apiKey,
                          analysisStyleProvider.analysisStyle,
                          selectedGender!,
                          userName!,
                          suscription!,
                        );
                        final tag = await GeminiService().generateTag(
                          _dreamController.text,
                          apiKey,
                        );
                        final emotions = await GeminiService().generateEmotion(
                          _dreamController.text,
                          apiKey,
                        );
                        FirebaseService().saveDream(
                          context,
                          _dreamController,
                          _selectedDate,
                          title,
                          analysis,
                          tag,
                          emotions,
                          analysisStyleProvider.analysisStyle,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error, intente de nuevo')),
                        );
                      } finally {
                        btnProvider.setLoading(false);
                        _dreamController.clear();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400,
                            Colors.purple.shade600,
                            Colors.indigo.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child:
                            btnProvider.isLoading
                                ? SizedBox(
                                  width: 40,
                                  height: 25,
                                  child: ThreeDotsLoading(color: Colors.white),
                                )
                                : Text(
                                  'Guardar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'roboto',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.indigo.shade400,
                    ),
                    child: Icon(
                      Iconsax.microphone_2,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _drawer(
  context,
  dreamCount,
  dontShowAgain,
  btnProvider,
  setState,
  pinProvider,
  analysisStyle,
  analysisStyleProvider,
) {
  return Drawer(
    width: MediaQuery.of(context).size.width * 0.6,
    child: Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DrawerHeadWidget(
            dreamCount: dreamCount,
            dontShowAgain: dontShowAgain,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => SubscriptionBottomSheet.show(context),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Actualiza tu plan',
                        style: RobotoTextStyle.smallTextStyle(
                          Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.star_rounded, color: Colors.amber),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20, thickness: 1),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return FavoriteDreamsScreen();
                      },
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Favoritos',
                        style: RobotoTextStyle.smallTextStyle(
                          Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20, thickness: 1),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Tus premios',
                        style: RobotoTextStyle.smallTextStyle(
                          Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20, thickness: 1),
              // Modo Claro / Oscuro
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          btnProvider.isButtonEnabled
                              ? 'Modo Claro'
                              : 'Modo Oscuro',
                          style: RobotoTextStyle.smallTextStyle(
                            Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    activeColor: Colors.purple.shade300,
                    value: btnProvider.isButtonEnabled,
                    onChanged: (value) async {
                      final can = await Haptics.canVibrate();

                      if (!can) {
                        return;
                      }
                      await Haptics.vibrate(HapticsType.success);
                      setState(() {
                        if (value) {
                          btnProvider.enableButton();
                        } else {
                          btnProvider.disableButton();
                        }
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isButtonEnabled', value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Pin activo / inactivo
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          pinProvider.isPinActive
                              ? 'Pin activo'
                              : 'Pin inactivo',
                          style: RobotoTextStyle.smallTextStyle(
                            Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    activeColor: Colors.purple.shade300,
                    value: pinProvider.isPinActive,
                    onChanged: (value2) async {
                      final can = await Haptics.canVibrate();

                      if (!can) {
                        return;
                      }
                      await Haptics.vibrate(HapticsType.success);
                      setState(() {
                        if (value2) {
                          pinProvider.enablePin();
                        } else {
                          pinProvider.disablePin();
                        }
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isPinActive', value2);
                    },
                  ),
                ],
              ),

              const Divider(height: 20, thickness: 1),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modos de Análisis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      AnalysisOptions().showAnalysisOptionsDialog(context);
                    },
                    child: Icon(
                      Iconsax.info_circle,
                      color: Colors.grey.shade800,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _analysisStyleContainer(
                '🧬 Científico',
                'Analiza sueños desde la neurociencia',
                'cientifico',
                context,
                () async {
                  final can = await Haptics.canVibrate();

                  if (!can) {
                    return;
                  }
                  await Haptics.vibrate(HapticsType.success);
                  SubscriptionBottomSheet.show(context);
                },
                analysisStyleProvider,
                true,
                Alignment.topCenter,
              ),

              _analysisStyleContainer(
                '🧠 Psicológico',
                'Explora emociones y símbolos internos',
                'psicologico',
                context,
                () async {
                  final can = await Haptics.canVibrate();

                  if (!can) {
                    return;
                  }
                  await Haptics.vibrate(HapticsType.success);
                  setState(() {
                    analysisStyle = 'psicologico';
                    analysisStyleProvider.analysisStyle = 'psicologico';
                  });
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({'analysisStyle': 'psicologico'});
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('analysisStyle', 'psicologico');
                },
                analysisStyleProvider,
                false,
                Alignment.center,
              ),

              _analysisStyleContainer(
                '🔮 Místico',
                'Interpreta señales y mensajes espirituales',
                'mistico',
                context,
                () async {
                  final can = await Haptics.canVibrate();

                  if (!can) {
                    return;
                  }
                  await Haptics.vibrate(HapticsType.success);
                  setState(() {
                    analysisStyle = 'mistico';
                    analysisStyleProvider.analysisStyle = 'mistico';
                  });
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({'analysisStyle': 'mistico'});
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('analysisStyle', 'mistico');
                },
                analysisStyleProvider,
                false,
                Alignment.center,
              ),

              _analysisStyleContainer(
                '🌀 Híbrido',
                'Combina  psicología y misticismo',
                'hibrido',
                context,
                () async {
                  final can = await Haptics.canVibrate();

                  if (!can) {
                    return;
                  }
                  await Haptics.vibrate(HapticsType.success);
                  setState(() {
                    analysisStyle = 'hibrido';
                    analysisStyleProvider.analysisStyle = 'hibrido';
                  });
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({'analysisStyle': 'hibrido'});
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('analysisStyle', 'hibrido');
                },
                analysisStyleProvider,
                false,
                Alignment.bottomCenter,
              ),

              const Divider(height: 20, thickness: 1),
              _buildDrawerItem(
                icon: Iconsax.message,
                title: 'Feedback',
                onTap: () => _feedback(context),
                color: Colors.grey.shade800,
              ),
              _buildDrawerItem(
                icon: Iconsax.logout,
                title: 'Cerrar sesión',
                onTap: () => _logout(context),
                color: Colors.grey.shade800,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _plusButton(BuildContext context) {
  return FadeIn(
    duration: Duration(milliseconds: 800),
    child: GestureDetector(
      onTap: () async {
        final can = await Haptics.canVibrate();

        if (!can) {
          return;
        }

        await Haptics.vibrate(HapticsType.success);
        SubscriptionBottomSheet.show(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 25, top: 16.0),
        child: Container(
          height: 30,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 38, 26, 84),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Obtén PRO ✨',
              style: RobotoTextStyle.smallTextStyle(Colors.white),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _homeScreenHeader(
  BuildContext context,
  suscription,
  user,
  setState,
  btnProvider,
) {
  return SizedBox(
    height: 60,
    width: MediaQuery.of(context).size.width,
    child: Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reverie', style: AppTextStyle.logoTitleStyle(Colors.white)),
            ],
          ),
          suscription == 'free'
              ? _plusButton(context)
              : const SizedBox.shrink(),
          SizedBox(width: MediaQuery.sizeOf(context).width - 350),
          user != null
              ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          Scaffold.of(context).openEndDrawer();
                          FocusScope.of(context).unfocus();
                        });
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor:
                            btnProvider.isButtonEnabled
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.shade200,
                        child: StreamBuilder<User?>(
                          stream: user,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child:
                                    snapshot.data?.photoURL != null
                                        ? Image.network(
                                          snapshot.data!.photoURL!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 20,
                                            );
                                          },
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            );
                                          },
                                        )
                                        : Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                              );
                            } else {
                              return CircleAvatar(
                                backgroundColor:
                                    btnProvider.isButtonEnabled
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.grey.shade200,
                                child: Icon(Icons.person, color: Colors.grey),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              )
              : const SizedBox.shrink(),
        ],
      ),
    ),
  );
}
