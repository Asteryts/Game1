// =====================================================================================
//  MENU.pde -> menu principal animado, intro de la historia, creditos y "como jugar"
// =====================================================================================

PGraphics cieloMenu, capaLejos, capaMedia, capaCerca;
String[] botonesMenu = {"JUGAR", "MINIJUEGOS", "COMO JUGAR", "CREDITOS", "SALIR"};
int seleccionMenu = 0;
float[] brilloBotones = new float[5];
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
  "CIUDAD NOVA", "", "un juego sobre rumores, redes y decisiones", "", "",
  "- EQUIPO -", "(escriban aqui sus nombres)", "(en el arreglo 'creditos' de Menu.pde)", "", "",
  "- ESCENARIOS -", "Barrio Residencial", "Colegio y Cafe 404", "Alcaldia de Nova", "Parque Central", "Centro NOVA", "Nova Noticias", "Plaza de la Votacion", "", "",
  "- MINIJUEGOS -", "Verificador Express", "Atrapa Bulos", "Caza Bots", "Rastreo de Fuentes", "", "",
  "Hecho con Processing", "", "", "Gracias por jugar.", "Recuerda: en Nova, tu eres el filtro."
};

String[] lineasIntro = {
  "Ciudad Nova. Faltan 7 dias para las elecciones.",
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
  terminarFondoPixel();
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

void dibujarMenu() {
  dibujarFondoCiudad();
  noStroke();
  fill(5, 2, 18, 100);
  rect(0, 0, width, height);
  // titulo con glitch
  boolean glitch = frameCount % 200 < 9;
  float g = glitch ? random(-6, 6) : 0;
  textFont(fuente);
  textAlign(CENTER, CENTER);
  textSize(66);
  fill(neonRosa, 170);
  text("CIUDAD NOVA", width / 2 + 3 + g, 92);
  fill(neonCian, 170);
  text("CIUDAD NOVA", width / 2 - 3 - g, 88);
  tituloNeon("CIUDAD NOVA", width / 2, 90, 66, color(225, 250, 255));
  if (glitch) {
    for (int i = 0; i < 3; i++) {
      int gy = int(random(55, 125));
      int gh = int(random(3, 10));
      copy(0, gy, width, gh, int(random(-20, 20)), gy, width, gh);
    }
  }
  // subtitulo que se escribe solo
  String sub = "-  en Nova, tu eres el filtro  -";
  int n = min(sub.length(), (frameCount / 3) % (sub.length() + 60));
  textFont(fuenteUI);
  textSize(15);
  fill(neonCian);
  text(sub.substring(0, n) + (frameCount % 30 < 15 ? "_" : " "), width / 2, 142);

  // botones
  for (int i = 0; i < botonesMenu.length; i++) {
    float bx = width / 2 - 140, by = 180 + i * 56, bw = 280, bh = 44;
    if (encima(bx, by, bw, bh) && (mouseX != pmouseX || mouseY != pmouseY) && seleccionMenu != i) {
      seleccionMenu = i;
      chispas(bx + 10, by + bh / 2, neonCian, 8);
    }
    boolean sel = seleccionMenu == i;
    brilloBotones[i] = lerp(brilloBotones[i], sel ? 1 : 0, 0.2);
    float br = brilloBotones[i];
    color c = i == 4 ? neonRosa : neonCian;
    float desp = br * 10;
    noStroke();
    for (int k = 4; k >= 1; k--) {
      fill(c, 18 * br);
      rect(bx - k * 4 + desp, by - k * 4, bw + k * 8, bh + k * 8, 14 + k * 4);
    }
    fill(lerpColor(color(14, 10, 32, 210), color(red(c) * 0.22, green(c) * 0.22, blue(c) * 0.22, 240), br));
    stroke(c, 120 + 135 * br);
    strokeWeight(1.5 + br);
    rect(bx + desp, by, bw, bh, 12);
    noStroke();
    if (br > 0.05) {
      fill(c, 255 * br);
      float fx = bx + 18 + desp + sin(frameCount * 0.2) * 3;
      triangle(fx, by + 14, fx, by + bh - 14, fx + 10, by + bh / 2);
      // brillo que cruza el boton
      float sx = bx + ((frameCount * 6) % (bw + 200)) - 100;
      fill(255, 25 * br);
      quad(sx + desp, by, sx + 30 + desp, by, sx + 10 + desp, by + bh, sx - 20 + desp, by + bh);
    }
    textFont(fuente);
    textSize(24);
    textAlign(CENTER, CENTER);
    fill(lerpColor(color(200, 200, 230), color(255), br));
    text(botonesMenu[i], width / 2 + desp, by + bh / 2 - 2);
  }
  // pie de pagina
  textFont(fuenteUI);
  textSize(11);
  fill(190, 180, 230, 200);
  textAlign(LEFT, CENTER);
  text("v2.0   -   Logros " + contarLogros() + "/" + logros.length, 14, height - 14);
  textAlign(RIGHT, CENTER);
  text("W/S o flechas + ENTER   -   ESC pausa   -   P telefono   -   F3 debug", width - 14, height - 14);
  // chispitas que suben
  if (random(1) < 0.3) {
    agregarParticula(new Particula(random(width), height + 5, random(-0.3, 0.3), random(-1.6, -0.6), random(120, 220), random(2, 3.5), random(1) < 0.5 ? neonCian : neonRosa, 6));
  }
}

void accionMenu(int i) {
  explosionConfeti(width / 2, 180 + i * 56 + 22, 25);
  if (i == 0) {
    if (!introVista) {
      lineaIntro = 0;
      letrasIntro = 0;
      scene = ESC_INTRO;
    } else {
      scene = 1;
    }
  } else if (i == 1) {
    regresoSala = 0;
    scene = ESC_MINIJUEGOS;
  } else if (i == 2) {
    regresoAyuda = 0;
    scene = ESC_COMO_JUGAR;
  } else if (i == 3) {
    scrollCreditos = height;
    scene = 2;
  } else if (i == 4) {
    guardarDatos();
    exit();
  }
}

void clickMenu() {
  for (int i = 0; i < botonesMenu.length; i++) {
    if (encima(width / 2 - 140, 180 + i * 56, 280, 44)) {
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
    {"W A S D / flechas", "caminar"}, {"SHIFT", "correr"}, {"E", "hablar / revisar objetos"}, {"ENTER", "avanzar dialogos"}, {"Clic", "elegir opciones"},
    {"P o TAB", "abrir el telefono"}, {"ESC", "pausa"}, {"F3", "modo debug"}
  };
  for (int i = 0; i < controles.length; i++) {
    float cy = 145 + i * 37;
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
  text("Cuando estes listo, ve a la Plaza de la Votacion para ver tu final. Hay 4 finales distintos!", 437, 400, 305, 50);
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
