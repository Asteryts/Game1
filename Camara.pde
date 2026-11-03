// =====================================================================================
//  CAMARA.pde -> la camara web y el minijuego 65 "Manotazo a los Bulos"
//  (el minijuego 66 "Salto con la Mano" esta en Salto.pde y usa esta misma deteccion)
//  Necesita la "Video Library for Processing 4" (Sketch > Importar biblioteca > Gestionar bibliotecas).
//
//  Como encuentra SOLO LA MANO (y no todo el cuerpo):
//   1. Cada cuadro de la camara se achica a 160x100 celdas (cada celda = 5x5 pixeles de pantalla).
//   2. Movimiento: se compara el gris de cada celda con el cuadro anterior.
//   3. Piel: se mira el color en "YCbCr" (Cb y Cr casi no cambian con la luz). La ropa y el fondo
//      casi nunca tienen color de piel, asi que moverlos no cuenta.
//   4. Movimiento + piel = candidatas. Se juntan en manchas (celdas vecinas).
//   5. La cara es la mancha de piel mas grande (aunque no se mueva): esa se ignora.
//   6. De las manchas que quedan, la mano es la que sigue a la del cuadro anterior (o la mas grande).
//  Con la tecla C (en las instrucciones) el juego aprende TU color de piel con TU luz.
//  Si no hay camara o Windows no deja usarla, se juega con el mouse.
// =====================================================================================

import processing.video.*;

Capture cam = null;
boolean camLista = false;
boolean modoMouse = false;
boolean forzarMouseCam = false;     // true = nunca intenta usar la camara (para pruebas)
int pedirCamara = 0;                // cuenta regresiva para encender la camara (asi alcanza a salir el aviso)
String msjCamara = "";

final int CW = 160, CH = 100;       // tamaño de la "vista" de la camara
final int UMBRAL_MOV = 22;          // cuanto debe cambiar el gris de una celda para contar como movimiento
final int CELDAS_GOLPE = 6;         // cuantas celdas de la mano encima de un bulo = manotazo
final int MANCHA_MIN = 6;           // una mano tiene al menos estas celdas (menos = ruido)
final int CARA_MIN = 120;           // una mancha de piel asi de grande es la cara (o el cuello)
int[] grisPrev = new int[CW * CH];
boolean[] mov = new boolean[CW * CH];        // donde esta la mano (agrandada un poco para golpear)
boolean[] piel = new boolean[CW * CH];
boolean[] movPiel = new boolean[CW * CH];
boolean[] esMano = new boolean[CW * CH];
int[] etiqueta = new int[CW * CH];
int[] pila = new int[CW * CH];
PImage vistaCam;
PImage vistaGrande;
float manoX = 400, manoY = 300, manoPX = 400, manoPY = 300, energiaMano = 0;
boolean manoDetectada = false;
int framesSinMano = 99;
float caraX0 = -1, caraY0 = -1, caraX1 = -1, caraY1 = -1;   // caja de la cara (en celdas)
float caraTam = 0;                                          // tamaño normal de la cara (promedio)
int framesSinCara = 0;

// rango de piel en Cb/Cr (se ajusta con la calibracion)
float cbMin = 77, cbMax = 132, crMin = 133, crMax = 178;
boolean pielCalibrada = false;
int[] ultimoColor = new int[CW * CH];   // colores del ultimo cuadro (para calibrar)

class Golpeable {
  float gx, gy, vx, vy, w, ang;
  int tipo;          // 0 verificado, 1 bulo
  String t;
  boolean golpeado = false;
}

ArrayList<Golpeable> golpeables = new ArrayList<Golpeable>();
int vidasMa = 3, bulosGolpeados = 0;
float tiempoMa = 45, spawnMa = 30;

// ------------------------------------- CAMARA -------------------------------------
boolean esJuegoCamara(int s) {
  return s == ESC_MANOTAZO || s == ESC_SALTO;
}

void encenderCamara() {
  if (forzarMouseCam) {
    modoMouse = true;
    msjCamara = "Modo mouse (camara desactivada)";
    return;
  }
  try {
    if (cam == null) {
      String[] lista = Capture.list();
      if (lista == null || lista.length == 0) {
        modoMouse = true;
        msjCamara = "No se encontro ninguna camara: se juega con el mouse";
        return;
      }
      cam = new Capture(this, lista[0]);
      msjCamara = "Camara: " + lista[0];
    }
    cam.start();
    camLista = true;
    modoMouse = false;
    for (int i = 0; i < grisPrev.length; i++) grisPrev[i] = -1;
  }
  catch (Throwable e) {
    println("No se pudo encender la camara: " + e);
    cam = null;
    camLista = false;
    modoMouse = true;
    msjCamara = "No se pudo usar la camara: se juega con el mouse";
  }
}

void apagarCamara() {
  if (cam != null) {
    try {
      cam.stop();
    }
    catch (Throwable e) {
    }
  }
  camLista = false;
}

// pantalla mientras se enciende la camara. Devuelve true si todavia esta esperando
boolean esperandoCamara(int idx) {
  if (pedirCamara <= 0) return false;
  background(8, 5, 20);
  tituloNeon("Encendiendo la camara...", width / 2, height / 2, 26, coloresJuegos[idx]);
  textFont(fuenteUI);
  textSize(13);
  fill(200);
  textAlign(CENTER, CENTER);
  text("La primera vez puede tardar unos segundos", width / 2, height / 2 + 40);
  pedirCamara--;
  if (pedirCamara == 0) encenderCamara();
  return true;
}

boolean pareceePiel(int c) {
  float r = (c >> 16) & 255, v = (c >> 8) & 255, b = c & 255;
  float cb = 128 - 0.168736 * r - 0.331264 * v + 0.5 * b;
  float cr = 128 + 0.5 * r - 0.418688 * v - 0.081312 * b;
  float lum = 0.299 * r + 0.587 * v + 0.114 * b;
  return lum > 35 && cb >= cbMin && cb <= cbMax && cr >= crMin && cr <= crMax;
}

// la palma va dentro del cuadro de calibracion; se aprende su color promedio
float[] cuadroCalibracion() {
  return new float[] {CW / 2 - 8, CH / 2 - 8, 16, 16};   // en celdas
}

void calibrarPiel() {
  if (modoMouse || vistaCam == null) return;
  float[] q = cuadroCalibracion();
  float sumCb = 0, sumCr = 0;
  int n = 0;
  for (int yy = int(q[1]); yy < q[1] + q[3]; yy++) {
    for (int xx = int(q[0]); xx < q[0] + q[2]; xx++) {
      int c = ultimoColor[yy * CW + xx];
      float r = (c >> 16) & 255, v = (c >> 8) & 255, b = c & 255;
      sumCb += 128 - 0.168736 * r - 0.331264 * v + 0.5 * b;
      sumCr += 128 + 0.5 * r - 0.418688 * v - 0.081312 * b;
      n++;
    }
  }
  if (n == 0) return;
  float mcb = sumCb / n, mcr = sumCr / n;
  cbMin = mcb - 14;
  cbMax = mcb + 14;
  crMin = mcr - 12;
  crMax = mcr + 12;
  pielCalibrada = true;
  chispas(width / 2, height / 2, neonVerde, 40);
  flotar("Piel calibrada!", width / 2, height / 2 - 60, neonVerde);
}

// junta celdas vecinas marcadas en "mapa" en manchas. Devuelve cuantas manchas hay;
// tam[k], cx[k], cy[k], minY[k] quedan con el tamaño, centro y borde de arriba de cada mancha
int manchas(boolean[] mapa, int[] tam, float[] cx, float[] cy, int[] minY, int[] x0, int[] x1, int[] y1, int max) {
  for (int i = 0; i < etiqueta.length; i++) etiqueta[i] = -1;
  int n = 0;
  for (int i = 0; i < mapa.length && n < max; i++) {
    if (!mapa[i] || etiqueta[i] >= 0) continue;
    int arriba = 0;
    pila[arriba++] = i;
    etiqueta[i] = n;
    tam[n] = 0;
    cx[n] = 0;
    cy[n] = 0;
    minY[n] = CH;
    x0[n] = CW;
    x1[n] = 0;
    y1[n] = 0;
    while (arriba > 0) {
      int p = pila[--arriba];
      int px = p % CW, py = p / CW;
      tam[n]++;
      cx[n] += px;
      cy[n] += py;
      minY[n] = min(minY[n], py);
      x0[n] = min(x0[n], px);
      x1[n] = max(x1[n], px);
      y1[n] = max(y1[n], py);
      int[] vecinos = {p - 1, p + 1, p - CW, p + CW};
      for (int q : vecinos) {
        if (q < 0 || q >= mapa.length) continue;
        if ((q == p - 1 && px == 0) || (q == p + 1 && px == CW - 1)) continue;
        if (mapa[q] && etiqueta[q] < 0) {
          etiqueta[q] = n;
          pila[arriba++] = q;
        }
      }
    }
    cx[n] /= tam[n];
    cy[n] /= tam[n];
    n++;
  }
  return n;
}

int[] mTam = new int[300], mMinY = new int[300], mX0 = new int[300], mX1 = new int[300], mY1 = new int[300];
float[] mCx = new float[300], mCy = new float[300];

// lee la camara (o el mouse) y deja en "mov" las celdas donde esta la mano
void leerMovimiento() {
  if (modoMouse || !camLista || cam == null) {
    for (int i = 0; i < mov.length; i++) mov[i] = false;
    energiaMano = 0;
    manoDetectada = false;
    if (dist(mouseX, mouseY, manoX, manoY) > 4) {   // se movio desde el cuadro anterior
      int mx = mouseX / 5, my = mouseY / 5;
      for (int yy = max(0, my - 4); yy < min(CH, my + 5); yy++) {
        for (int xx = max(0, mx - 4); xx < min(CW, mx + 5); xx++) mov[yy * CW + xx] = true;
      }
      energiaMano = 60;
      manoDetectada = true;
    }
    manoPX = manoX;
    manoPY = manoY;
    manoX = mouseX;
    manoY = mouseY;
    return;
  }
  if (!cam.available()) return;
  cam.read();
  cam.loadPixels();
  if (cam.width <= 0 || cam.pixels == null) return;
  procesarCuadro(cam);
}

// busca la mano en un cuadro de la camara (separado para poder probarlo con imagenes de prueba)
void procesarCuadro(PImage cam) {
  if (vistaCam == null) vistaCam = createImage(CW, CH, RGB);
  // recortar la imagen de la camara a la forma de la pantalla (16:10)
  float aspecto = CW / (float) CH;
  float srcW = cam.width, srcH = cam.width / aspecto;
  if (srcH > cam.height) {
    srcH = cam.height;
    srcW = srcH * aspecto;
  }
  float ox = (cam.width - srcW) / 2, oy = (cam.height - srcH) / 2;
  int movidos = 0;
  for (int yy = 0; yy < CH; yy++) {
    int camY = constrain(int(oy + yy * srcH / CH), 0, cam.height - 1);
    for (int xx = 0; xx < CW; xx++) {
      int camX = constrain(int(ox + (CW - 1 - xx) * srcW / CW), 0, cam.width - 1);   // espejo
      int c = cam.pixels[camY * cam.width + camX];
      int i = yy * CW + xx;
      ultimoColor[i] = c;
      int gr = (((c >> 16) & 255) * 3 + ((c >> 8) & 255) * 6 + (c & 255)) / 10;
      boolean m = grisPrev[i] >= 0 && abs(gr - grisPrev[i]) > UMBRAL_MOV;
      grisPrev[i] = gr;
      if (m) movidos++;
      piel[i] = pareceePiel(c);
      movPiel[i] = m && piel[i];
    }
  }
  // si cambio casi toda la imagen, fue la luz (o la camara ajustandose), no tu mano
  boolean cambioDeLuz = movidos > CW * CH * 0.45;
  // la cara: la mancha de piel mas grande (se mueva o no)
  int nPiel = manchas(piel, mTam, mCx, mCy, mMinY, mX0, mX1, mY1, 300);
  int cara = -1;
  for (int k = 0; k < nPiel; k++) if (mTam[k] >= CARA_MIN && (cara < 0 || mTam[k] > mTam[cara])) cara = k;
  if (cara >= 0) {
    // si la mancha crecio de golpe es porque la mano se pego a la cara: no se cambia la caja
    boolean tamNormal = caraTam == 0 || mTam[cara] < caraTam * 1.3;
    if (tamNormal) {
      caraTam = caraTam == 0 ? mTam[cara] : lerp(caraTam, mTam[cara], 0.2);
      caraX0 = mX0[cara] - 1;
      caraX1 = mX1[cara] + 1;
      caraY0 = mMinY[cara] - 1;
      caraY1 = mY1[cara] + 1;
    }
    framesSinCara = 0;
  } else if (++framesSinCara > 30) {
    caraX0 = caraY0 = caraX1 = caraY1 = -1;
    caraTam = 0;
  }
  // las manchas de piel que se mueven; la mano es la que no es la cara
  int nMov = cambioDeLuz ? 0 : manchas(movPiel, mTam, mCx, mCy, mMinY, mX0, mX1, mY1, 300);
  int elegida = -1;
  float mejor = 1e9;
  for (int k = 0; k < nMov; k++) {
    if (mTam[k] < MANCHA_MIN) continue;
    boolean enCara = mCx[k] >= caraX0 && mCx[k] <= caraX1 && mCy[k] >= caraY0 && mCy[k] <= caraY1;
    if (enCara) continue;
    // preferir la que sigue a la mano anterior; si no habia mano, la mas grande
    float costo = framesSinMano < 10 ? dist(mCx[k] * 5, mCy[k] * 5, manoX, manoY) - mTam[k] * 0.5 : -mTam[k];
    if (costo < mejor) {
      mejor = costo;
      elegida = k;
    }
  }
  for (int i = 0; i < mov.length; i++) {
    esMano[i] = elegida >= 0 && movPiel[i] && etiqueta[i] == elegida;
    mov[i] = false;
  }
  energiaMano = 0;
  manoPX = manoX;
  manoPY = manoY;
  if (elegida >= 0) {
    // la mano esta en la punta de la mancha: el tercio de arriba (si sale el brazo, no cuenta)
    float sx = 0, sy = 0;
    int n = 0;
    float limite = mMinY[elegida] + max(3, (mY1[elegida] - mMinY[elegida]) * 0.4);
    for (int i = 0; i < mov.length; i++) {
      if (!esMano[i]) continue;
      int px = i % CW, py = i / CW;
      // agrandar un poquito la mano para que golpear sea mas facil
      for (int dy = -2; dy <= 2; dy++) for (int dx = -2; dx <= 2; dx++) {
        int qx = px + dx, qy = py + dy;
        if (qx >= 0 && qx < CW && qy >= 0 && qy < CH) mov[qy * CW + qx] = true;
      }
      if (py <= limite) {
        sx += px;
        sy += py;
        n++;
      }
    }
    if (n > 0) {
      manoX = lerp(manoX, sx / n * 5, 0.6);
      manoY = lerp(manoY, sy / n * 5, 0.6);
    }
    energiaMano = mTam[elegida] * 4;
    manoDetectada = true;
    framesSinMano = 0;
  } else {
    framesSinMano++;
    manoDetectada = framesSinMano < 6;
  }
  // la vista que se ve en pantalla: la mano en cian, la piel en rosado suave, lo demas morado oscuro
  vistaCam.loadPixels();
  for (int i = 0; i < mov.length; i++) {
    int c = ultimoColor[i];
    int gr = (((c >> 16) & 255) * 3 + ((c >> 8) & 255) * 6 + (c & 255)) / 10;
    int v = gr / 2;
    if (esMano[i]) vistaCam.pixels[i] = 0xFF00F0FF;
    else if (piel[i]) vistaCam.pixels[i] = 0xFF000000 | (min(255, v + 60) << 16) | (min(255, v / 2 + 30) << 8) | min(255, v + 70);
    else vistaCam.pixels[i] = 0xFF000000 | (min(255, v * 6 / 10 + 20) << 16) | (min(255, v * 4 / 10 + 10) << 8) | min(255, v * 9 / 10 + 40);
  }
  vistaCam.updatePixels();
}

int movimientoEn(float x0, float y0, float w, float h) {
  int n = 0;
  int cx0 = max(0, int(x0 / 5)), cy0 = max(0, int(y0 / 5));
  int cx1 = min(CW - 1, int((x0 + w) / 5)), cy1 = min(CH - 1, int((y0 + h) / 5));
  for (int yy = cy0; yy <= cy1; yy++) {
    for (int xx = cx0; xx <= cx1; xx++) if (mov[yy * CW + xx]) n++;
  }
  return n;
}

// la camara de fondo, pixelada (cada celda = cuadrado de 5x5)
void dibujarVistaCamara() {
  if (vistaCam == null) return;
  if (vistaGrande == null) vistaGrande = createImage(width, height, RGB);
  vistaCam.loadPixels();
  vistaGrande.loadPixels();
  for (int yy = 0; yy < height; yy++) {
    int fila = (yy / 5) * CW;
    for (int xx = 0; xx < width; xx++) vistaGrande.pixels[yy * width + xx] = vistaCam.pixels[fila + xx / 5];
  }
  vistaGrande.updatePixels();
  image(vistaGrande, 0, 0);
}

// en las instrucciones: el cuadro donde va la palma para calibrar y como va la deteccion
void ayudaCamara() {
  if (modoMouse) return;
  float[] q = cuadroCalibracion();
  float b = 0.6 + 0.4 * sin(frameCount * 0.1);
  noFill();
  stroke(pielCalibrada ? neonVerde : neonAmarillo, 255 * b);
  strokeWeight(3);
  rect(q[0] * 5, q[1] * 5, q[2] * 5, q[3] * 5, 6);
  noStroke();
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, TOP);
  fill(pielCalibrada ? neonVerde : neonAmarillo);
  text(pielCalibrada ? "Piel calibrada  (C para repetir)" : "Pon la palma aqui y presiona C", q[0] * 5 + q[2] * 2.5, q[1] * 5 + q[3] * 5 + 6);
  fill(manoDetectada ? neonCian : color(160));
  textAlign(RIGHT, CENTER);
  text(manoDetectada ? "Mano detectada" : "Mueve la mano...", width - 14, height - 12);
}

// ------------------------------------- 65 MANOTAZO A LOS BULOS -------------------------------------
void resetManotazo() {
  golpeables.clear();
  vidasMa = 3;
  bulosGolpeados = 0;
  tiempoMa = 45;
  spawnMa = 30;
}

void dibujarManotazo() {
  if (esperandoCamara(8)) return;
  leerMovimiento();
  if (!modoMouse && vistaCam != null) {
    dibujarVistaCamara();
    noStroke();
    fill(8, 5, 20, 90);
    rect(0, 0, width, height);
  } else {
    fondoArcade(coloresJuegos[8]);
  }
  cabeceraJuego(8);
  textFont(fuenteUI);
  textSize(11);
  fill(modoMouse ? neonAmarillo : neonVerde);
  textAlign(LEFT, CENTER);
  text(msjCamara, 14, height - 12);
  if (estadoJuego == 0) {
    instruccionesCamara(8);
    dibujarMano();
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(8);
    return;
  }
  avanzarCuenta();
  textFont(fuenteUI);
  textSize(13);
  if (jugandoAhora()) {
    tiempoMa -= 1 / 60.0;
    float dific = 1 + (45 - tiempoMa) / 25.0;
    spawnMa--;
    if (spawnMa <= 0) {
      Golpeable gp = new Golpeable();
      gp.tipo = random(1) < 0.62 ? 1 : 0;
      gp.t = gp.tipo == 1 ? textosBulos[int(random(textosBulos.length))] : textosBuenos[int(random(textosBuenos.length))];
      gp.w = textWidth(gp.t) + 44;
      gp.gx = random(90, width - 90);
      gp.gy = 80;
      gp.vy = random(1.1, 1.8);
      golpeables.add(gp);
      spawnMa = random(35, 60) / dific;
    }
    int necesarias = modoMouse ? 1 : CELDAS_GOLPE;
    for (int i = golpeables.size() - 1; i >= 0; i--) {
      Golpeable gp = golpeables.get(i);
      if (gp.golpeado) {
        gp.gx += gp.vx;
        gp.gy += gp.vy;
        gp.vy += 0.45;
        gp.ang += gp.vx * 0.02;
        if (gp.gy > height + 60 || gp.gx < -150 || gp.gx > width + 150) golpeables.remove(i);
        continue;
      }
      gp.gy += gp.vy * dific;
      if (movimientoEn(gp.gx - gp.w / 2, gp.gy - 17, gp.w, 34) >= necesarias) {
        gp.golpeado = true;
        float empuje = manoX - manoPX;
        gp.vx = abs(empuje) > 2 ? constrain(empuje * 0.8, -16, 16) : (gp.gx < manoX ? -1 : 1) * random(8, 12);
        gp.vy = -random(5, 8);
        if (gp.tipo == 1) {
          bulosGolpeados++;
          puntaje += 10;
          chispas(gp.gx, gp.gy, neonVerde, 25);
          flotar("+10 MANOTAZO!", gp.gx, gp.gy - 30, neonVerde);
          sacudida = max(sacudida, 4);
        } else {
          puntaje = max(0, puntaje - 5);
          colorDestello = neonRojo;
          destello = 80;
          flotar("Era informacion real!", gp.gx, gp.gy - 30, neonRojo);
        }
        continue;
      }
      if (gp.gy > 445) {
        if (gp.tipo == 1) {
          vidasMa--;
          sacudida = 12;
          colorDestello = neonRojo;
          destello = 100;
          flotar("Se hizo viral!", gp.gx, 420, neonRojo);
        } else {
          puntaje += 5;
          flotar("+5 llego al feed", gp.gx, 420, neonVerde);
        }
        golpeables.remove(i);
      }
    }
    if (tiempoMa <= 0 || vidasMa <= 0) {
      if (puntaje >= 300) desbloquear(17);
      terminarJuego();
      return;
    }
  }
  // burbujas
  for (Golpeable gp : golpeables) {
    color col = gp.tipo == 1 ? neonRojo : neonVerde;
    pushMatrix();
    translate(gp.gx, gp.gy);
    rotate(gp.ang);
    noStroke();
    fill(col, 50);
    rect(-gp.w / 2 - 5, -20, gp.w + 10, 40, 20);
    fill(20, 16, 36, 235);
    stroke(col);
    strokeWeight(2.5);
    rect(-gp.w / 2, -16, gp.w, 32, 16);
    noStroke();
    fill(col);
    ellipse(-gp.w / 2 + 16, 0, 18, 18);
    fill(20);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(gp.tipo == 1 ? "!" : "v", -gp.w / 2 + 16, -1);
    fill(255);
    textSize(13);
    textAlign(LEFT, CENTER);
    text(gp.t, -gp.w / 2 + 30, -1);
    popMatrix();
  }
  // linea de peligro, vidas y tiempo
  noStroke();
  fill(neonRojo, 40 + 20 * sin(frameCount * 0.1));
  rect(0, 452, width, 10);
  for (int i = 0; i < 3; i++) {
    fill(i < vidasMa ? neonRosa : color(60, 50, 80));
    float hx = 30 + i * 28, hy = 80;
    ellipse(hx - 5, hy, 12, 12);
    ellipse(hx + 5, hy, 12, 12);
    triangle(hx - 11, hy + 2, hx + 11, hy + 2, hx, hy + 14);
  }
  fill(40, 36, 60);
  rect(130, 76, 540, 8, 4);
  fill(coloresJuegos[8]);
  rect(130, 76, 540 * max(0, tiempoMa) / 45.0, 8, 4);
  fill(255);
  textAlign(RIGHT, CENTER);
  textSize(12);
  text(int(max(0, tiempoMa)) + " s", 770, 80);
  dibujarMano();
  if (estadoJuego == 1) pantallaCuenta();
}

// la mano que sigue tu movimiento (en pixel art, con brillo si te estas moviendo)
void dibujarMano() {
  float e = constrain(energiaMano / 120.0, 0, 1);
  float s = 1 + e * 0.4;
  pushMatrix();
  translate(manoX, manoY);
  scale(s);
  noStroke();
  fill(coloresJuegos[8], 40 + 80 * e);
  ellipse(0, 0, 70, 70);
  fill(16, 8, 28);
  rect(-16, -12, 32, 30, 6);
  for (int i = 0; i < 4; i++) rect(-16 + i * 8, -32, 8, 24, 3);
  rect(14, -6, 12, 8, 3);
  fill(255, 214, 170);
  rect(-14, -10, 28, 26, 5);
  for (int i = 0; i < 4; i++) rect(-14 + i * 8, -30, 6, 22, 3);
  rect(14, -4, 10, 5, 2);
  popMatrix();
}

// instrucciones de los juegos de camara: se ve la camara detras para poder calibrar la piel
void instruccionesCamara(int idx) {
  if (modoMouse) {
    pantallaInstrucciones(idx);
    return;
  }
  noStroke();
  fill(10, 8, 26, 215);
  rect(60, 66, 680, 120, 14);
  tituloNeon(nombresJuegos[idx], width / 2, 88, 26, coloresJuegos[idx]);
  textFont(fuenteUI);
  textSize(13);
  fill(230);
  textAlign(CENTER, TOP);
  text(instruccionesJuegos[idx], 80, 108, 640, 76);
  ayudaCamara();
  if (frameCount % 50 < 35) {
    fill(10, 8, 26, 215);
    rect(250, 400, 300, 34, 10);
    fill(coloresJuegos[idx]);
    textSize(15);
    textAlign(CENTER, CENTER);
    text("ENTER o clic para empezar", width / 2, 416);
  }
}
