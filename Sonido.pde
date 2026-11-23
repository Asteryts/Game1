// =====================================================================================
//  SONIDO.pde -> efectos y musica generados con notas (traido de Red Quest)
//  No usa archivos: cada sonido se "fabrica" sumando ondas triangulares nota por nota.
//  M = prender / apagar la musica. En la pausa hay botones para musica y efectos.
// =====================================================================================

import javax.sound.sampled.*;

final int TASA = 22050;
Clip[] efectoSonido = new Clip[20];
Clip[] pistaMusica = new Clip[4];
int musicaSonando = -1;
boolean musicaActiva = true;
boolean efectosActivos = true;

// efectos (las notas son numeros MIDI: 60 = do central)
//  0 clic, 1 paso, 2 puerta, 3 notificacion, 4 monedas, 5 logro/compra, 6 decision buena,
//  7 decision mala, 8 tic, 9 perder, 10 fin de juego, 11 record, 12 fin del dia, 13 dia nuevo / premio,
//  14..19 voces de los personajes
int[][] notasEfecto = {
  {76}, {40}, {52, 60}, {79, 84}, {72, 76, 79, 84}, {72, 76, 79, 84, 88, 91}, {72, 76, 79}, {55, 51, 48}, {96},
  {57, 60, 64, 60, 57, 0, 45}, {60, 64, 67, 64, 60, 62, 60}, {72, 76, 79, 84, 79, 84, 88}, {57, 60, 64, 65, 64, 72, 69},
  {60, 67, 72, 76, 79, 84}, {64}, {76}, {60}, {48}, {70, 73}, {57}
};
float[] tiempoEfecto = {0.04, 0.03, 0.07, 0.10, 0.08, 0.08, 0.09, 0.12, 0.03, 0.22, 0.20, 0.18, 0.24, 0.25, 0.03, 0.03, 0.03, 0.035, 0.02, 0.03};
float[] volumenEfecto = {0.18, 0.06, 0.18, 0.24, 0.24, 0.27, 0.21, 0.21, 0.03, 0.17, 0.17, 0.18, 0.17, 0.17, 0.07, 0.07, 0.07, 0.08, 0.06, 0.06};

// musica: 0 sombrio, 1 regulado, 2 brillante, 3 viento (sin notas)
int[][] melodia = {
  {60, 0, 64, 0, 65, 64, 60, 0, 59, 0, 62, 0, 64, 62, 59, 0, 57, 0, 60, 0, 64, 65, 64, 60, 59, 60, 59, 0, 57, 0, 0, 0},
  {64, 0, 67, 0, 69, 67, 64, 0, 62, 0, 65, 0, 67, 65, 62, 0, 60, 0, 64, 0, 67, 69, 67, 64, 62, 64, 62, 0, 60, 0, 0, 0},
  {76, 72, 79, 76, 81, 79, 76, 72, 74, 71, 77, 74, 79, 77, 74, 71, 72, 76, 79, 76, 81, 83, 79, 76, 74, 76, 74, 71, 72, 0, 72, 0}
};
int[][] bajo = {
  {45, 45, 40, 40, 41, 38, 40, 45},
  {48, 48, 43, 43, 45, 41, 43, 48},
  {48, 48, 43, 43, 45, 41, 43, 48}
};
float[] tiempoMusica = {0.52, 0.38, 0.27};

float frecuencia(int nota) {
  return 440 * pow(2, (nota - 69) / 12.0);
}

float ondaTriangular(float f) {
  return 4 * abs(f % 1 - 0.5) - 1;
}

void sumarNota(float[] pista, int inicio, float duracion, int nota, float volumen) {
  if (nota == 0) return;
  int total = int(duracion * TASA);
  float f = frecuencia(nota);
  for (int i = 0; i < total; i++) {
    if (inicio + i < pista.length) {
      float onda = ondaTriangular(i * f / TASA);
      float apaga = 1 - i / float(total);
      pista[inicio + i] += onda * volumen * apaga * min(1, i / 60.0);
    }
  }
}

Clip crearClip(float[] pista) {
  byte[] datos = new byte[pista.length * 2];
  for (int i = 0; i < pista.length; i++) {
    int valor = int(constrain(pista[i], -1, 1) * 32767);
    datos[i * 2] = (byte) (valor & 255);
    datos[i * 2 + 1] = (byte) (valor >> 8);
  }
  try {
    AudioFormat formato = new AudioFormat(TASA, 16, 1, true, false);
    Clip clip = AudioSystem.getClip();
    Clip.class.getMethod("open", AudioFormat.class, datos.getClass(), Integer.TYPE, Integer.TYPE).invoke(clip, formato, datos, 0, datos.length);
    return clip;
  }
  catch (Exception e) {
    println("Sin sonido: " + e);
    return null;
  }
}

void cargarSonidos() {
  for (int e = 0; e < efectoSonido.length; e++) {
    int notas = notasEfecto[e].length;
    float[] pista = new float[int(notas * tiempoEfecto[e] * TASA)];
    for (int i = 0; i < notas; i++) sumarNota(pista, int(i * tiempoEfecto[e] * TASA), tiempoEfecto[e], notasEfecto[e][i], volumenEfecto[e]);
    efectoSonido[e] = crearClip(pista);
  }
  for (int m = 0; m < 3; m++) {
    float paso = tiempoMusica[m];
    float[] pista = new float[int(32 * paso * TASA)];
    for (int i = 0; i < 32; i++) sumarNota(pista, int(i * paso * TASA), paso * 1.4, melodia[m][i], 0.075);
    for (int i = 0; i < 8; i++) sumarNota(pista, int(i * 4 * paso * TASA), paso * 4, bajo[m][i], 0.07);
    pistaMusica[m] = crearClip(pista);
  }
  float[] viento = new float[6 * TASA];
  float suave = 0;
  for (int i = 0; i < viento.length; i++) {
    suave += (random(-1, 1) - suave) * 0.03;
    viento[i] = suave * 0.6 * (0.6 + 0.4 * sin(i * TWO_PI / viento.length));
  }
  pistaMusica[3] = crearClip(viento);
}

void sonar(int e) {
  if (!efectosActivos || e < 0 || e >= efectoSonido.length || efectoSonido[e] == null) return;
  efectoSonido[e].stop();
  efectoSonido[e].setFramePosition(0);
  efectoSonido[e].start();
}

// voz de cada personaje mientras habla (siempre la misma para la misma persona)
void sonarVoz(String quien) {
  if (frameCount % 4 == 0) sonar(14 + abs(quien.hashCode()) % 6);
}

// el ambiente de Nova: sombrio (0), regulado (1) o brillante (2), segun como vas
int nivelAmbiente() {
  float promedio = promedioAmbiente();   // ahora tambien cuenta la culpa (Ruta.pde)
  if (promedio < 38) return 0;
  if (promedio <= 68) return 1;
  return 2;
}

int musicaDeseada() {
  if (!musicaActiva) return -1;
  if (scene == ESC_ARRANQUE) return tArranque < ARR_TITULO ? 0 : 1;   // (Arranque.pde)
  if (scene == ESC_CINE_RQ) return musicaCineRQ();   // (Casa.pde)
  if (scene == ESC_ANIM_FINAL) return musicaAnimFinal();   // (Finales.pde)
  if (scene == ESC_GALERIA) return 1;
  if (scene == ESC_INTRO || scene == ESC_FIN_DIA) return 3;
  if (scene == ESC_FIN_GRAVE || scene == ESC_JUICIO || scene == ESC_SILENCIO) return 0;
  if (scene == ESC_FINAL_SECRETO) return 2;
  if (scene == ESC_EPILOGO) return finalSecretoElegido ? 2 : min(2, indiceFinalRQ());
  if (scene == 0 || scene == 2 || scene == ESC_ELEGIR_PERSONAJE || scene == ESC_SLOTS || scene == ESC_COMO_JUGAR || scene == ESC_HISTORIAL) return 1;
  if (scene == ESC_MINIJUEGOS || esMinijuego(scene) || scene == ESC_RULETA || scene == ESC_TIENDA) return 2;
  if (scene == ESC_FINAL) return (finalTipo == 0 || finalTipo == 2) ? 2 : 0;
  if (scene == ESC_PLAZA) return 1;
  if (momento == 3 && dia < 3) return 0;   // de noche suena mas lento
  return nivelAmbiente();
}

void actualizarMusica() {
  int deseada = musicaDeseada();
  if (deseada == musicaSonando) return;
  if (musicaSonando != -1 && pistaMusica[musicaSonando] != null) pistaMusica[musicaSonando].stop();
  musicaSonando = deseada;
  if (deseada != -1 && pistaMusica[deseada] != null) {
    pistaMusica[deseada].setFramePosition(0);
    pistaMusica[deseada].loop(Clip.LOOP_CONTINUOUSLY);
  }
}

// pasos mientras caminas
void pasosAlCaminar() {
  boolean moviendo = moverArriba || moverAbajo || moverIzquierda || moverDerecha;
  if (moviendo && esExploracion(scene) && frameCount % 16 == 0) sonar(1);
}

// botones de musica y efectos en la pausa
void dibujarOpcionesSonido() {
  botonNeon("Musica: " + (musicaActiva ? "SI" : "NO"), 590, 20, 96, 30, musicaActiva ? neonVerde : color(120), false);
  botonNeon("Efectos: " + (efectosActivos ? "SI" : "NO"), 694, 20, 96, 30, efectosActivos ? neonVerde : color(120), false);
}

boolean clickOpcionesSonido() {
  if (encima(590, 20, 96, 30)) {
    musicaActiva = !musicaActiva;
    return true;
  }
  if (encima(694, 20, 96, 30)) {
    efectosActivos = !efectosActivos;
    sonar(0);
    return true;
  }
  return false;
}
