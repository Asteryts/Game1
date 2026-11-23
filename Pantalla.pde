// =====================================================================================
//  PANTALLA.pde -> pantalla completa
//  Todo el juego esta hecho para 800x500. En pantalla completa:
//   1. Antes de cada cuadro, el lienzo de Processing (g) se cambia por "lienzoJuego", de 800x500,
//      y width/height siguen valiendo 800 y 500. Asi todo el codigo dibuja igual que siempre.
//   2. Despues de cada cuadro, ese lienzo se agranda al tamaño de la pantalla, centrado, con
//      bordes negros si la pantalla tiene otra forma.
//   3. El mouse se traduce de la pantalla grande a las coordenadas del juego.
//  Para jugar en ventana normal: PANTALLA_COMPLETA = false.
// =====================================================================================

import java.awt.Graphics2D;
import java.awt.RenderingHints;

final boolean PANTALLA_COMPLETA = true;
final int ANCHO_JUEGO = 800, ALTO_JUEGO = 500;

PGraphics lienzoJuego;
PGraphics gPantalla;              // el lienzo de verdad (del tamaño de la pantalla)
float escalaPantalla = 1, offPantallaX = 0, offPantallaY = 0;
boolean escalaEntera = true;      // true = pixeles nitidos (x2, x3...), false = estirado suave

void settings() {
  if (PANTALLA_COMPLETA) fullScreen();
  else size(ANCHO_JUEGO, ALTO_JUEGO);
  pixelDensity(1);   // Processing 4.5.7+ usa densidad 2 por defecto en pantallas HiDPI: descuadra el escalado, el mouse y el modo pixel
}

// se llama al principio de setup()
void prepararPantalla() {
  if (!PANTALLA_COMPLETA) return;
  gPantalla = g;
  // el tamaño mas grande que cabe: si cabe x2, x3... se usa entero (nitido); si no, se estira suave
  float cabe = min(gPantalla.width / (float) ANCHO_JUEGO, gPantalla.height / (float) ALTO_JUEGO);
  escalaEntera = cabe >= 2;
  escalaPantalla = escalaEntera ? floor(cabe) : cabe;
  offPantallaX = (gPantalla.width - ANCHO_JUEGO * escalaPantalla) / 2;
  offPantallaY = (gPantalla.height - ALTO_JUEGO * escalaPantalla) / 2;
  lienzoJuego = createGraphics(ANCHO_JUEGO, ALTO_JUEGO);
  lienzoJuego.smooth(2);
  width = ANCHO_JUEGO;
  height = ALTO_JUEGO;
  // el resto de setup() (fuente, estilos...) tambien se aplica al lienzo del juego
  g = lienzoJuego;
  lienzoJuego.beginDraw();
  registerMethod("pre", new Escalador());
  registerMethod("draw", escalador);
}

// se llama al final de setup(): se devuelve el lienzo de verdad
void terminarPreparacionPantalla() {
  if (!PANTALLA_COMPLETA) return;
  lienzoJuego.endDraw();
  g = gPantalla;
}

Escalador escalador;

public class Escalador {
  Escalador() {
    escalador = this;
  }

  // antes de draw(): todo se dibuja en el lienzo de 800x500
  public void pre() {
    width = ANCHO_JUEGO;
    height = ALTO_JUEGO;
    g = lienzoJuego;
    lienzoJuego.beginDraw();
  }

  // despues de draw(): el lienzo se agranda a la pantalla
  public void draw() {
    lienzoJuego.endDraw();
    g = gPantalla;
    gPantalla.resetMatrix();
    gPantalla.background(0);
    Graphics2D g2 = (Graphics2D) gPantalla.getNative();
    g2.setRenderingHint(RenderingHints.KEY_INTERPOLATION, escalaEntera ? RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR : RenderingHints.VALUE_INTERPOLATION_BILINEAR);
    gPantalla.imageMode(CORNER);
    gPantalla.image(lienzoJuego, offPantallaX, offPantallaY, ANCHO_JUEGO * escalaPantalla, ALTO_JUEGO * escalaPantalla);
  }
}

// el mouse llega en coordenadas de la pantalla: se pasa a las del juego (800x500)
protected void handleMouseEvent(MouseEvent ev) {
  if (!PANTALLA_COMPLETA || lienzoJuego == null) {
    super.handleMouseEvent(ev);
    return;
  }
  int jx = constrain(round((ev.getX() - offPantallaX) / escalaPantalla), 0, ANCHO_JUEGO - 1);
  int jy = constrain(round((ev.getY() - offPantallaY) / escalaPantalla), 0, ALTO_JUEGO - 1);
  super.handleMouseEvent(new MouseEvent(ev.getNative(), ev.getMillis(), ev.getAction(), ev.getModifiers(), jx, jy, ev.getButton(), ev.getCount()));
}
