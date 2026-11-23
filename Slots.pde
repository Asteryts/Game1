// =====================================================================================
//  SLOTS.pde -> 3 partidas guardadas, cada una con su personaje
//   - Al crear una partida eliges personaje (SeleccionPersonaje.pde) y queda fijo en ese slot.
//   - Para jugar con otro personaje hay que crear otra partida en otro slot.
//   - Se guarda al crear la partida y al empezar cada dia: si cierras el juego,
//     sigues desde el inicio del ultimo dia al que llegaste.
//   - Archivos: partida_slot1.txt, partida_slot2.txt, partida_slot3.txt (en la carpeta del sketch)
// =====================================================================================
final int ESC_SLOTS = 83;
final int NUM_SLOTS = 3;
final int ANCHO_SLOT = 220, ALTO_SLOT = 304, Y_SLOT = 100;

int slotActivo = -1;        // la partida que estas jugando (-1 = ninguna)
int slotNuevo = -1;         // el slot vacio en el que estas creando partida
int slotBorrando = -1;      // el slot que pide confirmacion para borrarse
int slotElegido = 0;        // el que esta marcado con el teclado
boolean cargandoSlot = false;
String tiendaInicial = "";  // monedas y gadgets de una partida nueva (se toma al abrir el juego)
HashMap<String, String>[] infoSlot = new HashMap[3];

String archivoSlot(int n) {
  return sketchPath("partida_slot" + (n + 1) + ".txt");
}

boolean slotExiste(int n) {
  return infoSlot[n] != null;
}

// lee el resumen de los 3 slots para dibujar las tarjetas
void leerSlots() {
  for (int n = 0; n < NUM_SLOTS; n++) {
    infoSlot[n] = null;
    try {
      File f = new File(archivoSlot(n));
      if (!f.exists()) continue;
      String[] l = loadStrings(f.getAbsolutePath());
      if (l == null || l.length == 0) continue;
      HashMap<String, String> m = new HashMap<String, String>();
      for (String s : l) {
        int i = s.indexOf('=');
        if (i > 0 && !m.containsKey(s.substring(0, i))) m.put(s.substring(0, i), s.substring(i + 1));
      }
      if (m.containsKey("genero")) infoSlot[n] = m;
    }
    catch (Exception e) {
      println("No se pudo leer el slot " + (n + 1) + ": " + e);
    }
  }
}

void abrirSlots() {
  leerSlots();
  slotBorrando = -1;
  slotNuevo = -1;
  if (slotActivo >= 0) slotElegido = slotActivo;
  scene = ESC_SLOTS;
}

// ------------------------------------- CREAR / CONTINUAR / BORRAR -------------------------------------
void elegirSlot(int n) {
  slotElegido = n;
  if (!slotExiste(n)) {   // vacio: primero eliges personaje
    slotNuevo = n;
    abrirSeleccionPersonaje();
  } else if (n == slotActivo && partidaEmpezada) {
    scene = 1;            // es la partida que ya estabas jugando: sigues justo donde ibas
  } else {
    cargarSlot(n);
  }
}

// la llama SeleccionPersonaje.pde al darle "Continuar"
void crearPartidaEnSlot(int genero) {
  if (slotNuevo < 0) slotNuevo = slotElegido;
  generoPersonaje = genero;
  slotActivo = slotNuevo;
  slotNuevo = -1;
  cargandoSlot = true;
  reiniciarPartida();
  if (!tiendaInicial.equals("")) cargarGuardadoTienda(tiendaInicial);   // monedas y gadgets desde cero
  cargandoSlot = false;
  guardarSlotActivo();
  guardarDatos();
  empezarCineApertura();
}

void borrarSlot(int n) {
  try {
    File f = new File(archivoSlot(n));
    if (f.exists()) f.delete();
  }
  catch (Exception e) {
    println("No se pudo borrar el slot " + (n + 1) + ": " + e);
  }
  if (n == slotActivo) {
    slotActivo = -1;
    cargandoSlot = true;
    reiniciarPartida();
    cargandoSlot = false;
  }
  slotBorrando = -1;
  leerSlots();
}

// ------------------------------------- GUARDAR -------------------------------------
void guardarSlotActivo() {
  if (slotActivo < 0 || cargandoSlot) return;
  try {
    ArrayList<String> l = new ArrayList<String>();
    l.add("genero=" + generoPersonaje);
    l.add("dia=" + dia);
    l.add("guardado=" + nf(day(), 2) + "/" + nf(month(), 2) + " " + nf(hour(), 2) + ":" + nf(minute(), 2));
    l.add("stats=" + viralidad + "," + confiabilidad + "," + impacto + "," + relacionSofi);
    l.add("monedas=" + monedas);
    l.add("tienda=" + textoGuardadoTienda());
    l.add("culpa=" + culpa);
    l.add("decisiones=" + decisionesTomadas);
    // la historia de Red Quest (Situaciones.pde)
    l.add("sitResuelta=" + textoBools(sitResuelta));
    l.add("sitElegida=" + textoInts(sitElegida));
    l.add("secHecho=" + textoBools(secHecho));
    l.add("secBien=" + textoBools(secBien));
    l.add("tienePrueba=" + textoBools(tienePrueba));
    // personajes originales del colegio, cafe y barrio (Lab.pde)
    l.add("npcEleccion=" + textoInts(npcEleccion));
    l.add("eleccionBarrio=" + textoInts(eleccionBarrio));
    l.add("npcHablado=" + textoBools(npcHablado));
    l.add("visitado=" + textoBools(visitado));
    l.add("premiado=" + textoBools(premiado));
    l.add("dec=" + textoInts(dec));
    l.add("barrio=" + pD1 + "," + pD18 + "," + siguienteBarrio + "," + idDec + "," + decC);
    l.add("barrioFlags=" + textoBools(new boolean[] {tLl, llEnt, pDes, a1, a2, a3, b1, b2, b3, c1, c2, c3, premiadoTV}));
    // ruta, culpa y premios (Ruta.pde, Eventos.pde, Responsable.pde)
    l.add("ruta=" + textoBools(new boolean[] {tieneMensajeShawn, vistoJuicio, vistoSilencio, vistoSecreto}));
    l.add("contadores=" + vecesApagoCelular + "," + diasRepetidos + "," + rumoresPremiados + "," + vecesDetenido);
    l.add("dilemasPremiados=" + textoInts(dilemasPremiados));
    for (String p : pausasPremiadas) l.add("pausa=" + limpiarCampo(p));
    for (String k : recuerdos.keySet()) l.add("recuerdo=" + limpiarCampo(k) + "\t" + (recuerdos.get(k) ? "1" : "0"));
    for (Decision d : historial) {
      l.add("decision=" + limpiarCampo(d.quien) + "\t" + limpiarCampo(d.que) + "\t" + limpiarCampo(d.consecuencia) + "\t"
        + limpiarCampo(d.leccion) + "\t" + limpiarCampo(d.hora) + "\t" + (d.buena ? 1 : 0) + "\t" + (d.compartio ? 1 : 0) + "\t"
        + (d.pausa ? 1 : 0) + "\t" + d.alcance);
    }
    // las charlas de los lugares caminables: con quien ya hablaste y que elegiste
    for (int esc : clavesLugares()) {
      HashMap<String, Integer> vistos = new HashMap<String, Integer>();
      for (Interactivo it : lugares.get(esc).inter) {
        int vez = vistos.containsKey(it.nombre) ? vistos.get(it.nombre) + 1 : 0;
        vistos.put(it.nombre, vez);
        boolean terminada = it.charla != null && it.charla.terminada;
        if (!terminada && !it.hablado) continue;
        l.add("charla=" + esc + "\t" + limpiarCampo(it.nombre) + "\t" + vez + "\t" + (terminada ? 1 : 0) + "\t"
          + (it.charla != null ? it.charla.elegida : -1) + "\t" + (it.hablado ? 1 : 0));
      }
    }
    saveStrings(archivoSlot(slotActivo), l.toArray(new String[0]));
  }
  catch (Exception e) {
    println("No se pudo guardar el slot " + (slotActivo + 1) + ": " + e);
  }
}

// ------------------------------------- CARGAR -------------------------------------
void cargarSlot(int n) {
  String[] l = null;
  try {
    l = loadStrings(archivoSlot(n));
  }
  catch (Exception e) {
    println("No se pudo abrir el slot " + (n + 1) + ": " + e);
  }
  if (l == null) return;
  HashMap<String, String> m = new HashMap<String, String>();
  for (String s : l) {
    int i = s.indexOf('=');
    if (i > 0 && !m.containsKey(s.substring(0, i))) m.put(s.substring(0, i), s.substring(i + 1));
  }
  cargandoSlot = true;
  slotActivo = n;
  generoPersonaje = int(valor(m, "genero", "0")) == PERSONAJE_FEMENINO ? PERSONAJE_FEMENINO : PERSONAJE_MASCULINO;
  reiniciarPartida();   // todo desde cero, con el personaje de este slot
  try {
    dia = constrain(int(valor(m, "dia", "0")), 0, 3);
    if (dia > 0) mensajesPendientes.clear();   // sin el mensaje de Sofi del lunes si cargas otro dia
    float[] st = float(split(valor(m, "stats", "0,0,0,50"), ','));
    if (st.length >= 4) {
      viralidad = st[0];
      confiabilidad = st[1];
      impacto = st[2];
      relacionSofi = st[3];
    }
    if (m.containsKey("tienda")) cargarGuardadoTienda(m.get("tienda"));
    culpa = int(valor(m, "culpa", "0"));
    decisionesTomadas = int(valor(m, "decisiones", "0"));
    leerBools(valor(m, "sitResuelta", ""), sitResuelta);
    leerInts(valor(m, "sitElegida", ""), sitElegida);
    leerBools(valor(m, "secHecho", ""), secHecho);
    leerBools(valor(m, "secBien", ""), secBien);
    leerBools(valor(m, "tienePrueba", ""), tienePrueba);
    leerInts(valor(m, "npcEleccion", ""), npcEleccion);
    leerInts(valor(m, "eleccionBarrio", ""), eleccionBarrio);
    leerBools(valor(m, "npcHablado", ""), npcHablado);
    leerBools(valor(m, "visitado", ""), visitado);
    leerBools(valor(m, "premiado", ""), premiado);
    leerInts(valor(m, "dec", ""), dec);
    int[] b = int(split(valor(m, "barrio", "0,0,15,0,0"), ','));
    if (b.length >= 5) {
      pD1 = b[0];
      pD18 = b[1];
      siguienteBarrio = b[2];
      idDec = b[3];
      decC = b[4];
    }
    boolean[] f = new boolean[13];
    leerBools(valor(m, "barrioFlags", ""), f);
    tLl = f[0];
    llEnt = f[1];
    pDes = f[2];
    a1 = f[3];
    a2 = f[4];
    a3 = f[5];
    b1 = f[6];
    b2 = f[7];
    b3 = f[8];
    c1 = f[9];
    c2 = f[10];
    c3 = f[11];
    premiadoTV = f[12];
    if (pD1 > 0) {   // ya pasaste la intro del barrio: que no vuelva a salir el dialogo de la llave
      mostrarDialogo = false;
      textoDialogo = "";
    }
    boolean[] r = new boolean[4];
    leerBools(valor(m, "ruta", ""), r);
    tieneMensajeShawn = r[0];
    vistoJuicio = r[1];
    vistoSilencio = r[2];
    vistoSecreto = r[3];
    int[] c = int(split(valor(m, "contadores", "0,0,0,0"), ','));
    if (c.length >= 4) {
      vecesApagoCelular = c[0];
      diasRepetidos = c[1];
      rumoresPremiados = c[2];
      vecesDetenido = c[3];
    }
    leerInts(valor(m, "dilemasPremiados", ""), dilemasPremiados);
    for (String s : l) {
      int i = s.indexOf('=');
      if (i < 0) continue;
      String k = s.substring(0, i);
      String[] p = split(s.substring(i + 1), '\t');
      if (k.equals("pausa")) pausasPremiadas.add(p[0]);
      else if (k.equals("recuerdo") && p.length >= 2) recuerdos.put(p[0], p[1].equals("1"));
      else if (k.equals("decision") && p.length >= 9) {
        Decision d = new Decision();
        d.quien = p[0];
        d.que = p[1];
        d.consecuencia = p[2];
        d.leccion = p[3];
        d.hora = p[4];
        d.buena = p[5].equals("1");
        d.compartio = p[6].equals("1");
        d.pausa = p[7].equals("1");
        d.alcance = int(p[8]);
        historial.add(d);
      } else if (k.equals("charla") && p.length >= 6) {
        restaurarCharla(int(p[0]), p[1], int(p[2]), p[3].equals("1"), int(p[4]), p[5].equals("1"));
      }
    }
  }
  catch (Exception e) {
    println("El slot " + (n + 1) + " estaba danado, se cargo lo que se pudo: " + e);
  }
  cargandoSlot = false;
  // el dia empieza desde la mañana, como al despertar
  momento = 0;
  decisionesMomento = 0;
  situacionesHoy = 0;
  avisoNoche = false;
  relojJuego = horaMomento[0] + 30;
  prevViral = hudV = viralidad;
  prevConf = hudC = confiabilidad;
  prevImp = hudI = impacto;
  hudS = relacionSofi;
  aplicarRecuerdos();      // lo que cambio en el mundo por lo que hiciste (Responsable.pde)
  actualizarHistoria();    // quien esta hoy (Situaciones.pde)
  guardarInicioDia();
  actualizarSofi();
  guardarDatos();
  if (dia == 0) {
    empezarCineApertura();   // el lunes empieza otra vez con la apertura
  } else {
    partidaEmpezada = true;
    empezarCineDia();        // la tarjeta del dia y despiertas en tu cama (Casa.pde)
    bannerTexto = dia >= 3 ? "JUEVES  -  DIA DE ELECCIONES" : nombreDia[dia] + "  -  " + nombreMomento[0];
    bannerVida = 170;
    mensajeSofi(mananaSofi[min(dia, 3)][nivelSofi()], 400);
  }
}

void restaurarCharla(int esc, String nombre, int vez, boolean terminada, int elegida, boolean hablado) {
  Lugar L = lugares.get(esc);
  if (L == null) return;
  int cuenta = 0;
  for (Interactivo it : L.inter) {
    if (!it.nombre.equals(nombre)) continue;
    if (cuenta++ != vez) continue;
    it.hablado = hablado;
    if (it.charla != null) {
      it.charla.terminada = terminada;
      if (it.charla.eleccion != null && elegida >= 0 && elegida < it.charla.eleccion.length) it.charla.elegida = elegida;
    }
    return;
  }
}

// ------------------------------------- PANTALLA DE SLOTS -------------------------------------
float xSlot(int n) {
  return width / 2 - (NUM_SLOTS * ANCHO_SLOT + (NUM_SLOTS - 1) * 20) / 2.0 + n * (ANCHO_SLOT + 20);
}

void dibujarSlots() {
  dibujarFondoCiudad();
  noStroke();
  fill(10, 8, 25, 205);
  rect(0, 0, width, height);
  botonVolver();
  tituloNeon("PARTIDAS", width / 2, 62, 34, neonCian);
  for (int n = 0; n < NUM_SLOTS; n++) dibujarTarjetaSlot(n);
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  fill(185, 191, 216);
  text("Cada partida tiene su personaje y no se puede cambiar. Se guarda al empezar cada dia.", width / 2, 432);
  text("Flechas o 1 / 2 / 3 para elegir  ·  ENTER para jugar  ·  SUPR para borrar", width / 2, 452);
  if (slotBorrando >= 0) dibujarConfirmarBorrado();
}

void dibujarTarjetaSlot(int n) {
  float bx = xSlot(n), cx = bx + ANCHO_SLOT / 2;
  boolean marcado = n == slotElegido && slotBorrando < 0;
  boolean sobre = slotBorrando < 0 && encima(bx, Y_SLOT, ANCHO_SLOT, ALTO_SLOT);
  color acento = marcado || sobre ? neonAmarillo : #7277A7;
  panelNeon(bx, Y_SLOT, ANCHO_SLOT, ALTO_SLOT, acento);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(14);
  fill(acento);
  text("SLOT " + (n + 1) + (n == slotActivo && partidaEmpezada ? "  ·  EN JUEGO" : ""), cx, Y_SLOT + 20);
  HashMap<String, String> m = infoSlot[n];
  if (m == null) {
    noFill();
    stroke(acento, 160);
    strokeWeight(3);
    ellipse(cx, Y_SLOT + 120, 90, 90);
    line(cx - 20, Y_SLOT + 120, cx + 20, Y_SLOT + 120);
    line(cx, Y_SLOT + 100, cx, Y_SLOT + 140);
    noStroke();
    textSize(18);
    fill(235);
    text("Nueva partida", cx, Y_SLOT + 196);
    textSize(12);
    fill(185, 191, 216);
    text("Eliges personaje al crearla", cx, Y_SLOT + 220);
    botonNeon("Crear", bx + 40, Y_SLOT + ALTO_SLOT - 56, ANCHO_SLOT - 80, 40, neonCian, marcado);
    return;
  }
  int genero = int(valor(m, "genero", "0"));
  int d = constrain(int(valor(m, "dia", "0")), 0, 3);
  noStroke();
  fill(37, 42, 69);
  ellipse(cx, Y_SLOT + 88, 96, 96);
  fill(10, 9, 25, 130);
  ellipse(cx, Y_SLOT + 132, 66, 11);
  int cuadro = marcado || sobre ? cuadroCaminataJugadorNova(relojSpriteNova, false) : 0;
  dibujarPoseJugadorNova(genero, JUGADOR_ABAJO, cuadro, cx, Y_SLOT + 131, 2.0);
  textSize(15);
  fill(235);
  text(nombresGenero[constrain(genero, 0, 1)], cx, Y_SLOT + 152);
  textSize(13);
  fill(neonAmarillo);
  text(d >= 3 ? "JUEVES  ·  ELECCIONES" : nombreDia[d], cx, Y_SLOT + 172);
  // barras chiquitas
  float[] st = float(split(valor(m, "stats", "0,0,0,50"), ','));
  String[] et = {"VIR", "CON", "IMP", "SOFI"};
  color[] co = {neonRosa, neonCian, neonAmarillo, colorSofi};
  for (int i = 0; i < 4 && i < st.length; i++) {
    float yy = Y_SLOT + 190 + i * 11;
    textSize(9);
    textAlign(LEFT, CENTER);
    fill(185, 191, 216);
    text(et[i], bx + 26, yy);
    fill(255, 30);
    rect(bx + 60, yy - 3, 120, 6, 3);
    fill(co[i]);
    rect(bx + 60, yy - 3, 120 * constrain(st[i], 0, 100) / 100.0, 6, 3);
  }
  textAlign(CENTER, CENTER);
  textSize(11);
  fill(185, 191, 216);
  text(valor(m, "monedas", "0") + " NovaCoins  ·  " + valor(m, "guardado", ""), cx, Y_SLOT + 241);
  botonNeon(n == slotActivo && partidaEmpezada ? "Seguir" : "Continuar", bx + 14, Y_SLOT + ALTO_SLOT - 46, 122, 34, neonCian, marcado);
  botonNeon("Borrar", bx + 142, Y_SLOT + ALTO_SLOT - 46, 64, 34, neonRosa, false);
}

void dibujarConfirmarBorrado() {
  noStroke();
  fill(0, 170);
  rect(0, 0, width, height);
  panelNeon(200, 160, 400, 180, neonRosa);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(20);
  fill(255);
  text("Borrar la partida del slot " + (slotBorrando + 1) + "?", width / 2, 200);
  textSize(13);
  fill(185, 191, 216);
  text("Se pierde el avance y el personaje. No se puede deshacer.", width / 2, 232);
  botonNeon("Borrar", 230, 276, 160, 42, neonRosa, false);
  botonNeon("Cancelar", 410, 276, 160, 42, neonCian, true);
}

void clickSlots() {
  if (slotBorrando >= 0) {
    if (encima(230, 276, 160, 42)) borrarSlot(slotBorrando);
    else if (encima(410, 276, 160, 42)) slotBorrando = -1;
    return;
  }
  if (clickVolver()) {
    scene = 0;
    return;
  }
  for (int n = 0; n < NUM_SLOTS; n++) {
    float bx = xSlot(n);
    if (!encima(bx, Y_SLOT, ANCHO_SLOT, ALTO_SLOT)) continue;
    slotElegido = n;
    if (slotExiste(n) && encima(bx + 142, Y_SLOT + ALTO_SLOT - 46, 64, 34)) {
      slotBorrando = n;
      return;
    }
    boolean boton = slotExiste(n) ? encima(bx + 14, Y_SLOT + ALTO_SLOT - 46, 122, 34) : encima(bx + 40, Y_SLOT + ALTO_SLOT - 56, ANCHO_SLOT - 80, 40);
    if (boton) elegirSlot(n);
    return;
  }
}

void teclaSlots() {
  boolean enter = key == ENTER || key == RETURN || key == ' ';
  if (slotBorrando >= 0) {
    if (enter) slotBorrando = -1;   // ENTER cancela: borrar solo con clic, para no borrar sin querer
    return;
  }
  if ((key == CODED && keyCode == LEFT) || key == 'a' || key == 'A') slotElegido = (slotElegido + NUM_SLOTS - 1) % NUM_SLOTS;
  else if ((key == CODED && keyCode == RIGHT) || key == 'd' || key == 'D') slotElegido = (slotElegido + 1) % NUM_SLOTS;
  else if (key >= '1' && key < '1' + NUM_SLOTS) slotElegido = key - '1';
  else if (key == DELETE || key == BACKSPACE) {
    if (slotExiste(slotElegido)) slotBorrando = slotElegido;
  } else if (enter) {
    if (keyEvent == null || !keyEvent.isAutoRepeat()) elegirSlot(slotElegido);
  }
}

// ------------------------------------- AYUDANTES -------------------------------------
String valor(HashMap<String, String> m, String k, String porDefecto) {
  return m != null && m.containsKey(k) ? m.get(k) : porDefecto;
}

String limpiarCampo(String s) {
  if (s == null) return "";
  return s.replace('\t', ' ').replace('\n', ' ').replace('\r', ' ');
}

String textoBools(boolean[] a) {
  String t = "";
  for (boolean b : a) t += b ? "1" : "0";
  return t;
}

void leerBools(String t, boolean[] a) {
  for (int i = 0; i < min(t.length(), a.length); i++) a[i] = t.charAt(i) == '1';
}

String textoInts(int[] a) {
  return join(nf(a, 0), ",");
}

void leerInts(String t, int[] a) {
  if (t.equals("")) return;
  int[] v = int(split(t, ','));
  for (int i = 0; i < min(v.length, a.length); i++) a[i] = v[i];
}

int[] clavesLugares() {
  int[] k = new int[lugares.size()];
  int i = 0;
  for (int c : lugares.keySet()) k[i++] = c;
  return sort(k);
}

// ------------------------------------- TEXTOS SEGUN EL PERSONAJE -------------------------------------
// En los dialogos se escribe {masculino|femenino}, por ejemplo "Bienvenid{o|a}" o "mij{o|a}".
// Pixel.pde pasa todo el texto que se dibuja por aqui, asi que funciona en dialogos, avisos y el celular.
String textoGenero(String t) {
  if (t == null || t.indexOf('{') < 0) return t;
  StringBuilder sb = new StringBuilder();
  int i = 0;
  while (i < t.length()) {
    char ch = t.charAt(i);
    int barra = ch == '{' ? t.indexOf('|', i) : -1;
    int fin = ch == '{' ? t.indexOf('}', i) : -1;
    if (ch != '{') {
      sb.append(ch);
      i++;
    } else if (fin < 0) {
      break;   // marca a medio escribir (efecto maquina de escribir): se muestra hasta aqui
    } else if (barra < 0 || barra > fin) {
      sb.append(t, i, fin + 1);   // llaves normales: se dejan como estan
      i = fin + 1;
    } else {
      sb.append(generoPersonaje == PERSONAJE_FEMENINO ? t.substring(barra + 1, fin) : t.substring(i + 1, barra));
      i = fin + 1;
    }
  }
  return sb.toString();
}
