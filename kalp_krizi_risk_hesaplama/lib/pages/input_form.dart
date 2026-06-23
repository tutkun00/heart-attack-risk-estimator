import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kalp_krizi_risk_hesaplama/pages/result_page.dart';
import 'package:kalp_krizi_risk_hesaplama/widgets/boxTitle.dart';
import 'package:kalp_krizi_risk_hesaplama/widgets/elevatedButton.dart';

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  // ── Toplam adım: boy/kilo(bmi)=1, hdl=1, ldl=1, sigara=1,
  //    aktivite=1, diyabet=1, kalp=1  → 7
  late int toplamAdimSayisi;
  ValueNotifier<int> tamamlananAdimSayisi = ValueNotifier(0);
  late bool button;

  // Smoking(0/1), Diabetes(0/1), Activity(0/1/2), Family(0/1)
  int? sigara = null, diyabet = null, aktivite = null, aileKalp = null;

  // ── Renk durumları ──
  Color sigaraEvet = Colors.white, sigaraHayir = Colors.white;
  Color diyabetEvet = Colors.white, diyabetHayir = Colors.white;
  Color kalpEvet = Colors.white, kalpHayir = Colors.white;
  Color fizikselAktDusuk = Colors.white,
      fizikselAktOrta = Colors.white,
      fizikselAktYuksek = Colors.white;

  String aktiviteDuzeyi = '';

  int riskSkoru = 0;
  int riskKesinlik = 0;

  // ── Controller'lar ──
  late TextEditingController boyController;
  late TextEditingController kiloController;
  late TextEditingController hdlController;
  late TextEditingController ldlController;

  // ── Tamamlanma bayrakları ──
  bool trueBmi = false;
  bool trueHDL = false;
  bool trueLDL = false;
  bool trueAktivite = false;

  // ── BMI hesaplama ──
  double? bmiDeger;

  String get bmiKategori {
    if (bmiDeger == null) return '';
    if (bmiDeger! < 18.5) return 'Zayıf';
    if (bmiDeger! < 25.0) return 'Normal ✓';
    if (bmiDeger! < 30.0) return 'Fazla Kilolu';
    return 'Obez';
  }

  Color get bmiKategoriRenk {
    if (bmiDeger == null) return Colors.grey;
    if (bmiDeger! < 18.5) return Colors.blue;
    if (bmiDeger! < 25.0) return const Color(0xFF22D3A8);
    if (bmiDeger! < 30.0) return Colors.amber;
    return Colors.redAccent;
  }

  void _hesaplaBmi() {
    final boy = double.tryParse(boyController.text);
    final kilo = double.tryParse(kiloController.text);
    if (boy != null && kilo != null && boy > 0 && kilo > 0) {
      final bmi = kilo / ((boy / 100) * (boy / 100));
      setState(() => bmiDeger = bmi);
      if (!trueBmi) {
        trueBmi = true;
        tamamlananAdimSayisi.value += 1;
      }
    } else {
      setState(() => bmiDeger = null);
      if (trueBmi) {
        trueBmi = false;
        tamamlananAdimSayisi.value -= 1;
      }
    }
  }

  @override
  void initState() {
    toplamAdimSayisi = 7;
    button = false;
    boyController = TextEditingController();
    kiloController = TextEditingController();
    hdlController = TextEditingController()..text = '0';
    ldlController = TextEditingController()..text = '0';

    super.initState();

    tamamlananAdimSayisi.addListener(() {
      setState(() {
        button = tamamlananAdimSayisi.value == toplamAdimSayisi;
      });
    });
  }

  @override
  void dispose() {
    boyController.dispose();
    kiloController.dispose();
    hdlController.dispose();
    ldlController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────
  // HDL / LDL değişim fonksiyonları
  // ────────────────────────────────────────────────────
  void changedHDLWidget(String value) {
    final v = value.trim();
    if (v != '0' && v.isNotEmpty && !trueHDL) {
      trueHDL = true;
      tamamlananAdimSayisi.value += 1;
    } else if ((v == '0' || v.isEmpty) && trueHDL) {
      trueHDL = false;
      tamamlananAdimSayisi.value -= 1;
    }
  }

  void changedLDLWidget(String value) {
    final v = value.trim();
    if (v != '0' && v.isNotEmpty && !trueLDL) {
      trueLDL = true;
      tamamlananAdimSayisi.value += 1;
    } else if ((v == '0' || v.isEmpty) && trueLDL) {
      trueLDL = false;
      tamamlananAdimSayisi.value -= 1;
    }
  }

  // Aktivite seçim yardımcısı
  void _setAktivite(String durum) {
    setState(() {
      fizikselAktDusuk = Colors.white;
      fizikselAktOrta = Colors.white;
      fizikselAktYuksek = Colors.white;
      aktiviteDuzeyi = durum;
      switch (durum) {
        case 'dusuk':
          fizikselAktDusuk = Colors.red;
          break;
        case 'orta':
          fizikselAktOrta = Colors.yellow.shade700;
          break;
        case 'yuksek':
          fizikselAktYuksek = Colors.green;
          break;
      }
    });
    if (!trueAktivite) {
      trueAktivite = true;
      tamamlananAdimSayisi.value += 1;
    }
  }

  // ── Renk sabitler ──
  static const _bgColor = Color.fromARGB(255, 10, 15, 26);
  static const _cardColor = Color.fromARGB(255, 19, 23, 14);
  static const _accentRed = Color.fromARGB(255, 224, 92, 83);
  static const _textMuted = Color.fromARGB(255, 189, 188, 188);

  // ── Tekrar eden dekorasyon ──
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: _cardColor,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: Colors.white12),
  );

  InputDecoration _numInputDecoration() => const InputDecoration(
    floatingLabelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(borderSide: BorderSide.none),
  );

  TextStyle get _numStyle => const TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  // ────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: h / 10),

            // ── Başlık ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                const Icon(Icons.favorite, color: _accentRed),
                const Spacer(flex: 1),
                Text(
                  'KARDİYOVASKÜLER',
                  style: GoogleFonts.archivoBlack(
                    color: _accentRed,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.7,
                    fontSize: 12,
                  ),
                ),
                const Spacer(flex: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Text(
                  'RİSK',
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const Spacer(flex: 1),
                Text(
                  'ANALİZİ',
                  style: GoogleFonts.dmSerifDisplay(
                    color: _accentRed,
                    fontSize: 32,
                  ),
                ),
                const Spacer(flex: 20),
              ],
            ),
            SizedBox(
              width: w * 0.90,
              child: const Text(
                'Parametrelerinizi girerek kardiyovasküler risk skorunuzu hesaplayın.',
                softWrap: true,
                style: TextStyle(color: _textMuted),
              ),
            ),
            SizedBox(height: h / 40),

            // ── Progress ────────────────────────────────
            ValueListenableBuilder<int>(
              valueListenable: tamamlananAdimSayisi,
              builder: (_, val, __) => SizedBox(
                width: w * 0.9,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tamamlanan',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '%${((val / toplamAdimSayisi) * 100).toInt()}',
                          style: const TextStyle(color: _textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: val / toplamAdimSayisi,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.redAccent,
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: h / 40),

            // ════════════════════════════════════════════
            // BÖLÜM: VÜCUT ÖLÇÜMLERİ
            // ════════════════════════════════════════════
            _sectionLabel('VÜCUT ÖLÇÜMLERİ', w),
            SizedBox(height: h / 100),

            Container(
              width: w * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Boxtitle(tt1: 'Vücut Kitle İndeksi (BMI)', tt2: ''),
                  const SizedBox(height: 12),

                  // Boy & Kilo satırı
                  Row(
                    children: [
                      // Boy
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Boy',
                              style: TextStyle(color: _textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2235),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: boyController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _hesaplaBmi(),
                                      cursorColor: Colors.white,
                                      textAlign: TextAlign.center,
                                      style: _numStyle,
                                      decoration: _numInputDecoration()
                                          .copyWith(hintText: '170'),
                                    ),
                                  ),
                                  const Text(
                                    'cm',
                                    style: TextStyle(
                                      color: Color(0xFF3A5A7A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Kilo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kilo',
                              style: TextStyle(color: _textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A2235),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: kiloController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _hesaplaBmi(),
                                      cursorColor: Colors.white,
                                      textAlign: TextAlign.center,
                                      style: _numStyle,
                                      decoration: _numInputDecoration()
                                          .copyWith(hintText: '70'),
                                    ),
                                  ),
                                  const Text(
                                    'kg',
                                    style: TextStyle(
                                      color: Color(0xFF3A5A7A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // BMI sonuç satırı
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2235),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bmiDeger != null ? bmiDeger!.toStringAsFixed(1) : '—',
                          style: GoogleFonts.dmSerifDisplay(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        if (bmiDeger != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: bmiKategoriRenk.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              bmiKategori,
                              style: TextStyle(
                                color: bmiKategoriRenk,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const Text(
                            'Hesaplanacak',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: h / 100),
            _infoTip(
              'Boy ve kilodan otomatik hesaplanır. Manuel girişe gerek yok.',
              w,
            ),
            SizedBox(height: h / 40),

            // ════════════════════════════════════════════
            // BÖLÜM: KAN DEĞERLERİ
            // ════════════════════════════════════════════
            _sectionLabel('KAN DEĞERLERİ', w),
            SizedBox(height: h / 100),

            // HDL
            _stepperCard(
              width: w,
              height: h,
              title: 'HDL Kolesterol',
              unit: 'mg/dL',
              controller: hdlController,
              onChanged: changedHDLWidget,
            ),
            SizedBox(height: h / 100),

            // LDL
            _stepperCard(
              width: w,
              height: h,
              title: 'Tahmini LDL Kolesterol',
              unit: 'mg/dL',
              controller: ldlController,
              onChanged: changedLDLWidget,
            ),
            SizedBox(height: h / 40),

            // ════════════════════════════════════════════
            // BÖLÜM: YAŞAM TARZI
            // ════════════════════════════════════════════
            _sectionLabel('YAŞAM TARZI', w),
            SizedBox(height: h / 100),

            // Sigara
            Container(
              width: w * 0.9,
              height: h / 8,
              decoration: _cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Spacer(),
                  Boxtitle(tt1: 'Sigara Kullanım Durumu', tt2: ''),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: h / 20,
                        child: BuildButton(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          onTop: () {
                            sigara = 1;
                            if (sigaraEvet == Colors.red) {
                              setState(() {
                                sigaraEvet = Colors.white;
                                sigaraHayir = Colors.white;
                              });
                              tamamlananAdimSayisi.value -= 1;
                            } else if (sigaraHayir == Colors.green) {
                              setState(() {
                                sigaraHayir = Colors.white;
                                sigaraEvet = Colors.red;
                              });
                            } else {
                              setState(() => sigaraEvet = Colors.red);
                              tamamlananAdimSayisi.value += 1;
                            }
                          },
                          width: w * 0.39,
                          text: 'Evet',
                          height: h,
                          icon: Icons.smoking_rooms_rounded,
                          styleColor: sigaraEvet,
                          column: false,
                          active: true,
                        ),
                      ),
                      SizedBox(
                        height: h / 20,
                        child: BuildButton(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          onTop: () {
                            sigara = 0;
                            if (sigaraHayir == Colors.green) {
                              setState(() {
                                sigaraHayir = Colors.white;
                                sigaraEvet = Colors.white;
                              });
                              tamamlananAdimSayisi.value -= 1;
                            } else if (sigaraEvet == Colors.red) {
                              setState(() {
                                sigaraEvet = Colors.white;
                                sigaraHayir = Colors.green;
                              });
                            } else {
                              setState(() => sigaraHayir = Colors.green);
                              tamamlananAdimSayisi.value += 1;
                            }
                          },
                          width: w * 0.39,
                          text: 'Hayır',
                          height: h,
                          icon: Icons.smoke_free,
                          styleColor: sigaraHayir,
                          column: false,
                          active: true,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(height: h / 100),

            // Fiziksel Aktivite
            Container(
              width: w * 0.9,
              height: h / 4,
              decoration: _cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Spacer(),
                  Boxtitle(tt1: 'Fiziksel Aktivite Düzeyi', tt2: ''),
                  const Spacer(),
                  SizedBox(
                    height: h / 20,
                    child: BuildButton(
                      color: const Color.fromARGB(255, 35, 35, 35),
                      onTop: () {
                        _setAktivite('dusuk');
                        aktivite = 0;
                      },
                      width: w * 0.8,
                      text: 'Düşük',
                      height: h,
                      icon: Icons.self_improvement_outlined,
                      styleColor: fizikselAktDusuk,
                      column: false,
                      active: true,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: h / 20,
                    child: BuildButton(
                      color: const Color.fromARGB(255, 35, 35, 35),
                      onTop: () {
                        _setAktivite('orta');
                        aktivite = 1;
                      },
                      width: w * 0.8,
                      text: 'Orta',
                      height: h,
                      icon: Icons.directions_walk_outlined,
                      styleColor: fizikselAktOrta,
                      column: false,
                      active: true,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: h / 20,
                    child: BuildButton(
                      color: const Color.fromARGB(255, 35, 35, 35),
                      onTop: () {
                        _setAktivite('yuksek');
                        aktivite = 2;
                      },
                      width: w * 0.8,
                      text: 'Yüksek',
                      height: h,
                      icon: Icons.directions_run_outlined,
                      styleColor: fizikselAktYuksek,
                      column: false,
                      active: true,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(height: h / 40),

            // ════════════════════════════════════════════
            // BÖLÜM: SAĞLIK GEÇMİŞİ
            // ════════════════════════════════════════════
            _sectionLabel('SAĞLIK GEÇMİŞİ', w),
            SizedBox(height: h / 100),

            // Diyabet
            Container(
              width: w * 0.9,
              height: h / 8,
              decoration: _cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Spacer(),
                  Boxtitle(tt1: 'Diyabet Tanısı Var mı?', tt2: ''),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: h / 20,
                        child: BuildButton(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          onTop: () {
                            diyabet = 1;
                            if (diyabetEvet == Colors.red) {
                              setState(() {
                                diyabetEvet = Colors.white;
                                diyabetHayir = Colors.white;
                              });
                              tamamlananAdimSayisi.value -= 1;
                            } else if (diyabetHayir == Colors.green) {
                              setState(() {
                                diyabetHayir = Colors.white;
                                diyabetEvet = Colors.red;
                              });
                            } else {
                              setState(() => diyabetEvet = Colors.red);
                              tamamlananAdimSayisi.value += 1;
                            }
                          },
                          width: w * 0.39,
                          text: 'Evet',
                          height: h,
                          icon: Icons.warning_amber_outlined,
                          styleColor: diyabetEvet,
                          column: false,
                          active: true,
                        ),
                      ),
                      SizedBox(
                        height: h / 20,
                        child: BuildButton(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          onTop: () {
                            diyabet = 0;
                            if (diyabetHayir == Colors.green) {
                              setState(() {
                                diyabetHayir = Colors.white;
                                diyabetEvet = Colors.white;
                              });
                              tamamlananAdimSayisi.value -= 1;
                            } else if (diyabetEvet == Colors.red) {
                              setState(() {
                                diyabetEvet = Colors.white;
                                diyabetHayir = Colors.green;
                              });
                            } else {
                              setState(() => diyabetHayir = Colors.green);
                              tamamlananAdimSayisi.value += 1;
                            }
                          },
                          width: w * 0.39,
                          text: 'Hayır',
                          height: h,
                          icon: Icons.check_sharp,
                          styleColor: diyabetHayir,
                          column: false,
                          active: true,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(height: h / 100),

            // Kalp Hastalığı Öyküsü
            Container(
              width: w * 0.9,
              height: h / 8,
              decoration: _cardDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Spacer(),
                  Boxtitle(tt1: 'Ailede Kalp Hastalığı Öyküsü', tt2: ''),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: h / 20,
                        child: BuildButton(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          onTop: () {
                            aileKalp = 1;
                            if (kalpEvet == Colors.red) {
                              setState(() {
                                kalpEvet = Colors.white;
                                kalpHayir = Colors.white;
                              });
                              tamamlananAdimSayisi.value -= 1;
                            } else if (kalpHayir == Colors.green) {
                              setState(() {
                                kalpHayir = Colors.white;
                                kalpEvet = Colors.red;
                              });
                            } else {
                              setState(() => kalpEvet = Colors.red);
                              tamamlananAdimSayisi.value += 1;
                            }
                          },
                          width: w * 0.39,
                          text: 'Evet',
                          height: h,
                          icon: Icons.warning_amber_outlined,
                          styleColor: kalpEvet,
                          column: false,
                          active: true,
                        ),
                      ),
                      SizedBox(
                        height: h / 20,
                        child: BuildButton(
                          color: const Color.fromARGB(255, 35, 35, 35),
                          onTop: () {
                            aileKalp = 0;
                            if (kalpHayir == Colors.green) {
                              setState(() {
                                kalpHayir = Colors.white;
                                kalpEvet = Colors.white;
                              });
                              tamamlananAdimSayisi.value -= 1;
                            } else if (kalpEvet == Colors.red) {
                              setState(() {
                                kalpEvet = Colors.white;
                                kalpHayir = Colors.green;
                              });
                            } else {
                              setState(() => kalpHayir = Colors.green);
                              tamamlananAdimSayisi.value += 1;
                            }
                          },
                          width: w * 0.39,
                          text: 'Hayır',
                          height: h,
                          icon: Icons.check_sharp,
                          styleColor: kalpHayir,
                          column: false,
                          active: true,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SizedBox(height: h / 50),

            // ── Analiz Butonu ────────────────────────────
            SizedBox(
              height: h / 20,
              child: BuildButton(
                color: Colors.redAccent,
                onTop: () async {
                  await tahminYap();
                  debugPrint(riskSkoru.toString());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultPage(
                        kesinlikYuzdesi: riskKesinlik,
                        riskSeviyesi: riskSkoru,
                      ),
                    ),
                  );
                },
                width: w * 0.9,
                text: 'Analizi Başlat',
                height: h,
                icon: Icons.arrow_forward,
                styleColor: Colors.white,
                column: false,
                active: button,
              ),
            ),
            SizedBox(height: h / 80),
            _infoTip(
              'Tüm alanlar doldurulduğunda analiz butonu aktif olur.',
              w,
            ),
            SizedBox(height: h / 10),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // YARDIMCI WIDGET METODLARİ
  // ────────────────────────────────────────────────────

  Widget _sectionLabel(String text, double w) => SizedBox(
    width: w * 0.85,
    child: Text(
      text,
      softWrap: true,
      style: const TextStyle(
        color: _textMuted,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
    ),
  );

  Widget _infoTip(String text, double w) => SizedBox(
    width: w * 0.90,
    child: Row(
      children: [
        const Icon(Icons.info_outlined, color: _textMuted, size: 18),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            softWrap: true,
            style: const TextStyle(color: _textMuted, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  /// Stepper kartı — HDL ve LDL için ortak
  Widget _stepperCard({
    required double width,
    required double height,
    required String title,
    required String unit,
    required TextEditingController controller,
    required void Function(String) onChanged,
  }) {
    return Container(
      width: width * 0.9,
      height: height / 8,
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Spacer(),
          Boxtitle(tt1: title, tt2: unit),
          const Spacer(),
          Container(
            width: width * 0.8,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Azalt
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white70),
                  onLongPress: () {
                    setState(() => controller.text = '0');
                    onChanged('0');
                  },
                  onPressed: () {
                    final cur = int.tryParse(controller.text) ?? 0;
                    final next = (cur - 5).clamp(0, 9999);
                    setState(() => controller.text = next.toString());
                    onChanged(controller.text);
                  },
                ),
                // Text field
                SizedBox(
                  width: width * 0.4,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    onChanged: onChanged,
                    cursorColor: Colors.white,
                    textAlign: TextAlign.center,
                    style: _numStyle,
                    decoration: _numInputDecoration(),
                  ),
                ),
                // Artır
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70),
                  onLongPress: () {
                    final cur = int.tryParse(controller.text) ?? 0;
                    setState(() => controller.text = (cur + 50).toString());
                    onChanged(controller.text);
                  },
                  onPressed: () {
                    final cur = int.tryParse(controller.text) ?? 0;
                    setState(() => controller.text = (cur + 5).toString());
                    onChanged(controller.text);
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<void> tahminYap() async {
    final baseUrl = 'https://umut8001-kardiyovaskuler.hf.space';

    // Sıralama: BMI, HDL, Smoking(0/1), Diabetes(0/1), Activity(0/1/2), Family(0/1), LDL
    print(bmiDeger);
    print(hdlController.text);
    print(sigara);
    print(diyabet);
    print(aktivite);
    print(aileKalp);
    print(ldlController.text);

    List<dynamic> inputData = [
      bmiDeger,
      double.parse(hdlController.text),
      sigara,
      diyabet,
      aktivite,
      aileKalp,
      double.parse(ldlController.text),
    ];

    try {
      // 1. ADIM: İsteği gönder, event_id al
      var postResponse = await http.post(
        Uri.parse('$baseUrl/gradio_api/call/predict'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"data": inputData}),
      );

      if (postResponse.statusCode != 200) {
        print("Post Hata: ${postResponse.statusCode} - ${postResponse.body}");
        return;
      }

      final eventId = jsonDecode(postResponse.body)['event_id'];
      print("Event ID: $eventId");

      // 2. ADIM: Sonucu al
      var getResponse = await http.get(
        Uri.parse('$baseUrl/gradio_api/call/predict/$eventId'),
      );

      print("HAM SONUÇ: ${getResponse.body}");

      if (getResponse.statusCode != 200) {
        print("Get Hata: ${getResponse.statusCode}");
        return;
      }

      // Gradio 6 SSE formatında dönüyor, her satırı parse et
      final lines = getResponse.body.split('\n');
      Map<String, dynamic>? sonuc;

      for (var line in lines) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          try {
            final parsed = jsonDecode(jsonStr);
            if (parsed is List && parsed[0] is List) {
              sonuc = parsed[0][0]; // [[{...}]] → {risk, certainty}
              break;
            } else if (parsed is List) {
              sonuc = parsed[0];
              break;
            }
          } catch (_) {}
        }
      }

      if (sonuc == null) {
        print("Sonuç parse edilemedi");
        return;
      }

      int risk = sonuc['risk'];
      riskKesinlik = sonuc['certainty'];

      /*if (risk == 0) {
        riskSkoru = 2;
      } else if (risk == 2) {
        riskSkoru = 0;
      } else if (risk == 1) {
        riskSkoru = 1;
      }*/

      riskSkoru = risk;

      print("Risk: $riskSkoru, Kesinlik: %$riskKesinlik");
    } catch (e) {
      print("Hata: $e");
    }
  }
}
