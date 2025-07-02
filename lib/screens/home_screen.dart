import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/screens/favorite_screen.dart';
import 'package:pillow/screens/login_screen.dart';
import 'package:pillow/screens/plan_screen.dart';
import 'package:provider/provider.dart';
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
  String apiKey = '';
  final TextEditingController _dreamController = TextEditingController();
  bool isLoading = false;
  String analysisStyle = '';
  String name = '';
  String? selectedGender = '';
  bool dontShowAgain = false;
  bool shouldShowDialog = false;
  int dreamCount = 0;

  @override
  void initState() {
    super.initState();
    _checkPreferences();
    getAPIKeyFromFirestore();
    initializeButtonState();
    getAnalysisStyle();
    getUserName();
    getUserSelectedGender();
    getDreamCountByUser();
    // Cargar el valor guardado al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ButtonProvider>(context, listen: false).loadPinStatus();
      Provider.of<DreamProvider>(context, listen: false).loadAnalysisStyle();
    });
    print('-----------------------$analysisStyle-------------------------');
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

  Future<void> getDreamCountByUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dreamsSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('dreams')
                .get();

        setState(() {
          dreamCount = dreamsSnapshot.docs.length;
        });

        print('-----------------Dream count: $dreamCount-----------------');
      }
    } catch (e) {
      print('Error getting dream count: $e');
    }
  }

  Future<void> _checkPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dontShowAgain = prefs.getBool('dontShowGenderDialog') ?? false;
      shouldShowDialog = !dontShowAgain;
    });
  }

  Future<void> getUserSelectedGender() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchUserSelectedGender = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()?['selectedGender'] ?? '');
        setState(() {
          selectedGender = fetchUserSelectedGender;
        });
      }
      print('-----------------$selectedGender-----------------');
    } catch (e) {}
  }

  Future<void> getUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchUserName = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()?['name'] ?? '');
        setState(() {
          name = fetchUserName;
        });
      }
      print('-----------------$name-----------------');
    } catch (e) {}
  }

  Future<void> getAnalysisStyle() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchedAnalysisStyle = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()?['analysisStyle'] ?? '');
        setState(() {
          analysisStyle = fetchedAnalysisStyle;
        });
      }
      print('-----------------$analysisStyle-----------------');
    } catch (e) {
      print('Error fetching analysis style: $e');
    }
  }

  Future<void> getAPIKeyFromFirestore() async {
    try {
      final doc = await firestore.collection('apiKey').doc('apiKey').get();
      if (doc.exists) {
        setState(() {
          apiKey = doc.data()?['apiKey'] ?? '';
        });
        print(
          '-----------------------------$apiKey-----------------------------------',
        );
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error fetching API key: $e');
    }
  }

  Future<void> initializeButtonState() async {
    final prefs = await SharedPreferences.getInstance();
    final isButtonEnabled = prefs.getBool('isButtonEnabled') ?? false;
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    if (isButtonEnabled) {
      btnProvider.enableButton();
    } else {
      btnProvider.disableButton();
    }
  }

  void _showPsychologicalSchools(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final isDarkMode = btnProvider.isButtonEnabled;
    final textColor = isDarkMode ? Colors.white : Colors.grey.shade900;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            title: Text(
              'Escuelas Psicológicas',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Freudiano', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle Freud selection
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Junguiano', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle Jung selection
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Gestalt', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    String? idealFor,
    String? styles,
    required String buttonText,
    required Color textColor,
    required Color cardColor,
    required VoidCallback onPressed,
    bool showDetails = true,
  }) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
            ),
            if (idealFor != null) ...[
              const SizedBox(height: 8),
              Text(
                'Ideal para:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                idealFor,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
            if (styles != null) ...[
              const SizedBox(height: 8),
              Text(
                'Estilos:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                styles,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void showAnalysisOptionsDialog(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final isDarkMode = btnProvider.isButtonEnabled;
    final textColor = isDarkMode ? Colors.white : Colors.grey.shade900;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Métodos de análisis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige el enfoque que mejor se adapte a tus necesidades',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnalysisCard(
                    context,
                    icon: '🧬',
                    title: 'Exploración Científica',
                    description:
                    'Observa tu sueño a través de la neurociencia. Explora cómo las emociones, recuerdos y experiencias se entrelazan mientras duermes.',
                    idealFor:
                    'Autoconocimiento basado en la ciencia, patrones de sueño y bienestar mental.',
                    styles: 'Análisis neurocognitivo, patrones REM, interpretación basada en contexto de vida.',
                    buttonText: 'Interpretación Científica',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                      _showPsychologicalSchools(context);
                    },
                  ),

                  const SizedBox(height: 20),
                  // Psychological Option
                  _buildAnalysisCard(
                    context,
                    icon: '🧠',
                    title: 'Exploración Psicológica',
                    description:
                        'Conecta tu sueño con emociones, partes de ti mismo y símbolos internos.',
                    idealFor:
                        'Comprensión personal, crecimiento interior, análisis emocional',
                    styles: 'Introspectivo, simbólico, terapéutico',
                    buttonText: 'Interpretación Psicológica',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                      _showPsychologicalSchools(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Mystical Option
                  _buildAnalysisCard(
                    context,
                    icon: '🔮',
                    title: 'Exploración Mística',
                    description:
                        'Descubre si tu sueño trae un mensaje del alma, una señal del universo o una energía especial.',
                    idealFor:
                        'Guía espiritual, significados ocultos, sincronías',
                    styles:
                        'Simbolología ancestral, tarot, energías, astrología',
                    buttonText: 'Interpretación Mística',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                      // Add mystical interpretation logic
                    },
                  ),

                  const SizedBox(height: 20),

                  // Hybrid Option
                  _buildAnalysisCard(
                    context,
                    icon: '🌀',
                    title: 'Ambas cosas (Híbrido)',
                    description:
                        '¿Y si los sueños fueran espejo de tu interior y mensajeros del universo? Combina ambos enfoques para una visión más completa.',
                    buttonText: 'Exploración Completa',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                      // Add hybrid interpretation logic
                    },
                    showDetails: false,
                  ),
                ],
              ),
            ),
          ),
    );
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
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    final analysisStyleProvider = Provider.of<DreamProvider>(
      context,
      listen: false,
    );
    analysisStyleProvider.analysisStyle = analysisStyle;
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
          endDrawerEnableOpenDragGesture: false,
          endDrawer: Drawer(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              children: [
                /*ElevatedButton(onPressed: (){
                  print(analysisStyleProvider.analysisStyle);
                }, child: Text('Test: Estilo de analisis')),*/
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade700,
                          Colors.deepPurple.shade400,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  btnProvider.isButtonEnabled
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey.shade200,
                              child: StreamBuilder<User?>(
                                stream: user,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: snapshot.data?.photoURL != null
                                          ? Image.network(
                                        snapshot.data!.photoURL!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                            size: 20,
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
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
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                dreamCount == 0 ? '' : '🌙 $dreamCount Sueños',
                                style: RobotoTextStyle.small2TextStyle(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              userName ?? name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return SelectGender();
                                  },
                                );
                              },
                              child: Icon(
                                selectedGender == 'male'
                                    ? Icons.male_rounded
                                    : selectedGender == 'female'
                                    ? Icons.female_rounded
                                    : selectedGender == 'other'
                                    ? Icons.transgender_rounded
                                    : Icons.question_mark_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          userEmail ?? 'Email',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Drawer Items
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
                                'Premium',
                                style: RobotoTextStyle.smallTextStyle(
                                  Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(width: 5,),
                              Icon(Icons.star_rounded, color: Colors.amber)
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
                              setState(() {
                                if (value) {
                                  btnProvider.enableButton();
                                } else {
                                  btnProvider.disableButton();
                                }
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
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
                              setState(() {
                                if (value2) {
                                  pinProvider.enablePin();
                                } else {
                                  pinProvider.disablePin();
                                }
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('isPinActive', value2);
                            },
                          ),
                        ],
                      ),

                      const Divider(height: 20, thickness: 1),

                      // Cards Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Modos de Análisis',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showAnalysisOptionsDialog(context);
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
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            analysisStyle = 'cientifico';
                            analysisStyleProvider.analysisStyle = 'cientifico';
                          });
                          final user = FirebaseAuth.instance.currentUser;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .update({'analysisStyle': 'cientifico'});

                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('analysisStyle', 'cientifico');
                        },
                        child: Card(
                          color:
                          analysisStyleProvider.analysisStyle ==
                              'cientifico'
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
                                      '🧬 Científico',
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
                                  'Analiza a través de la neurociencia.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () async {
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
                        child: Card(
                          color:
                              analysisStyleProvider.analysisStyle ==
                                      'psicologico'
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
                                      '🧠 Psicológico',
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
                                  'Analiza emociones y patrones mentales',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Místico Card
                      GestureDetector(
                        onTap: () async {
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
                        child: Card(
                          color:
                              analysisStyleProvider.analysisStyle == 'mistico'
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
                                      '🔮 Místico',
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
                                  'Interpreta señales y mensajes espirituales',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Híbrido Card
                      GestureDetector(
                        onTap: () async {
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
                        child: Card(
                          color:
                              analysisStyleProvider.analysisStyle == 'hibrido'
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
                                      '🌀 Híbrido',
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
                                  'Combina ambos enfoques de análisis',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Divider(height: 20, thickness: 1),

                      // Logout Option
                      _buildDrawerItem(
                        icon: Iconsax.logout,
                        title: 'Cerrar sesión',
                        onTap: () => _logout(context),
                        color: Colors.grey.shade800,
                      ),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'App Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          body: Container(
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
                SizedBox(
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
                            Text(
                              'Pillow',
                              style: AppTextStyle.titleStyle(
                                btnProvider.isButtonEnabled
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                            /*Text(
                              '👋  Hola, ${userName?.split(' ').first ?? name}',
                              style: RobotoTextStyle.subtitleStyle(
                                btnProvider.isButtonEnabled
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),*/
                          ],
                        ),
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
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(25),
                                              child: snapshot.data?.photoURL != null
                                                  ? Image.network(
                                                snapshot.data!.photoURL!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.person,
                                                    color: Colors.grey,
                                                    size: 20,
                                                  );
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
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
                                                      ? Colors.white
                                                          .withOpacity(0.2)
                                                      : Colors.grey.shade200,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.grey,
                                              ),
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
                ),
                CalendarTimeline(),
                DreamByDate(),
                //TextAudioInput(apiKey: apiKey),
              ],
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
                          Colors.purple.shade400,
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
                FloatingActionButton(
                  onPressed: () async {
                    if (selectedGender == '' && shouldShowDialog) {
                      await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return SelectGender();
                        },
                      );
                    }
                    if (analysisStyleProvider.analysisStyle.isEmpty &&
                        analysisSelected == false) {
                      await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return SelectAnalysisStyle();
                        },
                      );
                      analysisStyle = analysisStyleProvider.analysisStyle;
                      print(analysisStyle);
                      await Future.delayed(Duration(milliseconds: 300));

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
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        analysisStyleProvider
                                                .analysisStyle
                                                .isEmpty
                                            ? ''
                                            : analysisStyleProvider
                                            .analysisStyle ==
                                            'cientifico'
                                            ? '🧬'
                                            : analysisStyleProvider
                                                    .analysisStyle ==
                                                'psicologico'
                                            ? '🧠'
                                            : analysisStyleProvider
                                                    .analysisStyle ==
                                                'mistico'
                                            ? '🔮'
                                            : analysisStyleProvider
                                                    .analysisStyle ==
                                                'hibrido'
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
                                    textCapitalization:
                                        TextCapitalization.sentences,
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
                                  SizedBox(
                                    height: 70,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        if (_dreamController.text
                                            .trim()
                                            .isEmpty) {
                                          return;
                                        }
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          print(
                                            analysisStyleProvider.analysisStyle,
                                          );
                                          final title = await GeminiService()
                                              .generateTitle(
                                                _dreamController.text,
                                                apiKey,
                                                analysisStyle == ''
                                                    ? analysisStyleProvider
                                                        .analysisStyle
                                                    : analysisStyle,
                                                selectedGender!,
                                                userName ?? name,
                                              );
                                          FirebaseService().saveDream(
                                            context,
                                            _dreamController,
                                            _selectedDate,
                                            title,
                                            analysisStyle == ''
                                                ? analysisStyleProvider
                                                    .analysisStyle
                                                : analysisStyle,
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error, intente de nuevo',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          _dreamController.clear();
                                          Navigator.pop(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child:
                                              isLoading
                                                  ? SizedBox(
                                                    width: 25,
                                                    height: 25,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 4,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : Text(
                                                    'Guardar',
                                                    style: TextStyle(
                                                      fontFamily: 'roboto',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (analysisStyleProvider.analysisStyle.isNotEmpty ||
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
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom:
                                  MediaQuery.of(context)
                                      .viewInsets
                                      .bottom, // Ajusta el espacio según el teclado
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        analysisStyleProvider
                                            .analysisStyle
                                            .isEmpty
                                            ? ''
                                            : analysisStyleProvider
                                            .analysisStyle ==
                                            'cientifico'
                                            ? '🧬'
                                            : analysisStyleProvider
                                            .analysisStyle ==
                                            'psicologico'
                                            ? '🧠'
                                            : analysisStyleProvider
                                            .analysisStyle ==
                                            'mistico'
                                            ? '🔮'
                                            : analysisStyleProvider
                                            .analysisStyle ==
                                            'hibrido'
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
                                    textCapitalization:
                                        TextCapitalization.sentences,
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
                                  SizedBox(
                                    height: 70,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        if (_dreamController.text
                                            .trim()
                                            .isEmpty) {
                                          return;
                                        }
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          print(
                                            analysisStyleProvider.analysisStyle,
                                          );
                                          final title = await GeminiService()
                                              .generateTitle(
                                                _dreamController.text,
                                                apiKey,
                                                analysisStyle == ''
                                                    ? analysisStyleProvider
                                                        .analysisStyle
                                                    : analysisStyle,
                                                selectedGender!,
                                                userName ?? name,
                                              );
                                          FirebaseService().saveDream(
                                            context,
                                            _dreamController,
                                            _selectedDate,
                                            title,
                                            analysisStyle == ''
                                                ? analysisStyleProvider
                                                    .analysisStyle
                                                : analysisStyle,
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error, intente de nuevo',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          _dreamController.clear();
                                          Navigator.pop(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child:
                                              isLoading
                                                  ? SizedBox(
                                                    width: 25,
                                                    height: 25,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 4,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : Text(
                                                    'Guardar',
                                                    style: TextStyle(
                                                      fontFamily: 'roboto',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                          Colors.purple.shade400,
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

  Widget SelectGender() {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Column(
            children: [
              Text(
                'Selecciona tu género',
                style: RobotoTextStyle.subtitleStyle(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Esto nos permitirá personalizar tu experiencia',
                style: RobotoTextStyle.small2TextStyle(Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGenderCard(
                    context: context,
                    isSelected: selectedGender == 'male',
                    icon: Icons.male,
                    iconColor: Colors.blue,
                    onTap: () => setState(() => selectedGender = 'male'),
                  ),
                  _buildGenderCard(
                    context: context,
                    isSelected: selectedGender == 'female',
                    icon: Icons.female,
                    iconColor: Colors.pinkAccent,
                    onTap: () => setState(() => selectedGender = 'female'),
                  ),
                  _buildGenderCard(
                    context: context,
                    isSelected: selectedGender == 'other',
                    icon: Icons.transgender,
                    iconColor: Colors.purple,
                    onTap: () => setState(() => selectedGender = 'other'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: dontShowAgain,
                    onChanged: (value) {
                      setState(() {
                        dontShowAgain = value ?? false;
                      });
                    },
                    activeColor: Colors.purple,
                    checkColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "No volver a mostrar",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Prefiero no hacerlo',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final userUid = FirebaseAuth.instance.currentUser!.uid;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('dontShowGenderDialog', dontShowAgain);
                    await firestore.collection('users').doc(userUid).update({
                      'selectedGender': selectedGender,
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Continuar',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

Widget _buildGenderCard({
  required BuildContext context,
  required bool isSelected,
  required IconData icon,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade600 : Colors.grey.shade800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 30, color: iconColor)],
      ),
    ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Estás seguro de que quieres cerrar tu sesión?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.purple.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx); // Cerrar diálogo
                          Navigator.pop(context); // Cerrar drawer
                          AuthService().signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Salir',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
