// =====================================================================================
//  GALERIA.pde -> la galeria FINALES (escena 81)
//  Igual que la pagina "Finales de Star Quest": secciones, tarjetas con la animacion en vivo,
//  las 3 lineas de cada final y como se llega a el. Rueda del mouse o flechas para bajar.
// =====================================================================================

int regresoGaleria = 0;
float galeriaScroll = 0, galeriaScrollVista = 0;
boolean enMiniatura = false;   // true mientras se dibuja una miniatura (sin sonidos ni particulas)

String[] comoLlegas = {
  "El lunes en la tarde, a Kevin le das tu contraseña \"porque es tu amigo\".",
  "El martes, le cuentas a Mateo todo lo que le pasa a Sofi.",
  "El miercoles, aceptas el trato completo del asesor de la campaña rival.",
  "Terminar con Nova muy sombria y menos de 25 de relacion con Sofi.",
  "Confiabilidad de 60 o mas e Impacto de 50 o mas.",
  "Viralidad de 60 o mas con Confiabilidad por debajo de 40.",
  "Confiabilidad de 35 o mas, sin llegar al Filtro de Nova.",
  "Cuando no se cumple ninguno de los otros tres (pocas decisiones, barras bajas).",
  "Nova sombria y Sofi lejos de ti (relacion menor a 65).",
  "Un ambiente regulado, ni muy bueno ni muy malo.",
  "Nova brillante, gracias a buenas decisiones y poca culpa.",
  "Nova sombria pero con Sofi a tu lado (relacion de 65 o mas).",
  "Las 3 pruebas, el mensaje de Shawn, 4 insignias y 40 de relacion: el miercoles aparece \"Apagar el celular\"."
};
String[] seccionTitulo = {"Finales graves", "Final oculto", "Finales de Nova", "La verdad de @chismes_11B"};
String[] seccionTexto = {
  "Cortan el juego en seco cuando eliges la peor opcion de una situacion. Despues de la animacion puedes repetir el dia.",
  "Aparece antes de los resultados cuando todo salio muy mal.",
  "Salen justo antes de los resultados de la eleccion y dependen de tus barras de Viralidad, Confiabilidad e Impacto.",
  "Salen al tocar \"Epilogo\" despues de los resultados. Dependen del ambiente de Nova y de tu relacion con Sofi."
};
int[][] seccionFinales = {{0, 1, 2}, {3}, {4, 5, 6, 7}, {8, 9, 10, 11, 12}};

final float GAL_X = 24, GAL_TOP = 74, CARD_W = 240, CARD_GAP = 16, THUMB_H = 150, CARD_H = 318;

void abrirGaleria() {
  regresoGaleria = scene;
  scene = ESC_GALERIA;
}

// donde va cada tarjeta (en coordenadas del contenido, antes del scroll)
float[] posTarjeta(int id) {
  float yy = 0;
  for (int s = 0; s < seccionFinales.length; s++) {
    yy += 54;   // titulo y texto de la seccion
    for (int k = 0; k < seccionFinales[s].length; k++) {
      int col = k % 3, fila = k / 3;
      if (seccionFinales[s][k] == id) return new float[] {GAL_X + col * (CARD_W + CARD_GAP), yy + fila * (CARD_H + CARD_GAP)};
    }
    yy += ceil(seccionFinales[s].length / 3.0) * (CARD_H + CARD_GAP) + 10;
  }
  return new float[] {0, 0};
}

float altoGaleria() {
  float yy = 0;
  for (int s = 0; s < seccionFinales.length; s++) yy += 54 + ceil(seccionFinales[s].length / 3.0) * (CARD_H + CARD_GAP) + 10;
  return yy + 30;
}

float maxScrollGaleria() {
  return max(0, altoGaleria() - (height - GAL_TOP));
}

// la animacion de un final, chiquita y en bucle, dentro de su tarjeta
void miniaturaFinal(int id, float x, float y, float w, float h) {
  float s = w / 800.0;
  float t = (frameCount + id * 45) % ANIM_FIN;
  clip(x, y, w, h);
  pushMatrix();
  translate(x, y);
  scale(s);
  noStroke();
  fill(#101018);
  rect(0, 0, 800, 500);
  enMiniatura = true;
  int guardado = animId;
  animId = id;
  switch (id) {
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
  animId = guardado;
  enMiniatura = false;
  noStroke();
  fill(0);
  rect(0, 0, 800, 50);
  rect(0, 450, 800, 50);
  popMatrix();
  noClip();
}

// ------------------------------------- DESBLOQUEO -------------------------------------
// cada final se desbloquea la primera vez que llegas a el jugando, y queda guardado
boolean[] finalVisto = new boolean[13];
float sacudidaGaleria = 0;
int tarjetaSacudida = -1;

void desbloquearFinal(int id) {
  if (id < 0 || id >= finalVisto.length || finalVisto[id]) return;
  finalVisto[id] = true;
  avisar("Final desbloqueado", tituloAnim[id] + " ya esta en la galeria FINALES del menu.", #FFC846);
  guardarDatos();
}

int contarFinalesVistos() {
  int n = 0;
  for (boolean b : finalVisto) if (b) n++;
  return n;
}

String textoFinalesVistos() {
  String t = "";
  for (boolean b : finalVisto) t += b ? "1" : "0";
  return t;
}

void cargarFinalesVistos(String l) {
  l = trim(l);
  for (int i = 0; i < min(l.length(), finalVisto.length); i++) finalVisto[i] = l.charAt(i) == '1';
}

// ------------------------------------- TIPOGRAFIA WAIFU -------------------------------------
// la galeria y las animaciones de los finales usan la fuente CyberpunkWaifus del juego.
// Esa fuente no trae ñ ni tildes: se cambian por la letra sin tilde para que no salgan cuadritos.
PFont fuenteFinales() {
  return fuente != null ? fuente : fuenteUI;
}

String sinTildes(String s) {
  String a = "ñÑáéíóúÁÉÍÓÚü", b = "nNaeiouAEIOUu";
  StringBuilder r = new StringBuilder();
  for (int i = 0; i < s.length(); i++) {
    int k = a.indexOf(s.charAt(i));
    r.append(k >= 0 ? b.charAt(k) : s.charAt(i));
  }
  return r.toString();
}

void textoW(String s, float x, float y) {
  text(sinTildes(s), x, y);
}

void textoW(String s, float x, float y, float w, float h) {
  text(sinTildes(s), x, y, w, h);
}

// la miniatura de un final que todavia no has visto: estatica y un candado
void miniaturaBloqueada(int id, float x, float y, float w, float h) {
  clip(x, y, w, h);
  noStroke();
  fill(#0B0B12);
  rect(x, y, w, h);
  for (int i = 0; i < 90; i++) {
    float sx = x + hsh(i * 3.7 + (frameCount / 6) * 1.3) * w, sy = y + hsh(i * 5.9 + (frameCount / 6) * 0.7) * h;
    fill(60 + hsh(i * 1.1) * 60, 120);
    rect(sx, sy, 3, 2);
  }
  float cx = x + w / 2, cy = y + h / 2;
  fill(#2A2A40);
  rect(cx - 16, cy - 4, 32, 24, 4);
  noFill();
  stroke(#2A2A40);
  strokeWeight(5);
  arc(cx, cy - 4, 20, 24, PI, TWO_PI);
  noStroke();
  fill(#9A9AB4);
  ellipse(cx, cy + 6, 6, 6);
  rect(cx - 1.5, cy + 6, 3, 7);
  noClip();
}

// ------------------------------------- DIBUJO DE LA GALERIA -------------------------------------
void dibujarGaleria() {
  background(#101018);
  galeriaScroll = constrain(galeriaScroll, 0, maxScrollGaleria());
  galeriaScrollVista = lerp(galeriaScrollVista, galeriaScroll, 0.25);
  if (sacudidaGaleria > 0) sacudidaGaleria *= 0.85;
  float oy = GAL_TOP - galeriaScrollVista;
  textFont(fuenteFinales());
  // contenido que se desplaza
  clip(0, GAL_TOP, width, height - GAL_TOP);
  float yy = oy;
  for (int s = 0; s < seccionFinales.length; s++) {
    fill(#E6E6F0);
    textAlign(LEFT, TOP);
    textSize(17);
    textoW(seccionTitulo[s], GAL_X, yy + 6);
    fill(#9A9AB4);
    textSize(10);
    textoW(seccionTexto[s], GAL_X, yy + 30, 752, 22);
    yy += 54 + ceil(seccionFinales[s].length / 3.0) * (CARD_H + CARD_GAP) + 10;
  }
  for (int id = 0; id < tituloAnim.length; id++) {
    float[] p = posTarjeta(id);
    float cx = p[0], cy = oy + p[1];
    if (cy > height || cy + CARD_H < GAL_TOP) continue;   // fuera de la vista
    boolean visto = finalVisto[id];
    boolean s = mouseY > GAL_TOP && encima(cx, cy, CARD_W, CARD_H);
    if (id == tarjetaSacudida && sacudidaGaleria > 0.3) cx += random(-sacudidaGaleria, sacudidaGaleria);
    color c = visto ? colorAnim[id] : color(#5A5A72);
    noStroke();
    fill(#181827);
    rect(cx, cy, CARD_W, CARD_H, 12);
    if (visto) miniaturaFinal(id, cx, cy, CARD_W, THUMB_H);
    else miniaturaBloqueada(id, cx, cy, CARD_W, THUMB_H);
    clip(0, GAL_TOP, width, height - GAL_TOP);
    if (visto) {   // boton de play
      noStroke();
      fill(0, s ? 150 : 90);
      ellipse(cx + CARD_W / 2, cy + THUMB_H / 2, 40, 40);
      fill(s ? c : color(255, 220));
      triangle(cx + CARD_W / 2 - 6, cy + THUMB_H / 2 - 10, cx + CARD_W / 2 - 6, cy + THUMB_H / 2 + 10, cx + CARD_W / 2 + 11, cy + THUMB_H / 2);
    }
    // textos
    float ix = cx + 14, iy = cy + THUMB_H + 10;
    textFont(fuenteFinales());
    textAlign(LEFT, TOP);
    textSize(9);
    fill(#9A9AB4);
    textoW(tipoAnim[id].toUpperCase(), ix, iy);
    textSize(15);
    fill(c);
    textoW(visto ? tituloAnim[id] : "? ? ?", ix, iy + 14);
    textSize(10);
    if (visto) {
      for (int k = 0; k < 3; k++) {
        fill(c);
        textoW(">", ix, iy + 40 + k * 25);
        fill(#E6E6F0);
        textoW(lineasAnim[id][k], ix + 12, iy + 40 + k * 25, CARD_W - 40, 26);
      }
    } else {
      fill(#9A9AB4);
      textoW("Final bloqueado.", ix, iy + 40);
      textoW("Llega a este final jugando para verlo aqui.", ix, iy + 60, CARD_W - 28, 30);
    }
    stroke(#2A2A40);
    strokeWeight(1);
    line(ix, iy + 118, cx + CARD_W - 14, iy + 118);
    noStroke();
    fill(#9A9AB4);
    textSize(9);
    textoW((visto ? "Como llegas: " : "Pista: ") + comoLlegas[id], ix, iy + 124, CARD_W - 28, 34);
    // borde
    noFill();
    stroke(s ? c : color(#2A2A40), s ? 255 : 200);
    strokeWeight(s ? 2.5 : 1);
    rect(cx, cy, CARD_W, CARD_H, 12);
    noStroke();
  }
  noClip();
  // encabezado fijo
  fill(#101018);
  rect(0, 0, width, GAL_TOP);
  tituloNeon("STAR QUEST - FINALES", width / 2 + 30, 24, 22, #FFC846);
  textFont(fuenteFinales());
  textSize(11);
  fill(#E6E6F0);
  textAlign(CENTER, CENTER);
  textoW("Desbloqueados: " + contarFinalesVistos() + " / " + finalVisto.length, width / 2 + 30, 47);
  textSize(9);
  fill(#9A9AB4);
  textoW("Al terminar el jueves:  Juicio o Silencio  >  Final de Nova + resultados  >  Epilogo: la verdad", width / 2 + 30, 63);
  stroke(#2A2A40);
  strokeWeight(1);
  line(0, GAL_TOP - 1, width, GAL_TOP - 1);
  noStroke();
  botonVolver();
  // barra de scroll
  float total = altoGaleria(), vista = height - GAL_TOP;
  if (total > vista) {
    float bh = max(30, vista * vista / total);
    float by = GAL_TOP + (vista - bh) * (galeriaScrollVista / maxScrollGaleria());
    fill(#2A2A40);
    rect(width - 8, GAL_TOP + 4, 4, vista - 8, 2);
    fill(#FFC846, 180);
    rect(width - 8, by + 4, 4, bh - 8, 2);
  }
  if (galeriaScroll < 10) {
    fill(#9A9AB4, 150 + 100 * sin(frameCount * 0.08));
    textFont(fuenteFinales());
    textSize(9);
    textAlign(RIGHT, CENTER);
    textoW("rueda del mouse o flechas para ver mas", width - 18, height - 10);
  }
}

void clickGaleria() {
  if (clickVolver()) {
    scene = regresoGaleria == ESC_GALERIA || regresoGaleria == ESC_ANIM_FINAL ? 0 : regresoGaleria;
    return;
  }
  if (mouseY < GAL_TOP) return;
  float oy = GAL_TOP - galeriaScrollVista;
  for (int id = 0; id < tituloAnim.length; id++) {
    float[] p = posTarjeta(id);
    if (encima(p[0], oy + p[1], CARD_W, CARD_H)) {
      if (finalVisto[id]) empezarAnimFinal(id, -1);
      else {   // bloqueado: la tarjeta tiembla
        tarjetaSacudida = id;
        sacudidaGaleria = 8;
        sonar(7);
      }
      return;
    }
  }
}

void teclaGaleria() {
  if (key == CODED && keyCode == DOWN) galeriaScroll += 80;
  if (key == CODED && keyCode == UP) galeriaScroll -= 80;
  galeriaScroll = constrain(galeriaScroll, 0, maxScrollGaleria());
}

