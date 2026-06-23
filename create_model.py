from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import precision_recall_fscore_support, confusion_matrix, accuracy_score, ConfusionMatrixDisplay
from sklearn.model_selection import train_test_split, GridSearchCV, validation_curve
from imblearn.under_sampling import RandomUnderSampler
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import joblib
import seaborn as sns





dataset = pd.read_csv('cvd_dataset.csv')

print("Eksik veriler doldurulmadan önce veriseti\n",dataset.isnull().sum())

for col in dataset.select_dtypes(include='number'):
    dataset[col] = dataset[col].fillna(dataset[col].median())
print("-------------------------------------------------------------------------------------")    
print("Eksik veriler doldurulduktan sonra veriseti\n",dataset.isnull().sum())

dataset = dataset.drop( columns=["CVD Risk Score", "Blood Pressure (mmHg)", 'Height (m)'])

mapping_dict = {
    'Sex': {'M': 1, 'F': 0},
    'Smoking Status': {'Y': 1, 'N': 0},
    'Diabetes Status': {'Y': 1, 'N': 0},
    'Family History of CVD': {'Y': 1, 'N': 0},
    'Physical Activity Level': {'Low': 0, 'Moderate': 1, 'High': 2},
    'Blood Pressure Category': {'Normal': 0, 'Elevated': 1, 'Hypertension Stage 1': 2, 'Hypertension Stage 2': 3},
    'CVD Risk Level': {'LOW': 0, 'INTERMEDIARY': 1, 'HIGH': 2}
}

for col, mapping in mapping_dict.items():
    if col in dataset.columns:
        dataset[col] = dataset[col].map(mapping)

corr_matrix = dataset.select_dtypes(include=[np.number]).corr()

plt.figure(figsize=(16, 12))
sns.heatmap(corr_matrix, annot=True, fmt=".2f", cmap='coolwarm', center=0, linewidths=0.5)
plt.title('CVD Veri Seti - Detaylı Korelasyon Matrisi')
plt.xticks(rotation=45, ha='right')
plt.yticks(rotation=0)
plt.tight_layout()
plt.savefig('korelasyon_matrisi.png', dpi=300)



secilen_ozellikler = ["BMI","HDL (mg/dL)","Smoking Status","Diabetes Status", "Physical Activity Level", "Family History of CVD","Estimated LDL (mg/dL)"]

X = dataset[secilen_ozellikler]   
y = dataset["CVD Risk Level"]





X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=42, stratify=y)

# rus = RandomUnderSampler(random_state=42)
# X_train, y_train = rus.fit_resample(X_train, y_train)

print("Risk Seviyelerine Göre Dağılım:")
print(y_train.value_counts())
print("\nYüzdesel Dağılım:")
print(y_train.value_counts(normalize=True) * 100)




# Hiperparametre Başarı Grafikleri

param_grid = {
    'n_estimators': np.arange(100,501,50),
    'max_depth': np.arange(5,41,5),
    'min_samples_leaf': np.arange(5,41,5)
}


for p in param_grid.keys():
    param_range = param_grid[p]
    train_scores, test_scores = validation_curve(
        RandomForestClassifier(class_weight='balanced'),
        X_train, y_train, param_name=p, param_range=param_range,
        cv=3, scoring="f1_weighted", n_jobs=-1
    )

    train_mean = np.mean(train_scores, axis=1)
    test_mean = np.mean(test_scores, axis=1)

    plt.figure(figsize=(10, 6))
    plt.plot(param_range, train_mean, label="Eğitim Skoru (Train)", color="blue", marker='o')
    plt.plot(param_range, test_mean, label="Test Skoru (Validation)", color="red", marker='s')
    plt.title("Random Forest : ("+p+")")
    plt.xlabel("("+p+")")
    plt.ylabel("Weighted F-1 Score")
    plt.legend(loc="best")
    plt.grid(True)
    plt.savefig('overfit_analizi'+p+'.png', dpi=300, bbox_inches='tight')

    

# %%

# Eğitim
best_rf = RandomForestClassifier(n_estimators=300, max_depth=10, min_samples_leaf=10, class_weight='balanced')


best_rf.fit(X_train, y_train)

# Test seti üzerinde tahmin yapma ve başarıyı ölçme
y_pred = best_rf.predict(X_test)

macroavg = precision_recall_fscore_support(y_true=y_test, y_pred=y_pred, average='macro')
weightedavg = precision_recall_fscore_support(y_true=y_test, y_pred=y_pred, average='weighted')

print("------------------------------------------------------------------------------")
print(f"Accuracy Score : {accuracy_score(y_test, y_pred)}")
print("------------------------------------------------------------------------------")
print(f"Weighted Precision : {weightedavg[0]}, Weighted Recall : {weightedavg[1]}, Weighted F-1 Score : {weightedavg[2]}")
print("------------------------------------------------------------------------------")
print(f"Macro Precision : {macroavg[0]}, Macro Recall : {macroavg[1]}, Macro F-1 Score : {macroavg[2]}")
print("------------------------------------------------------------------------------")


# Özelliklerin önem sıralaması tablosu çizdirme
fi = pd.Series(best_rf.feature_importances_, index=secilen_ozellikler).sort_values(ascending=False)

plt.figure(figsize=(12, 8))
colors = ['#e74c3c' if i < 5 else '#3498db' if i < 10 else '#95a5a6' for i in range(len(fi))]
bars = plt.barh(fi.index[::-1], fi.values[::-1], color=colors[::-1])
plt.title('Random Forest – Feature Importance\n(Kırmızı: En Etkili 5, Mavi: 6-10)', fontsize=13)
plt.xlabel('Önem Skoru')
plt.tight_layout()
plt.savefig('ozellik_onem_tablosu.png', dpi=300, bbox_inches='tight')
plt.close()


      
# Confusion Matrix Çizdirme
cm = confusion_matrix(y_test, y_pred)
disp = ConfusionMatrixDisplay(confusion_matrix=cm, 
                              display_labels=['Düşük', 'Orta', 'Yüksek'])
plt.figure(figsize=(10, 8))
disp.plot(cmap='Blues', values_format='d')

plt.title('Kalp Krizi Riski Tahmin Karmaşıklık Matrisi')
plt.xlabel('Modelin Tahmini')
plt.ylabel('Gerçek Durum')
plt.savefig('karisiklik_matrisi.png', dpi=300, bbox_inches='tight')
# %%

# Modeli kaydetme

joblib.dump(best_rf, 'kalp_risk_modeli.pkl')