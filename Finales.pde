// =====================================================================================
//  FINALES.pde -> una animacion para cada final de Star Quest (estilo Red Quest)
//   0-2  finales graves: te robaron la cuenta, Sofi ya no confia en ti, Conecta suspendio tu cuenta
//   3    el silencio
//   4-7  los finales de Nova: el filtro, el agente del caos, el ciudadano consciente, el espectador silencioso
//   8-12 la verdad de @chismes_11B: el limbo, en equilibrio, el viaje, el ultimo refugio, desconectado
//  Cada animacion dura ~10 segundos, con 3 lineas de narracion. Clic o ENTER la adelanta.
//  En el menu, "FINALES" abre la galeria para verlas todas.
//  Escenas: 80 animacion de final, 81 galeria de finales.
// =====================================================================================

final int ESC_ANIM_FINAL = 80;
final int ESC_GALERIA = 81;

String[] tituloAnim = {
  "TE ROBARON LA CUENTA", "SOFI YA NO CONFIA EN TI", "CONECTA SUSPENDIO TU CUENTA", "SILENCIO",
  "EL FILTRO DE NOVA", "AGENTE DEL CAOS", "CIUDADANO CONSCIENTE", "ESPECTADOR SILENCIOSO",
  "EL LIMBO", "EN EQUILIBRIO", "EL VIAJE", "EL ULTIMO REFUGIO", "DESCONECTADO"
};
String[] tipoAnim = {
  "final grave", "final grave", "final grave", "final oculto",
  "final de Nova", "final de Nova", "final de Nova", "final de Nova",
  "la verdad", "la verdad", "la verdad", "la verdad", "final secreto"
};
String[][] lineasAnim = {
  {"Le diste tu contraseña a Kevin.", "Esa misma noche alguien entro a tu cuenta.", "Desde tu perfil se burlaron de Sofi. Todos creen que fuiste tu."},
  {"Contaste lo que Sofi te confio.", "En una hora lo sabia medio barrio.", "Sofi no volvio a escribirte."},
  {"Aceptaste el pago y creaste las cuentas falsas.", "Conecta rastreo cada una hasta ti.", "Cuenta suspendida. Y todo Nova sabe por que."},
  {"Uno a uno, dejaron de saludarte.", "Sofi no se despidio.", "Solo quedo la luz del celular."},
  {"Frenaste rumores y verificaste fuentes.", "Nova voto por propuestas, no por miedos.", "La ciudad aprendio a dudar antes de compartir."},
  {"Tus publicaciones volaron por toda Nova.", "Gano quien mas grito, no quien tenia razon.", "La ciudad tardara mucho en volver a confiar."},
  {"No fuiste perfect@.", "Pero aprendiste a dudar antes de compartir.", "Gracias a gente como tu, los bulos perdieron fuerza."},
  {"Miraste desde lejos.", "No echaste leña al fuego...", "...pero tampoco ayudaste a apagarlo."},
  {"Sofi se fue sin despedirse.", "Cada cosa que compartiste le dio fuerza a @chismes_11B.", "La cuenta sigue activa. Tu tambien."},
  {"La eleccion paso y nadie aclaro nada.", "Kevin borro su cuenta esa misma noche.", "Cada vez que te saluda, sonrie un poco de mas."},
  {"Juntaste las pruebas una por una.", "Camila manejaba @chismes_11B por envidia.", "Las pruebas la expusieron. Pero los videos siguen en algun lado."},
  {"Sofi te lo confeso en voz baja:", "ella creo @chismes_11B para defenderse, y se le salio de las manos.", "Siguen juntos. Ninguno de los dos duerme bien."},
  {"Apagaste el celular y lo dijiste en voz alta.", "Uno por uno, todos dejaron los celulares en la caja.", "Shawn, desde lejos, dejo de esperar: esta vez alguien hablo."}
};
color[] colorAnim = {#FF465A, #FF6E96, #FF465A, #8A8A98, #3CFF96, #FF465A, #00F0FF, #FFC846, #8A8A98, #4856E8, #FFC846, #E85D75, #B4A0FF};

int animId = 0;
int animDestino = -1;     // a que escena va al terminar (-1 = vuelve a la galeria)
float animT = 0;
final float ANIM_FIN = 560;

void empezarAnimFinal(int id, int destino) {
  animId = id;
  animDestino = destino;
  animT = 0;
  pararMovimiento();
  scene = ESC_ANIM_FINAL;
  if (destino >= 0) desbloquearFinal(id);   // llegaste a este final jugando: se desbloquea en la galeria (Galeria.pde)
  sonar(12);
}

void terminarAnimFinal() {
  if (animDestino < 0) scene = ESC_GALERIA;
  else scene = animDestino;
}

int musicaAnimFinal() {
  if (animId == 4 || animId == 6 || animId == 10 || animId == 12) return 2;
  if (animId == 9 || animId == 11) return 1;
  return 0;
}

// ------------------------------------- DIBUJO GENERAL -------------------------------------
void dibujarAnimFinal() {
  if (!pausaAbierta) animT++;
  float t = animT;
  background(#101018);
  noStroke();
  switch (animId) {
  case 0: animCuentaRobada(t); break;
  case 1: animSofiSeVa(t); break;
  case 2: animSuspendida(t); break;
  case 3: animSilencio(t); break;
  case 4: animFiltro(t); break;
  case 5: animCaos(t); break;
  case 6: animConsciente(t); break;
  case 7: animEspectador(t); break;
  case 8: animLimbo(t); break;
  case 9: animEquilibrio(t); break;
  case 10: animViaje(t); break;
  case 11: animRefugio(t); break;
  case 12: animDesconectado(t); break;
  }
  // franjas de cine con el titulo
  noStroke();
  fill(0);
  rect(0, 0, width, 50);
  rect(0, height - 50, width, 50);
  textFont(fuenteFinales());   // la tipografia Waifu (Galeria.pde)
  textAlign(CENTER, CENTER);
  textSize(10);
  fill(150);
  textoW(tipoAnim[animId].toUpperCase(), width / 2, 14);
  textSize(18);
  fill(colorAnim[animId]);
  textoW(tituloAnim[animId], width / 2, 33);
  // las tres lineas, una despues de otra
  int k = constrain(int((t - 20) / 170), 0, 2);
  String linea = lineasAnim[animId][k];
  float letras = constrain((t - 20 - k * 170) * 0.9, 0, linea.length());
  if (t > 20) {
    if (letras < linea.length()) sonarVoz("narrador");
    fill(10, 10, 25, 215);
    rect(80, 382, 640, 56, 10);
    fill(235);
    textSize(16);
    textoW(linea.substring(0, int(letras)), 100, 382, 600, 56);
  }
  fill(120);
  textSize(11);
  textAlign(RIGHT, CENTER);
  textoW(t < ANIM_FIN ? "clic / ENTER: adelantar" : "clic / ENTER: continuar", width - 14, height - 25);
  if (t >= ANIM_FIN) {
    textAlign(CENTER, CENTER);
    fill(colorAnim[animId], 150 + 100 * sin(frameCount * 0.1));
    textoW(animDestino < 0 ? "volver a la galeria" : "continuar", width / 2, height - 25);
  }
  // fundido de entrada y de salida
  float a = constrain(1 - t / 25.0, 0, 1);
  fill(#101018, 255 * a);
  rect(0, 0, width, height);
}

void clickAnimFinal() {
  if (animT < ANIM_FIN) {
    animT = min(ANIM_FIN, (int((animT - 20) / 170) + 1) * 170 + 20);   // salta a la siguiente linea
    if (animT > 20 + 2 * 170) animT = ANIM_FIN;
  } else terminarAnimFinal();
}

void teclaAnimFinal() {
  if (key == ENTER || key == RETURN || key == ' ') clickAnimFinal();
}

// ------------------------------------- PIEZAS PARA DIBUJAR -------------------------------------
// una persona en pixeles grandes (u = tamaño de cada pixel). (x, y) = la esquina de arriba de la cabeza
void personaU(float x, float y, float u, color pelo, color piel, color ropa, color pant, float a) {
  noStroke();
  fill(pelo, 255 * a);
  rect(x, y, 12 * u, 5 * u);
  rect(x - u, y + 3 * u, 2 * u, 8 * u);
  rect(x + 11 * u, y + 3 * u, 2 * u, 8 * u);
  fill(piel, 255 * a);
  rect(x + u, y + 4 * u, 10 * u, 8 * u);
  fill(#101018, 255 * a);
  rect(x + 3 * u, y + 7 * u, 2 * u, 2 * u);
  rect(x + 7 * u, y + 7 * u, 2 * u, 2 * u);
  fill(ropa, 255 * a);
  rect(x - u, y + 12 * u, 14 * u, 11 * u);
  fill(pant, 255 * a);
  rect(x, y + 23 * u, 5 * u, 8 * u);
  rect(x + 7 * u, y + 23 * u, 5 * u, 8 * u);
}

void tuU(float x, float y, float u, float a) {
  personaU(x, y, u, #1E1E2E, #F1C9A5, #2A2340, #1B1B2E, a);
}


// silueta oscura (gente de fondo)
void siluetaU(float x, float y, float u, color c) {
  noStroke();
  fill(c);
  rect(x, y, 12 * u, 12 * u, 3 * u);
  rect(x - u, y + 12 * u, 14 * u, 19 * u, 2 * u);
}

void celularU(float x, float y, float w, float h, color pantalla) {
  noStroke();
  fill(#191926);
  rect(x, y, w, h, w * 0.12);
  fill(pantalla);
  rect(x + w * 0.08, y + h * 0.06, w * 0.84, h * 0.88, w * 0.06);
}

void burbujaFinal(float bx, float by, String t, color fondo, color letra, float a) {
  textFont(fuenteFinales());
  textSize(13);
  float w = textWidth(t) + 22;
  noStroke();
  fill(fondo, 240 * a);
  rect(bx - w / 2, by - 15, w, 30, 12);
  triangle(bx - 6, by + 15, bx + 6, by + 15, bx, by + 23);
  fill(letra, 255 * a);
  textAlign(CENTER, CENTER);
  text(t, bx, by - 1);
}

void cieloNoche(float t) {
  for (int i = 0; i < 55; i++) {
    fill(255, 110 + 100 * sin(t * 0.05 + i));
    rect(hsh(i * 3.7) * width, 55 + hsh(i * 8.3) * 170, 2, 2);
  }
}

void edificios(float t, color ventanaOn, float rojo) {
  for (int i = 0; i < 14; i++) {
    float bx = i * 60 - 10, bh = 110 + hsh(i * 2.3) * 140;
    fill(#1B1B2E);
    rect(bx, 380 - bh, 54, bh);
    for (int k = 0; k < bh / 22; k++) {
      for (int c = 0; c < 3; c++) {
        boolean luz = hsh(i * 31 + k * 7 + c) > 0.42;
        boolean roja = hsh(i * 13 + k + c * 3) < rojo;
        fill(luz ? (roja ? color(#FF465A) : ventanaOn) : color(#24243A));
        rect(bx + 6 + c * 16, 380 - bh + 10 + k * 22, 8, 10);
      }
    }
  }
}

void sueloPlaza() {
  fill(#24203A);
  rect(0, 320, width, 80);
  fill(#2E2848);
  for (int i = 0; i < 12; i++) rect(i * 70, 330 + (i % 2) * 18, 50, 4);
}

// ------------------------------------- 0. TE ROBARON LA CUENTA -------------------------------------
void animCuentaRobada(float t) {
  float sh = t > 380 && t < 420 ? random(-4, 4) : 0;
  pushMatrix();
  translate(sh, 0);
  celularU(290, 62, 220, 310, #0C0C18);
  fill(#FF5A78);
  rect(308, 82, 184, 26, 6);
  fill(255);
  textFont(fuenteFinales());
  textSize(13);
  textAlign(CENTER, CENTER);
  text("Conecta", 400, 94);
  boolean intruso = t > 130;
  fill(intruso ? #3A1020 : #2A2A3A);
  ellipse(340, 136, 36, 36);
  if (intruso) {   // una capucha roja
    fill(#FF465A);
    arc(340, 140, 30, 34, PI, TWO_PI);
    fill(#101018);
    ellipse(340, 142, 16, 12);
  } else {
    fill(#8A8A98);
    ellipse(340, 130, 12, 12);
    rect(331, 138, 18, 9, 4);
  }
  textAlign(LEFT, CENTER);
  textSize(12);
  fill(235);
  text("@tu_usuario", 364, 130);
  fill(intruso ? #FF465A : color(150));
  textSize(10);
  text(intruso ? "sesion iniciada en otro celular" : "en linea", 364, 146);
  if (t < 130) {   // escribiendo la contraseña
    fill(#191926);
    rect(308, 180, 184, 34, 6);
    fill(200);
    textSize(12);
    int n = constrain(int(t / 10), 0, 10);
    String pass = "";
    for (int i = 0; i < n; i++) pass += "*";
    text("contrasena: " + pass + (frameCount % 30 < 15 ? "|" : ""), 318, 197);
  } else {   // publicaciones que tu no hiciste
    String[] posts = {"jajaja miren a Sofi", "Sofi no sirve para nada", "voten por cualquiera menos ella", "esto es de @tu_usuario"};
    int vis = constrain(int((t - 140) / 45), 0, 4);
    for (int i = 0; i < vis; i++) {
      float py = 176 + i * 46;
      fill(#2A1020);
      rect(308, py, 184, 38, 6);
      fill(#FF8C9A);
      textSize(11);
      text(posts[i], 318, py + 13);
      fill(#FF465A);
      text("<3 " + int(40 + (t - 140 - i * 45) * 3), 318, py + 28);
    }
  }
  if (t > 380) {   // la pantalla se raja
    stroke(255, 200);
    strokeWeight(2);
    line(330, 70, 400, 210);
    line(400, 210, 360, 365);
    line(400, 210, 500, 260);
    noStroke();
  }
  popMatrix();
  // corazones volando
  if (t > 160) {
    for (int i = 0; i < 10; i++) {
      float hy = 360 - ((t * 1.5 + i * 37) % 300);
      fill(#FF465A, 160);
      ellipse(540 + hsh(i * 3) * 120 + sin(t * 0.05 + i) * 10, hy, 12, 12);
    }
  }
}

// ------------------------------------- 1. SOFI YA NO CONFIA EN TI -------------------------------------
void animSofiSeVa(float t) {
  fill(#141826);
  rect(0, 50, width, 330);
  fill(#1E2236);
  rect(0, 320, width, 60);
  // lluvia
  stroke(150, 170, 220, 90);
  strokeWeight(1);
  for (int i = 0; i < 70; i++) {
    float rx = (hsh(i * 2.1) * width + t * 2) % width, ry = 50 + (hsh(i * 5.3) * 330 + t * 9) % 330;
    line(rx, ry, rx - 3, ry + 10);
  }
  noStroke();
  tuU(180, 216, 3.4, 1);
  // Sofi se va caminando
  float sx = 360 + max(0, t - 120) * 1.4;
  float paso = sin(t * 0.2) * 2;
  if (sx < width + 40) sofiU(sx, 216 + abs(paso), 3.4, 1);
  if (t > 40 && t < 200) burbujaFinal(sx + 20, 180, "Por que lo contaste?", #FF6E96, color(255), constrain((t - 40) / 15.0, 0, 1));
  if (t > 220 && t < 360) burbujaFinal(200, 180, "Sofi, espera...", color(235), color(30), 1);
  if (t > 380) {
    fill(#2A1020, 230);
    rect(250, 130, 300, 70, 12);
    fill(#FF6E96);
    textFont(fuenteFinales());
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Sofi te bloqueo.", 400, 155);
    fill(180);
    textSize(11);
    text("Ya no puedes ver su perfil.", 400, 180);
  }
}

// ------------------------------------- 2. CONECTA SUSPENDIO TU CUENTA -------------------------------------
void animSuspendida(float t) {
  int n = constrain(int(t / 7), 0, 48);
  for (int i = 0; i < n; i++) {
    float ax = 70 + (i % 12) * 56, ay = 80 + (i / 12) * 66;
    boolean gris = t > 320;
    fill(gris ? color(60) : color(#3A3A4A));
    ellipse(ax, ay, 36, 36);
    fill(gris ? color(90) : color(#8A8A98));
    textFont(fuenteFinales());
    textSize(11);
    textAlign(CENTER, CENTER);
    text("x  x", ax, ay - 3);
    fill(gris ? color(70) : color(#FF465A));
    textSize(8);
    text("bot" + (1000 + i * 37), ax, ay + 26);
  }
  if (t > 300) {   // el sello
    float e = constrain((t - 300) / 18.0, 0, 1);
    float esc = 3 - 2 * e;
    pushMatrix();
    translate(400 + (e >= 1 && t < 330 ? random(-5, 5) : 0), 220);
    rotate(-0.18);
    scale(esc);
    noFill();
    stroke(#FF465A, 255 * e);
    strokeWeight(5);
    rect(-190, -40, 380, 80, 8);
    noStroke();
    fill(#FF465A, 255 * e);
    textFont(fuenteFinales());
    textSize(32);
    textAlign(CENTER, CENTER);
    text("CUENTA SUSPENDIDA", 0, -2);
    popMatrix();
    if (!enMiniatura && int(t) == 318) sonar(9);
  }
}

// ------------------------------------- 3. SILENCIO -------------------------------------
void animSilencio(float t) {
  fill(#0B0B12);
  rect(0, 50, width, 330);
  float[] xs = {120, 230, 340, 520, 630};
  for (int i = 0; i < 5; i++) {
    float a = constrain(1 - (t - 60 - i * 70) / 40.0, 0, 1);
    if (a > 0) siluetaU(xs[i], 210, 3.4, color(70, 70, 90, 255 * a));
  }
  // tu, en el centro, con la luz del celular
  float brillo = 0.6 + 0.4 * sin(t * 0.08);
  fill(#9FD3FF, 40 * brillo);
  ellipse(445, 270, 220, 220);
  tuU(425, 210, 3.4, 1);
  fill(#9FD3FF);
  rect(437, 268, 18, 26, 3);
  if (t > 430) {
    fill(#FF465A);
    ellipse(446, 186, 16, 16);
    fill(220);
    textFont(fuenteFinales());
    textSize(12);
    textAlign(LEFT, CENTER);
    text("1 me gusta (tu)", 460, 186);
  }
}

// ------------------------------------- 4. EL FILTRO DE NOVA -------------------------------------
void animFiltro(float t) {
  fill(#141032);
  rect(0, 50, width, 330);
  cieloNoche(t);
  sueloPlaza();
  // el escudo que filtra
  float e = constrain(t / 60.0, 0, 1);
  noFill();
  stroke(#00F0FF, 180 * e);
  strokeWeight(4);
  arc(400, 330, 640 * e, 300 * e, PI, TWO_PI);
  stroke(#00F0FF, 50 * e);
  strokeWeight(14);
  arc(400, 330, 640 * e, 300 * e, PI, TWO_PI);
  noStroke();
  // rumores rojos que caen y se vuelven chispas verdes al tocar el escudo
  for (int i = 0; i < 9; i++) {
    float rx = 120 + hsh(i * 7.1) * 560;
    float ry = 40 + ((t * 1.6 + i * 50) % 160);
    if (ry < 175 - abs(rx - 400) * 0.12) {
      fill(#FF465A);
      rect(rx - 14, ry - 8, 28, 16, 6);
      fill(255);
      textFont(fuenteFinales());
      textSize(9);
      textAlign(CENTER, CENTER);
      text("bulo", rx, ry - 1);
    } else if (frameCount % 3 == 0 && !pausaAbierta && !enMiniatura) chispas(rx, ry, neonVerde, 2);
  }
  // la gente
  for (int i = 0; i < 9; i++) siluetaU(60 + i * 82, 300 - (i % 2) * 6, 1.6, color(#2A2448));
  // fuegos artificiales al final
  if (t > 380 && frameCount % 25 == 0 && !pausaAbierta && !enMiniatura) explosionConfeti(random(150, 650), random(80, 200), 30);
  if (t > 340) {
    fill(#3CFF96, 220);
    textFont(fuenteFinales());
    textSize(14);
    textAlign(CENTER, CENTER);
    text("NOVA DECIDE CON DATOS", 400, 300);
  }
}

// ------------------------------------- 5. AGENTE DEL CAOS -------------------------------------
void animCaos(float t) {
  fill(#1A0A14);
  rect(0, 50, width, 330);
  float rojo = constrain(t / 420.0, 0, 0.95);
  edificios(t, #FFC846, rojo);
  // flechas de "compartir" saltando entre edificios
  for (int i = 0; i < 6; i++) {
    float p = ((t * 0.012 + i * 0.17) % 1);
    float x0 = 40 + i * 120, x1 = x0 + 160;
    float ax = lerp(x0, x1, p), ay = 150 - sin(p * PI) * 90;
    fill(#FF465A);
    triangle(ax - 8, ay - 6, ax + 10, ay, ax - 8, ay + 6);
    fill(#FF465A, 80);
    ellipse(ax - 14, ay, 10, 6);
  }
  // la gente gritando
  float sh = t > 200 ? random(-2, 2) : 0;
  for (int i = 0; i < 8; i++) {
    siluetaU(70 + i * 90 + sh, 318, 1.4, color(#3A1A24));
    if (t > 150 + i * 20) burbujaFinal(82 + i * 90, 300 + (i % 2) * 6, "!!", #FF465A, color(255), 1);
  }
  fill(#FF465A, 40 * rojo);
  rect(0, 50, width, 330);
}

// ------------------------------------- 6. CIUDADANO CONSCIENTE -------------------------------------
void animConsciente(float t) {
  float amanecer = constrain((t - 300) / 200.0, 0, 1);
  fill(lerpColor(color(#141032), color(#FF9A5A), amanecer * 0.6));
  rect(0, 50, width, 330);
  fill(lerpColor(color(#24203A), color(#4A3A4A), amanecer));
  rect(0, 320, width, 60);
  tuU(380, 214, 3.4, 1);
  // el rumor llega, se detiene, se revisa y se cae
  float bx = constrain(760 - t * 3, 520, 800), by = 170;
  if (t > 260) by += (t - 260) * 2.5;
  boolean revisado = t > 200;
  if (by < 360) {
    fill(revisado ? color(110) : color(#FF465A));
    rect(bx - 50, by - 16, 100, 32, 10);
    fill(255);
    textFont(fuenteFinales());
    textSize(11);
    textAlign(CENTER, CENTER);
    text(revisado ? "sin fuente" : "URGENTE!!!", bx, by - 1);
  }
  if (t > 120 && t < 200) burbujaFinal(400, 180, "?", color(235), color(30), 1);
  if (t > 150 && t < 280) {   // la lupa
    noFill();
    stroke(#00F0FF);
    strokeWeight(4);
    ellipse(470, 200, 30, 30);
    line(480, 211, 492, 224);
    noStroke();
  }
  // los vecinos asienten
  if (t > 300) {
    for (int i = 0; i < 4; i++) {
      float vx = i < 2 ? 120 + i * 110 : 560 + (i - 2) * 110;
      personaU(vx, 230, 2.8, #2B1B10, #D9A27A, i % 2 == 0 ? color(#3A7BD5) : color(#46A064), #2B2B2B, constrain((t - 300 - i * 20) / 30.0, 0, 1));
      if (t > 340 + i * 20) {
        fill(#3CFF96);
        textFont(fuenteFinales());
        textSize(16);
        textAlign(CENTER, CENTER);
        text("v", vx + 16, 210);
      }
    }
  }
}

// ------------------------------------- 7. ESPECTADOR SILENCIOSO -------------------------------------
void animEspectador(float t) {
  // afuera, por la ventana: la ciudad con rumores volando
  fill(#141032);
  rect(150, 70, 500, 260);
  for (int i = 0; i < 8; i++) {
    float bx = 150 + i * 64, bh = 80 + hsh(i * 4.1) * 120;
    fill(#1B1B2E);
    rect(bx, 330 - bh, 56, bh);
  }
  for (int i = 0; i < 7; i++) {
    float rx = 150 + ((t * 1.2 + i * 80) % 500), ry = 110 + hsh(i * 2.7) * 140 + sin(t * 0.04 + i) * 10;
    fill(#FF465A, 200);
    rect(rx - 18, ry - 8, 36, 16, 6);
  }
  // gotas en el vidrio
  for (int i = 0; i < 25; i++) {
    float gx = 150 + hsh(i * 9.1) * 500, gy = 70 + ((hsh(i * 3.3) * 260 + t * (0.5 + hsh(i) * 1.5)) % 260);
    fill(180, 200, 255, 120);
    ellipse(gx, gy, 3, 6);
  }
  // el marco de la ventana y el cuarto oscuro
  fill(#0B0B12);
  rect(0, 50, 150, 330);
  rect(650, 50, 150, 330);
  rect(150, 50, 500, 20);
  rect(150, 330, 500, 50);
  fill(#5A4632);
  rect(150, 70, 500, 8);
  rect(150, 322, 500, 8);
  rect(396, 70, 8, 260);
  // tu, de espaldas, quiet@
  noStroke();
  fill(#0B0B12);
  rect(352, 230, 96, 150, 30);
  ellipse(400, 230, 70, 74);
}

// ------------------------------------- 8. EL LIMBO -------------------------------------
void animLimbo(float t) {
  fill(#0E0E16);
  rect(0, 50, width, 330);
  // la silla vacia de Sofi
  float a = constrain(1 - t / 300.0, 0.25, 1);
  fill(#6B4423, 255 * a);
  rect(110, 250, 70, 10);
  rect(110, 200, 10, 60);
  rect(114, 260, 6, 50);
  rect(170, 260, 6, 50);
  // @chismes_11B crece
  float r = 60 + t * 0.35;
  float p = 0.7 + 0.3 * sin(t * 0.08);
  fill(#FF465A, 30 * p);
  ellipse(470, 210, r * 2.2, r * 2.2);
  fill(#2A2A3A);
  ellipse(470, 210, r, r);
  fill(#8A8A98);
  ellipse(470, 210 - r * 0.12, r * 0.3, r * 0.3);
  rect(470 - r * 0.22, 210 + r * 0.05, r * 0.44, r * 0.2, 6);
  textFont(fuenteFinales());
  textAlign(CENTER, CENTER);
  fill(235);
  textSize(14);
  text("@chismes_11B", 470, 210 + r * 0.5 + 18);
  fill(#FF465A);
  textSize(12);
  text(nf(4812 + int(t * t * 0.05), 0) + " seguidores", 470, 210 + r * 0.5 + 36);
}

// ------------------------------------- 9. EN EQUILIBRIO -------------------------------------
void animEquilibrio(float t) {
  fill(#141826);
  rect(0, 50, width, 330);
  fill(#1E2236);
  rect(0, 320, width, 60);
  personaU(250, 214, 3.4, #141414, #C68E5E, #FF8C3C, #39404D, 1);   // Kevin
  // su celular: borrando la cuenta
  celularU(420, 110, 160, 220, #0C0C18);
  textFont(fuenteFinales());
  textAlign(CENTER, CENTER);
  float p = constrain((t - 60) / 220.0, 0, 1);
  fill(235);
  textSize(12);
  text(p < 1 ? "Eliminando cuenta..." : "Cuenta eliminada", 500, 170);
  fill(#2A2A3A);
  rect(445, 195, 110, 10, 5);
  fill(p < 1 ? #FF8C3C : color(#8A8A98));
  rect(445, 195, 110 * p, 10, 5);
  fill(150);
  textSize(10);
  text("@kevin_popular", 500, 222);
  // al final, Kevin te mira y sonrie (un poco de mas)
  if (t > 320) {
    fill(#101018);
    rect(250 + 3 * 3.4, 214 + 10 * 3.4, 6 * 3.4, 1.2 * 3.4);
    burbujaFinal(290, 180, ":)", color(235), color(30), constrain((t - 320) / 20.0, 0, 1));
  }
  if (t > 400) {
    fill(255, 120);
    textSize(30);
    text("?", 150, 200);
    text("?", 640, 120);
  }
}

// ------------------------------------- 10. EL VIAJE -------------------------------------
void animViaje(float t) {
  // un tablero de corcho con las pruebas
  fill(#3A2A1E);
  rect(0, 50, width, 330);
  fill(#B5874E);
  rect(70, 70, 660, 300, 8);
  String[] pruebas = {"CAPTURA", "VOLANTE", "GUIA"};
  float[][] pos = {{170, 140}, {170, 290}, {640, 215}};
  for (int i = 0; i < 3; i++) {
    float a = constrain((t - 20 - i * 70) / 20.0, 0, 1);
    if (a <= 0) continue;
    fill(245, 255 * a);
    rect(pos[i][0] - 55, pos[i][1] - 40, 110, 80, 4);
    fill(#FF465A, 255 * a);
    ellipse(pos[i][0], pos[i][1] - 36, 10, 10);
    fill(40, 255 * a);
    textFont(fuenteFinales());
    textSize(12);
    textAlign(CENTER, CENTER);
    text(pruebas[i], pos[i][0], pos[i][1] + 4);
    // el hilo rojo hacia el centro
    float h = constrain((t - 60 - i * 70) / 60.0, 0, 1);
    stroke(#D9283C);
    strokeWeight(2);
    line(pos[i][0], pos[i][1], lerp(pos[i][0], 410, h), lerp(pos[i][1], 210, h));
    noStroke();
  }
  // la foto del centro
  if (t > 200) {
    float a = constrain((t - 200) / 30.0, 0, 1);
    fill(235, 255 * a);
    rect(350, 140, 120, 140, 4);
    personaU(386, 158, 2.0, #A0522D, #F0C090, #20A39E, #333A56, a);
    fill(40, 255 * a);
    textFont(fuenteFinales());
    textSize(12);
    textAlign(CENTER, CENTER);
    text("CAMILA", 410, 266);
  }
  if (t > 360) {
    float e = constrain((t - 360) / 15.0, 0, 1);
    pushMatrix();
    translate(410, 210);
    rotate(-0.2);
    scale(2.4 - 1.4 * e);
    noFill();
    stroke(#FF465A, 255 * e);
    strokeWeight(4);
    rect(-80, -22, 160, 44, 6);
    noStroke();
    fill(#FF465A, 255 * e);
    textSize(22);
    textAlign(CENTER, CENTER);
    text("EXPUESTA", 0, -2);
    popMatrix();
    if (!enMiniatura && int(t) == 372) sonar(13);
  }
}

// ------------------------------------- 11. EL ULTIMO REFUGIO -------------------------------------
void animRefugio(float t) {
  fill(#0E1024);
  rect(0, 50, width, 330);
  cieloNoche(t);
  fill(255, 240, 200);
  ellipse(660, 110, 46, 46);
  fill(#0E1024);
  ellipse(674, 104, 40, 40);
  fill(#1A1A2E);
  rect(0, 330, width, 50);
  // la banca
  fill(#6B4423);
  rect(250, 292, 300, 10);
  rect(250, 270, 300, 8);
  rect(262, 302, 8, 30);
  rect(530, 302, 8, 30);
  tuU(300, 196, 3.0, 1);
  sofiU(440, 196, 3.0, 1);
  // la luz de los celulares
  float b = 0.6 + 0.4 * sin(t * 0.07);
  fill(#9FD3FF, 50 * b);
  ellipse(318, 270, 90, 60);
  ellipse(458, 270, 90, 60);
  fill(#9FD3FF);
  rect(312, 262, 14, 18, 3);
  fill(#FF465A);
  rect(452, 262, 14, 18, 3);
  if (t > 160 && t < 330) burbujaFinal(470, 165, "Fui yo...", #FF6E96, color(255), constrain((t - 160) / 15.0, 0, 1));
  if (t > 340) {   // el logo en su pantalla
    fill(#FF465A, 200);
    textFont(fuenteFinales());
    textSize(12);
    textAlign(CENTER, CENTER);
    text("@chismes_11B", 459, 182);
  }
}

// ------------------------------------- 12. DESCONECTADO -------------------------------------
void animDesconectado(float t) {
  float luz = constrain(t / 400.0, 0, 1);
  fill(lerpColor(color(#141032), color(#3A2A4A), luz));
  rect(0, 50, width, 330);
  cieloNoche(t + 200);
  sueloPlaza();
  // la caja en el centro
  fill(#7A4E2A);
  rect(350, 286, 100, 50, 4);
  fill(#5A3518);
  rect(350, 286, 100, 8);
  // la gente deja el celular en la caja
  float[] xs = {100, 180, 260, 500, 580, 660};
  for (int i = 0; i < 6; i++) {
    color ropa = i == 2 ? color(#E85D75) : (i == 3 ? color(#FF8C3C) : color(#3A3A5A));
    personaU(xs[i], 214, 2.6, #2B1B10, #F1C9A5, ropa, #24243A, 1);
    float p = constrain((t - 40 - i * 45) / 40.0, 0, 1);
    float cx = lerp(xs[i] + 15, 400, p), cy = lerp(262, 290, p) - sin(p * PI) * 70;
    if (p < 1) {
      fill(#9FD3FF);
      rect(cx - 6, cy - 8, 12, 16, 2);
    } else {
      fill(#202030);
      rect(360 + i * 13, 286, 10, 6);
    }
  }
  // Shawn se despide desde lejos
  float a = constrain(1 - (t - 360) / 120.0, 0, 0.8);
  if (a > 0) {
    dibujarFantasma(755, 330, a);
    if (t > 300 && t < 440) {
      fill(220, 235, 255, 255 * a);
      textFont(fuenteFinales());
      textSize(11);
      textAlign(CENTER, CENTER);
      text("(se despide)", 755, 236);
    }
  }
}

