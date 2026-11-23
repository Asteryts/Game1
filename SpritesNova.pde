import java.text.Normalizer;

final int SPRITE_ESPERA = 0, SPRITE_HABLA = 1, SPRITE_MOVIMIENTO = 2, SPRITE_SORPRESA = 3;
final int SPRITE_ANCHO = 72, SPRITE_ALTO = 88, SPRITE_COLUMNAS = 32;
final int SPRITE_PIES = 83;
// Filas del atlas de T/N. Cada fila tiene una pose quieta y cuatro de caminata.
final int JUGADOR_ABAJO = 0, JUGADOR_IZQUIERDA = 1, JUGADOR_DERECHA = 2, JUGADOR_ARRIBA = 3;
final int CELDA_JUGADOR = 56, PIES_JUGADOR = 51, POSES_JUGADOR = 5;
final PImage[][] caminataJugadorNova = new PImage[4][POSES_JUGADOR];
final PImage[][] caminataJugadoraNova = new PImage[4][POSES_JUGADOR];
PImage hablaJugadoraNova, sorpresaJugadoraNova;
final int ANCHO_SHAWN = 72, ALTO_SHAWN = 80, ANCLA_SHAWN = 77;
final PImage[] cuadrosShawnNova = new PImage[4];
final int[] vueloShawnNova = {0, 1, 0, 2, 3, 2};
final int[] fotogramasNova = {4, 14, 8, 12};
final PImage[] atlasNova = new PImage[4];
final HashMap<String, Integer> idsSpriteNova = new HashMap<String, Integer>();
final HashMap<String, String> clavesSpriteNova = new HashMap<String, String>();
PImage[][] celdasSpriteNova;
int relojSpriteNova, ultimoTiempoSpriteNova = -1;
int inicioSorpresaNova = -1, escenaSorpresaNova;
String personajeSorpresaNova = "";
float anteriorJugadorX, anteriorJugadorY;
int anteriorEscenaJugador = -1, anteriorCuadroJugador = -1;
boolean caminandoSpriteJugador;
int direccionPasoJugador, inicioPasoJugador;

void prepararSpritesNova() {
  prepararCaminataJugadorNova();
  prepararShawnNova();
  if (!new java.io.File(dataPath("sprites-nova.txt")).isFile()) return;
  String[] nombres = loadStrings("sprites-nova.txt");
  if (nombres == null) return;
  String[] ciclos = {"espera", "habla", "movimiento", "sorpresa"};
  celdasSpriteNova = new PImage[ciclos.length][];
  for (int i = 0; i < ciclos.length; i++) {
    String archivo = "sprites-nova-" + ciclos[i] + ".png";
    if (!new java.io.File(dataPath(archivo)).isFile()) continue;
    PImage atlas = loadImage(archivo);
    int celdas = nombres.length * fotogramasNova[i];
    if (atlas == null || atlas.width != SPRITE_COLUMNAS * SPRITE_ANCHO
        || atlas.height < ((celdas + SPRITE_COLUMNAS - 1) / SPRITE_COLUMNAS) * SPRITE_ALTO) continue;
    atlasNova[i] = atlas;
    celdasSpriteNova[i] = new PImage[celdas];
  }
  for (int i = 0; i < nombres.length; i++) {
    if (!nombres[i].isEmpty()) idsSpriteNova.put(claveSpriteNova(nombres[i]), i);
  }
}

void prepararShawnNova() {
  String archivo = "shawn-fantasma.png";
  if (!new java.io.File(dataPath(archivo)).isFile()) return;
  PImage atlas = loadImage(archivo);
  if (atlas == null || atlas.width != ANCHO_SHAWN * cuadrosShawnNova.length || atlas.height != ALTO_SHAWN) return;
  for (int i = 0; i < cuadrosShawnNova.length; i++) {
    cuadrosShawnNova[i] = atlas.get(i * ANCHO_SHAWN, 0, ANCHO_SHAWN, ALTO_SHAWN);
  }
}

void prepararCaminataJugadorNova() {
  cargarCaminataJugadorNova("jugador-caminata.png", caminataJugadorNova);
  cargarCaminataJugadorNova("jugadora-caminata.png", caminataJugadoraNova);
  PImage frente = caminataJugadoraNova[JUGADOR_ABAJO][0];
  if (frente != null) {
    // Dos gestos sobre los píxeles de la boca de la pose frontal.
    hablaJugadoraNova = frente.get();
    hablaJugadoraNova.set(26, 25, #592F46);
    hablaJugadoraNova.set(27, 25, #76384D);
    sorpresaJugadoraNova = hablaJugadoraNova.get();
    sorpresaJugadoraNova.set(26, 24, #592F46);
    sorpresaJugadoraNova.set(27, 24, #592F46);
  }
}

void cargarCaminataJugadorNova(String archivo, PImage[][] poses) {
  if (!new java.io.File(dataPath(archivo)).isFile()) return;
  PImage atlas = loadImage(archivo);
  if (atlas == null || atlas.width != CELDA_JUGADOR * POSES_JUGADOR
      || atlas.height != CELDA_JUGADOR * poses.length) return;
  for (int dir = 0; dir < poses.length; dir++) {
    for (int cuadro = 0; cuadro < POSES_JUGADOR; cuadro++) {
      poses[dir][cuadro] = atlas.get(cuadro * CELDA_JUGADOR, dir * CELDA_JUGADOR,
        CELDA_JUGADOR, CELDA_JUGADOR);
    }
  }
}

String claveSpriteNova(String nombre) {
  if (nombre == null || nombre.isEmpty()) return "";
  String clave = clavesSpriteNova.get(nombre);
  if (clave != null) return clave;
  int detalle = nombre.indexOf(" (");
  String base = detalle < 0 ? nombre : nombre.substring(0, detalle);
  clave = Normalizer.normalize(base.trim(), Normalizer.Form.NFD)
    .replaceAll("\\p{M}+", "").toLowerCase(java.util.Locale.ROOT);
  if (clave.equals("solomeo") || clave.equals("npc")) clave = "salomeo";
  else if (clave.equals("benito juarez")) clave = "benito";
  else if (clave.equals("tu")) clave = "t/n";
  clavesSpriteNova.put(nombre, clave);
  return clave;
}

void actualizarRelojSpritesNova() {
  int ahora = millis();
  if (ultimoTiempoSpriteNova >= 0 && !pausaAbierta && !telefonoAbierto) {
    relojSpriteNova += min(100, max(0, ahora - ultimoTiempoSpriteNova));
  }
  ultimoTiempoSpriteNova = ahora;
}

void reaccionSpriteNova(String nombre) {
  personajeSorpresaNova = claveSpriteNova(nombre);
  inicioSorpresaNova = relojSpriteNova;
  escenaSorpresaNova = scene;
}

String interlocutorSpritesNova() {
  if (charlaActiva != null && !charlaEligiendo && charlaLetras < textoCharla().length()) {
    String hablante = claveSpriteNova(charlaActiva.hablante);
    if (hablante.equals("lu y caro")) return textoCharla().startsWith("Caro:") ? "caro" : "lu";
    return hablante;
  }
  if (situacionAbierta() && estadoSit == 0 && letrasSit < avisoSit[sitAbierta].length()) {
    return claveSpriteNova(mensajeroSit[sitAbierta]);
  }
  if (mostrarDialogo && !paginter && npcHablando >= 0 && npcs[npcHablando][4] == scene) {
    return claveSpriteNova(nombresNpc[npcHablando]);
  }
  if (hablando && scene == 8 && dialogoIdx < quien.length) return claveSpriteNova(quien[dialogoIdx]);
  if (hablando && scene == 24) return "empleado";
  if (mostrarDialogo && (scene == 5 || (scene >= 18 && scene <= 23))) {
    int separador = textoDialogo.indexOf(':');
    if (separador >= 0 && separador < 24) {
      String hablante = claveSpriteNova(textoDialogo.substring(0, separador));
      if (hablante.equals("aquiles castro")) return "aquiles";
      if (idsSpriteNova.containsKey(hablante)) return hablante;
    }
    if (scene == 18 && textoDialogo.contains("\nArmando:")) return "armando";
  }
  return "";
}

int modoSpriteNova(String nombre) {
  String clave = claveSpriteNova(nombre);
  if (inicioSorpresaNova >= 0 && escenaSorpresaNova == scene
      && relojSpriteNova - inicioSorpresaNova < 12 * 70
      && clave.equals(personajeSorpresaNova)) return SPRITE_SORPRESA;
  if (clave.equals(interlocutorSpritesNova())) return SPRITE_HABLA;
  return SPRITE_ESPERA;
}

int cuadroSpriteNova(int modo, int fase) {
  if (modo == SPRITE_SORPRESA) return constrain((relojSpriteNova - inicioSorpresaNova) / 70, 0, 11);
  int tiempo = relojSpriteNova + fase;
  if (modo == SPRITE_ESPERA) {
    int paso = tiempo % 3200;
    if (paso >= 2880 && paso < 2970) return 3;
    return (paso / 300) % 3;
  }
  int intervalo = modo == SPRITE_MOVIMIENTO ? 74 : 88;
  return (tiempo / intervalo) % fotogramasNova[modo];
}

boolean dibujarSpriteNova(String nombre, float cx, float pies, float escala, int modo, int fase) {
  String clave = claveSpriteNova(nombre);
  if (clave.equals("shawn")) return dibujarShawnNova(cx, pies, escala, modo, fase);
  if (clave.equals("t/n") && generoPersonaje == PERSONAJE_FEMENINO) {
    if (dibujarGestoJugadoraNova(cx, pies, escala / 0.72, modo, fase)) return true;
  }
  Integer id = idsSpriteNova.get(clave);
  if (id == null) return false;
  if (atlasNova[modo] == null) modo = SPRITE_ESPERA;
  PImage atlas = atlasNova[modo];
  if (atlas == null) return false;
  int celda = id * fotogramasNova[modo] + cuadroSpriteNova(modo, fase);
  PImage sprite = celdasSpriteNova[modo][celda];
  if (sprite == null) {
    int sx = (celda % SPRITE_COLUMNAS) * SPRITE_ANCHO;
    int sy = (celda / SPRITE_COLUMNAS) * SPRITE_ALTO;
    sprite = atlas.get(sx, sy, SPRITE_ANCHO, SPRITE_ALTO);
    celdasSpriteNova[modo][celda] = sprite;
  }
  pintarSpriteNova(sprite, cx - SPRITE_ANCHO * escala / 2, pies - SPRITE_PIES * escala,
    SPRITE_ANCHO * escala, SPRITE_ALTO * escala);
  return true;
}

boolean dibujarShawnNova(float cx, float pies, float escala, int modo, int fase) {
  int tiempo = relojSpriteNova + fase;
  int paso = (tiempo / (modo == SPRITE_HABLA ? 115 : 190)) % vueloShawnNova.length;
  float flota = sin(tiempo * 0.0045) * 2.5;
  if (modo == SPRITE_SORPRESA) {
    int momento = cuadroSpriteNova(modo, fase);
    paso = momento < 6 ? 1 : 4;
    flota -= sin(momento / 11.0 * PI) * 7;
  }
  PImage figura = cuadrosShawnNova[vueloShawnNova[paso]];
  if (figura == null) return false;
  float tamano = escala >= 1 ? escala * 1.24 : escala;
  pintarSpriteNova(figura, cx - ANCHO_SHAWN * tamano / 2, pies - ANCLA_SHAWN * tamano + round(flota * escala),
    ANCHO_SHAWN * tamano, ALTO_SHAWN * tamano);
  return true;
}

void pintarSpriteNova(PImage sprite, float sx, float sy, float ancho, float alto) {
  pushStyle();
  imageMode(CORNER);
  if (g instanceof processing.awt.PGraphicsJava2D) {
    Graphics2D lienzo = ((processing.awt.PGraphicsJava2D) g).g2;
    RenderingHints pistas = lienzo.getRenderingHints();
    lienzo.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
    image(sprite, sx, sy, ancho, alto);
    lienzo.setRenderingHints(pistas);
  } else {
    image(sprite, sx, sy, ancho, alto);
  }
  popStyle();
}

boolean dibujarPersonaNova(String nombre, float cx, float pies, float fase) {
  if ("Lu y Caro".equals(nombre)) {
    boolean lu = dibujarPersonaNova("Lu", cx - 13, pies, fase);
    boolean caro = dibujarPersonaNova("Caro", cx + 13, pies + 2, fase + 0.7);
    return lu && caro;
  }
  return dibujarSpriteNova(nombre, cx, pies, 1, modoSpriteNova(nombre), round(fase * 210));
}

void marcaSpriteNova(float cx, float pies, float fase) {
  pushStyle();
  noStroke();
  float cy = pies - 76 - abs(sin(frameCount * 0.1 + fase)) * 6;
  fill(neonAmarillo);
  ellipse(cx, cy, 20, 20);
  fill(20);
  rect(cx - 1, cy - 5, 2, 6);
  rect(cx - 1, cy + 3, 2, 2);
  popStyle();
}

void actualizarPasoJugadorNova() {
  if (anteriorCuadroJugador == frameCount) return;
  boolean estabaCaminando = caminandoSpriteJugador;
  float dx = x - anteriorJugadorX, dy = y - anteriorJugadorY;
  float avance = mag(dx, dy);
  boolean entradaEnMarcha = anteriorEscenaJugador != scene && estabaCaminando
    && frameCount - anteriorCuadroJugador <= 2 && esExploracion(anteriorEscenaJugador) && esExploracion(scene)
    && !cargaActiva && (moverArriba || moverAbajo || moverIzquierda || moverDerecha);
  caminandoSpriteJugador = entradaEnMarcha || (anteriorEscenaJugador == scene
    && anteriorCuadroJugador == frameCount - 1 && avance > 0.01 && avance < 32);
  if (caminandoSpriteJugador) {
    if (!estabaCaminando) inicioPasoJugador = relojSpriteNova;
    if (entradaEnMarcha) direccionPasoJugador = direccionMiradaJugadorNova();
    else if (abs(dx) > abs(dy)) direccionPasoJugador = dx < 0 ? JUGADOR_IZQUIERDA : JUGADOR_DERECHA;
    else if (abs(dy) > abs(dx)) direccionPasoJugador = dy < 0 ? JUGADOR_ARRIBA : JUGADOR_ABAJO;
    else direccionPasoJugador = direccionMiradaJugadorNova();
  }
  anteriorCuadroJugador = frameCount;
  anteriorEscenaJugador = scene;
  anteriorJugadorX = x;
  anteriorJugadorY = y;
}

int direccionMiradaJugadorNova() {
  if (actual == izquierda) return JUGADOR_IZQUIERDA;
  if (actual == derecha) return JUGADOR_DERECHA;
  if (actual == arriba) return JUGADOR_ARRIBA;
  return JUGADOR_ABAJO;
}

int cuadroCaminataJugadorNova(int tiempo, boolean corre) {
  int intervalo = corre ? 82 : 110;
  return 1 + (tiempo / intervalo) % (POSES_JUGADOR - 1);
}

boolean dibujarCaminataJugadorNova(int direccion, int cuadro, float cx, float pies, float escala) {
  return dibujarPoseJugadorNova(generoPersonaje, direccion, cuadro, cx, pies, escala);
}

boolean dibujarPoseJugadorNova(int genero, int direccion, int cuadro, float cx, float pies, float escala) {
  PImage[][] poses = genero == PERSONAJE_FEMENINO ? caminataJugadoraNova : caminataJugadorNova;
  return pintarPoseJugadorNova(poses[direccion][cuadro], cx, pies, escala);
}

boolean pintarPoseJugadorNova(PImage sprite, float cx, float pies, float escala) {
  if (sprite == null) return false;
  pintarSpriteNova(sprite, cx - CELDA_JUGADOR * escala / 2, pies - PIES_JUGADOR * escala,
    CELDA_JUGADOR * escala, CELDA_JUGADOR * escala);
  return true;
}

boolean dibujarGestoJugadoraNova(float cx, float pies, float escala, int modo, int fase) {
  if (modo == SPRITE_MOVIMIENTO) {
    return dibujarPoseJugadorNova(PERSONAJE_FEMENINO, JUGADOR_ABAJO,
      cuadroCaminataJugadorNova(relojSpriteNova + fase, false), cx, pies, escala);
  }
  PImage sprite = caminataJugadoraNova[JUGADOR_ABAJO][0];
  float salto = 0;
  int cuadro = cuadroSpriteNova(modo, fase);
  if (modo == SPRITE_HABLA && cuadro % 3 != 0) sprite = hablaJugadoraNova;
  else if (modo == SPRITE_SORPRESA) {
    if (cuadro >= 2 && cuadro <= 8) sprite = sorpresaJugadoraNova;
    salto = round(sin(cuadro / 11.0 * PI) * 5);
  } else if (modo == SPRITE_ESPERA && cuadro == 1) salto = 1;
  return pintarPoseJugadorNova(sprite, cx, pies - salto * escala, escala);
}

void dibujarBaseJugadorNova() {
  int modo = modoSpriteNova("T/N");
  int direccion = caminandoSpriteJugador ? direccionPasoJugador : direccionMiradaJugadorNova();
  float cx = x + anchoPersonaje / 2, pies = y + altoPersonaje - 5;
  if (modo == SPRITE_HABLA || modo == SPRITE_SORPRESA) {
    if (dibujarSpriteNova("T/N", cx, pies, 0.72, modo, 0)) return;
  }
  if (caminandoSpriteJugador) {
    int cuadro = cuadroCaminataJugadorNova(relojSpriteNova - inicioPasoJugador, velocidad > velocidadBase);
    if (dibujarCaminataJugadorNova(direccion, cuadro, cx, pies, 1)) return;
    modo = SPRITE_MOVIMIENTO;
  }
  if (direccion == JUGADOR_ABAJO && dibujarSpriteNova("T/N", cx, pies, 0.72, modo, 0)) return;
  if (dibujarCaminataJugadorNova(direccion, 0, cx, pies, 1)) return;
  pushStyle();
  imageMode(CORNER);
  image(actual, x, y, anchoPersonaje, altoPersonaje);
  popStyle();
}
