// =====================================================================================
//  ESCENARIOS.pde -> lugares nuevos de Nova
//   45 Parque Central        (caminas, hablas, kiosko arcade, fuente de los deseos)
//   46 Centro NOVA           (la IA de la ciudad, terminales con minijuegos, un robot)
//   47 Nova Noticias EN VIVO (concurso de preguntas)
//   48 Plaza de la Votacion  (dia de elecciones)
//   49 Final                 (4 finales segun tus estadisticas)
//  + el mapa vivo (pines, carros que se mueven) y el sistema de dialogos nuevo
// =====================================================================================

// ------------------------------------- DIALOGOS NUEVOS (con efecto maquina de escribir) -------------------------------------
class Charla {
  String hablante;
  String[] lineas, eleccion, respuestas;
  float[][] efectos;
  String despedida;
  boolean terminada = false;

  Charla(String hablante, String[] lineas) {
    this.hablante = hablante;
    this.lineas = lineas;
  }

  Charla con(String[] eleccion, float[][] efectos, String[] respuestas, String despedida) {
    this.eleccion = eleccion;
    this.efectos = efectos;
    this.respuestas = respuestas;
    this.despedida = despedida;
    return this;
  }
}

Charla charlaActiva = null;
int charlaLinea = 0;
float charlaLetras = 0;
boolean charlaEligiendo = false;
String charlaRespuesta = null;

void abrirCharla(Charla c) {
  charlaActiva = c;
  charlaLinea = 0;
  charlaLetras = 0;
  charlaEligiendo = false;
  charlaRespuesta = null;
  if (c.terminada && c.despedida != null) charlaRespuesta = c.despedida;
  pararMovimiento();
}

String textoCharla() {
  if (charlaRespuesta != null) return charlaRespuesta;
  return charlaActiva.lineas[charlaLinea];
}

void avanzarCharla() {
  if (charlaActiva == null || charlaEligiendo) return;
  String t = textoCharla();
  if (charlaLetras < t.length()) {
    charlaLetras = t.length();
    return;
  }
  if (charlaRespuesta != null) {
    cerrarCharla();
    return;
  }
  charlaLinea++;
  charlaLetras = 0;
  if (charlaLinea >= charlaActiva.lineas.length) {
    charlaLinea = charlaActiva.lineas.length - 1;
    if (charlaActiva.eleccion != null && !charlaActiva.terminada) {
      charlaEligiendo = true;
    } else {
      charlaActiva.terminada = true;
      cerrarCharla();
    }
  }
}

void elegirCharla(int i) {
  if (!charlaEligiendo || i < 0 || i >= charlaActiva.eleccion.length) return;
  float[] e = charlaActiva.efectos[i];
  viralidad += e[0];
  confiabilidad += e[1];
  impacto += e[2];
  charlaRespuesta = charlaActiva.respuestas[i];
  charlaLetras = 0;
  charlaEligiendo = false;
  charlaActiva.terminada = true;
}

void cerrarCharla() {
  charlaActiva = null;
  charlaEligiendo = false;
  charlaRespuesta = null;
}

void dibujarCharla() {
  if (charlaActiva == null) return;
  String t = textoCharla();
  if (charlaLetras < t.length() && !pausaAbierta && !telefonoAbierto) charlaLetras += 1.2;
  float bx = 30, by = 350, bw = 740, bh = 135;
  noStroke();
  fill(8, 6, 22, 238);
  rect(bx, by, bw, bh, 12);
  stroke(neonCian, 200);
  strokeWeight(2);
  noFill();
  rect(bx, by, bw, bh, 12);
  noStroke();
  textFont(fuenteUI);
  textSize(14);
  float nw = textWidth(charlaActiva.hablante) + 30;
  fill(neonCian);
  rect(bx + 20, by - 14, nw, 28, 8);
  fill(10);
  textAlign(LEFT, CENTER);
  text(charlaActiva.hablante, bx + 35, by - 1);
  if (charlaEligiendo) {
    fill(neonAmarillo);
    textSize(15);
    textAlign(LEFT, TOP);
    text("Que decides?   (clic o teclas 1 / 2)", bx + 24, by + 20);
    for (int i = 0; i < charlaActiva.eleccion.length; i++) {
      botonNeon((i + 1) + ".  " + charlaActiva.eleccion[i], bx + 24, by + 46 + i * 40, bw - 48, 34, i == 0 ? neonRosa : neonCian, false);
    }
  } else {
    fill(240);
    textSize(16);
    textAlign(LEFT, TOP);
    text(t.substring(0, min(t.length(), int(charlaLetras))), bx + 24, by + 24, bw - 48, bh - 40);
    if (charlaLetras >= t.length() && frameCount % 40 < 28) {
      fill(neonCian);
      textSize(12);
      textAlign(RIGHT, BOTTOM);
      text("E / ENTER  >", bx + bw - 16, by + bh - 8);
    }
  }
}

void clickCharla() {
  if (charlaEligiendo) {
    for (int i = 0; i < charlaActiva.eleccion.length; i++) {
      if (encima(54, 396 + i * 40, 692, 34)) elegirCharla(i);
    }
  } else {
    avanzarCharla();
  }
}

// ------------------------------------- COSAS CON LAS QUE SE INTERACTUA -------------------------------------
class Interactivo {
  float ix, iy;
  String nombre;
  int tipo;          // 0 persona, 1 objeto, 2 maquina de minijuego, 3 robot
  color ropa = #3C78C8, pelo = #2A1E14;
  float fase;
  Charla charla;
  int destino;
  String[] frases;   // para objetos que dicen algo distinto cada vez
  boolean hablado = false;
  boolean oculto = false;   // true = lo dibuja el fondo (por ejemplo, detras de un mostrador)

  Interactivo(float ix, float iy, String nombre, int tipo) {
    this.ix = ix;
    this.iy = iy;
    this.nombre = nombre;
    this.tipo = tipo;
    fase = random(10);
  }
}

ArrayList<Interactivo> interParque = new ArrayList<Interactivo>();
ArrayList<Interactivo> interCentro = new ArrayList<Interactivo>();
Interactivo cercano = null;
float[][] obsParque = {{338, 200, 124, 66}, {60, 110, 112, 66}, {540, 340, 220, 95}};
float[][] obsCentro = {{350, 240, 100, 40}, {80, 205, 100, 30}, {620, 205, 100, 30}, {80, 375, 100, 30}, {620, 375, 100, 30}};

String[] fortunas = {
  "Lanzas una moneda a la fuente... Tu fortuna: 'Quien verifica dos veces, comparte una vez'.",
  "La moneda brilla al caer. Tu fortuna: 'Un rumor viaja rapido, pero la verdad llega para quedarse'.",
  "Plop. Tu fortuna: 'Hoy evitaras un bulo... si lees mas alla del titular'.",
  "La fuente salpica un poco. Tu fortuna: 'Las cuentas sin foto no traen buena suerte'."
};
String[] frasesEstanque = {
  "Los patos nadan tranquilos. Ninguno tiene Conecta. Se ven felices.",
  "Un pato te mira fijamente. Parece decir: 'y ya verificaste la fuente?'",
  "Hay reflejos de neon en el agua. Nova se ve bonita cuando nadie esta peleando."
};

Interactivo persona(float ix, float iy, String nombre, color ropa, color pelo, Charla ch) {
  Interactivo it = new Interactivo(ix, iy, nombre, 0);
  it.ropa = ropa;
  it.pelo = pelo;
  it.charla = ch;
  return it;
}

Interactivo maquina(float ix, float iy, String nombre, int destino) {
  Interactivo it = new Interactivo(ix, iy, nombre, 2);
  it.destino = destino;
  return it;
}

void prepararEscenarios() {
  interParque.clear();
  interCentro.clear();

  // ---------------- PARQUE ----------------
  interParque.add(maquina(115, 196, "Kiosko Arcade", ESC_ATRAPA));
  Interactivo fuenteDeseos = new Interactivo(400, 290, "Fuente de los deseos", 1);
  fuenteDeseos.frases = fortunas;
  interParque.add(fuenteDeseos);
  interParque.add(persona(560, 236, "Kevin", #FF8C3C, #141414, new Charla("Kevin (influencer)", new String[] {
    "Eyyy! Soy Kevin, 120 mil seguidores en Conecta. Tienes cara de buen extra para mi proximo video.",
    "La idea es epica: uso un filtro que me pone la cara de Ramirez y digo que va a cerrar el colegio. Bum, viral!",
    "Obvio es una 'broma'... aunque no pienso aclararlo. Te animas a grabarlo conmigo?"
  }).con(new String[] {"Grabar el video falso", "Proponer un video explicando los deepfakes"},
    new float[][] {{20, -15, -12}, {6, 10, 12}},
    new String[] {"Kevin: 300 mil vistas en una hora! ...Ups, la gente cree que es real y estan marchando al colegio.",
    "Kevin: 'Como detectar un deepfake'? Suena raro... pero a mis seguidores les encanto. Eres un crack!"},
    "Kevin: No olvides darle like y suscribirte! Jajaja.")));
  interParque.add(persona(160, 314, "Abuela Rosa", #B4648C, #DCDCDC, new Charla("Abuela Rosa", new String[] {
    "Ay, mijo, que bueno verte. Sientate un ratico conmigo en esta banca.",
    "Me llego una cadena al celular: dice que el agua de la fuente del parque esta contaminada.",
    "Dice 'compartelo antes de que lo borren'. Yo no se mucho de esto... la mando al grupo de la familia?"
  }).con(new String[] {"Reenviarla al grupo familiar", "Buscar primero el comunicado del acueducto"},
    new float[][] {{12, -10, -8}, {-4, 12, 8}},
    new String[] {"Rosa: Listo, enviada! ...Ay, ya me respondieron 14 personas asustadas. Y tu prima cancelo el picnic.",
    "Rosa: Mira, el acueducto dice que el agua esta perfecta. Esa cadena era puro cuento! Gracias, mijo."},
    "Rosa: Cuidate mucho. Y abrigate, que en Nova refresca de noche.")));
  interParque.add(persona(255, 440, "Profe Ines", #46A064, #5A3214, new Charla("Profe Ines", new String[] {
    "Hola. Soy la profe Ines, doy Ciencias Sociales en el colegio. Vengo a leer un rato al parque.",
    "Hoy les enseñe a mis estudiantes la 'lectura lateral': cuando ves algo sospechoso, no te quedes en esa pagina.",
    "Abre otra pestaña y busca quien esta detras. Si nadie serio confirma la noticia, desconfia.",
    "Y si quieres practicar, el kiosko arcade de alla arriba tiene un juego para atrapar bulos. Suerte!"
  })));
  Interactivo estanque = new Interactivo(650, 330, "Estanque", 1);
  estanque.frases = frasesEstanque;
  interParque.add(estanque);

  // ---------------- CENTRO NOVA ----------------
  interCentro.add(maquina(130, 262, "Terminal: Caza Bots", ESC_CAZABOTS));
  interCentro.add(maquina(670, 262, "Terminal: Rastreo", ESC_MEMORIA));
  interCentro.add(maquina(130, 432, "Terminal: Verificador", ESC_VERIFICADOR));
  interCentro.add(maquina(670, 432, "Terminal: Manotazo (camara)", ESC_MANOTAZO));
  Interactivo orbe = new Interactivo(400, 300, "NOVA", 1);
  orbe.frases = consejosNova;
  interCentro.add(orbe);
  Interactivo robot = new Interactivo(540, 190, "B-07", 3);
  robot.charla = new Charla("B-07 (bot)", new String[] {
    "BZZT. HOLA, HUMANO. SOY B-07, UNIDAD DE AMPLIFICACION DE MENSAJES. 0% MALDAD. 100% ENTUSIASMO.",
    "MI JEFE ANONIMO PAGA POR CADA CUENTA QUE PUBLIQUE '#FUERARAMIREZ' 400 VECES AL DIA.",
    "TE OFREZCO 50 CUENTAS FALSAS. SOLO DEBES PRESIONAR 'PUBLICAR' MUCHAS VECES. ACEPTAS?"
  }).con(new String[] {"Unirme a la granja de bots", "Reportar la granja de bots a Ada"},
    new float[][] {{22, -18, -14}, {-6, 12, 10}},
    new String[] {"B-07: EXCELENTE. TENDENCIA ALCANZADA. CONFIANZA CIUDADANA: ERROR 404 NOT FOUND.",
    "B-07: ...REPORTADO. MIS 50 CUENTAS HAN SIDO SUSPENDIDAS. APAGANDO... ADIOS, HUMANO HONESTO. BZZT."},
    "B-07: BZZT. ESTOY EN MODO AHORRO DE ENERGIA.");
  interCentro.add(robot);
  interCentro.add(persona(520, 446, "Ingeniera Ada", #505064, #141414, new Charla("Ingeniera Ada", new String[] {
    "Bienvenido al Centro NOVA. Soy Ada, del equipo que entreno a la IA de la ciudad.",
    "NOVA rastreo todo: la foto de Dani, el rumor del parque y el titular de Ramirez nacieron de la misma bola de nieve.",
    "El concejo nos pide una decision: podemos hacer que NOVA borre automaticamente todo lo que parezca rumor...",
    "...o que NOVA solo agregue etiquetas con contexto y fuentes, y que la gente decida. Tu que recomiendas?"
  }).con(new String[] {"Que NOVA borre todo lo sospechoso", "Que NOVA etiquete con contexto y fuentes"},
    new float[][] {{-5, -6, -4}, {0, 12, 10}},
    new String[] {"Ada: Lo intentamos... y NOVA borro tambien denuncias reales y chistes inocentes. Mucha gente siente que la censuran.",
    "Ada: Funciona! Las publicaciones falsas con etiqueta se comparten mucho menos, y nadie siente que le tapan la boca."},
    "Ada: Los terminales estan libres si quieres entrenar como verificador. Usalos!")));
  registrarLugares();   // arma los lugares caminables (Lugares.pde)
}

void ordenarPorProfundidad(ArrayList<Interactivo> l) {
  for (int i = 0; i < l.size(); i++) {
    for (int j = i + 1; j < l.size(); j++) {
      if (l.get(j).iy < l.get(i).iy) {
        Interactivo t = l.get(i);
        l.set(i, l.get(j));
        l.set(j, t);
      }
    }
  }
}

int charlasNuevasHabladas() {
  int n = 0;
  for (Lugar L : lugares.values()) {
    for (Interactivo it : L.inter) if ((it.tipo == 0 || it.tipo == 3) && it.hablado) n++;
  }
  return n;
}

void interactuar(Interactivo it) {
  if (it.tipo == 0 || it.tipo == 3) {
    it.hablado = true;
    abrirCharla(it.charla);
  } else if (it.tipo == 1) {
    abrirCharla(new Charla(it.nombre, new String[] {it.frases[int(random(it.frases.length))]}));
    if (it.nombre.startsWith("Fuente")) chispas(400, 230, neonAmarillo, 25);
  } else if (it.tipo == 2) {
    lanzarJuego(it.destino, false);
  }
}

// ------------------------------------- MOTOR PARA CAMINAR (todos los lugares de Lugares.pde) -------------------------------------
void entrarLugar(int s) {
  pararMovimiento();
  cerrarCharla();
  CerrarDialogo();
  if (esCaminable(s)) {
    x = 350;
    y = 390;
    actual = arriba;
  } else if (s == ESC_ESTUDIO) {
    iniciarEstudio();
  } else if (s == ESC_PLAZA) {
    iniciarPlaza();
  }
  scene = s;
}

boolean chocaLibre(float px, float py, float[][] obs) {
  float hx = px + 35, hy = py + 32, hw = 30, hh = 16;
  for (float[] o : obs) {
    if (hx < o[0] + o[2] && hx + hw > o[0] && hy < o[1] + o[3] && hy + hh > o[1]) return true;
  }
  return false;
}

void dibujarJugador() {
  noStroke();
  fill(0, 90);
  ellipse(x + 50, y + 47, 44, 10);
  image(actual, x, y, anchoPersonaje, altoPersonaje);
}

void dibujarEscenaCaminable() {
  Lugar L = lugares.get(scene);
  dibujarFondoLugar(scene);
  if (charlaActiva == null && !pausaAbierta && !telefonoAbierto) {
    float nx = x, ny = y;
    if (moverArriba) ny -= velocidad;
    if (moverAbajo) ny += velocidad;
    if (moverIzquierda) nx -= velocidad;
    if (moverDerecha) nx += velocidad;
    if (!chocaLibre(nx, y, L.obs)) x = nx;
    if (!chocaLibre(x, ny, L.obs)) y = ny;
    float px = x + 50, py = y + 40;   // los pies del personaje
    // los bordes: si hay una puerta en ese lado, sales; si no, es una pared
    if (y < L.yMin) {
      if (L.salidas[0] >= 0 && L.enRango(0, px)) {
        irAEscena(L.salidas[0], 0);
        return;
      }
      y = L.yMin;
    }
    if (y > height - 48) {
      if (L.salidas[2] >= 0 && L.enRango(2, px)) {
        irAEscena(L.salidas[2], 2);
        return;
      }
      y = height - 48;
    }
    if (x < -30) {
      if (L.salidas[3] >= 0 && L.enRango(3, py)) {
        irAEscena(L.salidas[3], 3);
        return;
      }
      x = -30;
    }
    if (x > width - 70) {
      if (L.salidas[1] >= 0 && L.enRango(1, py)) {
        irAEscena(L.salidas[1], 1);
        return;
      }
      x = width - 70;
    }
  }
  cercano = null;
  float mejor = 70;
  for (Interactivo it : L.inter) {
    float d = dist(x + 50, y + 25, it.ix, it.iy - 15);
    if (d < mejor) {
      mejor = d;
      cercano = it;
    }
  }
  dibujarFrenteLugar(scene, false);
  boolean jugadorListo = false;
  for (Interactivo it : L.inter) {
    if (!jugadorListo && it.iy > y + 48) {
      dibujarJugador();
      jugadorListo = true;
    }
    if (it.oculto) continue;
    if (it.tipo == 0) dibujarNPC(it.ix, it.iy, it.ropa, it.pelo, it.fase, !it.hablado && it.charla.eleccion != null, it.nombre);
    else if (it.tipo == 3) dibujarRobot(it.ix, it.iy, it.fase, it.nombre);
    else destelloObj(it.ix, it.iy - 50);
  }
  if (!jugadorListo) dibujarJugador();
  dibujarFrenteLugar(scene, true);
  if (cercano != null && charlaActiva == null) {
    float ky = cercano.tipo == 0 ? cercano.iy - 92 : cercano.tipo == 3 ? cercano.iy - 112 : cercano.iy - 76;
    teclaFlotante("E", cercano.ix, ky);
    if (cercano.tipo == 1 || cercano.tipo == 2) {
      textFont(fuenteUI);
      textSize(12);
      float w = textWidth(cercano.nombre) + 16;
      fill(0, 170);
      rect(cercano.ix - w / 2, ky + 18, w, 20, 10);
      fill(255);
      textAlign(CENTER, CENTER);
      text(cercano.nombre, cercano.ix, ky + 27);
    }
  }
  L.dibujarSalidas();
  botonVolver();
  dibujarCharla();
}

boolean teclaCaminable() {
  if (key == 'e' || key == 'E' || key == ENTER || key == RETURN || key == ' ') {
    if (charlaActiva != null) avanzarCharla();
    else if ((key == 'e' || key == 'E') && cercano != null) interactuar(cercano);
    return true;
  }
  if (charlaActiva != null && charlaEligiendo && (key == '1' || key == '2')) {
    elegirCharla(key - '1');
    return true;
  }
  if (key == CODED) {
    if (keyCode == UP) { moverArriba = true; actual = arriba; }
    if (keyCode == DOWN) { moverAbajo = true; actual = abajo; }
    if (keyCode == LEFT) { moverIzquierda = true; actual = izquierda; }
    if (keyCode == RIGHT) { moverDerecha = true; actual = derecha; }
  }
  return false;   // WASD y SHIFT siguen al keyPressed original
}

// ------------------------------------- FONDO: PARQUE CENTRAL -------------------------------------
void fondoParque() {
  background(46, 92, 60);
  noStroke();
  for (int i = 0; i < 160; i++) {
    fill(i % 2 == 0 ? color(56, 108, 70) : color(38, 80, 52));
    rect(hsh(i * 1.3) * width, hsh(i * 2.7) * height, 6, 3);
  }
  // caminos
  noFill();
  stroke(150, 120, 90);
  strokeWeight(54);
  line(400, 520, 400, 280);
  bezier(400, 330, 300, 330, 200, 260, 110, 215);
  bezier(400, 330, 520, 330, 640, 250, 820, 210);
  strokeWeight(44);
  ellipse(400, 232, 210, 128);
  stroke(176, 146, 110);
  strokeWeight(42);
  line(400, 520, 400, 280);
  bezier(400, 330, 300, 330, 200, 260, 110, 215);
  bezier(400, 330, 520, 330, 640, 250, 820, 210);
  strokeWeight(32);
  ellipse(400, 232, 210, 128);
  noStroke();
  // flores
  for (int i = 0; i < 40; i++) {
    fill(paletaFlores[i % paletaFlores.length]);
    float fx = hsh(i * 3.9 + 1) * width, fy = 140 + hsh(i * 8.1 + 2) * 340;
    if (abs(fx - 400) < 50) continue;
    ellipse(fx, fy, 6, 6);
  }
  // arboles de arriba
  for (int i = 0; i < 9; i++) arbolito(20 + i * 95 + hsh(i * 2.2) * 20, 122 + hsh(i) * 8, 28 + hsh(i * 4.4) * 8, i);
  arbolito(770, 300, 28, 3);
  arbolito(30, 470, 26, 5);
  arbolito(720, 480, 30, 7);
  // kiosko arcade
  kioskoArcade(115, 175);
  // bancas
  banca(160, 286);
  banca(255, 412);
  // postes
  poste(300, 170, 0);
  poste(520, 170, 1);
  poste(60, 330, 2);
  poste(740, 420, 3);
  // fuente
  fill(0, 60);
  ellipse(400, 246, 150, 70);
  fill(150, 145, 165);
  ellipse(400, 236, 140, 66);
  fill(60, 130, 200);
  ellipse(400, 234, 118, 50);
  fill(120, 190, 240, 120);
  for (int i = 0; i < 3; i++) {
    float r = ((frameCount * 0.6 + i * 30) % 90);
    noFill();
    stroke(200, 230, 255, 160 - r * 1.7);
    strokeWeight(1.5);
    ellipse(400, 234, r * 1.2, r * 0.5);
  }
  noStroke();
  fill(170, 165, 185);
  rect(394, 190, 12, 44, 3);
  ellipse(400, 192, 30, 10);
  // estanque con patos
  fill(0, 50);
  ellipse(650, 392, 236, 112);
  fill(50, 110, 170);
  ellipse(650, 385, 228, 104);
  fill(80, 150, 210);
  ellipse(640, 378, 180, 70);
  fill(60, 140, 80);
  ellipse(590, 400, 22, 12);
  ellipse(710, 370, 18, 10);
  for (int i = 0; i < 2; i++) {
    float t = frameCount * 0.008 + i * PI;
    float dx = 650 + cos(t) * 75, dy = 385 + sin(t) * 28;
    float dir = -sin(t) > 0 ? 1 : -1;
    fill(255, 255, 240);
    ellipse(dx, dy, 22, 13);
    ellipse(dx + dir * 9, dy - 8, 11, 11);
    fill(255, 170, 40);
    triangle(dx + dir * 13, dy - 9, dx + dir * 13, dy - 5, dx + dir * 19, dy - 7);
    fill(20);
    ellipse(dx + dir * 11, dy - 9, 2, 2);
  }
}

void banca(float cx, float cy) {
  noStroke();
  fill(0, 60);
  ellipse(cx, cy + 8, 100, 12);
  fill(110, 75, 50);
  rect(cx - 48, cy - 14, 96, 8, 2);
  rect(cx - 48, cy - 2, 96, 8, 2);
  fill(50);
  rect(cx - 42, cy + 6, 5, 8);
  rect(cx + 37, cy + 6, 5, 8);
}

void kioskoArcade(float cx, float cy) {
  noStroke();
  fill(0, 70);
  ellipse(cx, cy + 2, 130, 18);
  fill(40, 30, 70);
  rect(cx - 55, cy - 80, 110, 80, 6);
  for (int i = 0; i < 6; i++) {
    fill(i % 2 == 0 ? neonRosa : color(250));
    rect(cx - 62 + i * 21, cy - 98, 21, 20);
  }
  fill(20, 10, 40);
  rect(cx - 36, cy - 66, 72, 44, 4);
  float f = hsh(floor(frameCount / 10.0));
  fill(f < 0.33 ? neonCian : f < 0.66 ? neonVerde : neonRosa, 200);
  rect(cx - 32, cy - 62, 64, 36, 3);
  fill(20);
  rect(cx - 24, cy - 50 + sin(frameCount * 0.1) * 6, 10, 10);
  boolean on = hsh(floor(frameCount / 7.0) + 3) > 0.08;
  tituloNeon("ARCADE", cx, cy - 112, 18, on ? neonAmarillo : color(120, 100, 40));
}

// ------------------------------------- FONDO: CENTRO NOVA -------------------------------------
void fondoCentro() {
  background(10, 12, 28);
  stroke(0, 240, 255, 35);
  strokeWeight(1);
  for (int i = -12; i <= 12; i++) line(400 + i * 40, 125, 400 + i * 120, 500);
  for (int k = 0; k < 10; k++) {
    float t = k / 10.0;
    float ly = 125 + pow(t, 1.6) * 375;
    line(0, ly, width, ly);
  }
  noStroke();
  fill(16, 18, 40);
  rect(0, 0, width, 125);
  for (int i = 0; i < 10; i++) rack(8 + i * 79, 8, 70, 112, i);
  fill(0, 240, 255, 70);
  rect(0, 122, width, 3);
  cable(120, 125, 120, 222, 0);
  cable(680, 125, 680, 222, 1);
  cable(40, 125, 110, 392, 2);
  cable(400, 125, 400, 240, 3);
  terminal(130, 250, "CAZA BOTS", neonRosa);
  terminal(670, 250, "RASTREO", neonAmarillo);
  terminal(130, 420, "VERIFICADOR", neonCian);
  terminal(670, 420, "MANOTAZO", #FF5AA0);
  orbeNova(400, 205);
}

void rack(float rx, float ry, float rw, float rh, int i) {
  noStroke();
  fill(26, 28, 52);
  rect(rx, ry, rw, rh, 4);
  for (int r = 0; r < 9; r++) {
    float yy = ry + 6 + r * 11.5;
    fill(16, 18, 36);
    rect(rx + 5, yy, rw - 10, 9, 2);
    for (int l = 0; l < 3; l++) {
      boolean on = hsh(i * 31 + r * 7 + l * 3 + floor(frameCount / (6.0 + ((r + l) % 4) * 5))) > 0.4;
      color c = l == 0 ? neonVerde : l == 1 ? neonCian : neonRojo;
      fill(on ? c : color(40, 40, 60));
      rect(rx + rw - 30 + l * 8, yy + 3, 4, 3);
    }
  }
}

void cable(float x1, float y1, float x2, float y2, int i) {
  noFill();
  stroke(30, 34, 64);
  strokeWeight(5);
  bezier(x1, y1, x1, y1 + 60, x2, y2 - 60, x2, y2);
  noStroke();
  float t = ((frameCount * 0.01) + i * 0.27) % 1;
  float px = bezierPoint(x1, x1, x2, x2, t), py = bezierPoint(y1, y1 + 60, y2 - 60, y2, t);
  fill(neonCian, 80);
  ellipse(px, py, 12, 12);
  fill(neonCian);
  ellipse(px, py, 5, 5);
}

void terminal(float cx, float cy, String t, color c) {
  noStroke();
  fill(0, 80);
  ellipse(cx, cy - 12, 120, 20);
  fill(50, 54, 80);
  rect(cx - 50, cy - 45, 100, 30, 4);
  fill(70, 74, 104);
  rect(cx - 50, cy - 45, 100, 6, 4);
  fill(30, 32, 50);
  rect(cx - 5, cy - 60, 10, 16);
  fill(20, 22, 40);
  rect(cx - 38, cy - 104, 76, 48, 5);
  fill(c, 40);
  rect(cx - 48, cy - 114, 96, 68, 10);
  fill(red(c) * 0.2, green(c) * 0.2, blue(c) * 0.2);
  rect(cx - 34, cy - 100, 68, 40, 3);
  fill(c);
  for (int i = 0; i < 4; i++) {
    float w = 10 + hsh(i + floor(frameCount / 12.0) * 4 + cx) * 44;
    rect(cx - 30, cy - 94 + i * 9, w, 3);
  }
  textFont(fuenteUI);
  textSize(10);
  textAlign(CENTER, CENTER);
  fill(c);
  text(t, cx, cy - 122);
}

void orbeNova(float cx, float cy) {
  float f = sin(frameCount * 0.04) * 6;
  noStroke();
  fill(0, 90);
  ellipse(cx, cy + 66, 130, 34);
  fill(40, 44, 76);
  ellipse(cx, cy + 58, 110, 34);
  fill(60, 66, 104);
  ellipse(cx, cy + 52, 110, 30);
  fill(neonCian, 18);
  triangle(cx - 40, cy + 50, cx + 40, cy + 50, cx, cy - 30);
  for (int i = 6; i >= 1; i--) {
    fill(neonMorado, 14);
    ellipse(cx, cy + f, 30 + i * 14, 30 + i * 14);
  }
  noFill();
  strokeWeight(2);
  for (int i = 0; i < 3; i++) {
    pushMatrix();
    translate(cx, cy + f);
    rotate(frameCount * 0.02 * (i + 1) + i);
    stroke(i == 1 ? neonRosa : neonCian, 180);
    ellipse(0, 0, 90 - i * 14, 28 + i * 6);
    popMatrix();
  }
  noStroke();
  float p = 1 + 0.08 * sin(frameCount * 0.12);
  fill(neonCian);
  ellipse(cx, cy + f, 34 * p, 34 * p);
  fill(255);
  ellipse(cx - 6, cy - 6 + f, 10, 10);
  textFont(fuente);
  textSize(16);
  textAlign(CENTER, CENTER);
  fill(neonCian);
  text("NOVA", cx, cy - 52 + f);
}

// ------------------------------------- MAPA VIVO -------------------------------------
float[][] lugaresMapa = {
  // x0, y0, x1, y1, escena, pinX, pinY, nuevo(1/0)
  {30, 140, 270, 310, 7, 118, 160, 0},
  {580, 50, 780, 230, 5, 656, 92, 0},
  {580, 330, 780, 480, 24, 672, 372, 0},
  {280, 270, 396, 444, 45, 330, 330, 1},   // 45 = ESC_PARQUE
  {412, 0, 496, 130, 46, 454, 50, 1},     // 46 = ESC_CENTRO
  {324, 168, 396, 224, 47, 360, 178, 1},  // 47 = ESC_ESTUDIO
  {412, 308, 496, 416, 48, 454, 352, 1}   // 48 = ESC_PLAZA
};
String[] nombresMapa = {"Colegio", "Barrio Residencial", "Alcaldia", "Parque Central", "Centro NOVA", "Nova Noticias", "Plaza de la Votacion"};
float[][] autosMapa = new float[12][3];
boolean autosListos = false;

void dibujarMapaVivo() {
  if (!autosListos) {
    for (int i = 0; i < autosMapa.length; i++) {
      autosMapa[i][0] = random(width);
      autosMapa[i][1] = i % 4;
      autosMapa[i][2] = random(0.8, 1.8);
    }
    autosListos = true;
  }
  noStroke();
  for (float[] a : autosMapa) {
    if (!pausaAbierta && !telefonoAbierto) a[0] += a[2];
    float pos = a[0] % (width + 40) - 20;
    float ax, ay;
    boolean horizontal = a[1] < 2;
    if (a[1] == 0) { ax = pos; ay = 236; }
    else if (a[1] == 1) { ax = width - pos; ay = 258; }
    else if (a[1] == 2) { ax = 518; ay = pos * 0.62; }
    else { ax = 538; ay = height - pos * 0.62; }
    fill(255, 255, 200, 60);
    if (horizontal) ellipse(ax, ay, 18, 8);
    else ellipse(ax, ay, 8, 18);
    fill(255, 250, 210);
    ellipse(ax, ay, 4, 4);
  }
  eventosDelMapa();   // cosas aleatorias del mapa (Eventos.pde)
  // pines
  int sobreLugar = -1;
  for (int i = 0; i < lugaresMapa.length; i++) {
    float[] l = lugaresMapa[i];
    if (mouseX > l[0] && mouseX < l[2] && mouseY > l[1] && mouseY < l[3] && !telefonoAbierto && !pausaAbierta && !popupAbierto) sobreLugar = i;
  }
  for (int i = 0; i < lugaresMapa.length; i++) {
    float[] l = lugaresMapa[i];
    color c = l[7] == 1 ? neonRosa : neonCian;
    boolean s = i == sobreLugar;
    if (s) {
      noFill();
      stroke(c, 200);
      strokeWeight(2);
      rect(l[0], l[1], l[2] - l[0], l[3] - l[1], 10);
      noStroke();
      fill(c, 25);
      rect(l[0], l[1], l[2] - l[0], l[3] - l[1], 10);
    }
    float b = sin(frameCount * 0.08 + i) * 3 - (s ? 4 : 0);
    float r = (frameCount * 0.8 + i * 20) % 50;
    noFill();
    stroke(c, 200 - r * 4);
    strokeWeight(2);
    ellipse(l[5], l[6] + 14, r, r * 0.4);
    noStroke();
    fill(0, 120);
    ellipse(l[5], l[6] + 15, 14, 5);
    fill(c);
    ellipse(l[5], l[6] - 6 + b, 18, 18);
    triangle(l[5] - 8, l[6] - 2 + b, l[5] + 8, l[6] - 2 + b, l[5], l[6] + 12 + b);
    fill(20);
    ellipse(l[5], l[6] - 6 + b, 7, 7);
    if (l[7] == 1 && !visitado[int(l[4])]) {
      textFont(fuenteUI);
      textSize(9);
      fill(neonAmarillo);
      rect(l[5] + 8, l[6] - 26 + b, 38, 13, 6);
      fill(20);
      textAlign(CENTER, CENTER);
      text("NUEVO", l[5] + 27, l[6] - 20 + b);
    }
  }
  if (sobreLugar >= 0) {
    float[] l = lugaresMapa[sobreLugar];
    textFont(fuenteUI);
    textSize(14);
    String t = nombresMapa[sobreLugar];
    float w = max(textWidth(t), 110) + 24;
    float tx = constrain(l[5] - w / 2, 6, width - w - 6), ty = l[6] - 64;
    if (ty < 6) ty = l[6] + 22;
    fill(8, 6, 22, 235);
    rect(tx, ty, w, 40, 8);
    fill(255);
    textAlign(CENTER, TOP);
    text(t, tx + w / 2, ty + 5);
    textSize(10);
    fill(neonCian);
    text("clic para entrar", tx + w / 2, ty + 24);
  }
  // telefono del mapa
  float p = 0.5 + 0.5 * sin(frameCount * 0.1);
  noFill();
  stroke(neonCian, 120 * p);
  strokeWeight(3);
  rect(750, 10, 40, 50, 8);
  noStroke();
  if (notifPendientes > 0) {
    fill(neonRojo);
    ellipse(788, 12, 18, 18);
    fill(255);
    textFont(fuenteUI);
    textSize(10);
    textAlign(CENTER, CENTER);
    text(notifPendientes, 788, 11);
  }
  // cartel de informacion
  fill(8, 6, 22, 200);
  rect(10, 10, 250, 46, 10);
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(13);
  fill(255);
  text("Nova  -  " + textoHora() + "  -  faltan " + diasElecciones() + " dias", 22, 16);
  textSize(10);
  fill(neonCian);
  text("Elige un lugar   -   P telefono   -   ESC pausa", 22, 36);
  dibujarPopupMapa();
}

boolean clickMapaVivo() {
  if (popupAbierto) return clickPopupMapa();
  if (clickEventoMapa()) return true;
  // (expansion) la alcaldia ahora se alcanza caminando por la Avenida Central
  float[] alc = lugaresMapa[2];
  if (mouseX > alc[0] && mouseX < alc[2] && mouseY > alc[1] && mouseY < alc[3]) {
    entrarLugar(ESC_AVENIDA);
    return true;
  }
  if (encima(750, 10, 40, 50)) {
    abrirTelefono();
    return true;
  }
  for (int i = 3; i < lugaresMapa.length; i++) {
    float[] l = lugaresMapa[i];
    if (mouseX > l[0] && mouseX < l[2] && mouseY > l[1] && mouseY < l[3]) {
      entrarLugar(int(l[4]));
      return true;
    }
  }
  return false;
}

// ------------------------------------- 47 NOVA NOTICIAS (concurso en vivo) -------------------------------------
String[][] preguntasTV = {
  {"Ves un titular escandaloso de una pagina creada ayer. Que haces primero?", "Lo comparto rapido para que todos se enteren", "Busco quien esta detras y si medios serios lo confirman", "Comento en mayusculas", "Le doy like y sigo bajando", "1"},
  {"Que es la 'lectura lateral'?", "Leer el celular acostado", "Leer solo el titular y los comentarios", "Abrir otras pestañas para investigar la fuente", "Leer de derecha a izquierda", "2"},
  {"Un video de 9 segundos muestra a una candidata recibiendo dinero, sin fecha ni lugar. Eso indica...", "Que es 100% real porque es video", "Que puede estar cortado o sacado de contexto", "Que la candidata es culpable", "Nada, los videos no se editan", "1"},
  {"Cual es una señal tipica de una cuenta bot?", "Tiene foto de perfil de un perro", "Publica poco y saluda a sus amigos", "Es nueva, sin foto y publica cientos de veces al dia", "Sigue a sus compañeros del colegio", "2"},
  {"Una cadena dice: 'Compartelo antes de que lo borren!' Esa frase busca...", "Que actues con prisa y no verifiques", "Proteger la libertad de expresion", "Ayudar a los periodistas", "Informarte con calma", "0"},
  {"Compartiste algo falso sin querer. Que es lo mejor?", "Hacerte el loco", "Borrarlo y publicar una correccion", "Culpar a quien te lo envio", "Compartirlo otra vez por si acaso", "1"}
};
String[] introTV = {
  "Buenas noches, Nova! Esto es 'VERDAD O BULO', en vivo por Nova Noticias!",
  "Hoy nos acompaña alguien que ha estado investigando los rumores de la ciudad. Un aplauso!",
  "Te hare 6 preguntas. Cada respuesta correcta sube la confianza de toda la audiencia. Listo?"
};
int estadoTV = 0;   // 0 intro, 1 pregunta, 2 respuesta, 3 fin
int lineaTV = 0, preguntaTV = 0, elegidaTV = -1, aciertosTV = 0;
float letrasTV = 0, tiempoTV = 15, feedbackTV = 0, aplausos = 0.3;
boolean premioTV = false;
String ticker = "ULTIMA HORA:  La Junta Vecinal confirma la jornada del parque   -   NOVA etiqueta 120 publicaciones falsas   -   El debate es el jueves a las 7 p.m.   -   Recuerda: verifica antes de compartir   -   ";

void iniciarEstudio() {
  estadoTV = 0;
  lineaTV = 0;
  preguntaTV = 0;
  elegidaTV = -1;
  aciertosTV = 0;
  letrasTV = 0;
  aplausos = 0.3;
}

void dibujarEstudio() {
  degradado(0, 0, width, height, color(24, 6, 44), color(70, 12, 66));
  noStroke();
  for (int i = 0; i < 3; i++) {
    float a = sin(frameCount * 0.015 + i * 2) * 0.5;
    pushMatrix();
    translate(150 + i * 250, -10);
    rotate(a);
    fill(255, 240, 200, 16);
    triangle(0, 0, -80, 520, 80, 520);
    popMatrix();
  }
  // pantalla gigante
  panelNeon(190, 30, 590, 170, neonCian);
  if (estadoTV == 0 || estadoTV == 3) {
    tituloNeon("NOVA NOTICIAS", 485, 85, 38, neonCian);
    textFont(fuenteUI);
    textSize(16);
    fill(neonRosa);
    textAlign(CENTER, CENTER);
    text("VERDAD  O  BULO", 485, 130 + sin(frameCount * 0.1) * 3);
  } else {
    String[] q = preguntasTV[preguntaTV];
    textFont(fuenteUI);
    textSize(12);
    fill(neonCian);
    textAlign(LEFT, TOP);
    text("PREGUNTA " + (preguntaTV + 1) + " / " + preguntasTV.length, 214, 44);
    fill(255);
    textSize(18);
    text(q[0], 214, 66, 545, 110);
    if (estadoTV == 1) {
      fill(40, 36, 60);
      rect(214, 182, 545, 6, 3);
      fill(lerpColor(neonRojo, neonCian, tiempoTV / 15.0));
      rect(214, 182, 545 * tiempoTV / 15.0, 6, 3);
    }
  }
  // en vivo
  fill(frameCount % 60 < 40 ? neonRojo : color(120, 30, 40));
  ellipse(30, 70, 12, 12);
  textFont(fuenteUI);
  textSize(13);
  fill(255);
  textAlign(LEFT, CENTER);
  text("EN VIVO", 42, 70);
  // presentadora
  pushMatrix();
  translate(100, 330);
  scale(1.6);
  dibujarNPC(0, 0, #DC3C78, #3C2814, 1.5, false, "");
  popMatrix();
  fill(0, 160);
  rect(40, 340, 120, 20, 10);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(11);
  text("Vero Cidad", 100, 349);
  // burbuja de la presentadora
  String dice = "";
  if (estadoTV == 0) dice = introTV[lineaTV];
  else if (estadoTV == 2) dice = elegidaTV == int(preguntasTV[preguntaTV][5]) ? "Correcto! El publico enloquece!" : (elegidaTV == -1 ? "Se acabo el tiempo!" : "Uy, no! Esa no era...");
  if (!dice.equals("")) {
    if (letrasTV < dice.length() && !pausaAbierta) letrasTV += 1.1;
    fill(255);
    rect(20, 214, 330, 64, 12);
    triangle(80, 278, 100, 278, 88, 292);
    fill(30);
    textSize(13);
    textAlign(LEFT, TOP);
    text(dice.substring(0, min(dice.length(), int(letrasTV))), 32, 222, 306, 54);
  }
  // opciones
  if (estadoTV == 1 || estadoTV == 2) {
    String[] q = preguntasTV[preguntaTV];
    int buena = int(q[5]);
    for (int i = 0; i < 4; i++) {
      float bx = 380 + (i % 2) * 205, by = 214 + (i / 2) * 60;
      color c = neonCian;
      boolean marcado = false;
      if (estadoTV == 2) {
        if (i == buena) { c = neonVerde; marcado = true; }
        else if (i == elegidaTV) { c = neonRojo; marcado = true; }
        else c = color(90, 90, 120);
      }
      botonNeon("", bx, by, 195, 52, c, marcado);
      textFont(fuenteUI);
      textSize(11);
      fill(255);
      textAlign(LEFT, CENTER);
      text(char('A' + i) + ")  " + q[1 + i], bx + 10, by, 178, 52);
    }
  }
  if (estadoTV == 0 && letrasTV >= introTV[lineaTV].length() && frameCount % 40 < 28) {
    textFont(fuenteUI);
    textSize(13);
    fill(neonCian);
    textAlign(LEFT, CENTER);
    text("Clic o ENTER >", 380, 250);
  }
  // medidor de aplausos
  textFont(fuenteUI);
  textSize(10);
  fill(200);
  textAlign(LEFT, CENTER);
  text("CONFIANZA DEL PUBLICO", 380, 344);
  fill(40, 36, 60);
  rect(520, 340, 260, 8, 4);
  fill(neonAmarillo);
  rect(520, 340, 260 * constrain(aplausos, 0, 1), 8, 4);
  // publico
  for (int i = 0; i < 26; i++) {
    float ax = 16 + i * 31, fila = i % 2;
    float ay = 410 + fila * 26 + abs(sin(frameCount * (0.08 + aplausos * 0.12) + i)) * -6 * (0.3 + aplausos);
    fill(18, 10, 30);
    ellipse(ax, ay, 22, 22);
    rect(ax - 15, ay + 8, 30, 40, 10);
    if (hsh(i * 3.3) > 0.8) {
      fill(255, 255, 220, 200);
      rect(ax + 8, ay - 14, 5, 8);
    }
  }
  // cinta de noticias
  fill(200, 30, 60);
  rect(0, 478, width, 22);
  fill(255);
  textSize(12);
  textAlign(LEFT, CENTER);
  float tw = textWidth(ticker);
  float tx = width - (frameCount * 1.5) % (tw + width);
  text(ticker, tx, 488);
  text(ticker, tx + tw, 488);
  // logica
  if (!pausaAbierta && !telefonoAbierto) {
    if (estadoTV == 1) {
      tiempoTV -= 1 / 60.0;
      if (tiempoTV <= 0) responderTV(-1);
    } else if (estadoTV == 2) {
      feedbackTV--;
      if (feedbackTV <= 0) siguientePreguntaTV();
    }
    aplausos = lerp(aplausos, 0.25 + aciertosTV / 8.0, 0.02);
  }
  if (estadoTV == 3) finTV();
  botonVolver();
}

void responderTV(int i) {
  if (estadoTV != 1) return;
  elegidaTV = i;
  letrasTV = 0;
  estadoTV = 2;
  feedbackTV = 120;
  if (i == int(preguntasTV[preguntaTV][5])) {
    aciertosTV++;
    aplausos = min(1, aplausos + 0.3);
    explosionConfeti(width / 2, 210, 50);
  } else {
    sacudida = 8;
    aplausos = max(0, aplausos - 0.2);
  }
}

void siguientePreguntaTV() {
  preguntaTV++;
  if (preguntaTV >= preguntasTV.length) {
    estadoTV = 3;
    premioTV = false;
    desbloquear(8);
    if (!premiadoTV) {
      premiadoTV = true;
      premioTV = true;
      confiabilidad += aciertosTV * 2;
      impacto += aciertosTV * 2;
    }
    explosionConfeti(width / 2, 120, 80);
  } else {
    estadoTV = 1;
    elegidaTV = -1;
    tiempoTV = 15;
  }
}

boolean premiadoTV = false;

void finTV() {
  panelNeon(200, 120, 400, 250, neonAmarillo);
  tituloNeon("FIN DEL PROGRAMA", width / 2, 155, 26, neonAmarillo);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(40);
  fill(255);
  text(aciertosTV + " / " + preguntasTV.length, width / 2, 205);
  textSize(13);
  fill(220);
  String msj = aciertosTV >= 5 ? "Nova entera aprendio contigo esta noche!" : aciertosTV >= 3 ? "Buen trabajo! El publico confia un poco mas." : "Hay que practicar mas... el arcade te espera!";
  text(msj, width / 2, 245);
  fill(premioTV ? neonVerde : color(160));
  text(premioTV ? "+" + (aciertosTV * 2) + " Confiabilidad   +" + (aciertosTV * 2) + " Impacto" : "(el premio solo se da la primera vez)", width / 2, 270);
  botonNeon("Repetir", 230, 300, 160, 46, neonCian, false);
  botonNeon("Volver al mapa", 410, 300, 160, 46, neonRosa, false);
}

void clickEstudio() {
  if (clickVolver()) {
    scene = 1;
    return;
  }
  if (estadoTV == 0) avanzarTV();
  else if (estadoTV == 1) {
    for (int i = 0; i < 4; i++) {
      if (encima(380 + (i % 2) * 205, 214 + (i / 2) * 60, 195, 52)) responderTV(i);
    }
  } else if (estadoTV == 2) {
    if (feedbackTV < 100) feedbackTV = 0;
  } else if (estadoTV == 3) {
    if (encima(230, 300, 160, 46)) iniciarEstudio();
    else if (encima(410, 300, 160, 46)) scene = 1;
  }
}

void avanzarTV() {
  if (letrasTV < introTV[lineaTV].length()) {
    letrasTV = introTV[lineaTV].length();
    return;
  }
  lineaTV++;
  letrasTV = 0;
  if (lineaTV >= introTV.length) {
    lineaTV = introTV.length - 1;
    estadoTV = 1;
    preguntaTV = 0;
    tiempoTV = 15;
    elegidaTV = -1;
  }
}

void teclaEstudio() {
  boolean enter = key == ENTER || key == RETURN || key == ' ';
  if (estadoTV == 0 && enter) avanzarTV();
  else if (estadoTV == 1) {
    int i = -1;
    if (key >= '1' && key <= '4') i = key - '1';
    if (key == 'a' || key == 'A') i = 0;
    if (key == 'b' || key == 'B') i = 1;
    if (key == 'c' || key == 'C') i = 2;
    if (key == 'd' || key == 'D') i = 3;
    if (i >= 0) responderTV(i);
  } else if (estadoTV == 2 && enter && feedbackTV < 100) feedbackTV = 0;
  else if (estadoTV == 3 && enter) scene = 1;
}

// ------------------------------------- 48 PLAZA DE LA VOTACION -------------------------------------
int estadoPlaza = 0;   // 0 aviso, 1 animacion de votos
float tPlaza = 0;
int votosContados = 0;

void iniciarPlaza() {
  estadoPlaza = decisionesTomadas < 4 ? 0 : 1;
  tPlaza = 0;
  votosContados = 0;
}

void dibujarPlaza() {
  degradado(0, 0, width, 260, color(14, 8, 40), color(70, 30, 90));
  noStroke();
  for (int i = 0; i < 40; i++) {
    fill(255, 120 + 120 * sin(frameCount * 0.05 + i));
    rect(hsh(i * 2.1) * width, hsh(i * 4.3) * 160, 2, 2);
  }
  // alcaldia al fondo
  fill(40, 30, 70);
  rect(150, 120, 500, 140);
  triangle(140, 120, 400, 60, 660, 120);
  for (int i = 0; i < 8; i++) {
    fill(255, 210, 140, hsh(i * 5.5) > 0.3 ? 200 : 40);
    rect(185 + i * 58, 160, 20, 36, 3);
  }
  fill(26, 20, 46);
  rect(0, 260, width, 240);
  // guirnaldas de luces
  for (int k = 0; k < 2; k++) {
    for (int i = 0; i <= 20; i++) {
      float t = i / 20.0;
      float lx = t * width;
      float ly = 220 + k * 30 + sin(t * PI) * 40;
      color c = paletaFlores[(i + k) % paletaFlores.length];
      boolean on = hsh(i * 3 + k * 7 + floor(frameCount / 15.0)) > 0.25;
      fill(c, on ? 255 : 80);
      ellipse(lx, ly, 7, 7);
      if (on) {
        fill(c, 40);
        ellipse(lx, ly, 18, 18);
      }
    }
  }
  tituloNeon("DIA DE ELECCIONES", width / 2, 34, 34, neonAmarillo);
  // urna
  fill(0, 90);
  ellipse(400, 430, 140, 20);
  fill(220, 225, 240);
  rect(340, 340, 120, 90, 6);
  fill(180, 185, 210);
  rect(340, 340, 120, 14, 6, 6, 0, 0);
  fill(30);
  rect(375, 344, 50, 5, 2);
  textFont(fuenteUI);
  textSize(14);
  fill(60, 60, 110);
  textAlign(CENTER, CENTER);
  text("VOTO", 400, 392);
  if (estadoPlaza == 1) {
    if (!pausaAbierta) tPlaza++;
    for (int i = 0; i < 10; i++) {
      float pos = (tPlaza * 1.1 + i * 46) % 460;
      float cx = pos < 320 ? -20 + pos : 300 + (pos - 320) * 0.3;
      float alpha = pos < 320 ? 255 : map(pos, 320, 460, 255, 0);
      if (alpha > 10) dibujarNPC(cx, 440 - (i % 3) * 8, paletaRopa[i % paletaRopa.length], i % 2 == 0 ? #2A1E14 : #8C5A3C, i * 1.3, false, "");
      if (abs(pos - 330) < 1.2 && !pausaAbierta) {
        Particula p = new Particula(398, 336, random(-0.5, 0.5), -2.2, 40, 10, color(255), 3);
        p.grav = 0.12;
        agregarParticula(p);
        votosContados++;
      }
    }
    for (int i = 0; i < 10; i++) {
      float pos = (tPlaza * 0.9 + i * 50) % 500;
      dibujarNPC(width + 20 - pos, 470 - (i % 2) * 10, paletaRopa[(i + 3) % paletaRopa.length], #141414, i * 2.1, false, "");
    }
    panelNeon(250, 70, 300, 70, neonCian);
    textFont(fuenteUI);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("Nova decide...", width / 2, 92);
    textSize(22);
    fill(neonCian);
    text(nf(votosContados * 137 + int(tPlaza * 9), 0) + " votos", width / 2, 118);
    if (frameCount % 40 < 28) {
      textSize(12);
      fill(200);
      text("clic para ver los resultados", width / 2, 160);
    }
    if (tPlaza > 420) irAlFinal();
  } else {
    panelNeon(140, 130, 520, 220, neonRosa);
    tituloNeon("ESPERA...", width / 2, 165, 28, neonRosa);
    textFont(fuenteUI);
    textSize(15);
    fill(230);
    textAlign(CENTER, TOP);
    text("Todavia hay rumores sueltos por Nova y casi no has tomado decisiones (" + decisionesTomadas + "). Si votas ahora, la ciudad decidira con lo que hay.", 170, 195, 460, 80);
    botonNeon("Ir a votar igual", 170, 285, 220, 46, neonRosa, false);
    botonNeon("Seguir investigando", 410, 285, 220, 46, neonCian, false);
  }
  botonVolver();
}

void avanzarPlaza() {
  if (estadoPlaza == 0) estadoPlaza = 1;
  else irAlFinal();
}

void clickPlaza() {
  if (clickVolver()) {
    scene = 1;
    return;
  }
  if (estadoPlaza == 0) {
    if (encima(170, 285, 220, 46)) estadoPlaza = 1;
    else if (encima(410, 285, 220, 46)) scene = 1;
  } else if (tPlaza > 60) {
    irAlFinal();
  }
}

// ------------------------------------- 49 FINAL -------------------------------------
int finalTipo = 0;
float tFinal = 0;
float[] votosFinal = new float[4];
String[] candidatosFinal = {"Clemencia", "Patroclo", "Gonzalo", "Ramirez"};
color[] coloresCandidatos = {#DC6E8C, #3C78C8, #46A064, #DCA032};
String[] titulosFinal = {"EL FILTRO DE NOVA", "AGENTE DEL CAOS", "CIUDADANO CONSCIENTE", "ESPECTADOR SILENCIOSO"};
String[] textosFinal = {
  "Frenaste rumores, verificaste fuentes y ayudaste a otros a hacerlo. Nova voto por propuestas, no por miedos. Dani recupero su tranquilidad y el parque sigue en pie.",
  "Tus publicaciones volaron por toda Nova... y con ellas el miedo. Gano quien mas grito, no quien tenia razon. La ciudad tardara mucho en volver a confiar.",
  "No fuiste perfecto, pero aprendiste a dudar antes de compartir. Gracias a gente como tu, los bulos perdieron fuerza a mitad de camino.",
  "Miraste desde lejos mientras los rumores decidian por todos. No echaste leña al fuego... pero tampoco ayudaste a apagarlo."
};

void irAlFinal() {
  float c = confiabilidad, v = viralidad, im = impacto;
  if (c >= 60 && im >= 50) finalTipo = 0;
  else if (v >= 60 && c < 40) finalTipo = 1;
  else if (c >= 35) finalTipo = 2;
  else finalTipo = 3;
  votosFinal[0] = 25 + im * 0.15 + c * 0.05 - (v > 50 ? 5 : 0);
  votosFinal[1] = 25 + v * 0.3 - c * 0.15;
  votosFinal[2] = 25 + c * 0.25 + im * 0.1;
  votosFinal[3] = 25 + c * 0.1 - v * 0.1;
  float total = 0;
  for (int i = 0; i < 4; i++) {
    votosFinal[i] = max(3, votosFinal[i]);
    total += votosFinal[i];
  }
  for (int i = 0; i < 4; i++) votosFinal[i] = votosFinal[i] * 100 / total;
  tFinal = 0;
  scene = ESC_FINAL;
  desbloquear(9);
}

void dibujarFinal() {
  boolean bueno = finalTipo == 0 || finalTipo == 2;
  degradado(0, 0, width, height, bueno ? color(10, 10, 40) : color(30, 6, 14), bueno ? color(50, 20, 80) : color(70, 10, 30));
  if (!pausaAbierta) tFinal++;
  if (bueno && frameCount % 40 == 0) {
    float fx = random(100, 700), fy = random(60, 200);
    chispas(fx, fy, paletaFlores[int(random(paletaFlores.length))], 50);
  }
  if (!bueno) {
    stroke(150, 150, 200, 80);
    strokeWeight(1);
    for (int i = 0; i < 40; i++) {
      float rx = (hsh(i * 1.7) * width + frameCount * 2) % width;
      float ry = (hsh(i * 3.1) * height + frameCount * 9) % height;
      line(rx, ry, rx - 3, ry - 14);
    }
    noStroke();
  }
  tituloNeon("TU FINAL:", width / 2, 34, 20, color(200));
  color tc = finalTipo == 0 ? neonVerde : finalTipo == 1 ? neonRojo : finalTipo == 2 ? neonCian : neonAmarillo;
  float esc = min(1, tFinal / 40.0);
  tituloNeon(titulosFinal[finalTipo], width / 2, 72, 40 * (0.6 + 0.4 * esc), tc);
  textFont(fuenteUI);
  textSize(14);
  fill(230);
  textAlign(CENTER, TOP);
  text(textosFinal[finalTipo], 110, 104, 580, 70);
  // resultados de la votacion
  panelNeon(110, 186, 580, 190, tc);
  textSize(12);
  fill(200);
  textAlign(LEFT, TOP);
  text("RESULTADOS DE LA ELECCION", 132, 198);
  int ganador = 0;
  for (int i = 1; i < 4; i++) if (votosFinal[i] > votosFinal[ganador]) ganador = i;
  float escala = 380 / votosFinal[ganador];   // la barra del ganador ocupa todo el ancho
  float prog = constrain((tFinal - 30) / 120.0, 0, 1);
  prog = 1 - pow(1 - prog, 3);
  for (int i = 0; i < 4; i++) {
    float by = 224 + i * 36;
    fill(235);
    textSize(13);
    textAlign(LEFT, CENTER);
    text(candidatosFinal[i], 132, by + 9);
    fill(40, 36, 60);
    rect(240, by, 380, 18, 9);
    fill(coloresCandidatos[i]);
    rect(240, by, votosFinal[i] * escala * prog, 18, 9);
    fill(255);
    textAlign(RIGHT, CENTER);
    text(nf(votosFinal[i] * prog, 0, 1) + "%", 676, by + 9);
    if (prog >= 1 && i == ganador) {
      fill(neonAmarillo);
      textAlign(LEFT, CENTER);
      fill(20);
      text("GANA", 250, by + 9);
    }
  }
  textSize(12);
  fill(200);
  textAlign(CENTER, CENTER);
  text("Viralidad " + int(viralidad) + "   -   Confiabilidad " + int(confiabilidad) + "   -   Impacto " + int(impacto) + "   -   " + decisionesTomadas + " decisiones", width / 2, 392);
  botonNeon("Nueva partida", 190, 418, 200, 48, neonRosa, false);
  botonNeon("Seguir explorando", 410, 418, 200, 48, neonCian, false);
}

void clickFinal() {
  if (encima(190, 418, 200, 48)) {
    reiniciarPartida();
    scene = 0;
  } else if (encima(410, 418, 200, 48)) {
    scene = 1;
  }
}

// ------------------------------------- NUEVA PARTIDA -------------------------------------
void reiniciarPartida() {
  viralidad = 0;
  confiabilidad = 0;
  impacto = 0;
  prevViral = prevConf = prevImp = 0;
  hudV = hudC = hudI = 0;
  dec = new int[15];
  idDec = 0;
  decC = 0;
  pD1 = 0;
  pD18 = 0;
  tLl = false;
  llEnt = false;
  pDes = false;
  mostrarDialogo = true;
  textoDialogo = "T/N: No, no, no... Esto no me puede estar pasando! \nComo voy a perder la llave justo cuando estoy a punto de entrar a Nova?";
  a1 = a2 = a3 = false;
  b1 = b2 = b3 = false;
  c1 = c2 = c3 = false;
  md1 = md2 = md3 = false;
  dialogoIdx = 0;
  hablando = false;
  CerrarDialogo();
  mostrarDialogo = true;
  for (int i = 0; i < npcHablado.length; i++) npcHablado[i] = false;
  decisionesTomadas = 0;
  relojJuego = 17 * 60;
  notifPendientes = 0;
  feedVisibles = 3;
  premiadoTV = false;
  for (int i = 0; i < premiado.length; i++) premiado[i] = false;
  for (int i = 0; i < visitado.length; i++) visitado[i] = false;
  prepararTelefono();
  prepararEscenarios();
  cerrarCharla();
  particulas.clear();
  flotantes.clear();
}
