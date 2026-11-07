// =====================================================================================
//  VIDA.pde  ->  todo lo que hace que Nova se sienta VIVA
//  particulas, transiciones entre escenas, HUD, notificaciones, logros, hora del dia,
//  clima, pausa, personajes animados...
//  Es una pestaña nueva: Processing la junta solita con Lab.pde al compilar.
//  F3 = modo debug (las coordenadas del mouse que usaban para ubicar cosas)
// =====================================================================================

// ------------------------------------- ESCENAS NUEVAS -------------------------------------
final int ESC_MINIJUEGOS = 40;
final int ESC_VERIFICADOR = 41;
final int ESC_ATRAPA = 42;
final int ESC_CAZABOTS = 43;
final int ESC_MEMORIA = 44;
final int ESC_PARQUE = 45;
final int ESC_CENTRO = 46;
final int ESC_ESTUDIO = 47;
final int ESC_PLAZA = 48;
final int ESC_FINAL = 49;
final int ESC_COMO_JUGAR = 50;
final int ESC_INTRO = 51;
// (expansion) camino a la alcaldia, barrio nuevo, interior del colegio y minijuegos nuevos
final int ESC_AVENIDA = 52;
final int ESC_PASEO = 53;
final int ESC_MERCADO = 54;
final int ESC_CANCHA = 55;
final int ESC_CALLEJON = 56;
final int ESC_PASILLO = 57;
final int ESC_SALON = 58;
final int ESC_BIBLIOTECA = 59;
final int ESC_CAFETERIA = 60;
final int ESC_TELROTO = 61;
final int ESC_PENALES = 62;
final int ESC_FOTO = 63;
final int ESC_TECLADO = 64;
final int ESC_MANOTAZO = 65;   // minijuego con la camara (Camara.pde)
final int ESC_SALTO = 66;      // minijuego de saltar con la mano (Salto.pde)
final int ESC_HISTORIAL = 67;  // tu historial de decisiones (Responsable.pde)

// colores neon (son "final" para que se puedan usar desde cualquier pestaña sin problemas de orden)
final color neonCian = #00F0FF;
final color neonRosa = #FF3CC8;
final color neonMorado = #9650FF;
final color neonAmarillo = #FFDC3C;
final color neonVerde = #3CFF96;
final color neonRojo = #FF465A;

PFont fuenteUI;          // una fuente limpia para textos pequeños (la cyberpunk queda para titulos)
PImage vineta;           // sombra oscura en los bordes de la pantalla

boolean modoDebug = false;
boolean pausaAbierta = false;
boolean ignorarClick = false;   // para que mouseClicked no repita un clic que ya usamos
boolean introVista = false;

int escenaAnterior = -999;
float fundido = 255;            // 255 = pantalla negra, baja hasta 0 (transicion)
float bannerVida = 0;
String bannerTexto = "";
float sacudida = 0;
float destello = 0;
color colorDestello = #FFFFFF;

float prevViral = 0, prevConf = 0, prevImp = 0;
float hudV = 0, hudC = 0, hudI = 0;
int decisionesTomadas = 0;
float relojJuego = 17 * 60;     // minutos del dia, empieza a las 5:00 pm
int notifPendientes = 0;
int proximaNotif = 1200;
float ultimoX = -1, ultimoY = -1;
boolean[] visitado = new boolean[80];
boolean[] npcHablado = new boolean[8];   // personajes del colegio con los que ya hablaste
int siguienteBarrio = 15;                // a que parte del barrio lleva "Continuar" en la escena 33

// colores de ropa/pelo de los personajes del colegio (mismo orden que nombresNpc)
color[] ropaNPC = {#3C78DC, #8C6E50, #C85A8C, #DC8C3C, #9650FF, #3CB48C, #505050, #DC3C50};
color[] peloNPC = {#2A1E14, #CCCCCC, #8C5A3C, #141414, #E6C878, #5A3214, #1E1E1E, #B4643C};
color[] tonosPiel = {#F2C9A0, #D9A27A, #A86E4A, #7A4A30};

// ------------------------------------- PARTICULAS -------------------------------------
class Particula {
  float x, y, vx, vy, vida, vidaMax, tam, grav, ang, giro, semilla;
  color c;
  int tipo;   // 0 punto, 1 gota, 2 hoja, 3 confeti, 4 bit 0/1, 5 humo, 6 luciernaga, 7 onda de charco

  Particula(float x, float y, float vx, float vy, float vida, float tam, color c, int tipo) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.vida = vida;
    this.vidaMax = vida;
    this.tam = tam;
    this.c = c;
    this.tipo = tipo;
    ang = random(TWO_PI);
    giro = random(-0.12, 0.12);
    semilla = random(1);
  }

  boolean vivir() {
    x += vx;
    y += vy;
    vy += grav;
    ang += giro;
    vida--;
    if (tipo == 2) x += sin(vida * 0.08 + semilla * 6) * 0.7;   // las hojas se mecen
    if (tipo == 6) { vx += random(-0.05, 0.05); vy += random(-0.05, 0.05); vx *= 0.98; vy *= 0.98; }
    return vida > 0;
  }

  void dibujar() {
    float a = constrain(vida / vidaMax, 0, 1);
    noStroke();
    if (tipo == 0) {
      fill(c, 255 * a);
      ellipse(x, y, tam, tam);
    } else if (tipo == 1) {
      // gota en pixeles (cuadritos de 2x2 en diagonal)
      fill(c, 150 * a);
      for (int k = 0; k < 4; k++) rect(floor((x - vx * 0.6 * k) / PIXEL) * PIXEL, floor((y - vy * 0.6 * k) / PIXEL) * PIXEL, PIXEL, PIXEL);
    } else if (tipo == 2) {
      pushMatrix();
      translate(x, y);
      rotate(ang);
      fill(c, 230 * a);
      ellipse(0, 0, tam, tam * 0.55);
      popMatrix();
    } else if (tipo == 3) {
      pushMatrix();
      translate(x, y);
      rotate(ang);
      fill(c, 255 * a);
      rect(-tam / 2, -tam / 4, tam, tam / 2);
      popMatrix();
    } else if (tipo == 4) {
      fill(c, 190 * a);
      textFont(fuenteUI);
      textSize(tam);
      textAlign(CENTER, CENTER);
      text(semilla > 0.5 ? "1" : "0", x, y);
    } else if (tipo == 5) {
      fill(c, 60 * a);
      ellipse(x, y, tam * (1.6 - a), tam * (1.6 - a));
    } else if (tipo == 6) {
      float b = 0.5 + 0.5 * sin(vida * 0.12 + semilla * 9);
      fill(c, 50 * a * b);
      ellipse(x, y, tam * 4, tam * 4);
      fill(c, 255 * a * b);
      ellipse(x, y, tam, tam);
    } else if (tipo == 7) {
      noFill();
      stroke(c, 140 * a);
      strokeWeight(1);
      ellipse(x, y, tam * (1 - a) * 3, tam * (1 - a));
      noStroke();
    }
  }
}

ArrayList<Particula> particulas = new ArrayList<Particula>();

void agregarParticula(Particula p) {
  if (particulas.size() < 700) particulas.add(p);
}

void chispas(float cx, float cy, color c, int n) {
  for (int i = 0; i < n; i++) {
    float a = random(TWO_PI), v = random(1.5, 6);
    Particula p = new Particula(cx, cy, cos(a) * v, sin(a) * v, random(25, 55), random(2, 5), c, 0);
    p.grav = 0.08;
    agregarParticula(p);
  }
}

void explosionConfeti(float cx, float cy, int n) {
  color[] cs = {neonCian, neonRosa, neonAmarillo, neonVerde, neonMorado};
  for (int i = 0; i < n; i++) {
    float a = random(PI, TWO_PI), v = random(3, 8);
    Particula p = new Particula(cx, cy, cos(a) * v, sin(a) * v, random(60, 110), random(6, 10), cs[int(random(cs.length))], 3);
    p.grav = 0.15;
    agregarParticula(p);
  }
}

// ------------------------------------- TEXTOS FLOTANTES -------------------------------------
class TextoFlotante {
  float x, y, vida, vidaMax, tam;
  String t;
  color c;
  boolean burbuja;

  TextoFlotante(String t, float x, float y, color c, float tam, float vida, boolean burbuja) {
    this.t = t;
    this.x = x;
    this.y = y;
    this.c = c;
    this.tam = tam;
    this.vida = vida;
    this.vidaMax = vida;
    this.burbuja = burbuja;
  }
}

ArrayList<TextoFlotante> flotantes = new ArrayList<TextoFlotante>();

void flotar(String t, float fx, float fy, color c) {
  flotantes.add(new TextoFlotante(t, fx, fy, c, 22, 110, false));
}

void dibujarFlotantes(boolean mover) {
  textFont(fuenteUI);
  for (int i = flotantes.size() - 1; i >= 0; i--) {
    TextoFlotante f = flotantes.get(i);
    if (mover) {
      f.vida--;
      f.y -= f.burbuja ? 0.25 : 0.7;
    }
    if (f.vida <= 0) {
      flotantes.remove(i);
      continue;
    }
    float edad = f.vidaMax - f.vida;
    float a = constrain(f.vida / 25.0, 0, 1) * constrain(edad / 8.0, 0, 1);
    textAlign(CENTER, CENTER);
    noStroke();
    if (f.burbuja) {
      textSize(f.tam);
      float w = textWidth(f.t) + 20;
      fill(255, 240 * a);
      rect(f.x - w / 2, f.y - 14, w, 26, 12);
      triangle(f.x - 6, f.y + 11, f.x + 5, f.y + 11, f.x - 9, f.y + 20);
      fill(40, 20, 50, 255 * a);
      text(f.t, f.x, f.y - 2);
    } else {
      float esc = edad < 10 ? map(edad, 0, 10, 1.7, 1) : 1;
      textSize(f.tam * esc);
      fill(0, 200 * a);
      text(f.t, f.x + 2, f.y + 2);
      fill(f.c, 255 * a);
      text(f.t, f.x, f.y);
    }
  }
}

// ------------------------------------- AVISOS (toasts) -------------------------------------
class Aviso {
  String titulo, cuerpo;
  color c;
  float vida = 300, entrada = 0;
  Aviso(String titulo, String cuerpo, color c) {
    this.titulo = titulo;
    this.cuerpo = cuerpo;
    this.c = c;
  }
}

ArrayList<Aviso> avisos = new ArrayList<Aviso>();

void avisar(String titulo, String cuerpo, color c) {
  avisos.add(new Aviso(titulo, cuerpo, c));
  if (avisos.size() > 3) avisos.remove(0);
}

void dibujarAvisos() {
  float yy = 92;
  for (int i = 0; i < avisos.size(); i++) {
    Aviso a = avisos.get(i);
    if (!pausaAbierta) a.vida--;
    a.entrada = lerp(a.entrada, a.vida > 25 ? 1 : 0, 0.18);
    float w = 260, h = 56;
    float ax = width - (w + 10) * a.entrada;
    noStroke();
    fill(10, 8, 26, 235);
    rect(ax, yy, w, h, 10);
    fill(a.c);
    rect(ax, yy, 5, h, 10, 0, 0, 10);
    textFont(fuenteUI);
    textAlign(LEFT, TOP);
    textSize(12);
    fill(a.c);
    text(a.titulo, ax + 14, yy + 7);
    fill(230);
    textSize(11);
    text(a.cuerpo, ax + 14, yy + 24, w - 22, 32);
    yy += h + 8;
  }
  for (int i = avisos.size() - 1; i >= 0; i--) if (avisos.get(i).vida <= 0) avisos.remove(i);
}

// ------------------------------------- LOGROS -------------------------------------
String[] logroNombre = {"Bienvenido a Nova", "Ojo critico", "Agente del caos", "Jugador arcade", "Maestro verificador", "Cazabots",
  "Memoria de elefante", "Explorador urbano", "En vivo y en directo", "Fin de la historia", "Lengua suelta", "Atrapabulos",
  "Oido fino", "Goleador", "Ojo de halcon", "Dedos veloces", "Amigo de los gatos", "Mano de NOVA", "Saltarin", "Pensar antes de compartir"};
String[] logroDesc = {"Llega al mapa de la ciudad", "Alcanza 50 de confiabilidad", "Llega a 70 de viralidad", "Juega cualquier minijuego",
  "8 aciertos o mas en el Verificador", "Elimina 15 bots en una ronda", "Completa el Rastreo de Fuentes", "Visita todos los lugares de Nova",
  "Termina el programa de Nova Noticias", "Descubre un final", "Habla con 10 personajes", "300 puntos en Atrapa Bulos",
  "Llega a la ronda 7 en Telefono Roto", "Mete 5 de 5 penales", "Encuentra las 10 diferencias", "600 puntos en Teclado Veloz", "Hazte amigo de un gato del mapa", "300 puntos en Manotazo", "Aguanta los 60 s en Salto con la Mano", "Detente 3 veces antes de compartir un bulo"};
boolean[] logros = new boolean[20];

void desbloquear(int i) {
  if (i < 0 || i >= logros.length || logros[i]) return;
  logros[i] = true;
  avisar("LOGRO DESBLOQUEADO", logroNombre[i] + " - " + logroDesc[i], neonAmarillo);
  explosionConfeti(width - 130, 110, 30);
  guardarDatos();
}

int contarLogros() {
  int n = 0;
  for (boolean b : logros) if (b) n++;
  return n;
}

int personasConocidas() {
  int n = 0;
  boolean[] barrio = {a1, a2, a3, b1, b2, b3, c1, c2, c3};
  for (boolean b : barrio) if (b) n++;
  for (boolean b : npcHablado) if (b) n++;
  n += charlasNuevasHabladas();
  return n;
}

void revisarLogros() {
  if (confiabilidad >= 50) desbloquear(1);
  if (viralidad >= 70) desbloquear(2);
  if (personasConocidas() >= 10) desbloquear(10);
}

void revisarExplorador() {
  int[] sitios = {5, 7, 24, ESC_PARQUE, ESC_CENTRO, ESC_ESTUDIO, ESC_PLAZA, ESC_AVENIDA, ESC_MERCADO, ESC_PASILLO};
  for (int l : sitios) if (!visitado[l]) return;
  desbloquear(7);
}

// ------------------------------------- GUARDAR / CARGAR -------------------------------------
// guarda records, logros y si ya viste la intro en datos_nova.txt (en la carpeta del sketch)
void cargarDatos() {
  try {
    File f = new File(sketchPath("datos_nova.txt"));
    if (!f.exists()) return;
    String[] l = loadStrings(f.getAbsolutePath());
    if (l == null) return;
    if (l.length > 0) {
      String[] r = split(l[0], ',');
      for (int i = 0; i < min(r.length, records.length); i++) records[i] = int(trim(r[i]));
    }
    if (l.length > 1) for (int i = 0; i < min(l[1].length(), logros.length); i++) logros[i] = l[1].charAt(i) == '1';
    if (l.length > 2) introVista = trim(l[2]).equals("1");
  }
  catch (Exception e) {
    println("No se pudieron cargar los datos: " + e);
  }
}

void guardarDatos() {
  try {
    String lg = "";
    for (boolean b : logros) lg += b ? "1" : "0";
    String[] l = {join(nf(records, 0), ","), lg, introVista ? "1" : "0"};
    saveStrings(sketchPath("datos_nova.txt"), l);
  }
  catch (Exception e) {
    println("No se pudieron guardar los datos: " + e);
  }
}

// ------------------------------------- GANCHOS QUE LLAMA Lab.pde -------------------------------------
void vidaSetup() {
  fuenteUI = createFont("Arial", 18, true);
  crearVineta();
  prepararPixel();
  prepararMenu();
  prepararTelefono();
  prepararEscenarios();
  cargarDatos();
  prevViral = viralidad;
  prevConf = confiabilidad;
  prevImp = impacto;
  if (fuente != null) textFont(fuente);
}

// se llama al principio de draw(). Si devuelve true, la escena es nueva y ya se dibujo aqui
boolean vidaAntesDeDibujar() {
  if (scene != escenaAnterior) {
    alCambiarEscena(escenaAnterior, scene);
    escenaAnterior = scene;
  }
  if (sacudida > 0.4) {
    translate(random(-sacudida, sacudida), random(-sacudida, sacudida));
    sacudida *= 0.86;
  } else {
    sacudida = 0;
  }
  // (expansion) entrar al colegio por la puerta de la Calle 4, y bajar de la alcaldia al Paseo de Campana
  if (scene == 17 && !mostrarDialogo && y < 95 && x > 280 && x < 390) irAEscena(ESC_PASILLO, 0);
  if (scene == 24 && !hablando && y > height - 45) irAEscena(ESC_PASEO, 2);
  if (scene == 0 || scene == 2 || scene >= 40) {
    dibujarEscenaPropia();
    vidaDespuesDeDibujar();
    return true;
  }
  return false;
}

void dibujarEscenaPropia() {
  if (scene == 0) dibujarMenu();
  else if (scene == 2) dibujarCreditos();
  else if (scene == ESC_MINIJUEGOS) dibujarSalaArcade();
  else if (scene == ESC_VERIFICADOR) dibujarVerificador();
  else if (scene == ESC_ATRAPA) dibujarAtrapa();
  else if (scene == ESC_CAZABOTS) dibujarCazaBots();
  else if (scene == ESC_MEMORIA) dibujarMemoria();
  else if (scene == ESC_TELROTO) dibujarTelefonoRoto();
  else if (scene == ESC_PENALES) dibujarPenales();
  else if (scene == ESC_FOTO) dibujarFotoTrucada();
  else if (scene == ESC_TECLADO) dibujarTeclado();
  else if (scene == ESC_MANOTAZO) dibujarManotazo();
  else if (scene == ESC_SALTO) dibujarSalto();
  else if (scene == ESC_HISTORIAL) dibujarHistorial();
  else if (esCaminable(scene)) dibujarEscenaCaminable();
  else if (scene == ESC_ESTUDIO) dibujarEstudio();
  else if (scene == ESC_PLAZA) dibujarPlaza();
  else if (scene == ESC_FINAL) dibujarFinal();
  else if (scene == ESC_COMO_JUGAR) dibujarComoJugar();
  else if (scene == ESC_INTRO) dibujarIntro();
  else background(0);
}

void alCambiarEscena(int de, int a) {
  fundido = (de == -999) ? 255 : 210;
  // la lluvia, las hojas, el humo y los cantos son de cada lugar: no se pasan a la escena nueva
  for (int i = particulas.size() - 1; i >= 0; i--) {
    int t = particulas.get(i).tipo;
    if (t != 0 && t != 3) particulas.remove(i);
  }
  for (int i = flotantes.size() - 1; i >= 0; i--) if (flotantes.get(i).burbuja) flotantes.remove(i);
  String n = nombreEscena(a);
  if (!n.equals("") && (esExploracion(a) || a == 1)) {
    bannerTexto = n;
    bannerVida = 170;
  }
  if (a >= 0 && a < visitado.length) visitado[a] = true;
  if (a == 1) {
    desbloquear(0);
    alEntrarAlMapa();
  }
  revisarExplorador();
  ultimoX = -1;
  quizasPantallaCarga(de, a);   // pantalla de carga con tema (Carga.pde)
}

// se llama al final de draw(): efectos, HUD, telefono, pausa, avisos y transiciones encima de todo
void vidaDespuesDeDibujar() {
  resetMatrix();
  boolean libre = !pausaAbierta && !telefonoAbierto;
  if (libre && esExploracion(scene)) {
    relojJuego += 0.03;
    polvoAlCaminar();
    if (--proximaNotif <= 0) llegaNotificacion();
  }
  if (libre) generarAmbiente();
  vigilarEstadisticas();
  actualizarResponsable();   // rumores que crecen y mensajes que llegan (Responsable.pde)
  if (frameCount % 30 == 0) revisarLogros();

  for (int i = particulas.size() - 1; i >= 0; i--) {
    Particula p = particulas.get(i);
    if (libre && !p.vivir()) {
      particulas.remove(i);
      continue;
    }
    p.dibujar();
  }

  if (esExploracion(scene)) tinteHora();
  pistasInteraccion();
  if (esExploracion(scene)) dibujarHUD();
  dibujarFlotantes(libre);
  dibujarBanner();
  if (destello > 0) {
    noStroke();
    fill(colorDestello, destello);
    rect(0, 0, width, height);
    destello -= 7;
  }
  dibujarTelefono();
  if (pausaAbierta) dibujarPausa();
  if (scene != ESC_HISTORIAL) dibujarAvisos();
  dibujarRevision();
  dibujarPantallaCarga();
  if (fundido > 0) {
    noStroke();
    fill(0, fundido);
    rect(0, 0, width, height);
    fundido -= 16;
  }
  if (modoDebug && (scene == 0 || scene == 2 || scene >= 40)) dibujarDebugCoords();
  restaurarEstilo();
}

// deja el estilo igual que como lo dejaba el codigo original al final de cada draw
void restaurarEstilo() {
  if (fuente != null) textFont(fuente);
  noTint();
  rectMode(CORNER);
  imageMode(CORNER);
  ellipseMode(CENTER);
  strokeWeight(1);
  noStroke();
  fill(255, 255, 0);
  textAlign(LEFT, TOP);
  textSize(12);
}

void dibujarDebugCoords() {
  fill(255, 0, 0);
  noStroke();
  ellipse(mouseX, mouseY, 6, 6);
  fill(255);
  textFont(fuenteUI);
  textAlign(LEFT);
  textSize(14);
  text(mouseX + ", " + mouseY, mouseX + 10, mouseY - 10);
  fill(255, 255, 0);
  textSize(12);
  textAlign(LEFT, TOP);
  text("X: " + int(mouseXCoord) + " | Y: " + int(mouseYCoord) + "   escena " + scene + "   fps " + int(frameRate), 10, 10);
}

boolean vidaKeyPressed() {
  if (entradaDuranteCarga()) {
    if (key == ESC) key = 0;
    return true;
  }
  if (teclaRevision()) return true;   // la pausa antes de compartir (Responsable.pde)
  if (key == ESC) {
    key = 0;   // para que Processing no cierre el juego con ESC
    if (telefonoAbierto) {
      cerrarTelefono();
      return true;
    }
    if (popupAbierto) {
      popupAbierto = false;
      return true;
    }
    if (scene == 0) return true;
    if (scene == 2) {
      scene = 0;
      return true;
    }
    if (scene == ESC_COMO_JUGAR) {
      scene = regresoAyuda;
      return true;
    }
    if (scene == ESC_INTRO) {
      terminarIntro();
      return true;
    }
    if (scene == ESC_MINIJUEGOS) {
      scene = regresoSala;
      return true;
    }
    if (scene == ESC_HISTORIAL) {
      scene = ESC_FINAL;
      return true;
    }
    if (esMinijuego(scene)) {
      salirJuego();
      return true;
    }
    pausaAbierta = !pausaAbierta;
    pararMovimiento();
    return true;
  }
  if (key == CODED && keyCode == 114) {   // F3
    modoDebug = !modoDebug;
    return true;
  }
  if (pausaAbierta) return true;
  if (telefonoAbierto) {
    teclaTelefono();
    return true;
  }
  if ((key == 'p' || key == 'P' || key == TAB) && (esExploracion(scene) || scene == 1)) {
    abrirTelefono();
    return true;
  }
  if (scene == 0 || scene == 2 || scene >= 40) return teclaEscenaPropia();
  // flechas del teclado tambien mueven al personaje en todas las escenas
  if (key == CODED && esExploracion(scene)) {
    if (keyCode == UP) { moverArriba = true; actual = arriba; }
    if (keyCode == DOWN) { moverAbajo = true; actual = abajo; }
    if (keyCode == LEFT) { moverIzquierda = true; actual = izquierda; }
    if (keyCode == RIGHT) { moverDerecha = true; actual = derecha; }
  }
  return false;
}

void vidaKeyReleased() {
  if (key == CODED) {
    if (keyCode == UP) moverArriba = false;
    if (keyCode == DOWN) moverAbajo = false;
    if (keyCode == LEFT) moverIzquierda = false;
    if (keyCode == RIGHT) moverDerecha = false;
  }
}

boolean vidaMousePressed() {
  if (entradaDuranteCarga()) return true;
  if (clickRevision()) return true;
  if (pausaAbierta) {
    clickPausa();
    return true;
  }
  if (telefonoAbierto) {
    clickTelefono();
    return true;
  }
  if (scene == 0 || scene == 2 || scene >= 40) {
    clickEscenaPropia();
    return true;
  }
  if (scene == 1 && clickMapaVivo()) return true;
  if (esExploracion(scene) && encima(552, 8, 40, 60)) {
    abrirTelefono();
    return true;
  }
  return false;
}

boolean teclaEscenaPropia() {
  boolean enter = key == ENTER || key == RETURN;
  if (scene == 0) {
    teclaMenu();
    return true;
  }
  if (scene == 2) {
    if (enter || key == ' ') scene = 0;
    return true;
  }
  if (scene == ESC_COMO_JUGAR) {
    if (enter) scene = regresoAyuda;
    return true;
  }
  if (scene == ESC_INTRO) {
    if (enter || key == ' ' || key == 'e' || key == 'E') avanzarIntro();
    return true;
  }
  if (esMinijuego(scene)) {
    teclaJuego();
    return true;
  }
  if (esCaminable(scene)) return teclaCaminable();
  if (scene == ESC_ESTUDIO) {
    teclaEstudio();
    return true;
  }
  if (scene == ESC_PLAZA) {
    if (enter || key == ' ') avanzarPlaza();
    return true;
  }
  return true;
}

void clickEscenaPropia() {
  if (scene == 0) clickMenu();
  else if (scene == 2) scene = 0;
  else if (scene == ESC_COMO_JUGAR) {
    if (clickVolver()) scene = regresoAyuda;
  } else if (scene == ESC_INTRO) {
    if (encima(680, 16, 100, 34)) terminarIntro();
    else avanzarIntro();
  } else if (scene == ESC_MINIJUEGOS) clickSala();
  else if (esMinijuego(scene)) clickJuego();
  else if (esCaminable(scene)) {
    if (clickVolver()) {
      cerrarCharla();
      scene = 1;
    } else if (charlaActiva != null) clickCharla();
  } else if (scene == ESC_ESTUDIO) clickEstudio();
  else if (scene == ESC_PLAZA) clickPlaza();
  else if (scene == ESC_FINAL) clickFinal();
  else if (scene == ESC_HISTORIAL) clickHistorial();
}

// ------------------------------------- AYUDANTES -------------------------------------
boolean esBarrio(int s) {
  return s == 5 || s == 15 || s == 16 || (s >= 18 && s <= 23);
}

boolean esColegio(int s) {
  return s == 7 || s == 17 || s == 25 || s == 26 || s == 27;
}

boolean esExploracion(int s) {
  return esBarrio(s) || esColegio(s) || s == 8 || s == 24 || esCaminable(s);
}

String nombreEscena(int s) {
  switch (s) {
  case 1:
    return "MAPA DE NOVA";
  case 5:
    return "Entrada a Nova";
  case 18:
    return "Barrio  -  Plaza de Armando";
  case 19:
    return "Barrio  -  Junta Vecinal";
  case 15:
    return "Barrio  -  Calle del Chisme";
  case 20:
    return "Barrio  -  Parquecito";
  case 21:
    return "Barrio  -  Casa de Debora";
  case 16:
    return "Barrio  -  Zona en obra";
  case 22:
    return "Barrio  -  Muro de grafitis";
  case 23:
    return "Barrio  -  La Asamblea";
  case 7:
    return "Colegio  -  Calle 1";
  case 25:
    return "Colegio  -  Calle 2";
  case 26:
    return "Colegio  -  Calle 3";
  case 17:
    return "Colegio  -  Calle 4";
  case 27:
    return "Cafe 404";
  case 24:
    return "Alcaldia de Nova";
  case 8:
    return "Alcaldia  -  La protesta";
  case ESC_PARQUE:
    return "Parque Central";
  case ESC_CENTRO:
    return "Centro NOVA";
  case ESC_ESTUDIO:
    return "Nova Noticias  -  EN VIVO";
  case ESC_PLAZA:
    return "Plaza de la Votacion";
  case ESC_MINIJUEGOS:
    return "Sala Arcade";
  }
  if (esCaminable(s)) return lugares.get(s).nombre;
  return "";
}

void pararMovimiento() {
  moverArriba = moverAbajo = moverIzquierda = moverDerecha = false;
  velocidad = velocidadBase;
}

boolean encima(float bx, float by, float bw, float bh) {
  return mouseX >= bx && mouseX <= bx + bw && mouseY >= by && mouseY <= by + bh;
}

String signo(float d) {
  return (d > 0 ? "+" : "") + round(d);
}

String recortar(String s, int n) {
  return s.length() <= n ? s : s.substring(0, n - 3) + "...";
}

float nivelNoche() {
  float h = (relojJuego / 60.0) % 24;
  if (h >= 18 && h < 20.5) return map(h, 18, 20.5, 0, 1);
  if (h >= 20.5 || h < 5) return 1;
  if (h >= 5 && h < 7) return map(h, 5, 7, 1, 0);
  return 0;
}

boolean esDeNoche() {
  return nivelNoche() > 0.6;
}

String textoHora() {
  int m = int(relojJuego) % 1440;
  return nf(m / 60, 2) + ":" + nf(m % 60, 2);
}

int diasElecciones() {
  return max(1, 7 - decisionesTomadas / 3);
}

// ------------------------------------- BOTONES Y TEXTOS NEON -------------------------------------
void botonNeon(String t, float bx, float by, float bw, float bh, color c, boolean activo) {
  boolean s = activo || encima(bx, by, bw, bh);
  noStroke();
  if (s) {
    for (int i = 4; i >= 1; i--) {
      fill(c, 16);
      rect(bx - i * 3, by - i * 3, bw + i * 6, bh + i * 6, 12 + i * 3);
    }
  }
  fill(s ? color(red(c) * 0.25, green(c) * 0.25, blue(c) * 0.25, 240) : color(12, 10, 28, 225));
  stroke(c, s ? 255 : 140);
  strokeWeight(s ? 2.5 : 1.5);
  rect(bx, by, bw, bh, 10);
  noStroke();
  fill(s ? 255 : 225);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(min(18, bh * 0.42));
  text(t, bx + bw / 2, by + bh / 2 - 1);
}

void botonVolver() {
  botonNeon("<  Volver", 20, 16, 96, 34, neonCian, false);
}

boolean clickVolver() {
  return encima(20, 16, 96, 34);
}

void panelNeon(float px, float py, float pw, float ph, color c) {
  noStroke();
  for (int i = 3; i >= 1; i--) {
    fill(c, 12);
    rect(px - i * 4, py - i * 4, pw + i * 8, ph + i * 8, 16 + i * 4);
  }
  fill(10, 8, 26, 235);
  rect(px, py, pw, ph, 16);
  stroke(c, 200);
  strokeWeight(1.5);
  noFill();
  rect(px, py, pw, ph, 16);
  noStroke();
  fill(c);
  rect(px + 24, py, pw - 48, 3, 2);
}

void tituloNeon(String t, float tx, float ty, float tam, color c) {
  textFont(fuente);
  textSize(tam);
  textAlign(CENTER, CENTER);
  for (int i = 3; i >= 1; i--) {
    fill(c, 38);
    text(t, tx - i, ty);
    text(t, tx + i, ty);
    text(t, tx, ty - i);
    text(t, tx, ty + i);
  }
  fill(c);
  text(t, tx, ty);
}

void teclaFlotante(String k, float cx, float cy) {
  float b = sin(frameCount * 0.15) * 3;
  noStroke();
  fill(0, 120);
  rect(cx - 13, cy - 10 + b, 26, 26, 6);
  fill(245);
  rect(cx - 13, cy - 13 + b, 26, 26, 6);
  fill(20);
  textFont(fuenteUI);
  textSize(15);
  textAlign(CENTER, CENTER);
  text(k, cx, cy - 1 + b);
}

void destelloObj(float dx, float dy) {
  float s = 3 + 2.5 * sin(frameCount * 0.12 + dx);
  noStroke();
  fill(255, 240, 180, 210);
  quad(dx, dy - s * 2, dx + s * 0.5, dy, dx, dy + s * 2, dx - s * 0.5, dy);
  quad(dx - s * 2, dy, dx, dy - s * 0.5, dx + s * 2, dy, dx, dy + s * 0.5);
}

void iconoCelular(float cx, float cy, float s, boolean vibra) {
  float v = vibra ? random(-1.5, 1.5) : 0;
  noStroke();
  fill(230);
  rect(cx - 8 * s + v, cy - 14 * s, 16 * s, 28 * s, 4 * s);
  fill(vibra ? neonRosa : color(40, 60, 90));
  rect(cx - 6 * s + v, cy - 11 * s, 12 * s, 19 * s, 2);
  fill(40);
  ellipse(cx + v, cy + 11 * s, 3 * s, 3 * s);
}

// ------------------------------------- PERSONAJES ANIMADOS -------------------------------------
// cx = centro, pies = donde pisa. fase cambia el ritmo para que no se muevan todos igual
// (lo llama dibujarNPC de Pixel.pde, que lo vuelve un sprite pixel art y le pone el nombre)
void dibujarNPCCuerpo(float cx, float pies, color ropa, color pelo, float fase, boolean marca) {
  pushStyle();
  float t = frameCount * 0.06 + fase;
  float bob = sin(t) * 1.5;
  color piel = tonosPiel[int(hsh(fase * 3.7) * tonosPiel.length) % tonosPiel.length];
  noStroke();
  fill(0, 90);
  ellipse(cx, pies, 36, 10);
  // contorno oscuro, como en el pixel art de las calles
  fill(16, 8, 28);
  rect(cx - 11, pies - 20, 22, 22, 2);
  rect(cx - 15, pies - 42 + bob, 30, 29, 9);
  rect(cx - 19, pies - 38 + bob, 38, 22, 6);
  ellipse(cx, pies - 50 + bob, 30, 30);
  fill(40, 38, 60);
  rect(cx - 9, pies - 18, 7, 17, 2);
  rect(cx + 2, pies - 18, 7, 17, 2);
  fill(20);
  rect(cx - 10, pies - 3, 9, 4, 2);
  rect(cx + 1, pies - 3, 9, 4, 2);
  // brazos (se balancean un poquito)
  fill(red(ropa) * 0.75, green(ropa) * 0.75, blue(ropa) * 0.75);
  pushMatrix();
  translate(cx - 13, pies - 36 + bob);
  rotate(sin(t * 0.7) * 0.12);
  rect(-4, 0, 6, 20, 3);
  fill(piel);
  ellipse(-1, 21, 6, 6);
  popMatrix();
  fill(red(ropa) * 0.75, green(ropa) * 0.75, blue(ropa) * 0.75);
  pushMatrix();
  translate(cx + 13, pies - 36 + bob);
  rotate(-sin(t * 0.7) * 0.12);
  rect(-2, 0, 6, 20, 3);
  fill(piel);
  ellipse(1, 21, 6, 6);
  popMatrix();
  fill(ropa);
  rect(cx - 13, pies - 40 + bob, 26, 25, 8);
  fill(255, 40);
  rect(cx - 11, pies - 38 + bob, 8, 18, 4);
  float hy = pies - 50 + bob;
  fill(piel);
  ellipse(cx, hy, 25, 25);
  fill(pelo);
  arc(cx, hy - 2, 27, 25, PI, TWO_PI);
  rect(cx - 13, hy - 4, 5, 9, 2);
  boolean parpadea = ((frameCount + int(fase * 100)) % 210) < 7;
  fill(25);
  if (parpadea) {
    rect(cx - 7, hy + 2, 5, 1.5);
    rect(cx + 2, hy + 2, 5, 1.5);
  } else {
    ellipse(cx - 5, hy + 2, 3.5, 5);
    ellipse(cx + 5, hy + 2, 3.5, 5);
  }
  fill(255, 120, 120, 90);
  ellipse(cx - 8, hy + 7, 5, 3);
  ellipse(cx + 8, hy + 7, 5, 3);
  if (marca) {
    float b = abs(sin(frameCount * 0.1 + fase)) * 6;
    fill(neonAmarillo);
    ellipse(cx, hy - 32 - b, 20, 20);
    triangle(cx - 4, hy - 24 - b, cx + 4, hy - 24 - b, cx, hy - 18 - b);
    fill(30);
    textFont(fuenteUI);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("!", cx, hy - 33 - b);
  }
  popStyle();
}

void dibujarRobotCuerpo(float cx, float pies, float fase) {
  pushStyle();
  float t = frameCount * 0.07 + fase;
  float flota = sin(t) * 3;
  noStroke();
  fill(0, 90);
  ellipse(cx, pies, 34 - flota, 9);
  fill(16, 8, 28);
  rect(cx - 18, pies - 46 + flota, 36, 34, 7);
  rect(cx - 17, pies - 74 + flota, 34, 30, 7);
  fill(150, 160, 180);
  rect(cx - 16, pies - 44 + flota, 32, 30, 6);
  fill(90, 100, 120);
  rect(cx - 10, pies - 16 + flota, 20, 6, 3);
  fill(170, 180, 200);
  rect(cx - 15, pies - 72 + flota, 30, 26, 6);
  fill(15, 20, 35);
  rect(cx - 11, pies - 68 + flota, 22, 16, 4);
  fill(neonRojo);
  boolean parp = (frameCount + int(fase * 50)) % 120 < 6;
  if (!parp) {
    rect(cx - 8, pies - 63 + flota, 5, 5);
    rect(cx + 3, pies - 63 + flota, 5, 5);
  }
  stroke(150, 160, 180);
  strokeWeight(2);
  line(cx, pies - 72 + flota, cx, pies - 82 + flota);
  noStroke();
  fill(frameCount % 30 < 15 ? neonRojo : color(80, 20, 30));
  ellipse(cx, pies - 84 + flota, 7, 7);
  fill(neonCian);
  rect(cx - 8, pies - 36 + flota, 16, 4, 2);
  popStyle();
}

// ------------------------------------- EFECTOS DEL MUNDO -------------------------------------
void crearVineta() {
  vineta = createImage(width, height, ARGB);
  vineta.loadPixels();
  for (int yy = 0; yy < height; yy++) {
    for (int xx = 0; xx < width; xx++) {
      float dx = (xx - width / 2.0) / (width / 2.0);
      float dy = (yy - height / 2.0) / (height / 2.0);
      float d = sqrt(dx * dx * 0.8 + dy * dy * 0.9);
      float a = constrain(pow(max(0, d - 0.5) / 0.8, 1.6), 0, 1) * 150;
      vineta.pixels[yy * width + xx] = color(0, 0, 0, a);
    }
  }
  vineta.updatePixels();
}

void tinteHora() {
  boolean adentro = scene == 27 || (esCaminable(scene) && lugares.get(scene).interior);
  if (!adentro) {
    float h = (relojJuego / 60.0) % 24;
    float atardecer = (h >= 16.5 && h < 19.5) ? sin(map(h, 16.5, 19.5, 0, PI)) : 0;
    float noche = nivelNoche();
    noStroke();
    if (atardecer > 0) {
      fill(255, 120, 40, 34 * atardecer);
      rect(0, 0, width, height);
    }
    if (noche > 0) {
      fill(10, 20, 70, 70 * noche);
      rect(0, 0, width, height);
    }
  }
  image(vineta, 0, 0);
}

void polvoAlCaminar() {
  if (ultimoX >= 0 && (abs(x - ultimoX) > 0.5 || abs(y - ultimoY) > 0.5) && frameCount % 5 == 0) {
    agregarParticula(new Particula(x + 50 + random(-12, 12), y + 46, random(-0.4, 0.4), random(-0.6, -0.2), 26, random(5, 9), color(200, 190, 210), 5));
  }
  ultimoX = x;
  ultimoY = y;
}

String[] cantos = {"Queremos la verdad!", "Fuera bulos!", "Y la fuente?", "Nova despierta!", "Transparencia!", "#NovaDecide", "Pruebas, no chismes!"};

void generarAmbiente() {
  if (esBarrio(scene)) {
    // llovizna con charcos
    for (int i = 0; i < 2; i++) {
      agregarParticula(new Particula(random(-60, width), random(-20, 0), 2.5, random(10, 13), 55, 1.1, color(170, 190, 255), 1));
    }
    if (random(1) < 0.12) agregarParticula(new Particula(random(width), random(215, height), 0, 0, 36, random(8, 16), color(190, 210, 255), 7));
  } else if (esColegio(scene) && scene != 27) {
    if (random(1) < 0.06) {
      agregarParticula(new Particula(random(width), -10, random(0.3, 1.2), random(0.6, 1.3), 520, random(7, 11), random(1) < 0.5 ? color(230, 150, 60) : color(200, 90, 60), 2));
    }
  } else if (scene == 27) {
    if (frameCount % 7 == 0) {
      float[][] tazas = {{325, 200}, {630, 300}, {470, 165}};
      float[] t = tazas[int(random(tazas.length))];
      agregarParticula(new Particula(t[0] + random(-5, 5), t[1], random(-0.2, 0.2), -0.6, 70, 14, color(255), 5));
    }
  } else if (scene == 8 || scene == 24) {
    if (random(1) < 0.05) {
      Particula p = new Particula(random(width), -10, random(-0.5, 0.5), random(0.6, 1.2), 500, 9, random(1) < 0.5 ? color(255) : neonAmarillo, 3);
      p.giro = random(-0.05, 0.05);
      agregarParticula(p);
    }
    if (!hablando && frameCount % 75 == 0) {
      int r = int(random(1, 11));
      float[] o = obstaculos2[r];
      flotantes.add(new TextoFlotante(cantos[int(random(cantos.length))], o[0] + random(o[2]), o[1] + random(o[3]), color(255), 12, 100, true));
    }
  } else if (scene == ESC_PARQUE) {
    if (random(1) < 0.05 + nivelNoche() * 0.12) {
      agregarParticula(new Particula(random(width), random(120, height), random(-0.5, 0.5), random(-0.5, 0.5), random(150, 300), 3, color(220, 255, 120), 6));
    }
    if (frameCount % 2 == 0) {
      Particula p = new Particula(400 + random(-4, 4), 186, random(-1.3, 1.3), random(-3.6, -2.6), 40, 3, color(170, 220, 255), 0);
      p.grav = 0.16;
      agregarParticula(p);
    }
  } else if (scene == ESC_CENTRO) {
    if (random(1) < 0.25) agregarParticula(new Particula(random(width), height + 10, 0, random(-1.5, -0.6), random(120, 260), random(9, 14), random(1) < 0.5 ? neonCian : neonVerde, 4));
  } else if (esCaminable(scene)) {
    ambienteLugar(lugares.get(scene));
  }
}

void vigilarEstadisticas() {
  viralidad = constrain(viralidad, 0, 100);
  confiabilidad = constrain(confiabilidad, 0, 100);
  impacto = constrain(impacto, 0, 100);
  float dv = viralidad - prevViral, dc = confiabilidad - prevConf, di = impacto - prevImp;
  if (abs(dv) + abs(dc) + abs(di) > 0.01) {
    decisionesTomadas++;
    float yy = height * 0.36;
    if (abs(dv) > 0.01) flotar(signo(dv) + " Viralidad", width / 2 - 170, yy, neonRosa);
    if (abs(dc) > 0.01) flotar(signo(dc) + " Confiabilidad", width / 2, yy - 24, neonCian);
    if (abs(di) > 0.01) flotar(signo(di) + " Impacto", width / 2 + 170, yy, neonAmarillo);
    sacudida = max(sacudida, 6);
    boolean buena = dc > 0 || di > 0;
    colorDestello = buena ? neonCian : neonRosa;
    destello = 60;
    chispas(width / 2, yy, buena ? neonCian : neonRosa, 40);
  }
  prevViral = viralidad;
  prevConf = confiabilidad;
  prevImp = impacto;
  hudV = lerp(hudV, viralidad, 0.08);
  hudC = lerp(hudC, confiabilidad, 0.08);
  hudI = lerp(hudI, impacto, 0.08);
}

void llegaNotificacion() {
  proximaNotif = int(random(1500, 2600));
  if (feedVisibles < feed.length) {
    feedVisibles++;
    notifPendientes++;
    String[] p = feed[feedVisibles - 1];
    avisar("Conecta  -  " + p[0], recortar(p[1], 70), neonRosa);
  } else {
    avisar("NOVA IA", consejosNova[int(random(consejosNova.length))], neonCian);
  }
}

// ------------------------------------- HUD -------------------------------------
void barraMini(String lab, float mostrado, float real, float bx, float by, color c) {
  textFont(fuenteUI);
  textSize(10);
  fill(200);
  textAlign(LEFT, CENTER);
  text(lab, bx, by + 3);
  fill(40, 36, 60);
  rect(bx + 30, by, 120, 8, 4);
  fill(c);
  rect(bx + 30, by, 120 * constrain(mostrado, 0, 100) / 100.0, 8, 4);
  fill(255);
  textAlign(RIGHT, CENTER);
  text(int(real), bx + 176, by + 3);
}

void dibujarHUD() {
  float px = 598, py = 8;
  noStroke();
  fill(8, 6, 24, 200);
  rect(px, py, 194, 60, 10);
  stroke(neonMorado, 160);
  strokeWeight(1);
  noFill();
  rect(px, py, 194, 60, 10);
  noStroke();
  barraMini("VIR", hudV, viralidad, px + 10, py + 10, neonRosa);
  barraMini("CON", hudC, confiabilidad, px + 10, py + 27, neonCian);
  barraMini("IMP", hudI, impacto, px + 10, py + 44, neonAmarillo);

  boolean s = encima(552, 8, 40, 60);
  fill(8, 6, 24, 200);
  rect(552, 8, 40, 60, 10);
  stroke(s ? neonCian : neonMorado, s ? 255 : 160);
  noFill();
  rect(552, 8, 40, 60, 10);
  noStroke();
  iconoCelular(572, 32, 0.9, notifPendientes > 0 && frameCount % 50 < 12);
  fill(200);
  textFont(fuenteUI);
  textSize(10);
  textAlign(CENTER, CENTER);
  text("[P]", 572, 58);
  if (notifPendientes > 0) {
    fill(neonRojo);
    ellipse(590, 12, 17, 17);
    fill(255);
    text(notifPendientes, 590, 11);
  }
  textAlign(RIGHT, CENTER);
  textSize(11);
  fill(220, 220, 255, 210);
  text(textoHora() + (esDeNoche() ? "  -  noche" : ""), 790, 78);
}

void dibujarBanner() {
  if (bannerVida <= 0) return;
  if (!pausaAbierta) bannerVida--;
  float a = constrain(bannerVida / 30.0, 0, 1) * constrain((170 - bannerVida) / 15.0, 0, 1);
  textFont(fuenteUI);
  textSize(17);
  float w = textWidth(bannerTexto) + 70;
  float bx = width / 2 - w / 2, by = 78;
  noStroke();
  fill(8, 6, 22, 200 * a);
  rect(bx, by, w, 34, 17);
  stroke(neonCian, 200 * a);
  strokeWeight(1.5);
  noFill();
  rect(bx, by, w, 34, 17);
  noStroke();
  fill(neonCian, 255 * a);
  ellipse(bx + 18, by + 17, 7, 7);
  ellipse(bx + w - 18, by + 17, 7, 7);
  fill(255, 255 * a);
  textAlign(CENTER, CENTER);
  text(bannerTexto, width / 2, by + 16);
}

// "E" encima de los personajes del barrio y brillitos en los objetos que se pueden revisar
float[][] objetosDelBarrio(int s) {
  // {x visual, y visual, zona x0, x1, y0, y1} (las zonas son las mismas que usa keyPressed)
  if (s == 15) return new float[][] {{625, 330, 500, 650, 250, 350}};
  if (s == 20) return new float[][] {{210, 352, 100, 220, 280, 380}};
  if (s == 21) return new float[][] {{665, 360, 550, 680, 280, 380}};
  if (s == 16) return new float[][] {{610, 335, 500, 620, 250, 350}};
  if (s == 22) return new float[][] {{205, 175, 100, 220, 100, 200}};
  if (s == 23) return new float[][] {{665, 185, 550, 680, 100, 200}};
  if (s == 18) return new float[][] {{210, 190, 100, 220, 100, 220}};
  if (s == 19) return new float[][] {{625, 195, 500, 650, 100, 220}};
  if (s == 5) return new float[][] {{130, 370, 50, 150, 320, 430}, {700, 370, 620, 720, 320, 430}};
  return null;
}

void pistasInteraccion() {
  if (pausaAbierta || telefonoAbierto) return;
  if (scene == 17) {   // la puerta del colegio de la Calle 4 brilla para que se vea que se puede entrar
    float b = 0.5 + 0.5 * sin(frameCount * 0.08);
    noStroke();
    for (int i = 4; i >= 1; i--) {
      fill(neonCian, 10 + 8 * b);
      rect(383 - 30 - i * 6, 70 - i * 6, 60 + i * 12, 56 + i * 12, 8);
    }
    flechaSalida(383, 150 - sin(frameCount * 0.1) * 4, 0, "Entrar al colegio");
  }
  if (!esBarrio(scene)) return;
  float cx = -1, cy = -1;
  if (scene == 5) { cx = 301; cy = 394; }
  else if (scene == 18) { cx = 292; cy = 369; }
  else if (scene == 15 || scene == 16) { cx = 205; cy = 205; }
  else if (scene >= 19 && scene <= 23) { cx = 400; cy = 250; }
  boolean menuAbierto = (scene == 19 && md1) || (scene == 21 && md2) || (scene == 23 && md3);
  if (cx > 0 && dist(x, y, cx, cy) < 80 && !menuAbierto && !(mostrarDialogo && scene != 5)) teclaFlotante("E", cx, cy - 70);
  float[][] objs = objetosDelBarrio(scene);
  if (objs == null) return;
  for (float[] o : objs) {
    destelloObj(o[0], o[1] - 34);
    if (x >= o[2] && x <= o[3] && y >= o[4] && y <= o[5] && !menuAbierto) teclaFlotante("E", o[0], o[1] - 62);
  }
}

// ------------------------------------- PAUSA -------------------------------------
String[] opcionesPausa = {"Continuar", "Telefono", "Ir al mapa", "Como jugar", "Menu principal"};

void dibujarPausa() {
  noStroke();
  fill(5, 3, 15, 205);
  rect(0, 0, width, height);
  tituloNeon("PAUSA", width / 2, 95, 54, neonCian);
  for (int i = 0; i < opcionesPausa.length; i++) {
    botonNeon(opcionesPausa[i], width / 2 - 130, 150 + i * 56, 260, 44, i == 4 ? neonRosa : neonCian, false);
  }
  textFont(fuenteUI);
  textSize(12);
  fill(180);
  textAlign(CENTER, CENTER);
  text("Viralidad " + int(viralidad) + "   -   Confiabilidad " + int(confiabilidad) + "   -   Impacto " + int(impacto) + "   -   Logros " + contarLogros() + "/" + logros.length, width / 2, 455);
}

void clickPausa() {
  for (int i = 0; i < opcionesPausa.length; i++) {
    if (encima(width / 2 - 130, 150 + i * 56, 260, 44)) {
      pausaAbierta = false;
      if (i == 1) abrirTelefono();
      else if (i == 2) {
        CerrarDialogo();
        cerrarCharla();
        scene = 1;
      } else if (i == 3) {
        regresoAyuda = scene;
        scene = ESC_COMO_JUGAR;
      } else if (i == 4) {
        CerrarDialogo();
        cerrarCharla();
        scene = 0;
      }
      return;
    }
  }
}
