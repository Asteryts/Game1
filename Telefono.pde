// =====================================================================================
//  TELEFONO.pde -> el celular nuevo (se abre con P o TAB, o con el icono del mapa/HUD)
//  Apps: Conecta (feed con publicaciones para compartir o verificar), Stats, Juegos,
//  Logros, NOVA IA (consejos) y Mapa
// =====================================================================================

boolean telefonoAbierto = false;
float telAnim = 0;
int telApp = 0;            // 0 inicio, 1 conecta, 2 stats, 3 juegos, 4 logros, 5 nova
float feedScroll = 0;
float logrosScroll = 0;
int feedVisibles = 3;      // las demas publicaciones llegan como notificaciones mientras juegas
int[] estadoFeed;          // 0 pendiente, 1 compartida, 2 verificada
ArrayList<String> chatNova = new ArrayList<String>();
float novaEscribiendo = 0;

// usuario, texto, F (falsa) o V (verdadera), explicacion
String[][] feed = {
  {"@NovaVerdad24", "URGENTE: Ramirez quiere cerrar el colegio para vender el lote!! Difundan antes de que lo borren", "F", "Pagina creada ayer, sin autor ni documentos."},
  {"Junta Vecinal Nova", "Este sabado: jornada 'Recuperemos el parque'. Trae guantes y buena energia. 8:00 a.m.", "V", "Publicacion oficial de la Junta con fecha y lugar."},
  {"@chismenova", "Lo que Dani escondia en su casillero... (foto) #escandalo #colegio", "F", "Foto tomada sin permiso. Era una maqueta de geografia."},
  {"Alcaldia de Nova", "Recuerda: las mesas de votacion abren a las 8:00 a.m. el domingo. Lleva tu documento.", "V", "Cuenta oficial verificada."},
  {"@ladenuncia", "VIDEO: Clemencia comprando votos. No lo veras en los medios!!!", "F", "Clip de 9 segundos sin fecha, lugar ni fuente."},
  {"Cafe 404", "Hoy 2x1 en capuchinos para quien venga a conversar (no a pelear) de elecciones.", "V", "Cuenta del negocio desde 2018, nada sospechoso."},
  {"@tia_marta_oficial", "Reenvien: el agua del parque esta contaminada. Me lo dijo la vecina de mi prima.", "F", "El acueducto no ha emitido ninguna alerta."},
  {"Nova Noticias", "Debate de candidatos: jueves 7 p.m. en vivo. Envia tus preguntas.", "V", "Medio con redaccion y periodistas identificables."},
  {"@bot_patriota_8812", "Gonzalo quiere PROHIBIR los carros en toda Nova. Despierten!!!", "F", "Cuenta bot: creada hoy, 400 publicaciones. Su propuesta real es una ciclorruta."},
  {"Biblioteca Nova", "Taller gratis: como detectar imagenes manipuladas. Cupos limitados.", "V", "Institucion publica con pagina oficial."}
};

String[] consejosNova = {
  "Antes de compartir, preguntate: quien lo publica y desde cuando existe esa cuenta?",
  "Si un mensaje te pide urgencia ('compartelo YA'), frena: la prisa es la mejor amiga del bulo.",
  "Haz lectura lateral: abre otra pestaña y busca si medios serios dicen lo mismo.",
  "Una foto puede ser real y la historia falsa. Busca la imagen original con busqueda inversa.",
  "Los videos cortos sin fecha ni lugar pueden estar cortados para cambiar el sentido.",
  "Cuentas nuevas, sin foto y con cientos de publicaciones al dia suelen ser bots.",
  "Si compartiste algo falso, corrigelo publicamente. Eso tambien suma confianza.",
  "Desconfia de los titulares que te dan mucha rabia: estan hechos para que reacciones sin pensar.",
  "Que mucha gente lo comparta no lo vuelve verdad. Mil reenvios de un rumor siguen siendo un rumor."
};

String[] nombresApps = {"Conecta", "Stats", "Juegos", "Logros", "NOVA IA", "Mapa"};
color[] coloresApps = {#FF3CC8, #00F0FF, #3CFF96, #FFDC3C, #9650FF, #FF8C3C};

void prepararTelefono() {
  estadoFeed = new int[feed.length];
  chatNova.clear();
  chatNova.add("NOVA: Hola, soy NOVA, la IA de la ciudad. Toca 'Pedir consejo' cuando quieras.");
}

void abrirTelefono() {
  telefonoAbierto = true;
  telApp = 0;
  pararMovimiento();
}

void cerrarTelefono() {
  telefonoAbierto = false;
}

void teclaTelefono() {
  if (key == 'p' || key == 'P' || key == TAB) cerrarTelefono();
  if (key == BACKSPACE) telApp = 0;
}

void mouseWheel(MouseEvent ev) {
  if (telefonoAbierto && telApp == 1) feedScroll += ev.getCount() * 40;
  if (telefonoAbierto && telApp == 4) logrosScroll += ev.getCount() * 30;
}

void dibujarTelefono() {
  telAnim = lerp(telAnim, telefonoAbierto ? 1 : 0, 0.2);
  if (telAnim < 0.01) return;
  noStroke();
  fill(0, 150 * telAnim);
  rect(0, 0, width, height);
  float px = width / 2 - 140, py = 20 + (1 - telAnim) * 480, pw = 280, ph = 460;
  for (int i = 4; i >= 1; i--) {
    fill(neonCian, 10);
    rect(px - i * 4, py - i * 4, pw + i * 8, ph + i * 8, 36 + i * 4);
  }
  fill(18, 16, 28);
  rect(px, py, pw, ph, 36);
  stroke(80, 80, 110);
  strokeWeight(2);
  noFill();
  rect(px + 2, py + 2, pw - 4, ph - 4, 34);
  noStroke();
  float sx = px + 12, sy = py + 14, sw = pw - 24, sh = ph - 28;
  // fondo de pantalla animado
  fill(10, 8, 22);
  rect(sx, sy, sw, sh, 26);
  imageMode(CORNER);
  clip(sx, sy, sw, sh);
  for (int i = 0; i < sh; i += 6) {
    fill(lerpColor(color(40, 10, 70), color(10, 30, 70), i / sh));
    rect(sx, sy + i, sw, 6);
  }
  for (int i = 0; i < 5; i++) {
    fill(coloresApps[i], 35);
    float r = 90 + i * 20;
    ellipse(sx + sw / 2 + sin(frameCount * 0.01 + i * 1.3) * 80, sy + sh / 2 + cos(frameCount * 0.013 + i) * 120, r, r);
  }
  float cy = sy + 30, ch = sh - 30 - 34;
  if (telApp == 0) homeTelefono(sx, cy, sw, ch);
  else if (telApp == 1) appConecta(sx, cy, sw, ch);
  else if (telApp == 2) appStats(sx, cy, sw, ch);
  else if (telApp == 3) appJuegos(sx, cy, sw, ch);
  else if (telApp == 4) appLogros(sx, cy, sw, ch);
  else if (telApp == 5) appNova(sx, cy, sw, ch);
  // barra de estado
  fill(0, 120);
  rect(sx, sy, sw, 26);
  fill(18, 16, 28);
  rect(px + pw / 2 - 45, sy, 90, 20, 0, 0, 12, 12);
  textFont(fuenteUI);
  textSize(11);
  fill(255);
  textAlign(LEFT, CENTER);
  text(textoHora(), sx + 18, sy + 12);
  textAlign(RIGHT, CENTER);
  text("5G   87%", sx + sw - 18, sy + 12);
  noClip();
  boolean s = encima(px + pw / 2 - 50, py + ph - 42, 100, 30);
  fill(s ? 255 : 170);
  rect(px + pw / 2 - 45, py + ph - 26, 90, 5, 3);
}

void cabeceraApp(String t, color c, float sx, float cy, float sw) {
  fill(10, 8, 24, 240);
  rect(sx, cy, sw, 34);
  fill(c);
  rect(sx, cy + 33, sw, 2);
  fill(encima(sx + 4, cy, 40, 34) ? 255 : 200);
  textFont(fuenteUI);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("<", sx + 14, cy + 16);
  textSize(15);
  fill(255);
  textAlign(CENTER, CENTER);
  text(t, sx + sw / 2, cy + 16);
}

void iconoApp(int i, float cx, float cy, float s) {
  color c = coloresApps[i];
  noStroke();
  fill(c, 50);
  rect(cx - s / 2 - 3, cy - s / 2 - 3, s + 6, s + 6, 18);
  fill(lerpColor(c, color(20, 10, 40), 0.35));
  rect(cx - s / 2, cy - s / 2, s, s, 15);
  fill(255, 40);
  rect(cx - s / 2, cy - s / 2, s, s / 2, 15, 15, 0, 0);
  fill(255);
  stroke(255);
  strokeWeight(2.5);
  if (i == 0) {
    noStroke();
    rect(cx - 15, cy - 12, 30, 20, 6);
    triangle(cx - 8, cy + 6, cx, cy + 6, cx - 10, cy + 14);
    fill(c);
    ellipse(cx - 7, cy - 2, 4, 4);
    ellipse(cx, cy - 2, 4, 4);
    ellipse(cx + 7, cy - 2, 4, 4);
  } else if (i == 1) {
    noStroke();
    rect(cx - 14, cy, 7, 12);
    rect(cx - 4, cy - 8, 7, 20);
    rect(cx + 6, cy - 14, 7, 26);
  } else if (i == 2) {
    noStroke();
    rect(cx - 17, cy - 9, 34, 20, 9);
    fill(c);
    rect(cx - 11, cy - 1, 9, 3);
    rect(cx - 8, cy - 4, 3, 9);
    ellipse(cx + 8, cy - 2, 4, 4);
    ellipse(cx + 12, cy + 3, 4, 4);
  } else if (i == 3) {
    noStroke();
    arc(cx, cy - 6, 24, 26, 0, PI);
    rect(cx - 12, cy - 12, 24, 6);
    rect(cx - 2, cy + 6, 4, 6);
    rect(cx - 8, cy + 11, 16, 4, 2);
  } else if (i == 4) {
    noFill();
    ellipse(cx, cy, 30, 12);
    noStroke();
    fill(255);
    ellipse(cx, cy, 14, 14);
  } else if (i == 5) {
    noStroke();
    ellipse(cx, cy - 5, 20, 20);
    triangle(cx - 9, cy - 1, cx + 9, cy - 1, cx, cy + 14);
    fill(c);
    ellipse(cx, cy - 5, 8, 8);
  }
  noStroke();
}

float[] posApp(int i, float sx, float cy) {
  return new float[] {sx + 46 + (i % 3) * 82, cy + 150 + (i / 3) * 96};
}

void homeTelefono(float sx, float cy, float sw, float ch) {
  textFont(fuente);
  textSize(48);
  fill(255);
  textAlign(CENTER, CENTER);
  text(textoHora(), sx + sw / 2, cy + 36);
  textFont(fuenteUI);
  textSize(12);
  fill(210);
  text("Faltan " + diasElecciones() + " dias para las elecciones", sx + sw / 2, cy + 78);
  for (int i = 0; i < nombresApps.length; i++) {
    float[] p = posApp(i, sx, cy);
    boolean s = encima(p[0] - 30, p[1] - 30, 60, 60);
    iconoApp(i, p[0], p[1] - (s ? 3 : 0), 54);
    fill(255);
    textSize(11);
    textAlign(CENTER, CENTER);
    text(nombresApps[i], p[0], p[1] + 40);
    if (i == 0 && notifPendientes > 0) {
      fill(neonRojo);
      ellipse(p[0] + 25, p[1] - 25, 20, 20);
      fill(255);
      text(notifPendientes, p[0] + 25, p[1] - 26);
    }
  }
  // widget con tus estadisticas
  float wy = cy + ch - 74;
  fill(10, 8, 24, 200);
  rect(sx + 14, wy, sw - 28, 64, 14);
  fill(neonCian);
  textAlign(LEFT, CENTER);
  textSize(11);
  text(perfilJugador(), sx + 26, wy + 14);
  barraTel(sx + 26, wy + 28, sw - 52, viralidad, neonRosa);
  barraTel(sx + 26, wy + 39, sw - 52, confiabilidad, neonCian);
  barraTel(sx + 26, wy + 50, sw - 52, impacto, neonAmarillo);
}

void barraTel(float bx, float by, float bw, float v, color c) {
  fill(40, 36, 60);
  rect(bx, by, bw, 6, 3);
  fill(c);
  rect(bx, by, bw * constrain(v, 0, 100) / 100.0, 6, 3);
}

String perfilJugador() {
  if (decisionesTomadas == 0) return "Perfil: recien llegado a Nova";
  if (confiabilidad >= 60) return "Perfil: verificador estrella";
  if (viralidad >= 60 && confiabilidad < 40) return "Perfil: maquina de rumores";
  if (impacto >= 50) return "Perfil: voz de la comunidad";
  return "Perfil: ciudadano en duda";
}

// ---------- CONECTA ----------
void appConecta(float sx, float cy, float sw, float ch) {
  float top = cy + 40;
  float total = feedVisibles * 158;
  feedScroll = constrain(feedScroll, 0, max(0, total - (ch - 40)));
  float yy = top - feedScroll;
  for (int k = feedVisibles - 1; k >= 0; k--) {
    if (yy > cy - 160 && yy < cy + ch + 20) dibujarPost(k, sx + 8, yy, sw - 16);
    yy += 158;
  }
  cabeceraApp("Conecta", coloresApps[0], sx, cy, sw);
  if (total > ch - 40) {
    fill(255, 60);
    float alto = (ch - 40) * (ch - 40) / total;
    rect(sx + sw - 5, top + (ch - 40 - alto) * feedScroll / max(1, total - (ch - 40)), 3, alto, 2);
  }
}

void dibujarPost(int k, float bx, float by, float bw) {
  String[] p = feed[k];
  fill(26, 22, 44, 240);
  rect(bx, by, bw, 150, 12);
  fill(coloresApps[k % coloresApps.length]);
  ellipse(bx + 20, by + 20, 26, 26);
  fill(255);
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  String inicial = p[0].startsWith("@") ? p[0].substring(1, 2) : p[0].substring(0, 1);
  text(inicial.toUpperCase(), bx + 20, by + 19);
  textAlign(LEFT, CENTER);
  text(p[0], bx + 40, by + 14);
  fill(150);
  textSize(10);
  text("hace " + ((k * 7) % 50 + 3) + " min", bx + 40, by + 28);
  fill(230);
  textSize(12);
  textAlign(LEFT, TOP);
  text(p[1], bx + 10, by + 40, bw - 20, 56);
  int likes = int(hsh(k * 3.3) * 900 + 40 + (estadoFeed[k] == 0 ? frameCount * 0.04 * (k + 1) : 0));
  fill(160);
  textSize(10);
  text("♥ " + likes + "    " + int(likes * 0.4) + " compartidos", bx + 10, by + 97);
  if (estadoFeed[k] == 0) {
    float bw2 = (bw - 30) / 2;
    botonMini("Compartir", bx + 10, by + 114, bw2, 26, neonRosa);
    botonMini("Verificar", bx + 20 + bw2, by + 114, bw2, 26, neonCian);
  } else {
    boolean falso = p[2].equals("F");
    color sc = falso ? neonRojo : neonVerde;
    fill(sc);
    textSize(10);
    textAlign(LEFT, TOP);
    String quien = estadoFeed[k] == 1 ? "Lo compartiste. " : "Lo verificaste. ";
    text(quien + (falso ? "FALSO: " : "REAL: ") + p[3], bx + 10, by + 112, bw - 20, 36);
    pushMatrix();
    translate(bx + bw - 58, by + 26);
    rotate(-0.2);
    stroke(sc, 200);
    strokeWeight(2);
    noFill();
    rect(-40, -12, 80, 24, 4);
    noStroke();
    fill(sc, 220);
    textAlign(CENTER, CENTER);
    textSize(13);
    text(falso ? "FALSO" : "REAL", 0, -1);
    popMatrix();
  }
}

void botonMini(String t, float bx, float by, float bw, float bh, color c) {
  boolean s = encima(bx, by, bw, bh);
  fill(s ? c : color(red(c) * 0.25, green(c) * 0.25, blue(c) * 0.25));
  stroke(c);
  strokeWeight(1);
  rect(bx, by, bw, bh, 8);
  noStroke();
  fill(s ? color(15) : color(255));
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  text(t, bx + bw / 2, by + bh / 2 - 1);
}

void resolverPost(int k, boolean compartir) {
  boolean falso = feed[k][2].equals("F");
  if (compartir) {
    estadoFeed[k] = 1;
    if (falso) {
      viralidad += 8;
      confiabilidad -= 8;
      impacto -= 6;
    } else {
      viralidad += 6;
      confiabilidad += 2;
      impacto += 5;
    }
  } else {
    estadoFeed[k] = 2;
    if (falso) {
      confiabilidad += 6;
      impacto += 4;
    } else {
      confiabilidad += 4;
      impacto += 2;
    }
  }
}

// ---------- STATS ----------
void appStats(float sx, float cy, float sw, float ch) {
  cabeceraApp("Stats", coloresApps[1], sx, cy, sw);
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  fill(neonCian);
  textSize(13);
  text(perfilJugador(), sx + 16, cy + 46);
  String[] nom = {"Viralidad", "Confiabilidad", "Impacto"};
  float[] val = {viralidad, confiabilidad, impacto};
  color[] col = {neonRosa, neonCian, neonAmarillo};
  for (int i = 0; i < 3; i++) {
    float by = cy + 76 + i * 48;
    fill(230);
    textSize(12);
    textAlign(LEFT, TOP);
    text(nom[i], sx + 16, by);
    textAlign(RIGHT, TOP);
    text(int(val[i]) + " / 100", sx + sw - 16, by);
    fill(40, 36, 60);
    rect(sx + 16, by + 18, sw - 32, 14, 7);
    fill(col[i]);
    rect(sx + 16, by + 18, (sw - 32) * val[i] / 100.0, 14, 7);
  }
  textAlign(LEFT, TOP);
  textSize(11);
  fill(200);
  float by = cy + 230;
  text("Decisiones tomadas: " + decisionesTomadas, sx + 16, by);
  text("Personas con las que hablaste: " + personasConocidas(), sx + 16, by + 18);
  text("Logros: " + contarLogros() + " / " + logros.length, sx + 16, by + 36);
  for (int i = 0; i < records.length; i++) text(nombresJuegos[i] + ": " + records[i], sx + 16 + (i / 5) * 118, by + 58 + (i % 5) * 14);
}

// ---------- JUEGOS ----------
void appJuegos(float sx, float cy, float sw, float ch) {
  cabeceraApp("Juegos", coloresApps[2], sx, cy, sw);
  for (int i = 0; i < nombresJuegos.length; i++) {
    float by = cy + 38 + i * 32;
    boolean s = encima(sx + 10, by, sw - 20, 29);
    fill(s ? color(50, 40, 80) : color(26, 22, 44), 240);
    rect(sx + 10, by, sw - 20, 29, 9);
    fill(coloresJuegos[i]);
    rect(sx + 10, by, 6, 29, 9, 0, 0, 9);
    textFont(fuenteUI);
    textAlign(LEFT, TOP);
    textSize(12);
    fill(255);
    text(nombresJuegos[i], sx + 24, by + 2);
    textSize(9);
    fill(180);
    text("Record: " + records[i], sx + 24, by + 16);
    fill(coloresJuegos[i]);
    textSize(11);
    textAlign(RIGHT, CENTER);
    text("Jugar >", sx + sw - 20, by + 14);
  }
}

// ---------- LOGROS ----------
void appLogros(float sx, float cy, float sw, float ch) {
  cabeceraApp("Logros  " + contarLogros() + "/" + logros.length, coloresApps[3], sx, cy, sw);
  textFont(fuenteUI);
  logrosScroll = constrain(logrosScroll, 0, max(0, logros.length * 27 - (ch - 44)));
  for (int i = 0; i < logros.length; i++) {
    float by = cy + 42 + i * 27 - logrosScroll;
    if (by < cy + 30) continue;
    fill(logros[i] ? neonAmarillo : color(60, 56, 80));
    ellipse(sx + 22, by + 11, 14, 14);
    if (logros[i]) {
      stroke(20);
      strokeWeight(2);
      line(sx + 17, by + 11, sx + 21, by + 15);
      line(sx + 21, by + 15, sx + 27, by + 7);
      noStroke();
    }
    textAlign(LEFT, TOP);
    textSize(11);
    fill(logros[i] ? 255 : 150);
    text(logroNombre[i], sx + 36, by);
    textSize(9);
    fill(logros[i] ? 200 : 110);
    text(logroDesc[i], sx + 36, by + 13);
  }
}

// ---------- NOVA IA ----------
void appNova(float sx, float cy, float sw, float ch) {
  cabeceraApp("NOVA IA", coloresApps[4], sx, cy, sw);
  // orbe pequeño
  float pul = sin(frameCount * 0.08) * 4;
  noStroke();
  fill(neonMorado, 60);
  ellipse(sx + sw / 2, cy + 70, 60 + pul, 60 + pul);
  fill(neonCian);
  ellipse(sx + sw / 2, cy + 70, 26, 26);
  if (novaEscribiendo > 0) {
    novaEscribiendo--;
    if (novaEscribiendo <= 0) {
      chatNova.add("NOVA: " + consejosNova[int(random(consejosNova.length))]);
      while (chatNova.size() > 4) chatNova.remove(0);
    }
  }
  textFont(fuenteUI);
  textSize(11);
  float yy = cy + 112;
  for (String m : chatNova) {
    boolean mio = m.startsWith("Tu:");
    String t = mio ? m.substring(4) : m.substring(6);
    float bw = sw - 60;
    int lineas = int(textWidth(t) / (bw - 20)) + 1;
    float bh = 14 + lineas * 14;
    float bx = mio ? sx + 50 : sx + 10;
    fill(mio ? color(120, 40, 100) : color(40, 40, 90), 230);
    rect(bx, yy, bw, bh, 10);
    fill(255);
    textAlign(LEFT, TOP);
    text(t, bx + 10, yy + 6, bw - 20, bh);
    yy += bh + 8;
  }
  if (novaEscribiendo > 0) {
    fill(40, 40, 90, 230);
    rect(sx + 10, yy, 60, 26, 10);
    for (int i = 0; i < 3; i++) {
      fill(255, 120 + 135 * max(0, sin(frameCount * 0.2 - i)));
      ellipse(sx + 26 + i * 14, yy + 13, 7, 7);
    }
  }
  botonMini("Pedir consejo", sx + 30, cy + ch - 40, sw - 60, 32, neonMorado);
}

// ---------- CLICS ----------
void clickTelefono() {
  float px = width / 2 - 140, py = 20, pw = 280, ph = 460;
  if (!encima(px, py, pw, ph)) {
    cerrarTelefono();
    return;
  }
  if (encima(px + pw / 2 - 50, py + ph - 42, 100, 30)) {
    if (telApp == 0) cerrarTelefono();
    else telApp = 0;
    return;
  }
  float sx = px + 12, sy = py + 14, sw = pw - 24, sh = ph - 28;
  float cy = sy + 30, ch = sh - 30 - 34;
  if (telApp != 0 && encima(sx + 4, cy, 44, 34)) {
    telApp = 0;
    return;
  }
  if (telApp == 0) {
    for (int i = 0; i < nombresApps.length; i++) {
      float[] p = posApp(i, sx, cy);
      if (encima(p[0] - 30, p[1] - 30, 60, 60)) abrirApp(i);
    }
  } else if (telApp == 1) {
    if (mouseY < cy + 36) return;
    float yy = cy + 40 - feedScroll;
    float bw = sw - 16, bw2 = (bw - 30) / 2, bx = sx + 8;
    for (int k = feedVisibles - 1; k >= 0; k--) {
      if (estadoFeed[k] == 0) {
        if (encima(bx + 10, yy + 114, bw2, 26)) resolverPost(k, true);
        else if (encima(bx + 20 + bw2, yy + 114, bw2, 26)) resolverPost(k, false);
      }
      yy += 158;
    }
  } else if (telApp == 3) {
    for (int i = 0; i < nombresJuegos.length; i++) {
      if (encima(sx + 10, cy + 38 + i * 32, sw - 20, 29)) {
        cerrarTelefono();
        telAnim = 0;
        lanzarJuego(escenasJuegos[i], false);
        return;
      }
    }
  } else if (telApp == 5) {
    if (encima(sx + 30, cy + ch - 40, sw - 60, 32) && novaEscribiendo <= 0) {
      chatNova.add("Tu: Algun consejo?");
      while (chatNova.size() > 4) chatNova.remove(0);
      novaEscribiendo = 50;
    }
  }
}

void abrirApp(int i) {
  if (i == 5) {
    cerrarTelefono();
    CerrarDialogo();
    cerrarCharla();
    scene = 1;
    return;
  }
  telApp = i + 1;
  if (i == 0) {
    notifPendientes = 0;
    feedScroll = 0;
  }
}
