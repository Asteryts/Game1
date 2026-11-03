// =====================================================================================
//  PIXEL.pde -> hace que lo dibujado con codigo se vea pixel art, como las imagenes del juego
//  Truco: mientras se dibuja un fondo o un personaje, "g" (el lienzo de Processing) se cambia por
//  un lienzo chiquito a la mitad de resolucion y sin suavizado. Despues ese lienzo se agranda
//  x2 copiando cada pixel en un cuadrado de 2x2, asi los bordes quedan duros y cuadrados.
// =====================================================================================

final int PIXEL = 2;           // tamaño de cada "pixel" del arte (2 = la mitad de resolucion)

PGraphics lienzoFondo;          // 400x250 para los fondos
PImage grandeFondo;             // 800x500 ya agrandado
PGraphics lienzoSprite;         // 32x60 para un personaje
PImage grandeSprite;            // 64x120
PGraphics gGuardado;
int nivelPixel = 0;             // > 0 mientras se esta dibujando dentro de un lienzo chiquito
ArrayList<Object[]> etiquetasPendientes = new ArrayList<Object[]>();

// las imagenes de /data miden 2624x1632 y se dibujaban achicadas a 800x500 en CADA cuadro (eso bajaba
// los fps a ~35). Aqui se achican una sola vez al empezar; en pantalla se ven igual.
void optimizarImagenes() {
  PImage[] grandes = {foto, foto1, mapaImg, menuImg, calle1, calle2, calle3, calle4, alcaldia, pB1, fB1, fB2};
  for (PImage im : grandes) {
    if (im != null && im.width > width * 1.2) im.resize(width, height);
  }
  if (cafe1 != null && cafe1.width > 840) cafe1.resize(700, 400);   // el cafe se dibuja en 700x400
}

void prepararPixel() {
  optimizarImagenes();
  lienzoFondo = createGraphics(width / PIXEL, height / PIXEL);
  lienzoFondo.noSmooth();
  grandeFondo = createImage(width, height, RGB);
  lienzoSprite = createGraphics(64 / PIXEL, 120 / PIXEL);
  lienzoSprite.noSmooth();
  grandeSprite = createImage(64, 120, ARGB);
}

// ------------------------------------- FONDOS -------------------------------------
void empezarFondoPixel() {
  gGuardado = g;
  g = lienzoFondo;   // desde aqui, rect(), ellipse(), text()... dibujan en el lienzo chiquito
  lienzoFondo.beginDraw();
  lienzoFondo.background(0);
  lienzoFondo.scale(1.0 / PIXEL);   // asi se sigue dibujando con coordenadas de 800x500
  nivelPixel++;
}

void terminarFondoPixel() {
  lienzoFondo.endDraw();
  g = gGuardado;
  nivelPixel--;
  agrandar(lienzoFondo, grandeFondo, true);
  imageMode(CORNER);
  image(grandeFondo, 0, 0);
  // los letreros se dibujan nitidos encima del dibujo pixelado, para que se puedan leer
  pushStyle();
  for (TextoNitido t : textosPendientes) {
    textFont(t.fuente);
    textSize(t.tam);
    textAlign(t.alX, t.alY);
    fill(t.c);
    if (t.w > 0) super.text(t.t, t.x, t.y, t.w, t.h);
    else super.text(t.t, t.x, t.y);
  }
  popStyle();
  textosPendientes.clear();
  for (Object[] e : etiquetasPendientes) etiquetaNPC((Float) e[0], (Float) e[1], (String) e[2]);
  etiquetasPendientes.clear();
}

// ------------------------------------- LETREROS NITIDOS -------------------------------------
class TextoNitido {
  String t;
  float x, y, w, h, tam;
  int alX, alY;
  color c;
  PFont fuente;
}

ArrayList<TextoNitido> textosPendientes = new ArrayList<TextoNitido>();

// text() de Processing, pero si se esta dibujando un fondo pixelado guarda el texto para despues
public void text(String str, float tx, float ty) {
  if (nivelPixel > 0 && g == lienzoFondo) guardarTexto(str, tx, ty, 0, 0);
  else super.text(str, tx, ty);
}

public void text(String str, float tx, float ty, float tw, float th) {
  if (nivelPixel > 0 && g == lienzoFondo) guardarTexto(str, tx, ty, tw, th);
  else super.text(str, tx, ty, tw, th);
}

void guardarTexto(String str, float tx, float ty, float tw, float th) {
  TextoNitido t = new TextoNitido();
  t.t = str;
  t.x = lienzoFondo.screenX(tx, ty) * PIXEL;   // la posicion real en pantalla (con translate/rotate incluidos)
  t.y = lienzoFondo.screenY(tx, ty) * PIXEL;
  t.w = tw;
  t.h = th;
  t.tam = lienzoFondo.textSize;
  t.alX = lienzoFondo.textAlign;
  t.alY = lienzoFondo.textAlignY;
  t.c = lienzoFondo.fillColor;
  t.fuente = lienzoFondo.textFont != null ? lienzoFondo.textFont : fuenteUI;
  textosPendientes.add(t);
}

// copia cada pixel del lienzo chiquito en un cuadrado de PIXELxPIXEL
// "tono" le da el toque morado/neon de las imagenes del juego
void agrandar(PGraphics chico, PImage grande, boolean tono) {
  chico.loadPixels();
  grande.loadPixels();
  int cw = chico.width, ch = chico.height, gw = grande.width;
  for (int yy = 0; yy < ch; yy++) {
    for (int xx = 0; xx < cw; xx++) {
      int c = chico.pixels[yy * cw + xx];
      if (tono) {
        int r = (c >> 16) & 255, v = (c >> 8) & 255, b = c & 255;
        r = min(255, int(r * 0.9 + 12));
        v = int(v * 0.84 + 4);
        b = min(255, int(b * 0.95 + 26));
        // pocos colores, como en el pixel art
        r = (r >> 3) << 3;
        v = (v >> 3) << 3;
        b = (b >> 3) << 3;
        c = 0xFF000000 | (r << 16) | (v << 8) | b;
      }
      int base = yy * PIXEL * gw + xx * PIXEL;
      for (int py = 0; py < PIXEL; py++) {
        for (int px = 0; px < PIXEL; px++) grande.pixels[base + py * gw + px] = c;
      }
    }
  }
  grande.updatePixels();
}

// para pantallas que ya estan dibujadas (el fondo del menu): pixela lo que hay en pantalla
void pixelarPantalla() {
  loadPixels();
  for (int yy = 0; yy < height - 1; yy += PIXEL) {
    for (int xx = 0; xx < width - 1; xx += PIXEL) {
      int c = pixels[yy * width + xx];
      pixels[yy * width + xx + 1] = c;
      pixels[(yy + 1) * width + xx] = c;
      pixels[(yy + 1) * width + xx + 1] = c;
    }
  }
  updatePixels();
}

// ------------------------------------- PERSONAJES -------------------------------------
// cada personaje se dibuja en un sprite chiquito (64x120 de pantalla) y se agranda
void dibujarNPC(float cx, float pies, color ropa, color pelo, float fase, boolean marca, String nombre) {
  if (nivelPixel > 0) {   // ya estamos dentro de un fondo pixelado: se dibuja directo
    dibujarNPCCuerpo(cx, pies, ropa, pelo, fase, marca);
    if (nombre != null && !nombre.equals("")) etiquetasPendientes.add(new Object[] {cx, pies, nombre});
    return;
  }
  empezarSprite(cx, pies);
  dibujarNPCCuerpo(cx, pies, ropa, pelo, fase, marca);
  terminarSprite(cx, pies);
  etiquetaNPC(cx, pies, nombre);
}

void dibujarRobot(float cx, float pies, float fase, String nombre) {
  if (nivelPixel > 0) {
    dibujarRobotCuerpo(cx, pies, fase);
    return;
  }
  empezarSprite(cx, pies);
  dibujarRobotCuerpo(cx, pies, fase);
  terminarSprite(cx, pies);
  etiquetaNPC(cx, pies, nombre);
}

void empezarSprite(float cx, float pies) {
  gGuardado = g;
  g = lienzoSprite;
  lienzoSprite.beginDraw();
  lienzoSprite.clear();
  lienzoSprite.scale(1.0 / PIXEL);
  lienzoSprite.translate(-(cx - 32), -(pies - 112));
  nivelPixel++;
}

void terminarSprite(float cx, float pies) {
  lienzoSprite.endDraw();
  g = gGuardado;
  nivelPixel--;
  lienzoSprite.loadPixels();
  grandeSprite.loadPixels();
  int cw = lienzoSprite.width, ch = lienzoSprite.height, gw = grandeSprite.width;
  for (int yy = 0; yy < ch; yy++) {
    for (int xx = 0; xx < cw; xx++) {
      int c = lienzoSprite.pixels[yy * cw + xx];
      int base = yy * PIXEL * gw + xx * PIXEL;
      for (int py = 0; py < PIXEL; py++) {
        for (int px = 0; px < PIXEL; px++) grandeSprite.pixels[base + py * gw + px] = c;
      }
    }
  }
  grandeSprite.updatePixels();
  imageMode(CORNER);
  image(grandeSprite, cx - 32, pies - 112);
}

void etiquetaNPC(float cx, float pies, String nombre) {
  if (nombre == null || nombre.equals("")) return;
  pushStyle();
  noStroke();
  textFont(fuenteUI);
  textSize(11);
  float w = textWidth(nombre) + 12;
  fill(0, 160);
  rect(cx - w / 2, pies + 5, w, 16, 3);
  fill(255);
  textAlign(CENTER, CENTER);
  text(nombre, cx, pies + 12);
  popStyle();
}
