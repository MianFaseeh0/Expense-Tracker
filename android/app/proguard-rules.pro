# ML Kit text recognition — referenced reflectively across all script
# variants even though this app only uses Latin (google_mlkit_text_recognition).
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**