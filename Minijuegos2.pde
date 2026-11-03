// =====================================================================================
//  MINIJUEGOS2.pde -> 4 minijuegos nuevos (usan el mismo marco de Minijuegos.pde)
//   61 Telefono Roto   (memoriza y repite el orden en que pasa el rumor)
//   62 Penales         (apunta, elige la fuerza y vence al portero)
//   63 Foto Trucada    (encuentra lo que cambiaron en la foto editada)
//   64 Teclado Veloz   (escribe las palabras antes de que se vuelvan virales)
// =====================================================================================

// ------------------------------------- 61 TELEFONO ROTO -------------------------------------
int[] secuenciaTR = new int[60];
int largoTR = 0, mostrandoTR = 0, entradaTR = 0, estadoTR = 0;   // estado: 0 mostrando, 1 tu turno, 2 error, 3 ronda superada
float timerTR = 0;
float[] brilloTR = new float[4];
String[] palabrasTR = {"Dani", "maqueta", "parque", "colegio"};
String[] nombresTR = {"Vale", "Mateo", "Camila", "Nico"};
color[] coloresTR = {#FF3CC8, #00F0FF, #FFDC3C, #3CFF96};
float[][] posTR = {{400, 150}, {590, 270}, {400, 390}, {210, 270}};

void resetTelefonoRoto() {
  largoTR = 0;
  for (int i = 0; i < 4; i++) brilloTR[i] = 0;
  agregarPasoTR();
}

void agregarPasoTR() {
  secuenciaTR[largoTR++] = int(random(4));
  mostrandoTR = 0;
  entradaTR = 0;
  timerTR = 45;
  estadoTR = 0;
}

void dibujarTelefonoRoto() {
  fondoArcade(coloresJuegos[4]);
  cabeceraJuego(4);
  if (estadoJuego == 0) {
    pantallaInstrucciones(4);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(4);
    return;
  }
  avanzarCuenta();
  if (jugandoAhora()) {
    timerTR--;
    if (estadoTR == 0 && timerTR <= 0) {
      if (mostrandoTR < largoTR) {
        brilloTR[secuenciaTR[mostrandoTR]] = 1;
        mostrandoTR++;
        timerTR = max(16, 38 - largoTR * 2);
      } else {
        estadoTR = 1;
      }
    } else if (estadoTR == 2 && timerTR <= 0) {
      puntaje = (largoTR - 1) * 100;
      terminarJuego();
      return;
    } else if (estadoTR == 3 && timerTR <= 0) {
      agregarPasoTR();
    }
  }
  // cables entre los amigos
  stroke(coloresJuegos[4], 70);
  strokeWeight(3);
  for (int i = 0; i < 4; i++) line(posTR[i][0], posTR[i][1], posTR[(i + 1) % 4][0], posTR[(i + 1) % 4][1]);
  noStroke();
  for (int i = 0; i < 4; i++) {
    brilloTR[i] = max(0, brilloTR[i] - 0.05);
    float b = brilloTR[i];
    float r = 86 * (1 + 0.18 * b);
    float cx = posTR[i][0], cy = posTR[i][1];
    boolean s = estadoTR == 1 && dist(mouseX, mouseY, cx, cy) < 45;
    for (int k = 3; k >= 1; k--) {
      fill(coloresTR[i], (20 + 60 * b) / k);
      ellipse(cx, cy, r + k * 18 * (0.4 + b), r + k * 18 * (0.4 + b));
    }
    fill(lerpColor(color(30, 24, 50), coloresTR[i], 0.25 + 0.75 * b));
    stroke(coloresTR[i]);
    strokeWeight(s ? 4 : 2);
    ellipse(cx, cy, r, r);
    noStroke();
    // carita
    fill(tonosPiel[i % tonosPiel.length]);
    ellipse(cx, cy - 4, 44, 44);
    fill(30);
    ellipse(cx - 8, cy - 6, 5, 7);
    ellipse(cx + 8, cy - 6, 5, 7);
    if (b > 0.3) ellipse(cx, cy + 8, 12, 10);
    else rect(cx - 6, cy + 7, 12, 2);
    fill(255);
    textFont(fuenteUI);
    textSize(12);
    textAlign(CENTER, CENTER);
    text((i + 1) + ". " + nombresTR[i], cx, cy + 36);
    if (b > 0.25) {
      textSize(15);
      float w = textWidth(palabrasTR[i]) + 22;
      fill(255, 255 * b);
      rect(cx - w / 2, cy - 82, w, 28, 12);
      triangle(cx - 6, cy - 54, cx + 6, cy - 54, cx, cy - 46);
      fill(30, 255 * b);
      text(palabrasTR[i], cx, cy - 69);
    }
  }
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(17);
  String msj = estadoTR == 0 ? "Escucha como pasa el rumor..." : estadoTR == 1 ? "Tu turno! Repitelo igualito (" + entradaTR + "/" + largoTR + ")" : estadoTR == 2 ? "Lo deformaste! Asi nacen los rumores..." : "Perfecto! El mensaje llego intacto";
  fill(estadoTR == 2 ? neonRojo : estadoTR == 3 ? neonVerde : color(255));
  text(msj, width / 2, 270);
  textSize(13);
  fill(200);
  text("Ronda " + largoTR, width / 2, 296);
  if (estadoJuego == 1) pantallaCuenta();
}

void pulsarTR(int i) {
  if (estadoTR != 1 || i < 0 || i > 3) return;
  brilloTR[i] = 1;
  if (secuenciaTR[entradaTR] == i) {
    entradaTR++;
    if (entradaTR == largoTR) {
      puntaje = largoTR * 100;
      estadoTR = 3;
      timerTR = 50;
      chispas(width / 2, 270, neonVerde, 35);
      if (largoTR >= 7) desbloquear(12);
    }
  } else {
    estadoTR = 2;
    timerTR = 80;
    sacudida = 12;
    colorDestello = neonRojo;
    destello = 100;
  }
}

void clickTelefonoRoto() {
  for (int i = 0; i < 4; i++) if (dist(mouseX, mouseY, posTR[i][0], posTR[i][1]) < 48) pulsarTR(i);
}

// ------------------------------------- 62 PENALES -------------------------------------
int tirosP = 0, golesP = 0, faseP = 0;   // fase: 0 apuntando, 1 fuerza, 2 balon volando, 3 resultado
float apuntaP = 0, fuerzaP = 0, tP = 0, objX = 400, objY = 200, porteroX = 400, porteroObj = 400, resultadoP = 0;
boolean golP = false;
String msjP = "";

void resetPenales() {
  tirosP = 0;
  golesP = 0;
  faseP = 0;
  tP = 0;
  porteroX = 400;
}

void dibujarPenales() {
  // cancha vista desde el punto penal
  background(30, 60, 40);
  noStroke();
  degradado(0, 0, width, 110, color(30, 30, 70), color(80, 60, 120));
  for (int i = 0; i < 40; i++) {
    fill(paletaRopa[i % paletaRopa.length]);
    float salto = (golP && faseP == 3) ? abs(sin(frameCount * 0.3 + i)) * 8 : abs(sin(frameCount * 0.05 + i)) * 2;
    ellipse(10 + i * 20, 96 - salto, 14, 14);
  }
  for (int i = 0; i < 8; i++) {
    fill(i % 2 == 0 ? color(56, 130, 66) : color(48, 118, 58));
    rect(0, 110 + i * 50, width, 50);
  }
  // arco con malla
  stroke(255, 255, 255, 70);
  strokeWeight(1);
  for (float xx = 220; xx <= 580; xx += 14) line(xx, 120, xx, 262);
  for (float yy = 120; yy <= 262; yy += 14) line(220, yy, 580, yy);
  stroke(255);
  strokeWeight(6);
  line(220, 262, 220, 118);
  line(220, 118, 580, 118);
  line(580, 118, 580, 262);
  strokeWeight(2);
  line(0, 262, width, 262);
  noStroke();
  cabeceraJuego(5);
  if (estadoJuego == 0) {
    pantallaInstrucciones(5);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(5);
    return;
  }
  avanzarCuenta();
  boolean jugando = jugandoAhora();
  float dific = 1 + tirosP * 0.25;
  if (jugando) {
    if (faseP == 0) apuntaP = sin(frameCount * 0.045 * dific);
    if (faseP == 1) fuerzaP = 0.5 + 0.5 * sin(frameCount * 0.07 * dific);
    if (faseP < 2) porteroX = 400 + sin(frameCount * 0.025 * dific) * 90;
    if (faseP == 2) {
      tP += 0.035;
      porteroX = lerp(porteroX, porteroObj, 0.12);
      if (tP >= 1) {
        tP = 1;
        boolean fuera = objX < 226 || objX > 574 || objY < 124;
        boolean atajada = !fuera && abs(objX - porteroX) < 52 && objY > 150;
        golP = !fuera && !atajada;
        if (golP) {
          golesP++;
          int pts = 100 + (abs(objX - 400) > 120 ? 50 : 0);
          puntaje += pts;
          msjP = abs(objX - 400) > 120 ? "GOLAZO AL ANGULO! +" + pts : "GOOOL! +" + pts;
          explosionConfeti(objX, objY, 50);
        } else {
          msjP = fuera ? "Afuera! Muy desviado..." : "Atajada del portero!";
          sacudida = 8;
        }
        tirosP++;
        faseP = 3;
        resultadoP = 90;
      }
    } else if (faseP == 3) {
      resultadoP--;
      if (resultadoP <= 0) {
        if (tirosP >= 5) {
          if (golesP == 5) desbloquear(13);
          terminarJuego();
          return;
        }
        faseP = 0;
        tP = 0;
      }
    }
  }
  // portero
  pushMatrix();
  translate(porteroX, 258);
  scale(1.5);
  float estira = faseP >= 2 ? constrain((porteroObj - 400) / 200.0, -1, 1) : 0;
  rotate(estira * 0.5 * min(1, tP * 2));
  dibujarNPC(0, 0, #FFDC3C, #141414, 2, false, "");
  popMatrix();
  // balon
  float bx = 400, by = 440, tam = 34;
  if (faseP >= 2) {
    bx = lerp(400, objX, tP);
    by = lerp(440, objY, tP) - sin(tP * PI) * 40;
    tam = lerp(34, 18, tP);
  }
  fill(0, 70);
  ellipse(bx, faseP >= 2 ? lerp(450, 262, tP) : 452, tam, tam * 0.3);
  fill(250);
  ellipse(bx, by, tam, tam);
  fill(30);
  pushMatrix();
  translate(bx, by);
  rotate(tP * 12);
  for (int i = 0; i < 5; i++) {
    float a = i * TWO_PI / 5;
    ellipse(cos(a) * tam * 0.3, sin(a) * tam * 0.3, tam * 0.22, tam * 0.22);
  }
  popMatrix();
  // mira y barra de fuerza
  if (faseP <= 1) {
    float ax = 400 + apuntaP * 210;
    stroke(neonAmarillo, 200);
    strokeWeight(3);
    line(400, 420, ax, 200);
    noFill();
    ellipse(ax, 200, 26, 26);
    noStroke();
    fill(40, 36, 60);
    rect(720, 300, 22, 150, 6);
    if (faseP == 1) {
      fill(lerpColor(neonVerde, neonRojo, fuerzaP));
      rect(720, 300 + 150 * (1 - fuerzaP), 22, 150 * fuerzaP, 6);
    }
    fill(neonRojo, 120);
    rect(716, 300, 30, 16, 4);
    textFont(fuenteUI);
    textSize(11);
    fill(255);
    textAlign(CENTER, CENTER);
    text("FUERZA", 731, 464);
    textSize(16);
    text(faseP == 0 ? "Clic o ESPACIO para fijar la direccion" : "Clic o ESPACIO para fijar la fuerza (lo rojo = por encima)", width / 2, 480);
  }
  if (faseP == 3) tituloNeon(msjP, width / 2, 330, 32, golP ? neonVerde : neonRojo);
  // marcador de tiros
  for (int i = 0; i < 5; i++) {
    fill(i < tirosP ? (i < golesP ? neonVerde : neonRojo) : color(60, 60, 80));
    ellipse(40 + i * 26, 80, 18, 18);
  }
  if (estadoJuego == 1) pantallaCuenta();
}

void accionPenales() {
  if (faseP == 0) {
    faseP = 1;
  } else if (faseP == 1) {
    objX = 400 + apuntaP * 210;
    objY = 262 - fuerzaP * 165;
    float adivina = random(1) < 0.35 + tirosP * 0.08 ? objX : 400 + random(-160, 160);
    porteroObj = constrain(adivina, 250, 550);
    tP = 0;
    faseP = 2;
  }
}

// ------------------------------------- 63 FOTO TRUCADA -------------------------------------
class Pieza {
  int tipo;           // 0 rect, 1 circulo, 2 persona, 3 arbol, 4 auto
  float px, py, pw, ph;
  color c;
  float mx, my, mw, mh;   // version editada
  color mc;
  boolean oculta;          // en la editada desaparece
}

ArrayList<Pieza> piezasF = new ArrayList<Pieza>();
int[] difF = new int[5];
boolean[] halladaF = new boolean[5];
int rondaF = 0, halladasF = 0, erroresF = 0;
float tiempoF = 60, xMarcaF = -100, yMarcaF = -100, marcaErrF = 0;
color[] paletaFoto = {#DC3C3C, #3C78DC, #46B464, #F0C83C, #9650FF, #FF8C3C, #3CC8C8, #E6E6E6};

void resetFotoTrucada() {
  rondaF = 0;
  halladasF = 0;
  erroresF = 0;
  tiempoF = 60;
  generarFoto();
}

Pieza pieza(int tipo, float px, float py, float pw, float ph, color c) {
  Pieza p = new Pieza();
  p.tipo = tipo;
  p.px = p.mx = px;
  p.py = p.my = py;
  p.pw = p.mw = pw;
  p.ph = p.mh = ph;
  p.c = p.mc = c;
  piezasF.add(p);
  return p;
}

void generarFoto() {
  piezasF.clear();
  pieza(1, 60 + random(220), 40, 36, 36, #FFDC3C);                       // sol
  for (int i = 0; i < 3; i++) pieza(1, random(30, 320), random(30, 80), 50, 22, #F0F0FF);   // nubes
  float bx = 10;
  for (int i = 0; i < 5; i++) {
    float w = random(45, 70), h = random(80, 140);
    pieza(0, bx, 210 - h, w, h, paletaFoto[int(random(paletaFoto.length))]);
    for (int k = 0; k < 2; k++) pieza(0, bx + 8 + k * (w / 2 - 4), 210 - h + 14 + random(0, h - 50), 12, 14, #FFE6A0);
    bx += w + 4;
  }
  pieza(3, random(40, 140), 230, 30, 30, #3C9650);
  pieza(3, random(220, 320), 232, 26, 26, #3C9650);
  pieza(2, random(60, 290), 238, 14, 20, paletaFoto[int(random(paletaFoto.length))]);
  pieza(4, random(40, 260), 236, 60, 18, paletaFoto[int(random(paletaFoto.length))]);
  // elegir 5 cosas para editar
  IntList l = new IntList();
  for (int i = 0; i < piezasF.size(); i++) l.append(i);
  l.shuffle();
  for (int k = 0; k < 5; k++) {
    difF[k] = l.get(k);
    halladaF[k] = false;
    Pieza p = piezasF.get(difF[k]);
    int modo = int(random(4));
    if (modo == 0) {
      color nc = p.c;
      while (nc == p.c) nc = paletaFoto[int(random(paletaFoto.length))];
      p.mc = nc;
    } else if (modo == 1) {
      p.oculta = true;
    } else if (modo == 2) {
      p.mx += random(1) < 0.5 ? -16 : 16;
    } else {
      p.mw *= 1.6;
      p.mh *= 1.6;
    }
  }
}

void dibujarPieza(Pieza p, boolean editada, float ox, float oy) {
  if (editada && p.oculta) return;
  float px = ox + (editada ? p.mx : p.px), py = oy + (editada ? p.my : p.py);
  float pw = editada ? p.mw : p.pw, ph = editada ? p.mh : p.ph;
  fill(editada ? p.mc : p.c);
  noStroke();
  if (p.tipo == 0) rect(px, py, pw, ph);
  else if (p.tipo == 1) ellipse(px, py, pw, ph);
  else if (p.tipo == 2) {
    rect(px - pw / 2, py - ph, pw, ph, 4);
    fill(240, 200, 160);
    ellipse(px, py - ph - 6, 12, 12);
  } else if (p.tipo == 3) {
    fill(110, 75, 50);
    rect(px - 3, py - 4, 6, 14);
    fill(editada ? p.mc : p.c);
    ellipse(px, py - pw * 0.5, pw, ph);
  } else if (p.tipo == 4) {
    rect(px, py - ph, pw, ph, 5);
    fill(30);
    ellipse(px + 12, py, 12, 12);
    ellipse(px + pw - 12, py, 12, 12);
  }
}

void dibujarFoto(float ox, float oy, boolean editada) {
  noStroke();
  fill(0, 120);
  rect(ox + 6, oy + 6, 350, 260, 6);
  fill(240);
  rect(ox - 8, oy - 8, 366, 276, 6);
  clip(ox, oy, 350, 260);
  degradado(ox, oy, 350, 210, color(120, 180, 240), color(200, 220, 250));
  fill(80, 80, 90);
  rect(ox, oy + 210, 350, 50);
  fill(230, 200, 80);
  for (int i = 0; i < 6; i++) rect(ox + 10 + i * 60, oy + 238, 30, 3);
  for (Pieza p : piezasF) dibujarPieza(p, editada, ox, oy);
  noClip();
  for (int k = 0; k < 5; k++) {
    if (!halladaF[k]) continue;
    Pieza p = piezasF.get(difF[k]);
    noFill();
    stroke(neonVerde);
    strokeWeight(3);
    float r = max(28, max(p.pw, p.ph) + 12);
    ellipse(ox + p.px + (p.tipo == 0 || p.tipo == 4 ? p.pw / 2 : 0), oy + p.py + (p.tipo == 0 ? p.ph / 2 : p.tipo == 4 ? -p.ph / 2 : p.tipo == 2 ? -p.ph / 2 : 0), r, r);
    noStroke();
  }
}

void dibujarFotoTrucada() {
  fondoArcade(coloresJuegos[6]);
  cabeceraJuego(6);
  if (estadoJuego == 0) {
    pantallaInstrucciones(6);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(6);
    return;
  }
  avanzarCuenta();
  if (jugandoAhora()) {
    tiempoF -= 1 / 60.0;
    if (tiempoF <= 0) {
      tiempoF = 0;
      terminarFoto();
      return;
    }
  }
  dibujarFoto(32, 110, false);
  dibujarFoto(418, 110, true);
  textFont(fuenteUI);
  textSize(13);
  fill(255);
  textAlign(CENTER, CENTER);
  text("ORIGINAL", 207, 92);
  fill(neonRojo);
  text("EDITADA (con trampa)", 593, 92);
  if (marcaErrF > 0) {
    marcaErrF--;
    stroke(neonRojo, marcaErrF * 6);
    strokeWeight(4);
    line(xMarcaF - 10, yMarcaF - 10, xMarcaF + 10, yMarcaF + 10);
    line(xMarcaF + 10, yMarcaF - 10, xMarcaF - 10, yMarcaF + 10);
    noStroke();
  }
  int enRonda = 0;
  for (boolean b : halladaF) if (b) enRonda++;
  fill(255);
  textAlign(LEFT, CENTER);
  text("Foto " + (rondaF + 1) + " / 2      Diferencias: " + enRonda + " / 5", 32, 405);
  fill(40, 36, 60);
  rect(32, 425, 736, 8, 4);
  fill(coloresJuegos[6]);
  rect(32, 425, 736 * tiempoF / 60.0, 8, 4);
  textAlign(RIGHT, CENTER);
  fill(255);
  text(int(tiempoF) + " s", 768, 405);
  if (estadoJuego == 1) pantallaCuenta();
}

void clickFotoTrucada() {
  float ox = -1, oy = 110;
  if (encima(32, 110, 350, 260)) ox = 32;
  else if (encima(418, 110, 350, 260)) ox = 418;
  if (ox < 0) return;
  float lx = mouseX - ox, ly = mouseY - oy;
  for (int k = 0; k < 5; k++) {
    if (halladaF[k]) continue;
    Pieza p = piezasF.get(difF[k]);
    float cx = p.px + (p.tipo == 0 || p.tipo == 4 ? p.pw / 2 : 0);
    float cy = p.py + (p.tipo == 0 ? p.ph / 2 : (p.tipo == 4 || p.tipo == 2) ? -p.ph / 2 : p.tipo == 3 ? -p.pw * 0.5 : 0);
    float mcx = p.mx + (p.tipo == 0 || p.tipo == 4 ? p.mw / 2 : 0);
    float rad = max(22, max(p.mw, p.mh) / 2 + 10);
    if (dist(lx, ly, cx, cy) < rad || dist(lx, ly, mcx, cy) < rad) {
      halladaF[k] = true;
      halladasF++;
      puntaje += 100;
      chispas(mouseX, mouseY, neonVerde, 25);
      flotar("+100", mouseX, mouseY - 20, neonVerde);
      boolean todas = true;
      for (boolean b : halladaF) if (!b) todas = false;
      if (todas) {
        rondaF++;
        if (rondaF >= 2) terminarFoto();
        else generarFoto();
      }
      return;
    }
  }
  erroresF++;
  tiempoF = max(0, tiempoF - 3);
  puntaje = max(0, puntaje - 10);
  xMarcaF = mouseX;
  yMarcaF = mouseY;
  marcaErrF = 40;
  sacudida = 5;
}

void terminarFoto() {
  puntaje += int(tiempoF) * 5;
  if (halladasF >= 10) desbloquear(14);
  terminarJuego();
}

// ------------------------------------- 64 TECLADO VELOZ -------------------------------------
class PalabraT {
  String w;
  float px, py, vy;
  int hechas = 0;
}

ArrayList<PalabraT> palabrasT = new ArrayList<PalabraT>();
PalabraT objetivoT = null;
int vidasT = 3, comboT = 0;
float tiempoT = 60, spawnT = 30;
String[] bancoT = {"BULO", "FUENTE", "DATO", "PRUEBA", "FILTRO", "RUMOR", "NOVA", "VERIFICA", "CONTEXTO", "FECHA", "AUTOR", "CHISME",
  "VIRAL", "FAKE", "CADENA", "MEME", "BOT", "TITULAR", "ENLACE", "VIDEO", "FOTO", "PAGINA", "CUENTA", "ALERTA", "CALMA", "DUDA"};

void resetTeclado() {
  palabrasT.clear();
  objetivoT = null;
  vidasT = 3;
  comboT = 0;
  tiempoT = 60;
  spawnT = 20;
}

void dibujarTeclado() {
  fondoArcade(coloresJuegos[7]);
  cabeceraJuego(7);
  if (estadoJuego == 0) {
    pantallaInstrucciones(7);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(7);
    return;
  }
  avanzarCuenta();
  if (jugandoAhora()) {
    tiempoT -= 1 / 60.0;
    float dific = 1 + (60 - tiempoT) / 30.0;
    spawnT--;
    if (spawnT <= 0) {
      PalabraT p = new PalabraT();
      p.w = bancoT[int(random(bancoT.length))];
      p.px = random(70, 640);
      p.py = 110;
      p.vy = random(0.45, 0.8) * dific;
      palabrasT.add(p);
      spawnT = random(55, 90) / dific;
    }
    for (int i = palabrasT.size() - 1; i >= 0; i--) {
      PalabraT p = palabrasT.get(i);
      p.py += p.vy;
      if (p.py > 420) {
        vidasT--;
        comboT = 0;
        sacudida = 10;
        colorDestello = neonRojo;
        destello = 90;
        flotar("SE HIZO VIRAL!", p.px + 40, 400, neonRojo);
        if (objetivoT == p) objetivoT = null;
        palabrasT.remove(i);
      }
    }
    if (tiempoT <= 0 || vidasT <= 0) {
      if (puntaje >= 600) desbloquear(15);
      terminarJuego();
      return;
    }
  }
  // zona de peligro
  noStroke();
  fill(neonRojo, 30 + 20 * sin(frameCount * 0.1));
  rect(0, 420, width, 20);
  fill(neonRojo);
  textFont(fuenteUI);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("SI UNA PALABRA LLEGA AQUI, SE VUELVE VIRAL", width / 2, 430);
  // palabras
  textFont(fuente);
  textSize(22);
  for (PalabraT p : palabrasT) {
    float w = textWidth(p.w) + 24;
    boolean obj = p == objetivoT;
    fill(14, 10, 32, 230);
    stroke(obj ? neonAmarillo : coloresJuegos[7], obj ? 255 : 140);
    strokeWeight(obj ? 3 : 1.5);
    rect(p.px, p.py - 18, w, 34, 10);
    noStroke();
    textAlign(LEFT, CENTER);
    float tx = p.px + 12;
    for (int k = 0; k < p.w.length(); k++) {
      fill(k < p.hechas ? neonVerde : color(255));
      String c = str(p.w.charAt(k));
      text(c, tx, p.py - 3);
      tx += textWidth(c);
    }
  }
  if (objetivoT != null) {
    stroke(neonAmarillo, 150);
    strokeWeight(2);
    line(width / 2, 470, objetivoT.px + 20, objetivoT.py + 16);
    noStroke();
  }
  // "teclado" de abajo
  fill(30, 26, 50);
  rect(250, 455, 300, 40, 8);
  fill(coloresJuegos[7]);
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  text(objetivoT == null ? "Escribe la primera letra de una palabra" : "Escribiendo: " + objetivoT.w.substring(0, objetivoT.hechas) + "_", width / 2, 475);
  for (int i = 0; i < 3; i++) {
    fill(i < vidasT ? neonRosa : color(60, 50, 80));
    float hx = 30 + i * 28, hy = 80;
    ellipse(hx - 5, hy, 12, 12);
    ellipse(hx + 5, hy, 12, 12);
    triangle(hx - 11, hy + 2, hx + 11, hy + 2, hx, hy + 14);
  }
  fill(255);
  textAlign(RIGHT, CENTER);
  text(int(max(0, tiempoT)) + " s", 770, 80);
  if (comboT > 2) {
    fill(neonAmarillo);
    textAlign(LEFT, CENTER);
    text("COMBO x" + comboT, 120, 80);
  }
  if (estadoJuego == 1) pantallaCuenta();
}

void teclaTeclado() {
  if (estadoJuego != 2 || key == CODED) return;
  char k = Character.toUpperCase(key);
  if (k < 'A' || k > 'Z') return;
  if (objetivoT == null) {
    PalabraT mejor = null;
    for (PalabraT p : palabrasT) if (p.w.charAt(0) == k && (mejor == null || p.py > mejor.py)) mejor = p;
    if (mejor == null) {
      comboT = 0;
      return;
    }
    objetivoT = mejor;
    objetivoT.hechas = 1;
  } else if (objetivoT.w.charAt(objetivoT.hechas) == k) {
    objetivoT.hechas++;
  } else {
    comboT = 0;
    sacudida = 3;
    return;
  }
  if (objetivoT.hechas >= objetivoT.w.length()) {
    comboT++;
    int pts = objetivoT.w.length() * 10 + comboT * 5;
    puntaje += pts;
    chispas(objetivoT.px + 40, objetivoT.py, neonVerde, 25);
    flotar("+" + pts, objetivoT.px + 40, objetivoT.py - 26, neonVerde);
    palabrasT.remove(objetivoT);
    objetivoT = null;
  }
}
