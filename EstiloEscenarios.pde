// Las paletas de la galería sólo se aplican a los escenarios dibujados por el juego.
boolean estiloPixelActivo = true;
final String carpetaEstiloPixel = "escenarios-pixel/";
final HashMap<String, PaletaEscenario> paletasEscenario = new HashMap<String, PaletaEscenario>();
int[] muestrasEstiloEscenario = new int[0];
final String[] planosEstiloCine = {"cine-ciudad", "cine-caras", "cine-chismes", "cine-shawn", "cine-sofi", "cine-cuarto"};

void prepararEstiloEscenarios() {
  String archivo = carpetaEstiloPixel + "paletas.txt";
  if (!new File(dataPath(archivo)).isFile()) return;
  String[] lineas = loadStrings(archivo);
  if (lineas == null) return;
  for (String linea : lineas) {
    String[] datos = split(linea, '|');
    if (datos.length != 4) continue;
    String[] colores = split(datos[3], ',');
    int[] tonos = new int[colores.length];
    for (int i = 0; i < tonos.length; i++) tonos[i] = 0xff000000 | unhex(colores[i]);
    int paso = parseInt(datos[1]);
    if (tonos.length > 0 && (paso == 2 || paso == 4)) {
      paletasEscenario.put(datos[0], new PaletaEscenario(tonos, paso, datos[2].equals("1"), datos[0].hashCode()));
    }
  }
}

void alternarEstiloEscenarios() {
  estiloPixelActivo = !estiloPixelActivo;
  guardarDatos();
}

String rotuloEstiloEscenarios() {
  return estiloPixelActivo ? "Pixel art: ACTIVADO" : "Pixel art: ORIGINAL";
}

void aplicarEstiloPantalla(int escenaDibujada) {
  if (!estiloPixelActivo) return;
  // Estas pantallas mezclan el fondo con texto y controles. Aquí sólo cambia la paleta.
  if (esMinijuego(escenaDibujada) && escenaDibujada != ESC_SALTO && escenaDibujada != ESC_MANOTAZO) {
    aplicarEstiloEscenario(g, "arcade-" + escenaDibujada, true);
  }
  else if (escenaDibujada == ESC_ESTUDIO) aplicarEstiloEscenario(g, "estudio", true);
  else if (escenaDibujada == ESC_PLAZA) aplicarEstiloEscenario(g, "votacion", true);
  else if (escenaDibujada == ESC_TIENDA) aplicarEstiloEscenario(g, "tienda", true);
  else if (escenaDibujada == ESC_RULETA) aplicarEstiloEscenario(g, "ruleta", true);
  else if (escenaDibujada == ESC_MINIJUEGOS) aplicarEstiloEscenario(g, "sala-arcade", true);
  else if (escenaDibujada == ESC_JUICIO) aplicarEstiloEscenario(g, "juicio", true);
  else if (escenaDibujada == ESC_FINAL_SECRETO) aplicarEstiloEscenario(g, "final-secreto", true);
}

class PaletaEscenario {
  final int paso, semilla;
  final boolean textura;
  final int[] tonos;
  int[] tabla;

  PaletaEscenario(int[] tonos, int paso, boolean textura, int semilla) {
    this.tonos = tonos;
    this.paso = paso;
    this.textura = textura;
    this.semilla = semilla;
  }

  // Una tabla de 5 bits por canal evita buscar el tono más cercano por cada píxel de cada cuadro.
  void prepararTabla() {
    tabla = new int[32 * 32 * 32];
    for (int i = 0; i < tabla.length; i++) {
      int r = ((i >>> 10) & 31) * 8 + 4, v = ((i >>> 5) & 31) * 8 + 4, a = (i & 31) * 8 + 4;
      int muestra = graduarColorEscenario(r, v, a);
      int cercano = tonos[0], minimo = Integer.MAX_VALUE;
      for (int tono : tonos) {
        int distancia = distanciaColorEscenario(muestra, tono);
        if (distancia < minimo) {
          minimo = distancia;
          cercano = tono;
        }
      }
      tabla[i] = cercano;
    }
  }

  int tono(int original, int variacion) {
    int r = canalEscenario((original >>> 16 & 255) + variacion);
    int v = canalEscenario((original >>> 8 & 255) + variacion);
    int a = canalEscenario((original & 255) + variacion);
    return tabla[((r >>> 3) << 10) | ((v >>> 3) << 5) | (a >>> 3)];
  }
}

void aplicarEstiloEscenario(PImage lienzo, String id, boolean conservarDetalle) {
  if (!estiloPixelActivo || id == null) return;
  PaletaEscenario estilo = paletasEscenario.get(id);
  if (estilo == null) return;
  if (estilo.tabla == null) estilo.prepararTabla();

  lienzo.loadPixels();
  int[] pix = lienzo.pixels;
  int w = lienzo.pixelWidth, h = lienzo.pixelHeight;
  if (conservarDetalle) {
    for (int i = 0; i < pix.length; i++) {
      int c = pix[i];
      int r = c >>> 16 & 255, v = c >>> 8 & 255, a = c & 255;
      // Conserva el contraste de los rótulos blancos, los iconos y las siluetas negras.
      int mayor = max(r, max(v, a)), menor = min(r, min(v, a));
      if ((mayor >= 240 && mayor - menor < 32) || mayor < 9) continue;
      pix[i] = estilo.tono(c, 0);
    }
  } else {
    int paso = estilo.paso * lienzo.pixelDensity;
    int columnas = (w + paso - 1) / paso, filas = (h + paso - 1) / paso;
    int cantidad = columnas * filas;
    if (muestrasEstiloEscenario.length < cantidad) muestrasEstiloEscenario = new int[cantidad];
    for (int fy = 0; fy < filas; fy++) {
      for (int fx = 0; fx < columnas; fx++) {
        int x = fx * paso, y = fy * paso;
        muestrasEstiloEscenario[fy * columnas + fx] = promediarCeldaEscenario(pix, w, h, x, y, paso);
      }
    }
    for (int fy = 0; fy < filas; fy++) {
      for (int fx = 0; fx < columnas; fx++) {
        int i = fy * columnas + fx;
        int c = muestrasEstiloEscenario[i];
        int lado = muestrasEstiloEscenario[i + (fx + 1 < columnas ? 1 : 0)];
        int abajo = muestrasEstiloEscenario[i + (fy + 1 < filas ? columnas : 0)];
        int luz = luzEscenario(c), borde = max(luzEscenario(lado), luzEscenario(abajo)) - luz;
        int variacion = borde > 29 && luz < 172 ? (borde > 74 ? -7 : -4) : 0;
        if (estilo.textura && luz > 33 && luz < 171
            && distanciaColorEscenario(c, lado) < 120 && distanciaColorEscenario(c, abajo) < 120) {
          int fase = ruidoEstiloEscenario(fx / 2 + fy * 121, estilo.semilla);
          if (fase % 59 == 0) variacion += 11;
          else if (fase % 47 == 0) variacion -= 10;
          else if (fy > filas * 0.53 && ruidoEstiloEscenario(fx + fy / 2 * 99, estilo.semilla) % 63 == 0) variacion += 7;
        }
        int tono = estilo.tono(c, variacion);
        int x = fx * paso, y = fy * paso;
        int finX = min(w, x + paso), finY = min(h, y + paso);
        for (int py = y; py < finY; py++) java.util.Arrays.fill(pix, py * w + x, py * w + finX, tono);
      }
    }
  }
  lienzo.updatePixels();
}

int promediarCeldaEscenario(int[] pix, int w, int h, int x, int y, int paso) {
  int c1 = pix[y * w + x], c2 = pix[y * w + min(w - 1, x + paso - 1)];
  int c3 = pix[min(h - 1, y + paso - 1) * w + x];
  int c4 = pix[min(h - 1, y + paso - 1) * w + min(w - 1, x + paso - 1)];
  int centro = pix[min(h - 1, y + paso / 2) * w + min(w - 1, x + paso / 2)];
  int r = ((c1 >>> 16 & 255) + (c2 >>> 16 & 255) + (c3 >>> 16 & 255) + (c4 >>> 16 & 255) + 2 * (centro >>> 16 & 255)) / 6;
  int v = ((c1 >>> 8 & 255) + (c2 >>> 8 & 255) + (c3 >>> 8 & 255) + (c4 >>> 8 & 255) + 2 * (centro >>> 8 & 255)) / 6;
  int a = ((c1 & 255) + (c2 & 255) + (c3 & 255) + (c4 & 255) + 2 * (centro & 255)) / 6;
  return r << 16 | v << 8 | a;
}

int luzEscenario(int c) {
  return (3 * (c >>> 16 & 255) + 6 * (c >>> 8 & 255) + (c & 255)) / 10;
}

int distanciaColorEscenario(int primero, int segundo) {
  int r = (primero >>> 16 & 255) - (segundo >>> 16 & 255);
  int v = (primero >>> 8 & 255) - (segundo >>> 8 & 255);
  int a = (primero & 255) - (segundo & 255);
  return 2 * r * r + 3 * v * v + 2 * a * a;
}

int canalEscenario(int valor) {
  return Math.max(0, Math.min(255, valor));
}

int graduarColorEscenario(int r, int v, int a) {
  int l = (3 * r + 6 * v + a) / 10;
  if (l < 8 && max(r, max(v, a)) < 16) return 0x0c0e19;
  float sombra = max(0, (145 - l) / 145.0), claro = max(0, (l - 124) / 131.0);
  float contraste = (l - 105) * 0.085;
  int rojo = canalEscenario(round(r + (r - l) * 0.12 + contraste + 2 * sombra + 8 * claro));
  int verde = canalEscenario(round(v + (v - l) * 0.12 + contraste - 3 * sombra + 3 * claro));
  int azul = canalEscenario(round(a + (a - l) * 0.14 + contraste + 11 * sombra - 3 * claro));
  return rojo << 16 | verde << 8 | azul;
}

int ruidoEstiloEscenario(int indice, int semilla) {
  int ruido = indice * 0x45d9f3b ^ semilla;
  ruido = ((ruido >>> 16) ^ ruido) * 0x45d9f3b;
  ruido = ((ruido >>> 16) ^ ruido) * 0x45d9f3b;
  return (ruido ^ (ruido >>> 16)) & Integer.MAX_VALUE;
}
