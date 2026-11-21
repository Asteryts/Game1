// =====================================================================================
//  MOVER.pde -> moverse con el mouse, estilo League of Legends
//   - CLIC DERECHO en cualquier parte del piso: el personaje camina hasta ahi.
//     En los lugares nuevos tambien sirve el CLIC IZQUIERDO en el piso.
//   - Clic sobre una persona u objeto: camina hasta ella y le habla solo al llegar.
//   - Busca el camino esquivando obstaculos (en los lugares que tienen obstaculos marcados).
//   - Aparece el marcador verde donde hiciste clic. Las teclas siguen funcionando:
//     si tocas una flecha o WASD, se cancela el camino.
// =====================================================================================

boolean caminandoClic = false;
float destinoX, destinoY;               // posicion del sprite (x, y) a la que va
ArrayList<float[]> rutaClic = new ArrayList<float[]>();
Interactivo objetivoClic = null;        // a quien le va a hablar al llegar
float marcaX, marcaY, marcaT = 0;       // el marcador del clic
color marcaColor = #3CFF96;
float ultimoAvanceX, ultimoAvanceY;
int framesAtascado = 0;
final int CELDA = 20;

// ------------------------------------- ORDENES -------------------------------------
// clic en un punto del piso: (mx, my) es donde deberian quedar los pies
void ordenarCaminar(float mx, float my) {
  objetivoClic = null;
  marcaX = mx;
  marcaY = my;
  marcaT = 26;
  marcaColor = #3CFF96;
  destinoX = mx - 50;
  destinoY = my - 40;
  planearRuta();
  // si hiciste clic en una salida (una puerta o el borde con flecha), sigue derecho hasta cruzarla
  if (esCaminable(scene)) {
    Lugar L = lugares.get(scene);
    if (my > height - 50 && L.salidas[2] >= 0 && L.enRango(2, mx)) rutaClic.add(new float[] {mx - 50, height});
    else if (my < L.yMin + 52 && L.salidas[0] >= 0 && L.enRango(0, mx)) rutaClic.add(new float[] {mx - 50, L.yMin - 20});
    else if (mx < 40 && L.salidas[3] >= 0 && L.enRango(3, my)) rutaClic.add(new float[] {-60, my - 40});
    else if (mx > width - 40 && L.salidas[1] >= 0 && L.enRango(1, my)) rutaClic.add(new float[] {width - 20, my - 40});
  }
  caminandoClic = true;
  framesAtascado = 0;
  ultimoAvanceX = x;
  ultimoAvanceY = y;
}

void ordenarHablar(Interactivo it) {
  ordenarCaminar(it.ix, it.iy + 18);
  objetivoClic = it;
  marcaColor = #FFDC3C;
}

void pararClic() {
  caminandoClic = false;
  objetivoClic = null;
  rutaClic.clear();
  moverArriba = moverAbajo = moverIzquierda = moverDerecha = false;
}

// ------------------------------------- CAMINO (busqueda en una cuadricula) -------------------------------------
float[][] obstaculosActuales() {
  if (esCaminable(scene)) {
    Lugar L = lugares.get(scene);
    if (L != null) return L.obs;
  }
  return new float[0][0];
}

float yMinActual() {
  if (esCaminable(scene)) {
    Lugar L = lugares.get(scene);
    if (L != null) return L.yMin;
  }
  return 0;
}

boolean celdaLibre(int cx, int cy) {
  float px = cx * CELDA + CELDA / 2 - 50, py = cy * CELDA + CELDA / 2 - 40;
  if (py < yMinActual() - 2 || py > height - 48 || px < -30 || px > width - 70) return false;
  return !chocaLibre(px, py, obstaculosActuales());
}

void planearRuta() {
  rutaClic.clear();
  float[][] obs = obstaculosActuales();
  if (obs.length == 0) {   // sin obstaculos conocidos: derecho
    rutaClic.add(new float[] {destinoX, destinoY});
    return;
  }
  int cols = width / CELDA, filas = height / CELDA;
  int sx = constrain(int((x + 50) / CELDA), 0, cols - 1), sy = constrain(int((y + 40) / CELDA), 0, filas - 1);
  int tx = constrain(int((destinoX + 50) / CELDA), 0, cols - 1), ty = constrain(int((destinoY + 40) / CELDA), 0, filas - 1);
  // si el destino esta dentro de un obstaculo, el punto libre mas cercano
  if (!celdaLibre(tx, ty)) {
    float mejor = 1e9;
    int bx = tx, by = ty;
    for (int i = 0; i < cols; i++) for (int j = 0; j < filas; j++) {
      if (!celdaLibre(i, j)) continue;
      float d = dist(i, j, tx, ty);
      if (d < mejor) {
        mejor = d;
        bx = i;
        by = j;
      }
    }
    tx = bx;
    ty = by;
    destinoX = tx * CELDA + CELDA / 2 - 50;
    destinoY = ty * CELDA + CELDA / 2 - 40;
  }
  // busqueda a lo ancho (8 direcciones)
  int[] previo = new int[cols * filas];
  java.util.Arrays.fill(previo, -2);
  java.util.ArrayDeque<Integer> cola = new java.util.ArrayDeque<Integer>();
  int ini = sy * cols + sx, fin = ty * cols + tx;
  previo[ini] = -1;
  cola.add(ini);
  int[] dx = {1, -1, 0, 0, 1, 1, -1, -1};
  int[] dy = {0, 0, 1, -1, 1, -1, 1, -1};
  boolean llego = false;
  while (!cola.isEmpty()) {
    int c = cola.poll();
    if (c == fin) {
      llego = true;
      break;
    }
    int cx = c % cols, cy = c / cols;
    for (int k = 0; k < 8; k++) {
      int nx = cx + dx[k], ny = cy + dy[k];
      if (nx < 0 || ny < 0 || nx >= cols || ny >= filas) continue;
      int n = ny * cols + nx;
      if (previo[n] != -2 || !celdaLibre(nx, ny)) continue;
      if (k >= 4 && (!celdaLibre(cx + dx[k], cy) || !celdaLibre(cx, cy + dy[k]))) continue;   // no cortar esquinas
      previo[n] = c;
      cola.add(n);
    }
  }
  if (!llego) {
    rutaClic.add(new float[] {destinoX, destinoY});
    return;
  }
  ArrayList<float[]> inversa = new ArrayList<float[]>();
  for (int c = fin; c != -1 && c != ini; c = previo[c]) inversa.add(new float[] {(c % cols) * CELDA + CELDA / 2 - 50, (c / cols) * CELDA + CELDA / 2 - 40});
  for (int i = inversa.size() - 1; i >= 0; i--) rutaClic.add(inversa.get(i));
  if (rutaClic.size() > 0) rutaClic.set(rutaClic.size() - 1, new float[] {destinoX, destinoY});
}

// ------------------------------------- CADA CUADRO -------------------------------------
// convierte el siguiente punto de la ruta en "teclas" (moverArriba, etc.) para que todas las escenas lo entiendan
void actualizarMovimientoClic() {
  if (!caminandoClic) return;
  boolean puedeMoverse = (esExploracion(scene) || scene == 5) && !pausaAbierta && !telefonoAbierto && charlaActiva == null && !situacionAbierta() && revisionActiva == null && !cargaActiva;
  if (!puedeMoverse) {
    if (scene == 1 || !esExploracion(scene)) pararClic();
    else moverArriba = moverAbajo = moverIzquierda = moverDerecha = false;
    return;
  }
  // ya llego a quien le iba a hablar?
  if (objetivoClic != null && dist(x + 50, y + 25, objetivoClic.ix, objetivoClic.iy - 15) < 62) {
    Interactivo it = objetivoClic;
    pararClic();
    actual = it.iy < y + 30 ? arriba : abajo;
    interactuar(it);
    return;
  }
  while (rutaClic.size() > 0) {
    float[] p = rutaClic.get(0);
    if (abs(p[0] - x) <= velocidad && abs(p[1] - y) <= velocidad) rutaClic.remove(0);
    else break;
  }
  if (rutaClic.size() == 0) {
    pararClic();
    return;
  }
  float[] p = rutaClic.get(0);
  float dxp = p[0] - x, dyp = p[1] - y;
  float umbral = velocidad * 0.6;
  moverDerecha = dxp > umbral;
  moverIzquierda = dxp < -umbral;
  moverAbajo = dyp > umbral;
  moverArriba = dyp < -umbral;
  if (abs(dxp) > abs(dyp)) actual = dxp > 0 ? derecha : izquierda;
  else actual = dyp > 0 ? abajo : arriba;
  // atascado contra algo (en las escenas sin obstaculos conocidos)
  if (dist(x, y, ultimoAvanceX, ultimoAvanceY) < 0.3) framesAtascado++;
  else framesAtascado = 0;
  ultimoAvanceX = x;
  ultimoAvanceY = y;
  if (framesAtascado > 25) pararClic();
}

void dibujarMarcaClic() {
  if (marcaT <= 0) return;
  if (!pausaAbierta) marcaT--;
  float t = marcaT / 26.0;
  noFill();
  stroke(marcaColor, 255 * t);
  strokeWeight(2);
  float r = 10 + 22 * t;
  ellipse(marcaX, marcaY, r * 2, r);
  // las flechitas que apuntan al centro
  for (int k = 0; k < 4; k++) {
    float a = k * HALF_PI + QUARTER_PI;
    float ax = marcaX + cos(a) * r, ay = marcaY + sin(a) * r * 0.5;
    float bx = marcaX + cos(a) * (r - 8), by = marcaY + sin(a) * (r - 8) * 0.5;
    line(ax, ay, bx, by);
  }
  noStroke();
  fill(marcaColor, 200 * t);
  ellipse(marcaX, marcaY, 5, 3);
}

// ------------------------------------- CLICS -------------------------------------
boolean esEscenaParaCaminar() {
  return (esExploracion(scene) || scene == 5) && scene != 1;
}

Interactivo interactivoBajoMouse() {
  if (!esCaminable(scene)) return null;
  Lugar L = lugares.get(scene);
  if (L == null) return null;
  for (Interactivo it : L.inter) {
    if (it.ausente || it.oculto) continue;
    float alto = it.tipo == 4 ? 100 : 80;
    if (mouseX > it.ix - 26 && mouseX < it.ix + 26 && mouseY > it.iy - alto && mouseY < it.iy + 6) return it;
  }
  return null;
}

// se llama desde vidaMousePressed. Devuelve true si el clic fue para caminar
boolean clickParaCaminar() {
  if (!esEscenaParaCaminar() || pausaAbierta || telefonoAbierto || charlaActiva != null || situacionAbierta() || revisionActiva != null) return false;
  boolean derecho = mouseButton == RIGHT;
  boolean izquierdoEnPiso = mouseButton == LEFT && esCaminable(scene) && !clickVolver() && mouseY > 70;
  if (!derecho && !izquierdoEnPiso) return false;
  if (!derecho && encima(552, 8, 40, 60)) return false;   // el boton del celular
  Interactivo it = interactivoBajoMouse();
  if (it != null) ordenarHablar(it);
  else ordenarCaminar(mouseX, mouseY);
  return true;
}

// tocar una tecla de movimiento cancela el camino del mouse
void teclaCancelaClic() {
  if (!caminandoClic) return;
  boolean mueve = (key == CODED && (keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT)) || "wasdWASD".indexOf(key) >= 0;
  if (mueve) pararClic();
}
