import gradio as gr
import joblib
import numpy as np

try:
    model = joblib.load("kalp_risk_modeli.pkl")
except:
    model = None

def predict_heart_risk(bmi, hdl, smoking, diabetes, activity, family, ldl):
    if model is None:
        return [{"risk": -1, "certainty": 0}]

    # Tüm inputlar int/float olarak geliyor
    input_data = np.array([[bmi, hdl, int(smoking), int(diabetes), int(activity), int(family), ldl]])

    try:
        if hasattr(model, "predict_proba"):
            probs = model.predict_proba(input_data)[0]
            high_risk_prob = probs[2]

            if high_risk_prob >= 0.70:
                risk_level = 2  # YÜKSEK
            elif high_risk_prob >= 0.35:
                risk_level = 1  # ORTA
            else:
                risk_level = 0  # DÜŞÜK

            certainty = int(max(probs) * 100)
        else:
            pred = model.predict(input_data)[0]
            risk_level = 2 if pred == 1 else 0
            certainty = 100

        return [{"risk": risk_level, "certainty": certainty}]

    except Exception as e:
        return [{"risk": -1, "certainty": 0}]

demo = gr.Interface(
    fn=predict_heart_risk,
    inputs=[
        gr.Number(label="BMI"),
        gr.Number(label="HDL"),
        gr.Number(label="Smoking (0/1)"),
        gr.Number(label="Diabetes (0/1)"),
        gr.Number(label="Activity (0=Hafif, 1=Orta, 2=Aktif)"),
        gr.Number(label="Family (0/1)"),
        gr.Number(label="LDL"),
    ],
    outputs="json",
    api_name="predict"
)

demo.launch()