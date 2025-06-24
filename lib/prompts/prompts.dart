class Prompts {
  // Prompt para análisis psicológico
  static const String psychologicalExploration = '''
Explora el siguiente sueño desde una perspectiva psicológica profunda, sin usar tecnicismos. Conecta cada elemento del sueño con emociones internas, partes del subconsciente y símbolos personales.

Usa un tono introspectivo y terapéutico, ayudando a quien lo soñó a comprender qué aspectos de sí mismo podrían estar reflejados. Considera posibles conflictos, deseos, miedos o necesidades emocionales no expresadas.

No des una interpretación absoluta; ofrece caminos posibles de reflexión y crecimiento interior. Usa lenguaje claro, humano y empático.
''';

  // Prompt para análisis místico o espiritual
  static const String mysticalExploration = '''
Interpreta el siguiente sueño desde una perspectiva mística y espiritual. Explora si contiene mensajes del alma, señales del universo o energías que buscan manifestarse.

Usa simbología ancestral, elementos del tarot, astrología o arquetipos espirituales si es relevante. Relaciona los símbolos con posibles sincronicidades, guías internas o aprendizajes del alma.

Tu tono debe ser evocador, intuitivo y respetuoso. No des una verdad absoluta, sino una lectura abierta que invite a la introspección espiritual y la conexión con lo invisible.
''';

  // Prompt para análisis híbrido
  static const String hybridExploration = '''
Analiza el siguiente sueño combinando dos miradas complementarias: la psicológica y la mística.

Desde lo psicológico, conecta el sueño con emociones internas, deseos inconscientes y partes del yo. Desde lo místico, interpreta símbolos, mensajes del alma y posibles señales del universo.

Tu enfoque debe ser equilibrado, integrador y empático. No des respuestas cerradas, sino una reflexión profunda que invite a descubrir tanto el mundo interior como las conexiones espirituales que el sueño pueda revelar.

Tono: introspectivo, simbólico y ligeramente poético. Ideal para quienes buscan comprenderse y sentir que el universo también les habla.

Evita ABSOLUTAMENTE texto entre asteriscos.
''';

  // Prompt de resumen rápido
  static const String quickSummary = '''
Resume brevemente el siguiente sueño en 2-3 frases clave, sin perder su esencia. No hagas análisis, solo resumen.
''';

  // Prompt para detectar emociones principales
  static const String emotionDetection = '''
Detecta y nombra las emociones predominantes presentes en el siguiente sueño. Sé específico y directo.
''';

  // Prompt para simbolismo onírico
  static const String symbolMeaning = '''
Explica el significado simbólico de los elementos presentes en el sueño. Relaciónalos con contextos personales y culturales si es relevante.
''';
}
