import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultPage extends StatefulWidget {
  final int riskSeviyesi;
  final int kesinlikYuzdesi;

  const ResultPage({
    super.key,
    required this.riskSeviyesi,
    required this.kesinlikYuzdesi,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _riskData = [
    {
      'image': 'assets/images/dusuk.png',
      'label': 'Düşük',
      'accentColor': Color(0xFF4CAF50),
      'bgGlow': Color(0x224CAF50),
    },
    {
      'image': 'assets/images/orta.png',
      'label': 'Orta',
      'accentColor': Color(0xFFFFA726),
      'bgGlow': Color(0x22FFA726),
    },
    {
      'image': 'assets/images/yuksek.png',
      'label': 'Yüksek',
      'accentColor': Color(0xFFE05C53),
      'bgGlow': Color(0x22E05C53),
    },
  ];

  Map<String, dynamic> get _current {
    final idx = widget.riskSeviyesi.clamp(0, 2);
    return Map<String, dynamic>.from(_riskData[idx]);
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final accent = _current['accentColor'] as Color;
    final bgGlow = _current['bgGlow'] as Color;
    final label = _current['label'] as String;
    final imagePath = _current['image'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Color(0xFFE05C53),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'KARDİYOVASKÜLER RİSK',
                              style: GoogleFonts.archivoBlack(
                                color: const Color(0xFFE05C53),
                                fontSize: 11,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),

                    SizedBox(height: height * 0.02),

                    Text(
                      'ANALİZ',
                      style: GoogleFonts.dmSerifDisplay(
                        color: Colors.white,
                        fontSize: 36,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'SONUCU',
                      style: GoogleFonts.dmSerifDisplay(
                        color: const Color(0xFFE05C53),
                        fontSize: 36,
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    Container(
                      width: width * 0.85,
                      height: height * 0.2,
                      decoration: BoxDecoration(
                        color: bgGlow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: accent.withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: accent.withOpacity(0.18),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Image.asset(
                        imagePath,
                        height: height * 0.28,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.favorite,
                          color: accent,
                          size: height * 0.18,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: accent.withOpacity(0.5)),
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: GoogleFonts.archivoBlack(
                          color: accent,
                          fontSize: 13,
                          letterSpacing: 3,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.025),

                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.dmSerifDisplay(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '%${widget.kesinlikYuzdesi.toStringAsFixed(1)} ',
                            style: GoogleFonts.dmSerifDisplay(
                              color: accent,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                            text: 'kesinlikle kalp\nkrizi riskiniz ',
                          ),
                          TextSpan(
                            text: label,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.03),

                    Container(
                      width: width * 0.85,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13170E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFBDBCBC),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bu sonuç yalnızca bilgilendirme amaçlıdır. '
                              'Kesin tanı için bir kardiyolog ile görüşmeniz önerilir.',
                              style: TextStyle(
                                color: const Color(0xFFBDBCBC),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    SizedBox(
                      width: width * 0.85,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(
                          'Tekrar Analiz Et',
                          style: GoogleFonts.archivoBlack(
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.06),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
