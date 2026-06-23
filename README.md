# 🫀 Kardiyovasküler Hastalık (KVH) Risk Tahmin Sistemi

Bireyin sağlık verilerini analiz ederek kalp-damar hastalığı riskini **Düşük / Orta / Yüksek** olarak sınıflandıran bir makine öğrenmesi projesi. Arayüz için bir DART framework'ü olan Flutter kullanılmıştır.

---

## Ne İşe Yarar?

Kardiyovasküler hastalıklar dünya genelinde önde gelen ölüm nedenlerinden biridir. Bu sistem, kişiye ait birkaç temel sağlık göstergesi (BMI, kolesterol değerleri, sigara kullanımı vb.) girilerek o kişinin kalp-damar hastalığına yakalanma riskini otomatik olarak tahmin eder.

Çıktı üç seviyeden biri olur:

| Seviye | Anlam |
|--------|-------|
| **Düşük** | Belirgin bir risk faktörü yok |
| **Orta** | Dikkat edilmesi gereken risk faktörleri mevcut |
| **Yüksek** | Ciddi risk — tıbbi değerlendirme önerilir |

---

## Kullanılan Giriş Özellikleri

Model yalnızca aşağıdaki 7 özellikle çalışır. Bu özellikler korelasyon analizi ile tüm veri setinden seçilmiştir:

| Özellik | Açıklama |
|---------|----------|
| `BMI` | Vücut kitle indeksi |
| `HDL` | İyi kolesterol (mg/dL) |
| `Smoking Status` | Sigara kullanımı (0: Hayır, 1: Evet) |
| `Diabetes Status` | Diyabet durumu (0: Hayır, 1: Evet) |
| `Physical Activity Level` | Fiziksel aktivite (0: Hafif, 1: Orta, 2: Aktif) |
| `Family History of CVD` | Ailede KVH geçmişi (0: Hayır, 1: Evet) |
| `Estimated LDL` | Kötü kolesterol (mg/dL) |

---

## Model ve Teknik Detaylar

Bu projenin odak noktası makine öğrenmesi modelinin doğru kurulması ve optimize edilmesidir.

### Algoritma: Random Forest Classifier

Birden fazla karar ağacının bir araya gelmesiyle oluşan topluluk öğrenmesi (ensemble learning) yöntemi seçildi. Dengesiz sınıf dağılımını dengelemek için `class_weight='balanced'` parametresi kullanıldı.

### Hiperparametre Optimizasyonu

Her parametre için `validation_curve` ile sistematik arama yapıldı, eğitim ve doğrulama skorları karşılaştırılarak en stabil değerler belirlendi:

| Parametre | Test Aralığı | Seçilen Değer |
|-----------|-------------|---------------|
| `n_estimators` | 100 → 500 | **300** |
| `max_depth` | 5 → 40 | **10** |
| `min_samples_leaf` | 5 → 40 | **10** |

### Tahmin Mantığı

Model sınıfların olasılığını da çıkarır (`predict_proba`). 

```
Yüksek risk olasılığı ≥ 0.70  →  Yüksek Kesinlik
Yüksek risk olasılığı ≥ 0.35  →  Orta Kesinlik
Yüksek risk olasılığı < 0.35  →  Düşük Kesinlik
```

Bu yaklaşım, sınır vakalarında daha hassas bir ayrım yapılmasını sağlar.

### Veri Seti

- **1.530 satır** gerçek sağlık verisi (`cvd_dataset.csv`)
- Eksik değerler medyan ile dolduruldu
- Kategorik değişkenler sayısal forma dönüştürüldü
- %75 eğitim / %25 test olarak bölündü (stratified)

---



### English ---------------------


# 🫀 Cardiovascular Disease (CVD) Risk Prediction System

A machine learning project that analyzes an individual's health data and classifies the risk of cardiovascular disease as **Low / Medium / High**. Flutter, a DART framework, was used for the interface.

---

## What is it used for?

Cardiovascular diseases are one of the leading causes of death worldwide. This system automatically predicts a person's risk of developing cardiovascular disease by entering a few basic health indicators of the person (BMI, cholesterol values, smoking, etc.).

The output is one of three levels:

| Level | Meaning |
|--------|------|
| **Low** | No obvious risk factors |
| **Medium** | There are risk factors to consider |
| **High** | Serious risk — medical evaluation recommended |

---

## Input Properties Used

The model only works with the following 7 features. These features were selected from the entire data set by correlation analysis:

| Feature | Description |
|---------|----------|
| `BMI` | Body mass index |
| `HDL` | Good cholesterol (mg/dL) |
| `Smoking Status` | Smoking (0: No, 1: Yes) |
| `Diabetes Status` | Diabetes status (0: No, 1: Yes) |
| `Physical Activity Level` | Physical activity (0: Light, 1: Moderate, 2: Active) |
| `Family History of CVD` | Family history of CVD (0: No, 1: Yes) |
| `Estimated LDL` | Bad cholesterol (mg/dL) |

---

## Model and Technical Details

The focus of this project is the correct establishment and optimization of the machine learning model.

### Algorithm: Random Forest Classifier

The ensemble learning method, which consists of combining more than one decision tree, was chosen. The `class_weight='balanced'` parameter was used to balance the unbalanced class distribution.

### Hyperparameter Optimization

A systematic search was made with `validation_curve` for each parameter, and the most stable values were determined by comparing the training and validation scores:

| Parameter | Test Range | Selected Value |
|-------------|-------------|---------------|
| `n_estimators` | 100 → 500 | **300** |
| `max_depth` | 5 → 40 | **10** |
| `min_samples_leaf` | 5 → 40 | **10** |

### Prediction Logic

The model also infers the probability of the classes (`predict_proba`).

```
High risk probability ≥ 0.70 → High Certainty
High risk probability ≥ 0.35 → Medium Certainty
High risk probability < 0.35 → Low Certainty
```

This approach allows for a more precise distinction in borderline cases.

### Dataset

- **1,530 rows** actual health data (`cvd_dataset.csv`)
- Missing values filled with median
- Categorical variables converted to numerical form
- Divided as 75% training / 25% testing (stratified)

---
