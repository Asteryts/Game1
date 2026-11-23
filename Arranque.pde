// =====================================================================================
//  ARRANQUE.pde -> la cinematica al abrir el juego (antes del menu)
//   1. Negro: "Red Quest + Nova"
//   2. Una publicacion brilla en el centro... y se comparte: la red crece por toda la pantalla
//   3. Aparece Nova de noche y los rumores flotan por la ciudad
//   4. Tu, Sofi y Shawn
//   5. El titulo STAR QUEST cae en bloques (el mismo del menu)
//  Cualquier tecla o clic: salta al titulo. Otra vez: al menu.
// =====================================================================================
final int ESC_ARRANQUE = 84;
final int ARR_RED = 140, ARR_CIUDAD = 330, ARR_GENTE = 480, ARR_TITULO = 650, ARR_FIN = 1000;

int tArranque = 0;
ArrayList<float[]> nodosArr = new ArrayList<float[]>();     // x, y, padre, cuadro en que nace, generacion
ArrayList<float[]> burbujasArr = new ArrayList<float[]>();  // x, y, cuadro en que sale, cual texto
float[][] estrellasArr = new float[90][3];
String[] rumoresArr = {"URGENTE!!!", "COMPARTE YA", "@chismes_11B", "es verdad??", "me lo mandaron",
  "MIREN ESTO", "antes de que lo borren", "1.2k compartidos", "dicen que...", "fuente: un amigo"};
String[][] frasesArr = {
  {"Todo empieza con una publicacion.", "80", "200"},
  {"Alguien la comparte. Y alguien mas. Y alguien mas.", "210", "330"},
  {"En Nova, un rumor llega mas rapido que la verdad.", "345", "475"},
  {"Faltan tres dias para las elecciones.", "490", "640"}
};

void empezarArranque() {
  tArranque = 0;
  nodosArr.clear();
  burbujasArr.clear();
  java.util.Random r = new java.util.Random(11);   // siempre la misma red
  nodosArr.add(new float[] {400, 238, -1, ARR_RED, 0});
  for (int gen = 1; gen <= 5; gen++) {
    int hasta = nodosArr.size();
    for (int i = 0; i < hasta; i++) {
      float[] p = nodosArr.get(i);
      if (p[4] != gen - 1) continue;
      for (int k = 0; k < 2; k++) {
        float ang = r.nextFloat() * TWO_PI;
        float dist = 46 + gen * 14 + r.nextFloat() * 30;
        float nx = constrain(p[0] + cos(ang) * dist, 24, 776);
        float ny = constrain(p[1] + sin(ang) * dist * 0.7, 30, 440);
        nodosArr.add(new float[] {nx, ny, i, ARR_RED + gen * 30 + r.nextFloat() * 18, gen});
      }
    }
  }
  for (int i = 0; i < 14; i++) {
    float[] n = nodosArr.get(1 + r.nextInt(nodosArr.size() - 1));
    burbujasArr.add(new float[] {n[0], n[1], ARR_CIUDAD + 10 + i * 10 + r.nextFloat() * 6, i % rumoresArr.length});
  }
  for (float[] e : estrellasArr) {
    e[0] = r.nextFloat() * 800;
    e[1] = r.nextFloat() * 500;
    e[2] = 0.5 + r.nextFloat() * 1.8;
  }
  scene = ESC_ARRANQUE;
}

// tecla o clic: primero salta al titulo, despues al menu
void saltarArranque() {
  if (tArranque < ARR_TITULO) {
    tArranque = ARR_TITULO;
    sonar(0);
  } else if (tArranque > ARR_TITULO + 40) {
    terminarArranque();
  }
}

void terminarArranque() {
  menuDesde = frameCount - 400;   // el titulo del menu ya aparece puesto (acaba de caer aqui)
  ultimoCuadroMenu = frameCount;
  scene = 0;
}

void dibujarArranque() {
  int t = tArranque++;
  background(4, 3, 12);
  noStroke();
  // estrellas
  float aEst = constrain(map(t, 40, 140, 0, 1), 0, 1);
  for (float[] e : estrellasArr) {
    fill(255, (120 + 100 * sin(frameCount * 0.04 + e[0])) * aEst);
    rect(e[0], e[1], e[2], e[2]);
  }
  // la ciudad de Nova aparece de noche
  if (t > ARR_CIUDAD - 40) {
    float aC = constrain(map(t, ARR_CIUDAD - 40, ARR_CIUDAD + 60, 0, 1), 0, 1);
    pushStyle();
    tint(255, 255 * aC);
    dibujarFondoCiudad();
    popStyle();
    fill(4, 3, 12, 255 - 120 * aC);
    rect(0, 0, width, height);
  }
  if (t < ARR_TITULO) {
    dibujarRedArranque(t);
    dibujarBurbujasArranque(t);
    dibujarGenteArranque(t);
    dibujarFraseArranque(t);
    if (t < 110) {   // "Red Quest + Nova"
      float a = constrain(min(map(t, 10, 40, 0, 1), map(t, 80, 110, 1, 0)), 0, 1);
      textFont(fuenteUI);
      textAlign(CENTER, CENTER);
      textSize(14);
      fill(200, 205, 230, 255 * a);
      text("RED QUEST  +  NOVA", width / 2, height / 2 - 6);
      textSize(11);
      fill(neonCian, 200 * a);
      text("dos juegos, una ciudad", width / 2, height / 2 + 16);
    }
  } else {
    dibujarTituloArranque(t - ARR_TITULO);
  }
  // barras de cine
  fill(0);
  rect(0, 0, width, 26);
  rect(0, height - 26, width, 26);
  if (t > 30 && t < ARR_TITULO) {
    textFont(fuenteUI);
    textSize(10);
    textAlign(RIGHT, CENTER);
    fill(120, 125, 150);
    text("cualquier tecla para saltar", width - 14, height - 13);
  }
  if (t >= ARR_FIN) terminarArranque();
}

void dibujarRedArranque(int t) {
  float apaga = constrain(map(t, ARR_CIUDAD, ARR_GENTE + 40, 1, 0.25), 0.25, 1);
  // la publicacion del centro
  if (t > 70) {
    float[] c = nodosArr.get(0);
    float pul = 1 + 0.25 * sin(frameCount * 0.15);
    float a = constrain(map(t, 70, 110, 0, 1), 0, 1) * apaga;
    fill(neonCian, 40 * a);
    ellipse(c[0], c[1], 58 * pul, 58 * pul);
    fill(20, 22, 40, 255 * a);
    rect(c[0] - 11, c[1] - 18, 22, 36, 5);
    fill(neonCian, 230 * a);
    rect(c[0] - 8, c[1] - 14, 16, 24, 2);
  }
  // los compartidos: cada nodo nace de su padre y la señal viaja por la linea
  int ultimaGen = -1;
  for (int i = 1; i < nodosArr.size(); i++) {
    float[] n = nodosArr.get(i);
    float[] p = nodosArr.get(int(n[2]));
    float avance = constrain((t - n[3]) / 22.0, 0, 1);
    if (avance <= 0) continue;
    float x = lerp(p[0], n[0], avance), y = lerp(p[1], n[1], avance);
    stroke(n[4] % 2 == 0 ? #4856E8 : #FF5A78, 170 * apaga);
    strokeWeight(1.6);
    line(p[0], p[1], x, y);
    noStroke();
    if (avance < 1) {
      fill(#FFC846, 230);
      rect(x - 4, y - 4, 8, 8);
    } else {
      float s = 9 + 2 * sin(frameCount * 0.1 + i);
      fill(#FFC846, 60 * apaga);
      ellipse(n[0], n[1], s + 8, s + 8);
      fill(n[4] % 2 == 0 ? #9AA4FF : #FF8FA3, 230 * apaga);
      ellipse(n[0], n[1], s, s);
    }
    if (int(t - n[3]) == 0) ultimaGen = int(n[4]);
  }
  if (ultimaGen >= 0) sonar(8);   // un "tic" por cada ola de compartidos
  if (t > ARR_RED + 20 && t < ARR_CIUDAD) {   // contador
    int vivos = 0;
    for (float[] n : nodosArr) if (t >= n[3] + 22) vivos++;
    textFont(fuenteUI);
    textSize(12);
    textAlign(LEFT, CENTER);
    fill(#FFC846);
    text("compartido " + int(pow(vivos, 1.9)) + " veces", 18, 44);
  }
}

void dibujarBurbujasArranque(int t) {
  textFont(fuenteUI);
  textSize(11);
  for (float[] b : burbujasArr) {
    float vida = t - b[2];
    if (vida < 0 || vida > 170) continue;
    if (int(vida) == 0) sonar(3);
    float a = constrain(min(vida / 15.0, (170 - vida) / 30.0), 0, 1);
    String s = rumoresArr[int(b[3])];
    float w = textWidth(s) + 16;
    float bx = constrain(b[0] - w / 2, 8, width - w - 8), by = min(b[1] - 30 - vida * 0.35, 352);   // sin tapar la frase de abajo
    fill(12, 10, 28, 225 * a);
    rect(bx, by, w, 20, 8);
    triangle(b[0] - 4, by + 20, b[0] + 4, by + 20, b[0], by + 26);
    fill(int(b[3]) % 3 == 0 ? neonRosa : (int(b[3]) % 3 == 1 ? neonAmarillo : neonCian), 255 * a);
    textAlign(CENTER, CENTER);
    text(s, bx + w / 2, by + 9);
  }
}

void dibujarGenteArranque(int t) {
  if (t < ARR_GENTE) return;
  float[] xs = {230, 400, 570};
  String[] nom = {"Tu", "Sofi", "Shawn"};
  for (int i = 0; i < 3; i++) {
    float sube = constrain(map(t, ARR_GENTE + i * 25, ARR_GENTE + 40 + i * 25, 0, 1), 0, 1);
    if (sube <= 0) continue;
    float pies = 330 + 40 * (1 - sube);
    fill(0, 0, 0, 110 * sube);
    ellipse(xs[i], 334, 70, 12);
    pushStyle();
    tint(255, 255 * sube);
    if (i == 0) {
      dibujarPoseJugadorNova(generoPersonaje, JUGADOR_ABAJO, 0, xs[i], pies, 2.3);
    } else if (i == 1) {
      if (!dibujarSpriteNova("Sofi", xs[i], pies, 1.45, SPRITE_ESPERA, 0)) dibujarSofiCuerpo(xs[i], pies, frameCount * 0.05, false);
    } else {
      dibujarFantasma(xs[i], pies - 4 * sin(frameCount * 0.05), 0.55 * sube);
    }
    popStyle();
    textFont(fuenteUI);
    textSize(13);
    textAlign(CENTER, CENTER);
    fill(i == 0 ? neonAmarillo : (i == 1 ? colorSofi : color(200, 215, 255)), 255 * sube);
    text(nom[i], xs[i], 352);
  }
}

void dibujarFraseArranque(int t) {
  for (String[] f : frasesArr) {
    int desde = int(f[1]), hasta = int(f[2]);
    if (t < desde || t > hasta) continue;
    int letras = min(f[0].length(), (t - desde) / 2);
    float a = constrain(min((t - desde) / 12.0, (hasta - t) / 20.0), 0, 1);
    noStroke();
    fill(4, 3, 12, 190 * a);   // franja oscura para que la frase se lea encima de la red
    rect(0, 388, width, 44);
    textFont(fuenteUI);
    textSize(17);
    textAlign(CENTER, CENTER);
    fill(0, 150 * a);
    text(f[0].substring(0, letras), width / 2 + 2, 412);
    fill(235, 240, 255, 255 * a);
    text(f[0].substring(0, letras), width / 2, 410);
  }
}

void dibujarTituloArranque(int tm) {
  noStroke();
  fill(4, 3, 12, 150);
  rect(0, 0, width, height);
  pushMatrix();
  translate(0, 110);
  tituloBloques(tm, 4, true);
  tituloBloques(tm, 0, false);
  popMatrix();
  if (tm == 62) {
    sonar(13);
    explosionConfeti(width / 2, 210, 30);
  }
  if (tm > 70) {
    String sub = "en Nova, tu eres el filtro";
    int n = min(sub.length(), (tm - 70) / 3);
    textFont(fuenteUI);
    textAlign(CENTER, CENTER);
    textSize(16);
    fill(neonCian);
    text(sub.substring(0, n) + (n < sub.length() && frameCount % 20 < 10 ? "_" : ""), width / 2, 264);
  }
  if (tm > 160 && frameCount % 60 < 40) {
    textSize(13);
    fill(235);
    text("Presiona cualquier tecla", width / 2, 380);
  }
  if (tm > 62 && frameCount % 240 < 5) {   // el glitch de Nova
    for (int i = 0; i < 2; i++) {
      int gy = int(random(176, 222));
      copy(0, gy, width, 4, int(random(-14, 14)), gy, width, 4);
    }
  }
}
