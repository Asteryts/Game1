// =====================================================================================
//  FONDOS.pde -> fondos dibujados con codigo para las escenas que no tienen imagen
//  (el barrio de atras, la entrada a Nova, la alcaldia si no carga su foto...)
//  Si algun dia ponen las imagenes en /data, el juego usa las imagenes y estos quedan de respaldo
// =====================================================================================

color[] paletaCasas = {#7A4670, #465A86, #8C6450, #507A6E, #6E508C, #8C5064};
color[] paletaFlores = {#FF6EB4, #FFD45A, #8CE0FF, #FF8C5A};
color[] paletaRopa = {#C8464B, #3C78C8, #46A064, #DCA032, #8C50B4, #3CA0A0, #DC6E8C, #646478};

// numero "aleatorio" pero siempre igual para la misma entrada (asi el fondo no tiembla)
float hsh(float n) {
  float s = sin(n * 12.9898) * 43758.5453;
  return s - floor(s);
}

void degradado(float x0, float y0, float w, float h, color c1, color c2) {
  noStroke();
  for (float i = 0; i < h; i += 4) {
    fill(lerpColor(c1, c2, i / h));
    rect(x0, y0 + i, w, min(4, h - i));
  }
}

void arbolito(float tx, float ty, float r, float fase) {
  float bal = sin(frameCount * 0.02 + fase) * 2;
  noStroke();
  fill(0, 70);
  ellipse(tx, ty + 4, r * 1.8, r * 0.6);
  fill(80, 55, 40);
  rect(tx - 4, ty - r * 0.9, 8, r * 0.9);
  fill(30, 85, 60);
  ellipse(tx + bal, ty - r * 1.2, r * 2, r * 1.8);
  fill(45, 110, 75);
  ellipse(tx - r * 0.3 + bal, ty - r * 1.4, r * 1.3, r * 1.2);
  fill(70, 140, 95, 180);
  ellipse(tx - r * 0.45 + bal, ty - r * 1.6, r * 0.6, r * 0.5);
}

void poste(float px, float base, float fase) {
  float brillo = 0.85 + 0.15 * sin(frameCount * 0.05 + fase);
  if (hsh(px + floor(frameCount / 8.0)) > 0.985) brillo = 0.3;   // a veces parpadea
  noStroke();
  for (int i = 5; i >= 1; i--) {
    fill(255, 220, 140, 14 * brillo);
    ellipse(px, base - 88, i * 26, i * 26);
  }
  fill(55, 55, 70);
  rect(px - 3, base - 90, 6, 90);
  rect(px - 10, base - 4, 20, 4);
  fill(255, 235, 170, 255 * brillo);
  ellipse(px, base - 90, 12, 8);
}

void flechaSalida(float fx, float fy, int dir, String t) {
  // dir: 0 arriba, 1 derecha, 2 abajo, 3 izquierda
  float b = sin(frameCount * 0.12) * 4;
  pushMatrix();
  translate(fx, fy);
  pushMatrix();
  rotate(dir * HALF_PI);
  translate(0, -b);
  noStroke();
  fill(neonCian, 70);
  triangle(-14, 8, 14, 8, 0, -12);
  fill(neonCian, 230);
  triangle(-9, 5, 9, 5, 0, -8);
  popMatrix();
  textFont(fuenteUI);
  textSize(11);
  fill(255, 220);
  textAlign(CENTER, CENTER);
  float ty = dir == 0 ? 22 : dir == 2 ? -22 : 22;
  text(t, 0, ty);
  popMatrix();
}

// ------------------------------------- BARRIO -------------------------------------
// (pixel art) el fondo se dibuja en el lienzo chiquito de Pixel.pde; las flechas quedan nitidas
void fondoBarrio(int s) {
  empezarFondoPixel();
  fondoBarrioMundo(s);
  terminarFondoPixel();
  salidasBarrio(s);
}

void fondoBarrioMundo(int s) {
  float sem = s * 17.31;
  degradado(0, 0, width, 70, color(14, 8, 34), color(58, 28, 84));
  noStroke();
  for (int i = 0; i < 30; i++) {
    float sx = hsh(sem + i * 1.7) * width, sy = hsh(sem + i * 3.1) * 55;
    fill(255, 140 + 110 * sin(frameCount * 0.04 + i));
    rect(sx, sy, 2, 2);
  }
  // fila de casas
  float cx = -10 - hsh(sem) * 40;
  int k = 0;
  while (cx < width) {
    float w = 115 + hsh(sem + k * 7.3) * 60;
    float h = 72 + hsh(sem + k * 2.9) * 40;
    color pared = paletaCasas[int(hsh(sem + k * 5.1) * paletaCasas.length) % paletaCasas.length];
    float base = 150;
    fill(pared);
    rect(cx, base - h, w - 10, h);
    fill(0, 40);
    rect(cx, base - 12, w - 10, 12);
    fill(red(pared) * 0.45, green(pared) * 0.4, blue(pared) * 0.55);
    triangle(cx - 8, base - h, cx + (w - 10) / 2, base - h - 26, cx + w - 2, base - h);
    int nv = max(1, int((w - 40) / 32));
    for (int v = 0; v < nv; v++) {
      float vx = cx + 12 + v * 32, vy = base - h + 14;
      boolean luz = hsh(sem + k * 13 + v) > 0.35;
      if (luz) {
        float parp = hsh(sem + k + v * 9) > 0.85 ? (0.75 + 0.25 * sin(frameCount * 0.2 + v)) : 1;
        fill(255, 210, 120, 50 * parp);
        rect(vx - 4, vy - 4, 26, 28, 5);
        fill(255, 214, 130, 235 * parp);
      } else {
        fill(28, 26, 48);
      }
      rect(vx, vy, 18, 20, 2);
      fill(0, 60);
      rect(vx + 8, vy, 2, 20);
    }
    fill(60, 34, 34);
    rect(cx + (w - 10) - 34, base - 36, 20, 36, 3, 3, 0, 0);
    fill(255, 200, 80);
    ellipse(cx + (w - 10) - 18, base - 18, 3, 3);
    cx += w;
    k++;
  }
  // anden de arriba
  fill(92, 86, 110);
  rect(0, 150, width, 58);
  stroke(70, 66, 88);
  strokeWeight(1);
  for (int i = 0; i < width; i += 44) line(i, 150, i, 208);
  line(0, 179, width, 179);
  noStroke();
  fill(120, 115, 140);
  rect(0, 204, width, 6);
  // calle
  fill(36, 34, 46);
  rect(0, 210, width, 92);
  fill(255, 12);
  for (int i = 0; i < 40; i++) rect(hsh(sem + i * 5) * width, 212 + hsh(sem + i * 8) * 86, 3, 2);
  fill(235, 200, 80);
  for (int i = 0; i < width; i += 64) rect(i + 10, 254, 34, 4, 2);
  fill(120, 115, 140);
  rect(0, 300, width, 6);
  // anden de abajo
  fill(92, 86, 110);
  rect(0, 306, width, 46);
  stroke(70, 66, 88);
  for (int i = 22; i < width; i += 44) line(i, 306, i, 352);
  noStroke();
  // jardines
  fill(30, 64, 46);
  rect(0, 352, width, 148);
  fill(40, 80, 56);
  for (int i = 0; i < 60; i++) rect(hsh(sem + i * 2.3) * width, 356 + hsh(sem + i * 4.7) * 140, 4, 3);
  for (int i = 0; i < 18; i++) {
    fill(paletaFlores[i % paletaFlores.length]);
    ellipse(hsh(sem + i * 9.1) * width, 372 + hsh(sem + i * 6.6) * 120, 5, 5);
  }
  fill(110, 80, 60);
  for (int i = 0; i < width; i += 18) rect(i, 352, 4, 16);
  rect(0, 356, width, 3);
  for (int i = 0; i < 6; i++) arbolito(60 + i * 140 + hsh(sem + i * 4) * 40, 440 + hsh(sem + i) * 45, 22 + hsh(sem + i * 2) * 10, i);
  for (int i = 0; i < 4; i++) poste(90 + i * 210 + hsh(sem + i * 3) * 20, 206, i);
  objetosBarrio(s);
}

void salidasBarrio(int s) {
  if (s == 15) flechaSalida(400, 22, 0, "Parquecito");
  if (s == 20) {
    flechaSalida(400, 470, 2, "Calle del Chisme");
    flechaSalida(22, 250, 3, "Debora");
  }
  if (s == 21) flechaSalida(778, 250, 1, "Parquecito");
  if (s == 16) flechaSalida(400, 22, 0, "Grafitis");
  if (s == 22) {
    flechaSalida(400, 470, 2, "Zona en obra");
    flechaSalida(22, 250, 3, "Asamblea");
  }
  if (s == 23) flechaSalida(778, 250, 1, "Grafitis");
  if (s == 18) {
    flechaSalida(400, 470, 2, "Entrada");
    flechaSalida(22, 250, 3, "Junta");
    flechaSalida(778, 250, 1, "Mercado");
  }
  if (s == 19) flechaSalida(778, 250, 1, "Plaza");
}

void objetosBarrio(int s) {
  if (s == 15) cartelRoto(625, 330);
  else if (s == 20) basurero(210, 352);
  else if (s == 21) carpetaSuelo(665, 360);
  else if (s == 16) zonaObra(610, 335);
  else if (s == 22) muroGrafiti(205, 200);
  else if (s == 23) buzon(665, 190);
  else if (s == 18) cajaVieja(210, 195);
  else if (s == 19) {
    letreroJunta();
    papelesSuelo(625, 195);
  }
}

void cartelRoto(float cx, float cy) {
  noStroke();
  fill(70, 50, 40);
  rect(cx - 30, cy - 50, 5, 50);
  rect(cx + 25, cy - 50, 5, 50);
  fill(230, 220, 190);
  beginShape();
  vertex(cx - 38, cy - 80);
  vertex(cx + 38, cy - 80);
  vertex(cx + 38, cy - 52);
  vertex(cx + 20, cy - 44);
  vertex(cx - 10, cy - 50);
  vertex(cx - 38, cy - 40);
  endShape(CLOSE);
  fill(200, 60, 60);
  textFont(fuenteUI);
  textSize(9);
  textAlign(CENTER, CENTER);
  text("CANCELADO", cx, cy - 66);
}

void basurero(float cx, float cy) {
  noStroke();
  fill(0, 80);
  ellipse(cx, cy + 2, 40, 10);
  fill(40, 110, 70);
  rect(cx - 17, cy - 42, 34, 42, 4);
  fill(30, 90, 55);
  rect(cx - 20, cy - 48, 40, 8, 3);
  fill(255, 60);
  rect(cx - 12, cy - 36, 4, 30, 2);
  fill(120, 200, 255, 160);
  rect(cx - 6, cy - 58, 6, 12, 2);
}

void carpetaSuelo(float cx, float cy) {
  noStroke();
  fill(0, 70);
  ellipse(cx, cy + 3, 50, 10);
  fill(240);
  pushMatrix();
  translate(cx, cy - 4);
  rotate(0.15);
  rect(-18, -10, 34, 22);
  popMatrix();
  fill(230, 180, 60);
  pushMatrix();
  translate(cx, cy - 2);
  rotate(-0.08);
  rect(-22, -12, 44, 26, 3);
  fill(200, 150, 40);
  rect(-22, -16, 16, 6, 2);
  popMatrix();
}

void zonaObra(float cx, float cy) {
  noStroke();
  for (int i = 0; i < 3; i++) {
    float px = cx - 40 + i * 40;
    fill(0, 70);
    ellipse(px, cy + 2, 22, 6);
    fill(255, 120, 30);
    triangle(px - 9, cy, px + 9, cy, px, cy - 26);
    fill(255);
    rect(px - 5, cy - 14, 10, 4);
  }
  fill(60, 60, 70);
  rect(cx - 55, cy - 52, 110, 8);
  for (int i = 0; i < 6; i++) {
    fill(i % 2 == 0 ? color(255, 200, 40) : color(30));
    rect(cx - 55 + i * 18.3, cy - 52, 18.3, 8);
  }
  fill(180, 40, 40);
  rect(cx + 30, cy - 18, 28, 16, 3);
}

void muroGrafiti(float cx, float cy) {
  noStroke();
  fill(110, 104, 120);
  rect(cx - 85, cy - 50, 170, 48, 3);
  stroke(90, 84, 100);
  strokeWeight(1);
  for (float yy = cy - 50; yy < cy; yy += 12) line(cx - 85, yy, cx + 85, yy);
  noStroke();
  strokeWeight(5);
  stroke(neonRosa);
  line(cx - 70, cy - 12, cx - 40, cy - 40);
  stroke(neonCian);
  line(cx + 40, cy - 40, cx + 70, cy - 12);
  noStroke();
  textFont(fuente);
  textSize(22);
  textAlign(CENTER, CENTER);
  fill(neonAmarillo);
  text("VERDAD", cx, cy - 26);
}

void buzon(float cx, float cy) {
  noStroke();
  fill(0, 70);
  ellipse(cx, cy + 2, 30, 8);
  fill(60, 60, 70);
  rect(cx - 3, cy - 26, 6, 26);
  fill(40, 80, 170);
  rect(cx - 16, cy - 50, 32, 26, 12, 12, 3, 3);
  fill(20);
  rect(cx - 9, cy - 40, 18, 3);
  fill(220, 50, 50);
  rect(cx + 14, cy - 52, 3, 14);
}

void cajaVieja(float cx, float cy) {
  noStroke();
  fill(0, 70);
  ellipse(cx, cy + 2, 50, 10);
  fill(170, 120, 70);
  rect(cx - 22, cy - 34, 44, 34, 2);
  fill(140, 95, 55);
  quad(cx - 22, cy - 34, cx - 30, cy - 44, cx + 4, cy - 44, cx, cy - 34);
  fill(240);
  rect(cx - 8, cy - 26, 16, 10);
}

void papelesSuelo(float cx, float cy) {
  noStroke();
  for (int i = 0; i < 6; i++) {
    pushMatrix();
    translate(cx - 30 + hsh(i * 3.1) * 60, cy - 10 + hsh(i * 7.7) * 16);
    rotate(hsh(i * 5.5) * 2 - 1);
    fill(245, 240, 225);
    rect(-9, -6, 18, 12);
    fill(120);
    rect(-6, -3, 12, 1.5);
    rect(-6, 1, 9, 1.5);
    popMatrix();
  }
}

void letreroJunta() {
  float b = 0.75 + 0.25 * sin(frameCount * 0.08);
  noStroke();
  fill(20, 14, 36);
  rect(280, 46, 240, 40, 6);
  stroke(neonVerde, 230 * b);
  strokeWeight(2);
  noFill();
  rect(280, 46, 240, 40, 6);
  noStroke();
  tituloNeon("JUNTA VECINAL", 400, 64, 20, neonVerde);
}

// ------------------------------------- ENTRADA A NOVA (escena 5) -------------------------------------
void fondoEntrada() {
  empezarFondoPixel();
  fondoEntradaMundo();
  terminarFondoPixel();
}

void fondoEntradaMundo() {
  degradado(0, 0, width, 170, color(20, 10, 45), color(90, 40, 110));
  noStroke();
  for (int i = 0; i < 16; i++) {
    float bx = i * 55 + hsh(i) * 20, bh = 60 + hsh(i * 3.3) * 90;
    fill(30, 20, 62);
    rect(bx, 150 - bh, 48, bh);
    for (int w = 0; w < 6; w++) {
      if (hsh(i * 9 + w) > 0.5) {
        fill(w % 2 == 0 ? neonCian : neonRosa, 160);
        rect(bx + 8 + (w % 3) * 13, 150 - bh + 12 + (w / 3) * 18, 5, 7);
      }
    }
  }
  // muralla
  fill(70, 64, 86);
  rect(0, 120, width, 150);
  stroke(58, 52, 72);
  strokeWeight(1);
  for (float yy = 120; yy < 270; yy += 18) {
    line(0, yy, width, yy);
    for (float xx = ((yy / 18) % 2) * 20; xx < width; xx += 40) line(xx, yy, xx, yy + 18);
  }
  noStroke();
  // puerta
  float gx = 290, gw = 220;
  fill(30, 26, 40);
  rect(gx - 12, 48, gw + 24, 222, 100, 100, 0, 0);
  boolean abierta = llEnt;
  fill(abierta ? color(40, 74, 64) : color(58, 48, 72));
  rect(gx, 66, gw, 204, 90, 90, 0, 0);
  stroke(20);
  strokeWeight(2);
  line(gx + gw / 2, 70, gx + gw / 2, 270);
  for (float yy = 110; yy < 270; yy += 30) line(gx + 10, yy, gx + gw - 10, yy);
  noStroke();
  float pulso = 0.6 + 0.4 * sin(frameCount * 0.1);
  fill(abierta ? neonVerde : neonRojo, 80 * pulso);
  ellipse(gx + gw / 2, 185, 34, 34);
  fill(abierta ? neonVerde : neonRojo);
  ellipse(gx + gw / 2, 185, 16, 16);
  tituloNeon("NOVA", gx + gw / 2, 30, 30, neonCian);
  // suelo
  fill(44, 40, 54);
  rect(0, 270, width, 230);
  stroke(54, 50, 66);
  for (float xx = 0; xx < width; xx += 50) line(xx, 270, xx + (xx - 400) * 0.6, 500);
  for (float yy = 300; yy < 500; yy += 40) line(0, yy, width, yy);
  noStroke();
  contenedor(130, 370, color(40, 110, 70));
  contenedor(700, 370, color(50, 80, 130));
  fill(25);
  ellipse(195, 395, 26, 20);
  ellipse(640, 398, 22, 18);
  poste(60, 280, 0);
  poste(560, 280, 1);
}

void contenedor(float cx, float cy, color c) {
  noStroke();
  fill(0, 90);
  ellipse(cx, cy + 32, 120, 16);
  fill(c);
  rect(cx - 55, cy - 20, 110, 52, 4);
  fill(red(c) * 0.7, green(c) * 0.7, blue(c) * 0.7);
  rect(cx - 58, cy - 28, 116, 12, 3);
  fill(255, 40);
  for (int i = 0; i < 4; i++) rect(cx - 45 + i * 26, cy - 12, 4, 36);
  fill(30);
  ellipse(cx - 40, cy + 33, 10, 10);
  ellipse(cx + 40, cy + 33, 10, 10);
}

// ------------------------------------- ALCALDIA (si no carga alcaldia.jpeg) -------------------------------------
PGraphics cacheAlcaldia;
float[][] pancartas;
String[] textosPancarta = {"VERDAD", "FUERA", "FAKE?", "#Nova", "FUENTE?", "NO + BULOS", "DATOS!"};

void fondoAlcaldia() {
  empezarFondoPixel();
  fondoAlcaldiaMundo();
  terminarFondoPixel();
}

void fondoAlcaldiaMundo() {
  if (cacheAlcaldia == null) construirAlcaldia();
  image(cacheAlcaldia, 0, 0);
  fill(255, 220, 120);
  textFont(fuenteUI);
  textSize(13);
  textAlign(CENTER, CENTER);
  text("ALCALDIA DE NOVA", 400, 25);   // fuera de la imagen guardada, para que salga nitido
  // banderas que ondean
  for (int i = 0; i < 2; i++) {
    float fx = 120 + i * 560;
    fill(80);
    noStroke();
    rect(fx, 4, 3, 60);
    fill(i == 0 ? neonCian : neonRosa);
    beginShape();
    for (int k = 0; k <= 10; k++) vertex(fx + 3 + k * 4, 8 + sin(frameCount * 0.12 + k * 0.6) * 3);
    for (int k = 10; k >= 0; k--) vertex(fx + 3 + k * 4, 26 + sin(frameCount * 0.12 + k * 0.6) * 3);
    endShape(CLOSE);
  }
  // pancartas que suben y bajan
  textFont(fuenteUI);
  textSize(8);
  textAlign(CENTER, CENTER);
  for (int i = 0; i < pancartas.length; i++) {
    float[] p = pancartas[i];
    float b = abs(sin(frameCount * 0.09 + p[2] * 7)) * 6;
    stroke(90, 70, 50);
    strokeWeight(2);
    line(p[0], p[1] - 22, p[0], p[1] - 34 - b);
    noStroke();
    fill(paletaRopa[int(p[2] * 100) % paletaRopa.length]);
    rect(p[0] - 17, p[1] - 46 - b, 34, 14, 2);
    fill(255);
    text(textosPancarta[int(p[2] * 31) % textosPancarta.length], p[0], p[1] - 40 - b);
  }
}

void construirAlcaldia() {
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.noStroke();
  for (int i = 0; i < 120; i += 3) {
    pg.fill(lerpColor(color(40, 20, 70), color(120, 60, 110), i / 120.0));
    pg.rect(0, i, width, 3);
  }
  pg.fill(200, 190, 215);
  pg.rect(60, 12, 680, 102);
  pg.fill(170, 160, 195);
  pg.rect(50, 4, 700, 14);
  for (int i = 0; i < 10; i++) {
    pg.fill(230, 225, 240);
    pg.rect(98 + i * 66, 34, 14, 72);
    pg.fill(185, 178, 205);
    pg.rect(95 + i * 66, 32, 20, 5);
  }
  pg.fill(150, 140, 175);
  pg.rect(60, 104, 680, 10);
  pg.fill(30, 25, 50);
  pg.rect(280, 16, 240, 20, 4);
  pg.fill(90, 64, 52);
  pg.rect(372, 58, 56, 56, 28, 28, 0, 0);
  // piso de la plaza
  pg.fill(112, 102, 122);
  pg.rect(0, 114, width, 386);
  pg.stroke(98, 88, 108);
  pg.strokeWeight(1);
  for (int xx = 0; xx < width; xx += 32) pg.line(xx, 114, xx, height);
  for (int yy = 114; yy < height; yy += 32) pg.line(0, yy, width, yy);
  pg.noStroke();
  // alfombra del pasillo
  pg.fill(150, 40, 60);
  pg.rect(372, 114, 80, 386);
  pg.fill(220, 180, 80);
  pg.rect(372, 114, 3, 386);
  pg.rect(449, 114, 3, 386);
  // multitud en las zonas de choque (asi se ve por que no puedes pasar)
  ArrayList<float[]> listaPancartas = new ArrayList<float[]>();
  for (int r = 1; r < obstaculos2.length - 1; r++) {
    float[] o = obstaculos2[r];
    for (float py = o[1] + 30; py <= o[1] + o[3] + 4; py += 34) {
      for (float px = o[0] + 14; px < o[0] + o[2] - 8; px += 30) {
        float sd = hsh(px * 0.37 + py * 1.91);
        float jx = px + (sd - 0.5) * 10;
        personaMini(pg, jx, py, sd);
        if (sd > 0.72) listaPancartas.add(new float[] {jx, py, sd});
      }
    }
  }
  pancartas = new float[listaPancartas.size()][];
  for (int i = 0; i < pancartas.length; i++) pancartas[i] = listaPancartas.get(i);
  pg.endDraw();
  cacheAlcaldia = pg;
}

void personaMini(PGraphics pg, float px, float py, float sd) {
  color ropa = paletaRopa[int(sd * 97) % paletaRopa.length];
  color piel = tonosPiel[int(sd * 53) % tonosPiel.length];
  pg.fill(0, 60);
  pg.ellipse(px, py, 20, 6);
  pg.fill(40, 38, 60);
  pg.rect(px - 5, py - 9, 4, 9);
  pg.rect(px + 1, py - 9, 4, 9);
  pg.fill(ropa);
  pg.rect(px - 7, py - 24, 14, 17, 5);
  pg.fill(piel);
  pg.ellipse(px, py - 29, 12, 12);
  pg.fill(sd > 0.5 ? color(30, 20, 15) : color(120, 70, 40));
  pg.arc(px, py - 30, 13, 12, PI, TWO_PI);
}

void dibujarCandidatos() {
  noStroke();
  fill(60, 40, 80);
  rect(340, 196, 134, 12, 4);
  fill(255, 220, 120);
  rect(340, 196, 134, 3);
  dibujarNPC(358, 198, #DC6E8C, #3C2814, 1, false, "");
  dibujarNPC(390, 198, #3C78C8, #141414, 2, false, "");
  dibujarNPC(422, 198, #46A064, #8C5A3C, 3, false, "");
  dibujarNPC(454, 198, #505050, #CCCCCC, 4, false, "");
}
