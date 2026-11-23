// =====================================================================================
//  MENU.pde -> menu principal animado, intro de la historia, creditos y "como jugar"
// =====================================================================================

PGraphics cieloMenu, capaLejos, capaMedia, capaCerca;
String[] botonesMenu = {"JUGAR", "MINIJUEGOS", "COMO JUGAR", "CREDITOS", "FINALES", "SALIR"};
int seleccionMenu = 0;
float[] brilloBotones = new float[6];
int regresoAyuda = 0;
float scrollCreditos = 500;
int lineaIntro = 0;
float letrasIntro = 0;
float[][] autosVoladores = new float[7][4];   // x, y, velocidad, color
float[][] gotasMenu = new float[90][3];
float[][] letreros = {
  // x, y, ancho, alto, color (0 cian, 1 rosa, 2 amarillo)
  {40, 230, 26, 110, 1}, {150, 270, 70, 26, 0}, {640, 220, 26, 120, 0}, {720, 300, 60, 24, 2}, {250, 300, 22, 80, 2}, {560, 290, 22, 70, 1}
};
String[] textosLetreros = {"BAR", "404", "NOVA", "CAFE", "IA", "HOTEL"};

// AQUI VAN SUS NOMBRES! (cambien las lineas del equipo por sus nombres reales)
String[] creditos = {
  "STAR QUEST", "", "un juego sobre rumores, redes y decisiones en Ciudad Nova", "", "",
  "- EQUIPO -", "(Santiago Ortega)", "(Valeria Chacon)", "(David Mendoza)", "(Gabriela Bustillo)", "(David Serrano)", "(Samuel Orozco)",
  "- HISTORIA DE RED QUEST -", "Sofi, Shawn, @chismes_11B y la musica", "vienen del juego Red Quest del otro grupo", "", "",
  "- ESCENARIOS -", "Barrio Residencial", "Colegio y Cafe 404", "Alcaldia de Nova", "Parque Central", "Centro NOVA", "Nova Noticias", "Plaza de la Votacion", "", "",
  "- MINIJUEGOS -", "Verificador Express", "Atrapa Bulos", "Caza Bots", "Rastreo de Fuentes", "", "",
  "Hecho con Processing", "", "", "Gracias por jugar.", "Recuerda: en Nova, tu eres el filtro."
};

String[] lineasIntro = {
  "Ciudad Nova. Las elecciones son el jueves.",
  "Conecta, la red social de la ciudad, arde con rumores, videos cortados y titulares falsos.",
  "Cada vez que alguien comparte sin pensar, el rumor crece. Cada vez que alguien verifica, la ciudad respira.",
  "Tus decisiones mueven tres cosas: VIRALIDAD, CONFIABILIDAD e IMPACTO.",
  "Explora el barrio, el colegio, la alcaldia, el parque... habla con la gente y decide que compartes.",
  "Recuerda: en Nova, tu eres el filtro."
};

void prepararMenu() {
  cieloMenu = createGraphics(width, height);
  cieloMenu.beginDraw();
  cieloMenu.noStroke();
  for (int i = 0; i < height; i += 2) {
    cieloMenu.fill(lerpColor(color(10, 4, 30), color(95, 22, 92), pow(i / (float) height, 1.3)));
    cieloMenu.rect(0, i, width, 2);
  }
  for (int i = 0; i < 90; i++) {
    cieloMenu.fill(255, random(80, 220));
    float s = random(1, 2.5);
    cieloMenu.rect(random(width), random(height * 0.55), s, s);
  }
  cieloMenu.endDraw();
  capaLejos = crearCapa(0);
  capaMedia = crearCapa(1);
  capaCerca = crearCapa(2);
  for (float[] a : autosVoladores) {
    a[0] = random(width);
    a[1] = random(70, 230);
    a[2] = random(1.5, 4) * (random(1) < 0.5 ? -1 : 1);
    a[3] = random(1);
  }
  for (float[] g : gotasMenu) {
    g[0] = random(width);
    g[1] = random(height);
    g[2] = random(8, 14);
  }
}

PGraphics crearCapa(int nivel) {
  int w = width + 160;
  PGraphics pg = createGraphics(w, height);
  pg.beginDraw();
  pg.noStroke();
  float bx = -20;
  color base = nivel == 0 ? color(44, 20, 76) : nivel == 1 ? color(28, 12, 54) : color(14, 6, 30);
  float suelo = nivel == 0 ? 330 : nivel == 1 ? 365 : 405;
  while (bx < w) {
    float bw = nivel == 2 ? random(70, 130) : random(40, 90);
    float bh = nivel == 0 ? random(120, 260) : nivel == 1 ? random(90, 210) : random(80, 210);
    pg.fill(base);
    pg.rect(bx, suelo - bh, bw, bh + 200);
    if (random(1) < 0.35) pg.rect(bx + bw * 0.4, suelo - bh - random(10, 30), 3, 30);
    float vw = nivel == 2 ? 6 : 3, vh = nivel == 2 ? 8 : 4, paso = nivel == 2 ? 14 : 8;
    for (float vy = suelo - bh + 10; vy < suelo - 10; vy += paso) {
      for (float vx = bx + 6; vx < bx + bw - 8; vx += paso) {
        float r = random(1);
        if (r < 0.28) {
          pg.fill(r < 0.1 ? color(0, 240, 255, 200) : r < 0.18 ? color(255, 80, 200, 190) : color(255, 210, 140, 200));
          pg.rect(vx, vy, vw, vh);
        }
      }
    }
    bx += bw + random(2, 12);
  }
  pg.endDraw();
  return pg;
}

// (pixel art) la ciudad del menu se dibuja en el lienzo chiquito de Pixel.pde
void dibujarFondoCiudad() {
  empezarFondoPixel();
  dibujarFondoCiudadMundo();
  terminarFondoPixel("menu");
}

void dibujarFondoCiudadMundo() {
  image(cieloMenu, 0, 0);
  // planeta con anillo (como el logo del menu viejo)
  float pf = sin(frameCount * 0.01) * 4;
  noStroke();
  for (int i = 5; i >= 1; i--) {
    fill(140, 230, 255, 10);
    ellipse(660, 92 + pf, 70 + i * 16, 70 + i * 16);
  }
  fill(160, 225, 245);
  ellipse(660, 92 + pf, 70, 70);
  fill(120, 190, 220);
  ellipse(648, 84 + pf, 18, 14);
  ellipse(672, 104 + pf, 12, 9);
  noFill();
  stroke(200, 245, 255, 200);
  strokeWeight(3);
  pushMatrix();
  translate(660, 92 + pf);
  rotate(-0.35);
  arc(0, 0, 130, 34, -0.15, PI + 0.15);
  popMatrix();
  noStroke();

  float px = (mouseX - width / 2) / (float) width;
  image(capaLejos, -80 - px * 18, 0);
  image(capaMedia, -80 - px * 38, 0);
  // autos voladores
  for (float[] a : autosVoladores) {
    a[0] += a[2];
    if (a[0] > width + 40) a[0] = -40;
    if (a[0] < -40) a[0] = width + 40;
    color luz = a[3] < 0.5 ? neonCian : neonRosa;
    float dir = a[2] > 0 ? 1 : -1;
    stroke(luz, 90);
    strokeWeight(2);
    line(a[0], a[1], a[0] - dir * 40, a[1]);
    noStroke();
    fill(40, 40, 60);
    rect(a[0] - 9, a[1] - 3, 18, 6, 3);
    fill(255, 255, 220);
    ellipse(a[0] + dir * 9, a[1], 4, 4);
    fill(255, 60, 60);
    ellipse(a[0] - dir * 9, a[1], 3, 3);
  }
  image(capaCerca, -80 - px * 65, 0);
  // letreros de neon que parpadean
  textFont(fuenteUI);
  for (int i = 0; i < letreros.length; i++) {
    float[] l = letreros[i];
    float lx = l[0] - px * 65;
    color c = l[4] == 0 ? neonCian : l[4] == 1 ? neonRosa : neonAmarillo;
    float on = hsh(i * 7 + floor(frameCount / 6.0)) > 0.06 ? 1 : 0.25;
    fill(c, 30 * on);
    rect(lx - 6, l[1] - 6, l[2] + 12, l[3] + 12, 6);
    fill(15, 8, 30);
    rect(lx, l[1], l[2], l[3], 4);
    stroke(c, 255 * on);
    strokeWeight(2);
    noFill();
    rect(lx, l[1], l[2], l[3], 4);
    noStroke();
    fill(c, 255 * on);
    textAlign(CENTER, CENTER);
    String t = textosLetreros[i];
    if (l[3] > l[2]) {
      textSize(13);
      for (int k = 0; k < t.length(); k++) text(t.charAt(k), lx + l[2] / 2, l[1] + 16 + k * (l[3] - 20) / max(1, t.length() - 1) * 0.9);
    } else {
      textSize(14);
      text(t, lx + l[2] / 2, l[1] + l[3] / 2 - 1);
    }
  }
  // calle mojada con reflejo
  fill(12, 6, 26);
  rect(0, 405, width, 95);
  int f = nivelPixel > 0 ? PIXEL : 1;   // get() lee pixeles reales del lienzo, que es mas chiquito
  PImage reflejo = get(0, 305 / f, width / f, 100 / f);
  pushMatrix();
  translate(0, 505);
  scale(1, -1);
  tint(255, 70);
  image(reflejo, sin(frameCount * 0.05) * 2, 0, width, 100);
  noTint();
  popMatrix();
  fill(10, 4, 24, 120);
  rect(0, 405, width, 95);
  // lluvia
  stroke(180, 200, 255, 90);
  strokeWeight(1);
  for (float[] g : gotasMenu) {
    g[1] += g[2];
    g[0] += 1.5;
    if (g[1] > height) {
      g[1] = -10;
      g[0] = random(-50, width);
    }
    line(g[0], g[1], g[0] - 2, g[1] - g[2] * 1.4);
  }
  noStroke();
}

// (Star Quest) el menu combina el de Nova (ciudad neon, brillos) con el de Red Quest
// (la red de personajes conectados, el titulo de bloques dorados y los botones de papel)
float[] nodoMX = {0.14, 0.86, 0.08, 0.24, 0.76, 0.92};
float[] nodoMY = {0.11, 0.11, 0.50, 0.86, 0.86, 0.50};
String[] nodoMNombre = {"Tu", "Sofi", "Mateo", "Kevin", "Camila", "Shawn"};
int[] conexionMA = {0, 2, 3, 4, 1, 1};
int[] conexionMB = {2, 3, 4, 1, 0, 5};
String[][] letraMenu = {
  {"#####", "#....", "#####", "....#", "#####"},   // S
  {"#####", "..#..", "..#..", "..#..", "..#.."},   // T
  {".###.", "#...#", "#####", "#...#", "#...#"},   // A
  {"####.", "#...#", "####.", "#..#.", "#...#"},   // R
  {".###.", "#...#", "#...#", "#..#.", ".##.#"},   // Q
  {"#...#", "#...#", "#...#", "#...#", ".###."},   // U
  {"#####", "#....", "####.", "#....", "#####"}    // E
};
int[] letrasMenu = {0, 1, 2, 3, -1, 4, 5, 6, 0, 1};   // S T A R _ Q U E S T
int menuDesde = 0;   // cuadro en que se abrio el menu (para la animacion del titulo)
int ultimoCuadroMenu = -10;

void dibujarMenu() {
  if (frameCount - ultimoCuadroMenu > 2) menuDesde = frameCount;   // volviste al menu: el titulo cae otra vez
  ultimoCuadroMenu = frameCount;
  int tm = frameCount - menuDesde;
  // la ciudad de Nova al fondo, apagada por la noche de Red Quest
  dibujarFondoCiudad();
  noStroke();
  for (int i = 0; i < height; i += 4) {
    float a = map(i, 0, height, 250, 120);
    fill(16, 16, 24, a);
    rect(0, i, width, 4);
  }
  // la red de personajes
  for (int e = 0; e < conexionMA.length; e++) {
    float ax = nodoMX[conexionMA[e]] * width, ay = nodoMY[conexionMA[e]] * height;
    float bx = nodoMX[conexionMB[e]] * width, by = nodoMY[conexionMB[e]] * height;
    boolean encendida = e == 4 || contarFinalesVistos() > e || e == 0;
    stroke(e == 4 ? #FF5A78 : (encendida ? #4856E8 : color(#2A2A3A)));
    strokeWeight(e == 4 ? 2.5 : 2);
    line(ax, ay, bx, by);
  }
  noStroke();
  senalMenu(4, (tm % 200) / 200.0);
  senalMenu((tm / 150) % 4, (tm % 150) / 150.0);
  for (int n = 0; n < nodoMX.length; n++) nodoMenu(n);

  // "CONECTADO"
  textFont(fuenteUI);
  textSize(11);
  textAlign(CENTER, CENTER);
  fill(#FF5A78);
  float wE = textWidth("CONECTADO");
  ellipse(width / 2 - wE / 2 - 10, 22, 7, 7);
  text("CONECTADO", width / 2, 22);

  // el titulo en bloques (cae letra por letra, con su sombra)
  tituloBloques(tm, 4, true);
  tituloBloques(tm, 0, false);
  if (frameCount % 260 < 6) {   // un glitch de vez en cuando, como en Nova
    for (int i = 0; i < 2; i++) {
      int gy = int(random(66, 112));
      copy(0, gy, width, 4, int(random(-14, 14)), gy, width, 4);
    }
  }
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(14);
  fill(255);
  text("Lo que publicas en Conecta cambia el mundo que ves", width / 2, 134);
  String sub = "en Nova, tu eres el filtro";
  int n = min(sub.length(), (frameCount / 3) % (sub.length() + 60));
  textSize(11);
  fill(neonCian, 200);
  text(sub.substring(0, n) + (frameCount % 30 < 15 ? "_" : " "), width / 2, 154);

  // botones de papel de Red Quest, con el brillo neon de Nova
  for (int i = 0; i < botonesMenu.length; i++) {
    float bx = width / 2 - 140, by = 176 + i * 48, bw = 280, bh = 40;
    if (encima(bx, by, bw, bh) && (mouseX != pmouseX || mouseY != pmouseY) && seleccionMenu != i) {
      seleccionMenu = i;
      chispas(bx + 10, by + bh / 2, #FFC846, 8);
    }
    boolean sel = seleccionMenu == i;
    brilloBotones[i] = lerp(brilloBotones[i], sel ? 1 : 0, 0.2);
    float br = brilloBotones[i];
    color c = i == 5 ? neonRosa : (i == 4 ? #FFC846 : neonCian);
    float desp = br * 8;
    noStroke();
    for (int k = 3; k >= 1; k--) {
      fill(c, 16 * br);
      rect(bx - k * 4 + desp, by - k * 4, bw + k * 8, bh + k * 8, 14 + k * 4);
    }
    fill(0, 110);
    rect(bx + 4 + desp, by + 4, bw, bh, 12, 5, 12, 5);
    fill(lerpColor(color(#F4EEDF), color(#FFC846), br));
    stroke(#15151F);
    strokeWeight(3);
    rect(bx + desp, by, bw, bh, 12, 5, 12, 5);
    noStroke();
    if (br > 0.05) {
      fill(#15151F, 255 * br);
      float fx = bx + 16 + desp + sin(frameCount * 0.2) * 3;
      triangle(fx, by + 13, fx, by + bh - 13, fx + 9, by + bh / 2);
    }
    textFont(fuente);
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(#15151F);
    text(botonesMenu[i], width / 2 + desp, by + bh / 2 - 2);
  }
  // pie de pagina
  textFont(fuenteUI);
  textSize(10);
  fill(150, 150, 180, 200);
  textAlign(LEFT, CENTER);
  text("Logros " + contarLogros() + "/" + logros.length + "   -   Finales " + contarFinalesVistos() + "/13", 14, height - 12);
  textAlign(RIGHT, CENTER);
  text("W/S o flechas + ENTER", width - 14, height - 12);
  botonNeon(rotuloEstiloEscenarios(), width / 2 - 100, 471, 200, 24,
    estiloPixelActivo ? neonCian : color(150), false);
  if (random(1) < 0.2) {
    agregarParticula(new Particula(random(width), height + 5, random(-0.3, 0.3), random(-1.4, -0.5), random(120, 220), random(2, 3), random(1) < 0.5 ? color(#FFC846) : color(#FF5A78), 6));
  }
}

// el cuadradito dorado que viaja por una conexion (como en Red Quest)
void senalMenu(int e, float avance) {
  float ax = nodoMX[conexionMA[e]] * width, ay = nodoMY[conexionMA[e]] * height;
  float bx = nodoMX[conexionMB[e]] * width, by = nodoMY[conexionMB[e]] * height;
  noStroke();
  fill(#FFC846, 70);
  rect(lerp(ax, bx, avance) - 7, lerp(ay, by, avance) - 7, 14, 14);
  fill(#FFC846);
  rect(lerp(ax, bx, avance) - 4, lerp(ay, by, avance) - 4, 8, 8);
}

void nodoMenu(int n) {
  float cx = nodoMX[n] * width, cy = nodoMY[n] * height;
  boolean principal = n < 2;
  fill(#191926);
  stroke(principal ? #FFC846 : color(#2A2A3A));
  strokeWeight(2.5);
  ellipse(cx, cy, 64, 64);
  noStroke();
  boolean conSprite;
  if (n == 0) {
    int direccion = (relojSpriteNova / 1600) % caminataJugadorNova.length;
    int tiempo = relojSpriteNova % 1600;
    int cuadro = tiempo < 220 ? 0 : cuadroCaminataJugadorNova(tiempo - 220, false);
    conSprite = dibujarCaminataJugadorNova(direccion, cuadro, cx, cy + 23, 1.06);
    if (!conSprite) conSprite = dibujarSpriteNova(nodoMNombre[n], cx, cy + 23, 0.76, SPRITE_ESPERA, 0);
  } else {
    conSprite = dibujarSpriteNova(nodoMNombre[n], cx, cy + 23, 0.76, SPRITE_ESPERA, n * 230);
  }
  if (!conSprite) dibujarNodoMenuOriginal(n, cx, cy);
  if (!principal) {
    fill(#191926, conSprite ? 42 : 110);
    ellipse(cx, cy, 60, 60);
  }
  textFont(fuenteUI);
  textSize(10);
  fill(190);
  textAlign(CENTER, CENTER);
  text(nodoMNombre[n], cx, cy + 42);
}

void dibujarNodoMenuOriginal(int n, float cx, float cy) {
  float u = 1.55, px = cx - 6 * u, py = cy - 14 * u;
  float b = sin(frameCount * 0.05 + n) * 1;
  if (n == 0) tuU(px, py + b, u, 1);
  else if (n == 1) sofiU(px, py + b, u, 1);
  else if (n == 2) personaU(px, py + b, u, #2B1B10, #8D5A3B, #2E8B57, #3B3B3B, 1);
  else if (n == 3) personaU(px, py + b, u, #141414, #C68E5E, #FF8C3C, #39404D, 1);
  else if (n == 4) personaU(px, py + b, u, #A0522D, #F0C090, #20A39E, #333A56, 1);
  else {   // Shawn, chiquito para que quepa en su circulo
    pushMatrix();
    translate(cx, cy + 20);
    scale(0.55);
    dibujarFantasma(0, 0, 0.8);
    popMatrix();
  }
}

void tituloBloques(int tm, float corrido, boolean sombra) {
  float c = 7.5;
  float x0 = width / 2 - (letrasMenu.length * 6 - 1) * c / 2;
  float y0 = 66;
  noStroke();
  for (int i = 0; i < letrasMenu.length; i++) {
    int l = letrasMenu[i];
    if (l < 0) continue;
    float baja = max(0, 15 + i * 5 - tm) * 10;
    for (int f = 0; f < 5; f++) {
      for (int col = 0; col < 5; col++) {
        if (letraMenu[l][f].charAt(col) != '#') continue;
        if (sombra) fill(0, 150);
        else fill(lerpColor(#FFE08A, #FF9A3C, f / 4.0));
        rect(x0 + (i * 6 + col) * c + corrido, y0 + f * c - baja + corrido, c, c);
      }
    }
  }
}

void accionMenu(int i) {
  explosionConfeti(width / 2, 176 + i * 48 + 20, 25);
  if (i == 0) {
    abrirSlots();   // las 3 partidas guardadas (Slots.pde)
  } else if (i == 1) {
    regresoSala = 0;
    scene = ESC_MINIJUEGOS;
  } else if (i == 2) {
    regresoAyuda = 0;
    scene = ESC_COMO_JUGAR;
  } else if (i == 3) {
    scrollCreditos = height;
    scene = 2;
  } else if (i == 4) {   // la galeria de finales (Finales.pde)
    abrirGaleria();
  } else if (i == 5) {
    guardarDatos();
    exit();
  }
}

void clickMenu() {
  if (encima(width / 2 - 100, 471, 200, 24)) {
    alternarEstiloEscenarios();
    return;
  }
  for (int i = 0; i < botonesMenu.length; i++) {
    if (encima(width / 2 - 140, 176 + i * 48, 280, 40)) {
      accionMenu(i);
      return;
    }
  }
}

void teclaMenu() {
  if (key == 'w' || key == 'W' || (key == CODED && keyCode == UP)) seleccionMenu = (seleccionMenu + botonesMenu.length - 1) % botonesMenu.length;
  if (key == 's' || key == 'S' || (key == CODED && keyCode == DOWN)) seleccionMenu = (seleccionMenu + 1) % botonesMenu.length;
  if (key == ENTER || key == RETURN || key == ' ') accionMenu(seleccionMenu);
}

// ------------------------------------- INTRO -------------------------------------
void dibujarIntro() {
  dibujarFondoCiudad();
  noStroke();
  fill(4, 2, 14, 185);
  rect(0, 0, width, height);
  String t = lineasIntro[lineaIntro];
  if (letrasIntro < t.length()) letrasIntro += 0.8;
  panelNeon(90, 150, 620, 190, neonCian);
  textFont(fuenteUI);
  textSize(21);
  fill(240);
  textAlign(CENTER, CENTER);
  text(t.substring(0, min(t.length(), int(letrasIntro))), 120, 170, 560, 150);
  for (int i = 0; i < lineasIntro.length; i++) {
    fill(i <= lineaIntro ? neonCian : color(70, 70, 100));
    ellipse(width / 2 - (lineasIntro.length - 1) * 9 + i * 18, 370, 8, 8);
  }
  if (letrasIntro >= t.length() && frameCount % 40 < 28) {
    textSize(13);
    fill(neonCian);
    text("Clic o ENTER para continuar", width / 2, 405);
  }
  botonNeon("Saltar  >>", 680, 16, 100, 34, neonRosa, false);
  tituloNeon("CIUDAD NOVA", width / 2, 80, 40, neonCian);
}

void avanzarIntro() {
  String t = lineasIntro[lineaIntro];
  if (letrasIntro < t.length()) {
    letrasIntro = t.length();
    return;
  }
  lineaIntro++;
  letrasIntro = 0;
  if (lineaIntro >= lineasIntro.length) terminarIntro();
}

void terminarIntro() {
  introVista = true;
  lineaIntro = 0;
  guardarDatos();
  scene = 1;
}

// ------------------------------------- CREDITOS -------------------------------------
void dibujarCreditos() {
  dibujarFondoCiudad();
  noStroke();
  fill(4, 2, 14, 170);
  rect(0, 0, width, height);
  scrollCreditos -= 0.8;
  if (scrollCreditos < -creditos.length * 34 - 40) scrollCreditos = height;
  for (int i = 0; i < creditos.length; i++) {
    float cy = scrollCreditos + i * 34;
    if (cy < -40 || cy > height + 40) continue;
    float a = constrain(min(cy - 40, height - 40 - cy) / 60.0, 0, 1);
    String l = creditos[i];
    if (i == 0) {
      tituloNeon(l, width / 2, cy, 40, neonCian);
    } else if (l.startsWith("-")) {
      textFont(fuente);
      textSize(22);
      fill(neonRosa, 255 * a);
      textAlign(CENTER, CENTER);
      text(l, width / 2, cy);
    } else {
      textFont(fuenteUI);
      textSize(17);
      fill(235, 255 * a);
      textAlign(CENTER, CENTER);
      text(l, width / 2, cy);
    }
  }
  botonVolver();
}

// ------------------------------------- COMO JUGAR -------------------------------------
void dibujarComoJugar() {
  dibujarFondoCiudad();
  noStroke();
  fill(4, 2, 14, 190);
  rect(0, 0, width, height);
  tituloNeon("COMO JUGAR", width / 2, 50, 40, neonCian);
  panelNeon(40, 90, 345, 370, neonCian);
  panelNeon(415, 90, 345, 370, neonRosa);
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(17);
  fill(neonCian);
  text("CONTROLES", 62, 108);
  fill(neonRosa);
  text("TU OBJETIVO", 437, 108);
  String[][] controles = {
    {"Clic derecho", "caminar (como en LoL)"}, {"W A S D / flechas", "caminar"}, {"SHIFT", "correr"}, {"E", "hablar / revisar objetos"}, {"ENTER", "avanzar dialogos"}, {"Clic", "elegir opciones"},
    {"P o TAB", "abrir el telefono"}, {"ESC", "pausa"}, {"F3", "modo debug"}
  };
  for (int i = 0; i < controles.length; i++) {
    float cy = 145 + i * 33;
    textSize(12);
    float w = textWidth(controles[i][0]) + 16;
    fill(235);
    rect(62, cy, w, 24, 6);
    fill(20);
    textAlign(LEFT, CENTER);
    text(controles[i][0], 70, cy + 11);
    fill(220);
    textSize(13);
    text(controles[i][1], 62 + w + 12, cy + 11);
  }
  textAlign(LEFT, TOP);
  textSize(13);
  fill(225);
  text("Nova esta llena de rumores antes de las elecciones. Habla con la gente, revisa Conecta en tu telefono y decide que hacer con cada noticia.", 437, 140, 305, 90);
  barraEjemplo("VIRALIDAD", "que tanto se riega lo que publicas", neonRosa, 240);
  barraEjemplo("CONFIABILIDAD", "que tanto confian en ti", neonCian, 295);
  barraEjemplo("IMPACTO", "cuanto ayudas a tu comunidad", neonAmarillo, 350);
  fill(200);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Cuando estes list{o|a}, ve a la Plaza de la Votacion para ver tu final. Hay 4 finales distintos!", 437, 400, 305, 50);
  botonVolver();
}

void barraEjemplo(String t, String d, color c, float by) {
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(13);
  fill(c);
  text(t, 437, by);
  fill(190);
  textSize(11);
  text(d, 437, by + 17);
  fill(40, 36, 60);
  rect(437, by + 34, 300, 8, 4);
  fill(c);
  rect(437, by + 34, 300 * (0.5 + 0.4 * sin(frameCount * 0.03 + by)), 8, 4);
}
