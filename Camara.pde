// =====================================================================================
//  CAMARA.pde -> minijuego 65 "Manotazo a los Bulos" (se juega moviendo la mano frente a la camara)
//  Necesita la "Video Library for Processing 4" (Sketch > Importar biblioteca > Gestionar bibliotecas).
//  Como funciona: cada cuadro de la camara se achica a 160x100, se pasa a gris y se compara con el
//  anterior. Donde cambio mucho, hay movimiento (tu mano). Si hay movimiento encima de un bulo, le
//  das un manotazo. Si no hay camara o Windows no deja usarla, se juega con el mouse.
// =====================================================================================

import processing.video.*;

Capture cam = null;
boolean camLista = false;
boolean modoMouse = false;
boolean forzarMouseCam = false;     // true = nunca intenta usar la camara (para pruebas)
int pedirCamara = 0;                // cuenta regresiva para encender la camara (asi alcanza a salir el aviso)
String msjCamara = "";

final int CW = 160, CH = 100;       // tamaño de la "vista" de la camara (cada celda = 5x5 pixeles de pantalla)
final int UMBRAL_MOV = 28;          // cuanto debe cambiar el gris de una celda para contar como movimiento
final int CELDAS_GOLPE = 10;        // cuantas celdas con movimiento encima de un bulo = manotazo
int[] grisPrev = new int[CW * CH];
boolean[] mov = new boolean[CW * CH];
PImage vistaCam;
PImage vistaGrande;
float manoX = 400, manoY = 300, manoPX = 400, manoPY = 300, energiaMano = 0;

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

// lee la camara (o el mouse) y llena el mapa de movimiento "mov"
void leerMovimiento() {
  if (modoMouse || !camLista || cam == null) {
    for (int i = 0; i < mov.length; i++) mov[i] = false;
    energiaMano = 0;
    if (dist(mouseX, mouseY, manoX, manoY) > 4) {   // se movio desde el cuadro anterior
      int mx = mouseX / 5, my = mouseY / 5;
      for (int yy = max(0, my - 4); yy < min(CH, my + 5); yy++) {
        for (int xx = max(0, mx - 4); xx < min(CW, mx + 5); xx++) mov[yy * CW + xx] = true;
      }
      energiaMano = 60;
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
  if (vistaCam == null) vistaCam = createImage(CW, CH, RGB);
  vistaCam.loadPixels();
  // recortar la imagen de la camara a la forma de la pantalla (16:10)
  float aspecto = CW / (float) CH;
  float srcW = cam.width, srcH = cam.width / aspecto;
  if (srcH > cam.height) {
    srcH = cam.height;
    srcW = srcH * aspecto;
  }
  float ox = (cam.width - srcW) / 2, oy = (cam.height - srcH) / 2;
  int movidos = 0;
  float sx = 0, sy = 0;
  for (int yy = 0; yy < CH; yy++) {
    int camY = constrain(int(oy + yy * srcH / CH), 0, cam.height - 1);
    for (int xx = 0; xx < CW; xx++) {
      int camX = constrain(int(ox + (CW - 1 - xx) * srcW / CW), 0, cam.width - 1);   // espejo
      int c = cam.pixels[camY * cam.width + camX];
      int gr = (((c >> 16) & 255) * 3 + ((c >> 8) & 255) * 6 + (c & 255)) / 10;
      int i = yy * CW + xx;
      boolean m = grisPrev[i] >= 0 && abs(gr - grisPrev[i]) > UMBRAL_MOV;
      mov[i] = m;
      grisPrev[i] = gr;
      if (m) {
        movidos++;
        sx += xx;
        sy += yy;
      }
      int v = gr / 2;
      vistaCam.pixels[i] = m ? 0xFF00F0FF : (0xFF000000 | (min(255, v * 6 / 10 + 20) << 16) | (min(255, v * 4 / 10 + 10) << 8) | min(255, v * 9 / 10 + 40));
    }
  }
  vistaCam.updatePixels();
  // si cambio casi toda la imagen, fue la luz (o la camara ajustandose), no tu mano
  if (movidos > CW * CH * 0.45) {
    for (int i = 0; i < mov.length; i++) mov[i] = false;
    movidos = 0;
  }
  energiaMano = movidos;
  manoPX = manoX;
  manoPY = manoY;
  if (movidos > 25) {
    manoX = lerp(manoX, sx / movidos * 5, 0.5);
    manoY = lerp(manoY, sy / movidos * 5, 0.5);
  }
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

// ------------------------------------- 65 MANOTAZO A LOS BULOS -------------------------------------
void resetManotazo() {
  golpeables.clear();
  vidasMa = 3;
  bulosGolpeados = 0;
  tiempoMa = 45;
  spawnMa = 30;
}

void dibujarManotazo() {
  if (pedirCamara > 0) {
    background(8, 5, 20);
    tituloNeon("Encendiendo la camara...", width / 2, height / 2, 26, coloresJuegos[8]);
    textFont(fuenteUI);
    textSize(13);
    fill(200);
    textAlign(CENTER, CENTER);
    text("La primera vez puede tardar unos segundos", width / 2, height / 2 + 40);
    pedirCamara--;
    if (pedirCamara == 0) encenderCamara();
    return;
  }
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
    pantallaInstrucciones(8);
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
