// =====================================================================================
//  CASA.pde -> STAR QUEST: tu cuarto y las cinematicas (con el ambiente de Red Quest)
//   - Cada dia empiezas despertando en tu cama. Desde la puerta sales a Nova.
//   - De noche vuelves a casa y duermes en la cama (si te faltan conversaciones, pasan sin ti).
//   - En el cuarto: armario (tu ropa), estante (tu coleccion), TV (Nova Noticias),
//     escritorio (tus notas) y la ventana (de noche... alguien mira desde afuera).
//   - Cinematicas: la apertura (Nova, @chismes_11B, Shawn, Sofi) y la tarjeta de cada dia.
//  Escenas: 78 tu casa, 79 cinematica.
// =====================================================================================

final int ESC_CASA = 78;
final int ESC_CINE_RQ = 79;

boolean partidaEmpezada = false;
boolean confirmarDormir = false;
int clicsVentana = 0;

// ------------------------------------- EL CUARTO -------------------------------------
// el mapa del cuarto de Red Quest (cada letra es una baldosa de 40x40)
String[] mapaCasa = {
  "###########VV#######",
  "#YY..vv..RR...XXX.p#",
  "#YY......RR...XXX..#",
  "#..................#",
  "#..................#",
  "#.....oooooooo.....#",
  "#.....oooooooo.....#",
  "#..................#",
  "#.UU...............#",
  "#.................p#",
  "#########SS#########"
};
final float CASA_OY = 40;   // el cuarto empieza en y = 40

void registrarCasa() {
  Lugar c = new Lugar(78, "Tu casa");
  c.interior = true;
  c.yMin = 118;
  c.obs = new float[][] {
    {0, 0, 40, 500}, {760, 0, 40, 500},                 // paredes de los lados
    {0, 440, 360, 60}, {440, 440, 360, 60},             // pared de abajo (menos la puerta)
    {40, 80, 80, 80}, {200, 80, 80, 40}, {360, 80, 80, 80}, {560, 80, 120, 80}, {80, 360, 80, 40}
  };
  c.puerta(2, 1, "Salir a Nova", 360, 440);
  c.agregar(objetoCasa(85, 178, "Cama"));
  c.agregar(objetoCasa(240, 160, "TV"));
  c.agregar(objetoCasa(400, 178, "Armario"));
  c.agregar(objetoCasa(482, 150, "Ventana"));
  c.agregar(objetoCasa(620, 178, "Estante"));
  c.agregar(objetoCasa(120, 420, "Escritorio"));
  lugares.put(78, c);
}

Interactivo objetoCasa(float ix, float iy, String n) {
  Interactivo it = new Interactivo(ix, iy, n, 1);
  it.frases = new String[] {""};
  return it;
}

// una baldosa del cuarto con medidas de Red Quest (16 px por baldosa, aqui 40 px: x2.5)
void rp(int tx, int ty, float x, float y, float w, float h) {
  rect(tx * 40 + x * 2.5, CASA_OY + ty * 40 + y * 2.5, w * 2.5, h * 2.5);
}

color colorVidrioCasa() {
  float h = (relojJuego / 60.0) % 24;
  if (momento == 3 || h >= 20 || h < 6) return #142050;
  if (h >= 17) return #FF9A5A;
  return #9FD3FF;
}

void fondoCasa() {
  background(#101018);
  noStroke();
  color muro = #A7B6D9, piso = #C9A27E, linea = #A9835E;
  for (int ty = 0; ty < mapaCasa.length; ty++) {
    for (int tx = 0; tx < 20; tx++) {
      char c = mapaCasa[ty].charAt(tx);
      // piso
      fill(piso);
      rp(tx, ty, 0, 0, 16, 16);
      fill(linea);
      rp(tx, ty, 0, 15, 16, 1);
      rp(tx, ty, (ty % 2) * 8, 0, 1, 16);
      if (c == '#') {
        fill(muro);
        rp(tx, ty, 0, 0, 16, 16);
        fill(0, 40);
        rp(tx, ty, 0, 12, 16, 4);
        fill(255, 40);
        rp(tx, ty, 0, 6, 16, 1);
      } else if (c == 'V') {   // ventana
        fill(muro);
        rp(tx, ty, 0, 0, 16, 16);
        fill(#5A4632);
        rp(tx, ty, 1, 1, 14, 13);
        fill(colorVidrioCasa());
        rp(tx, ty, 2, 2, 12, 11);
        fill(#5A4632);
        rp(tx, ty, 7, 2, 1, 11);
        if (momento == 3) {   // estrellas
          fill(255, 200);
          rp(tx, ty, 4 + tx % 3, 4, 1, 1);
          rp(tx, ty, 10, 7 + tx % 2, 1, 1);
        }
      } else if (c == 'S') {   // puerta
        fill(muro);
        rp(tx, ty, 0, 0, 16, 16);
        fill(#7A4E2A);
        rp(tx, ty, 2, 1, 12, 15);
        fill(#5A3518);
        rp(tx, ty, 2, 1, 12, 1);
        rp(tx, ty, 8, 1, 1, 15);
        fill(#E0C060);
        rp(tx, ty, 5, 9, 1, 2);
        rp(tx, ty, 10, 9, 1, 2);
      } else if (c == 'Y') {   // cama
        fill(#6B4423);
        rp(tx, ty, 0, 0, 16, 16);
        fill(#4F79C7);
        rp(tx, ty, 1, 1, 15, 15);
        if (ty == 1) {
          fill(255);
          rp(tx, ty, 2, 2, 13, 6);
        }
      } else if (c == 'v') {   // TV
        fill(#2B2B33);
        rp(tx, ty, 0, 2, 16, 10);
        color[] cs = {#FF5A78, #FFC846, #4856E8};
        fill(cs[(frameCount / 30 + tx) % 3]);
        rp(tx, ty, 1, 3, 14, 8);
        fill(#6B4220);
        rp(tx, ty, 3, 12, 10, 3);
      } else if (c == 'R') {   // armario
        fill(#7A4E2A);
        rp(tx, ty, 0, 0, 16, 16);
        fill(#5A3518);
        rp(tx, ty, 15, 0, 1, 16);
        fill(#E0C060);
        rp(tx, ty, 11 - (tx % 2) * 6, 8, 2, 2);
      } else if (c == 'X') {   // estante con la coleccion
        fill(#6B4423);
        rp(tx, ty, 0, 0, 16, 16);
        fill(#4E3119);
        rp(tx, ty, 0, 7, 16, 1);
        fill(#F2C14E);
        rp(tx, ty, 3, 2, 3, 4);
        rp(tx, ty, 10, 10, 3, 4);
        fill(#9D8CD9);
        rp(tx, ty, 10, 2, 3, 4);
      } else if (c == 'o') {   // alfombra
        fill(#B5483F);
        rp(tx, ty, 0, 0, 16, 16);
        fill(#D9A441);
        if ((tx + ty) % 2 == 0) rp(tx, ty, 6, 6, 4, 4);
      } else if (c == 'U') {   // escritorio
        fill(#A9743F);
        rp(tx, ty, 0, 3, 16, 6);
        fill(#6B4220);
        rp(tx, ty, 0, 9, 16, 2);
        rp(tx, ty, 2 + (tx % 2) * 10, 11, 2, 4);
        if (tx == 2) {   // un cuaderno
          fill(240);
          rp(tx, ty, 4, 1, 7, 3);
        }
      } else if (c == 'p') {   // planta
        fill(#A0522D);
        rp(tx, ty, 5, 10, 6, 5);
        fill(#2F7D3A);
        rp(tx, ty, 3, 3, 10, 7);
        fill(#46A04F);
        rp(tx, ty, 5, 1, 5, 4);
      }
    }
  }
  // de noche: lampara tenue
  if (momento == 3) {
    fill(10, 14, 40, 90);
    rect(0, 0, width, height);
    fill(255, 210, 140, 22);
    ellipse(120, 420, 260, 160);
    // y a veces... alguien en la ventana
    if (dia <= 1 && !tieneMensajeShawn && frameCount % 400 < 220) {
      fill(225, 232, 250, 150);
      ellipse(480, CASA_OY + 22, 14, 16);
      rect(474, CASA_OY + 28, 12, 10);
    }
  }
}

// ------------------------------------- OBJETOS DEL CUARTO -------------------------------------
String[][] noticiasTV = {
  {"Nova Noticias: crece la desconfianza en Conecta. 'Ya no se que creer', dice una vecina.", "Nova Noticias: @chismes_11B vuelve a ser tendencia. Nadie sabe quien esta detras."},
  {"Nova Noticias: las elecciones del Consejo de Juventud siguen en pie. Se espera una participacion record.", "Nova Noticias: expertos recomiendan revisar quien publica, cuando y con que pruebas."},
  {"Nova Noticias: jovenes de todo Nova organizan jornadas para inscribirse a votar.", "Nova Noticias: un dia tranquilo en Conecta. Hasta los memes son amables."}
};

boolean interactuarCasa(Interactivo it) {
  if (scene != ESC_CASA) return false;
  String n = it.nombre;
  if (n.equals("Cama")) usarCama();
  else if (n.equals("TV")) decirCasa("TV", noticiasTV[nivelAmbiente()][int(random(2))]);
  else if (n.equals("Armario")) usarArmario();
  else if (n.equals("Estante")) {
    decirCasa("Tu coleccion", "Pruebas: " + contarPruebas() + "/3   -   Insignias: " + contarBienSec() + "/6   -   Logros: " + contarLogros() + "/" + logros.length + ". (Las ves en el celular, app Pruebas)");
    abrirTelefono();
    telApp = 9;
  } else if (n.equals("Escritorio")) decirCasa("Tus notas", "Lo que sigue: " + textoObjetivo() + ".");
  else if (n.equals("Ventana")) usarVentana();
  return true;
}

int contarPruebas() {
  int n = 0;
  for (boolean b : tienePrueba) if (b) n++;
  return n;
}

void decirCasa(String quien, String t) {
  abrirCharla(new Charla(quien, new String[] {t}));
}

void usarCama() {
  if (dia >= 3) {
    decirCasa("Tu", "Hoy son las elecciones. Nada de volver a dormir: Sofi me espera en la Plaza de la Votacion.");
    return;
  }
  if (momento == 3) {
    confirmarDormir = false;
    irAFinDelDia();
    return;
  }
  int faltan = 3 - situacionesHoy;
  if (!confirmarDormir) {
    confirmarDormir = true;
    decirCasa("Tu", "Todavia me faltan " + faltan + " conversaciones importantes. Si duermo, pasaran sin mi (-5 de confiabilidad y -3 con Sofi cada una). Toca la cama otra vez para dormir igual.");
    return;
  }
  // dormir igual: las conversaciones pasan sin ti
  confirmarDormir = false;
  for (int s = dia * 3 + situacionesHoy; s < dia * 3 + 3; s++) {
    sitResuelta[s] = true;
    sitElegida[s] = -1;
  }
  sinMonedasPorCambio = true;
  confiabilidad = max(0, confiabilidad - 5 * faltan);
  cambiarRelacionSofi(-3 * faltan);
  for (int k = 0; k < faltan; k++) sumarCulpa();
  situacionesHoy = 3;
  momento = 3;
  irAFinDelDia();
}

void usarArmario() {
  int[] opciones = new int[tengoRopa.length + 1];
  int n = 0;
  opciones[n++] = -1;
  for (int i = 0; i < tengoRopa.length; i++) if (tengoRopa[i]) opciones[n++] = i;
  if (n == 1) {
    decirCasa("Armario", "Solo tienes tu ropa de siempre. En la Tienda NOVA venden ropa (y alguna se gana ayudando).");
    return;
  }
  int actualIdx = 0;
  for (int k = 0; k < n; k++) if (opciones[k] == ropaPuesta) actualIdx = k;
  ropaPuesta = opciones[(actualIdx + 1) % n];
  guardarDatos();
  decirCasa("Armario", ropaPuesta < 0 ? "Te pusiste tu ropa de siempre." : "Te pusiste: " + nombreRopa[ropaPuesta] + ". (Toca el armario otra vez para cambiar)");
  chispas(x + 50, y + 20, ropaPuesta < 0 ? color(255) : colorRopa[ropaPuesta], 20);
}

void usarVentana() {
  if (momento == 3 && dia <= 1 && !tieneMensajeShawn) {
    clicsVentana++;
    if (clicsVentana >= 3) {
      clicsVentana = 0;
      hablarConShawn(npcShawn);   // el mismo encuentro del Callejon (Ruta.pde)
    } else {
      decirCasa("Ventana", clicsVentana == 1 ? "Esta oscuro afuera. Por un segundo crees ver a alguien parado en la calle..." : "Ahi esta otra vez. Palido, quieto, mirando hacia tu ventana.");
    }
    return;
  }
  if (momento == 3) decirCasa("Ventana", "Nova de noche: en cada ventana, la luz azul de un celular.");
  else decirCasa("Ventana", "Desde aqui se ve todo el barrio. Hoy es " + nombreDia[dia] + ".");
}

// entrar a la casa (desde el mapa o al despertar)
void irACasa(boolean enLaCama) {
  pararMovimiento();
  cerrarCharla();
  CerrarDialogo();
  confirmarDormir = false;
  clicsVentana = 0;
  if (enLaCama) {
    x = 100;
    y = 140;
    actual = abajo;
  } else {
    x = 350;
    y = 382;
    actual = arriba;
  }
  scene = ESC_CASA;
}

void despertar() {
  irACasa(true);
  String[][] lineas = {
    {"Tu: ...El celular otra vez. 47 notificaciones.", "Tu: Sofi me escribio a las 6:12. Hoy se inscribe oficialmente al Consejo de Juventud.", "Tu: Bueno. A levantarse. La puerta esta abajo."},
    {"Tu: Martes. Anoche casi no dormi pensando en lo de ayer.", "Tu: Hoy toca el barrio. Ojala no haya otro rumor."},
    {"Tu: Miercoles. Ultimo dia de campaña.", "Tu: Mañana se vota. Todo lo que pase hoy cuenta."},
    {"Tu: Jueves. Hoy se vota.", "Tu: Sofi me espera en la Plaza de la Votacion."}
  };
  abrirCharla(new Charla("Tu", lineas[min(dia, 3)]));
}

// ------------------------------------- CINEMATICAS (estilo Red Quest) -------------------------------------
int cinePlano = 0;
float cineT = 0, cineLetras = 0;
boolean cineApertura = true;   // true = la apertura completa, false = solo la tarjeta del dia

String[] lineasApertura = {
  "Nova. Una ciudad donde todo pasa primero por Conecta.",
  "Aqui un rumor llega mas rapido que la verdad. Y nadie quiere quedarse por fuera.",
  "Hace semanas, una cuenta anonima publica los secretos de todos: @chismes_11B. Nadie sabe quien es.",
  "Hace dos años, Shawn dejo de venir al colegio. Su ultimo post decia: \"alguien va a decir algo?\"",
  "Sofi, tu mejor amiga, se lanzo al Consejo de Juventud. Las elecciones son el jueves.",
  "Faltan tres dias. Y tu celular no deja de sonar.",
  "",
  ""
};
String[] nombreEscenario = {"EL COLEGIO", "EL BARRIO", "LA CIUDAD", "LA ELECCION"};
String[] descripcionDia = {
  "En el colegio todos usan Conecta para comunicarse, compartir fotos, opinar y organizar actividades.",
  "En el barrio, Conecta sirve para informarse y organizar planes. Pero un rumor puede volverse viral en minutos.",
  "Se acercan las elecciones del Consejo de Juventud y Sofi es candidata. Una publicacion puede ayudarla o destruirla.",
  "Hoy Nova vota. Todo lo que compartiste, callaste o defendiste ya esta hecho."
};

void empezarCineApertura() {
  cineApertura = true;
  cinePlano = 0;
  cineT = 0;
  cineLetras = 0;
  partidaEmpezada = true;
  pararMovimiento();
  scene = ESC_CINE_RQ;
}

void empezarCineDia() {
  cineApertura = false;
  cinePlano = 7;
  cineT = 0;
  cineLetras = 0;
  pararMovimiento();
  scene = ESC_CINE_RQ;
}

String lineaCine() {
  return cinePlano < lineasApertura.length ? lineasApertura[cinePlano] : "";
}

void siguientePlano() {
  if (cinePlano >= 7) {
    terminarCine();
    return;
  }
  cinePlano++;
  cineT = 0;
  cineLetras = 0;
}

void terminarCine() {
  introVista = true;
  guardarDatos();
  despertar();
}

void saltarCineRQ() {
  if (cinePlano < 7) {
    cinePlano = 7;
    cineT = 0;
    cineLetras = 0;
  } else terminarCine();
}

// pixeles grandes (como Red Quest): 1 pixel = 5x5
void pxc(float px, float py, float pw, float ph) {
  rect(px * 5, 50 + py * 5, pw * 5, ph * 5);
}

void dibujarCineRQ() {
  if (!pausaAbierta) cineT++;
  background(#101018);
  noStroke();
  float a = constrain(cineT / 25.0, 0, 1);
  switch (cinePlano) {
  case 0:
    cineCiudad();
    break;
  case 1:
    cineCaras();
    break;
  case 2:
    cineChismes();
    break;
  case 3:
    cineShawn();
    break;
  case 4:
    cineSofi();
    break;
  case 5:
    cineCuarto();
    break;
  case 6:
    cineTitulo();
    break;
  case 7:
    cineTarjetaDia();
    break;
  }
  // franjas de cine
  fill(0);
  rect(0, 0, width, 50);
  rect(0, height - 50, width, 50);
  // el texto, letra por letra
  String t = lineaCine();
  if (t.length() > 0) {
    if (!pausaAbierta) cineLetras = min(cineLetras + 0.9, t.length());
    if (cineLetras < t.length()) sonarVoz("narrador");
    fill(10, 10, 25, 215);
    rect(80, 382, 640, 60, 10);
    fill(235);
    textFont(fuenteUI);
    textSize(17);
    textAlign(CENTER, CENTER);
    text(t.substring(0, int(cineLetras)), 100, 382, 600, 60);
    if (cineLetras >= t.length() && cineT > 60 + t.length() * 1.1 + 120) siguientePlano();
  } else if (cinePlano == 6 && cineT > 170) siguientePlano();
  // fundido de entrada
  fill(#101018, 255 * (1 - a));
  rect(0, 0, width, height);
  fill(120);
  textFont(fuenteUI);
  textSize(11);
  textAlign(RIGHT, CENTER);
  text(cinePlano < 7 ? "clic / ENTER: siguiente     ESC: saltar" : "", width - 14, height - 25);
}

void cineCiudad() {
  // cielo con estrellas y edificios con ventanas encendidas
  for (int i = 0; i < 60; i++) {
    fill(255, 120 + 100 * sin(frameCount * 0.05 + i));
    rect(hsh(i * 3.3) * width, 55 + hsh(i * 9.1) * 120, 2, 2);
  }
  fill(255, 240, 200);
  pxc(130, 6, 8, 8);
  fill(#101018);
  pxc(133, 5, 8, 8);
  for (int i = 0; i < 18; i++) {
    float bx = i * 9 - 2, bh = 18 + hsh(i * 2.3) * 30;
    fill(#1B1B2E);
    pxc(bx, 66 - bh, 8, bh);
    for (int k = 0; k < bh / 4; k++) {
      boolean luz = hsh(i * 17 + k) > 0.45;
      fill(luz ? (hsh(i + k) > 0.5 ? color(#9FD3FF) : color(#FFC846)) : color(#24243A));
      pxc(bx + 2 + (k % 2) * 3, 66 - bh + 2 + (k / 2) * 4, 2, 2);
    }
  }
  fill(#0B0B14);
  pxc(0, 66, 160, 2);
}

void cineCaras() {
  // filas de personas iluminadas por el celular
  for (int f = 0; f < 2; f++) {
    for (int i = 0; i < 7; i++) {
      float cx = 12 + i * 22 + f * 11, cy = 22 + f * 26;
      float brillo = 0.6 + 0.4 * sin(frameCount * 0.07 + i + f * 3);
      fill(#2A2A3A);
      pxc(cx - 5, cy + 8, 10, 12);
      fill(lerpColor(color(#202030), color(#9FD3FF), brillo * 0.6));
      pxc(cx - 4, cy, 8, 8);
      fill(#101018);
      pxc(cx - 2, cy + 3, 1, 1);
      pxc(cx + 1, cy + 3, 1, 1);
      fill(lerpColor(color(#4856E8), color(#DDF2FF), brillo));
      pxc(cx - 2, cy + 11, 4, 6);
    }
  }
}

void cineChismes() {
  // el perfil de @chismes_11B en un celular
  fill(#191926);
  pxc(52, 2, 56, 62);
  fill(#08080F);
  pxc(54, 5, 52, 56);
  fill(#FF5A78);
  pxc(56, 7, 48, 7);
  fill(255);
  textFont(fuenteUI);
  textSize(18);
  textAlign(CENTER, CENTER);
  text("Conecta", 400, 50 + 10.5 * 5);
  fill(#2A2A3A);
  pxc(74, 17, 12, 12);
  fill(#8A8A98);
  pxc(78, 19, 4, 4);
  pxc(76, 23, 8, 4);
  fill(235);
  textSize(16);
  text("@chismes_11B", 400, 50 + 32 * 5);
  fill(#FF5A78);
  textSize(12);
  text("4.812 seguidores  -  0 siguiendo", 400, 50 + 36 * 5);
  for (int k = 0; k < 3; k++) {
    fill(#191926);
    pxc(58, 40 + k * 7, 44, 6);
    fill(#3A3A4A);
    pxc(60, 41 + k * 7, 30 - k * 6, 1);
    pxc(60, 43 + k * 7, 38 - k * 4, 1);
  }
}

void cineShawn() {
  // una banca vacia con un nombre tallado... y alguien que ya no esta
  fill(#1B1B2E);
  pxc(0, 52, 160, 16);
  fill(#6B4423);
  pxc(40, 38, 70, 4);
  pxc(40, 44, 70, 3);
  pxc(44, 47, 3, 6);
  pxc(103, 47, 3, 6);
  fill(#C9A27E);
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  text("SHAWN", 75 * 5, 50 + 40 * 5);
  float f = 0.3 + 0.3 * sin(frameCount * 0.04);
  dibujarFantasma(122 * 5, 50 + 50 * 5, f);
}

void cineSofi() {
  // Sofi frente a su cartel de campaña
  fill(#1B1B2E);
  pxc(0, 56, 160, 12);
  fill(#F2C230);
  pxc(84, 10, 44, 30);
  fill(#E85D75);
  pxc(86, 12, 40, 26);
  fill(255);
  textFont(fuenteUI);
  textSize(17);
  textAlign(CENTER, CENTER);
  text("SOFI", 106 * 5, 50 + 20 * 5);
  textSize(10);
  text("CONSEJO DE JUVENTUD", 106 * 5, 50 + 28 * 5);
  // Sofi en pixeles (pelo, cara, chaqueta y pantalon de Red Quest)
  float b = sin(frameCount * 0.05) * 0.5;
  fill(#4A2C1A);
  pxc(52, 22 + b, 12, 6);
  pxc(51, 26 + b, 3, 10);
  pxc(62, 26 + b, 3, 10);
  fill(#F1C9A5);
  pxc(53, 26 + b, 10, 9);
  fill(#101018);
  pxc(55, 29 + b, 2, 2);
  pxc(59, 29 + b, 2, 2);
  fill(#E85D75);
  pxc(51, 35 + b, 14, 12);
  fill(#2D3A5A);
  pxc(52, 47, 5, 9);
  pxc(59, 47, 5, 9);
}

void cineCuarto() {
  // tu cuarto a oscuras, la cama y el celular vibrando
  fill(#1B1F33);
  pxc(0, 0, 160, 68);
  fill(#142050);
  pxc(108, 8, 22, 16);
  fill(#5A4632);
  pxc(118, 8, 1, 16);
  fill(#6B4423);
  pxc(20, 34, 70, 22);
  fill(#2E4C8C);
  pxc(22, 34, 66, 18);
  fill(#8A8FA8);
  pxc(24, 30, 18, 8);
  // el celular en la mesita
  fill(#3A2A20);
  pxc(96, 44, 16, 12);
  float v = (frameCount % 40 < 20) ? 1 : 0;
  fill(#9FD3FF);
  pxc(100 + v, 40, 6, 4);
  fill(#9FD3FF, 40);
  ellipse((103 + v) * 5, 50 + 42 * 5, 120, 70);
}

void cineTitulo() {
  for (int i = 0; i < 50; i++) {
    float tw = 0.5 + 0.5 * sin(frameCount * 0.08 + i);
    fill(255, 220, 120, 200 * tw);
    rect(hsh(i * 5.7) * width, 60 + hsh(i * 2.9) * 320, 2, 2);
  }
  float e = constrain(cineT / 50.0, 0, 1);
  tituloNeon("STAR QUEST", width / 2, 200, 40 + 36 * e, #FFC846);
  fill(200, 255 * e);
  textFont(fuenteUI);
  textSize(15);
  textAlign(CENTER, CENTER);
  text("tres dias. una ciudad. lo que compartes se queda.", width / 2, 270);
}

void cineTarjetaDia() {
  int d = min(dia, 3);
  // el cuarto al amanecer de fondo
  fill(#1B1F33);
  pxc(0, 0, 160, 68);
  fill(lerpColor(color(#142050), color(#FF9A5A), constrain(cineT / 120.0, 0, 1)));
  pxc(132, 8, 22, 16);
  fill(10, 10, 25, 215);
  rect(176, 100, 448, 260, 14);
  fill(#FFC846);
  textFont(fuenteUI);
  textAlign(CENTER, TOP);
  textSize(28);
  text(nombreDia[d] + ": " + nombreEscenario[d], width / 2, 118);
  fill(255);
  textSize(15);
  String extra = d < 3 ? "\n\nHoy hay 3 conversaciones importantes (\"!\"). El tiempo solo avanza cuando hablas con ellas." : "\n\nLas urnas abren en la Plaza de la Votacion.";
  text(descripcionDia[d] + extra, 206, 168, 388, 150);
  botonNeon("COMENZAR", 300, 318, 200, 32, #FFC846, frameCount % 60 < 30);
}

void clickCineRQ() {
  if (cinePlano == 7) {
    if (encima(300, 318, 200, 32) || cineT > 30) terminarCine();
    return;
  }
  String t = lineaCine();
  if (t.length() > 0 && cineLetras < t.length()) cineLetras = t.length();
  else siguientePlano();
}

void teclaCineRQ() {
  if (key == ENTER || key == RETURN || key == ' ') clickCineRQ();
}

// la musica de las cinematicas (Sonido.pde)
int musicaCineRQ() {
  if (cinePlano <= 3) return 0;   // sombrio
  if (cinePlano <= 5) return 3;   // viento
  return 1;
}

// una casita pequeña para el boton "Ir a casa" de dia
void dibujarCasita(float cx, float cy) {
  noStroke();
  fill(#FFC846);
  triangle(cx - 10, cy - 1, cx + 10, cy - 1, cx, cy - 10);
  fill(#E8D5A3);
  rect(cx - 7, cy - 1, 14, 10);
  fill(#7A4E2A);
  rect(cx - 2, cy + 3, 4, 6);
}
