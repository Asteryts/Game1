// =====================================================================================
//  RUTA.pde -> fase 3 de la union con Red Quest
//   1. Juego mas lineal: de dia el mapa solo deja entrar a donde sigue la historia
//      (y "Ir a ..." te lleva directo). De noche puedes explorar todo.
//   2. Culpa y ambiente: tus malas decisiones oscurecen Nova, la gente murmura
//      y Shawn (un fantasma) te susurra. Las buenas la iluminan.
//   3. Shawn: aparece en el Callejon de los murales las noches del lunes y martes.
//   4. La noche en el celular: antes de dormir lees Conecta y a Sofi. Con culpa, insomnio.
//   5. Finales: el juicio de Shawn, el silencio, el final secreto DESCONECTADO
//      y un epilogo con la verdad de @chismes_11B y lo que paso con cada persona.
//   6. Ropa en la tienda (los outfits de Red Quest).
//  Escenas: 74 juicio, 75 silencio, 76 epilogo, 77 final secreto.
// =====================================================================================

final int ESC_JUICIO = 74;
final int ESC_SILENCIO = 75;
final int ESC_EPILOGO = 76;
final int ESC_FINAL_SECRETO = 77;

// ------------------------------------- 1. JUEGO LINEAL -------------------------------------
// a que pin del mapa pertenece cada escena: 0 colegio, 1 barrio, 2 alcaldia/avenida, 3 parque, 4 centro, 5 estudio, 6 plaza
int pinDeEscena(int s) {
  if (s == 7 || s == 17 || (s >= 25 && s <= 27) || (s >= 57 && s <= 60)) return 0;
  if (esBarrio(s) || s == 54 || s == 55 || s == 56) return 1;
  if (s == 24 || s == 52 || s == 53) return 2;
  if (s == 45) return 3;
  if (s == 46) return 4;
  if (s == 47) return 5;
  if (s == 48) return 6;
  if (s == 78) return 1;   // tu casa queda en el barrio
  return -1;
}

// a donde lleva la historia ahora (escena caminable), o -1
int escenaObjetivo() {
  if (postJuego) return -1;   // despues del final no hay a donde ir: se explora libre (PostJuego.pde)
  if (dia >= 3) return ESC_PLAZA;
  int s = situacionActual();
  if (s >= 0) return lugarSit[s];
  for (int k = 0; k < 6; k++) if (secDisponible(k)) return lugarSec[k];
  if (momento == 3 && dia <= 1 && !tieneMensajeShawn) return ESC_CALLEJON;
  if (momento == 3) return ESC_CASA;   // a dormir (Casa.pde)
  return -1;
}

boolean pinPermitido(int i) {
  if (dia >= 3 || momento == 3) return true;   // de noche y el jueves: libre
  int obj = escenaObjetivo();
  if (obj >= 0 && pinDeEscena(obj) == i) return true;
  for (int k = 0; k < 6; k++) if (secDisponible(k) && pinDeEscena(lugarSec[k]) == i) return true;
  return false;
}

String nombreEscenaCorto(int s) {
  for (int k = 0; k < lugarSit.length; k++) if (lugarSit[k] == s) return nombreLugarSit[k];
  for (int k = 0; k < lugarSec.length; k++) if (lugarSec[k] == s) return nombreLugarSec[k];
  if (s == ESC_PLAZA) return "la Plaza de la Votacion";
  if (s == ESC_CALLEJON) return "el Callejon de los murales";
  if (s == ESC_CASA) return "tu casa";
  return "alla";
}

int lugarMapaEncima() {
  if (popupAbierto || telefonoAbierto || pausaAbierta || kioscoMapaEncima() >= 0) return -1;
  for (int i = 0; i < lugaresMapa.length; i++) {
    float[] l = lugaresMapa[i];
    if (mouseX > l[0] && mouseX < l[2] && mouseY > l[1] && mouseY < l[3]) return i;
  }
  return -1;
}

// candados, el "SIGUIENTE" y el boton para ir directo (se dibuja encima del mapa)
void dibujarGuiaMapa() {
  int obj = escenaObjetivo();
  int pinObj = obj >= 0 ? pinDeEscena(obj) : -1;
  for (int i = 0; i < lugaresMapa.length; i++) {
    float[] l = lugaresMapa[i];
    if (!pinPermitido(i)) {
      // candado gris encima del pin
      noStroke();
      fill(20, 18, 30, 210);
      ellipse(l[5], l[6] - 6, 22, 22);
      fill(150);
      rect(l[5] - 6, l[6] - 7, 12, 9, 2);
      noFill();
      stroke(150);
      strokeWeight(2);
      arc(l[5], l[6] - 8, 8, 10, PI, TWO_PI);
      noStroke();
    } else if (i == pinObj) {
      float r = 30 + 8 * sin(frameCount * 0.12);
      noFill();
      stroke(neonAmarillo, 220);
      strokeWeight(3);
      ellipse(l[5], l[6] - 6, r, r);
      noStroke();
      fill(neonAmarillo);
      textFont(fuenteUI);
      textSize(10);
      float tw = 66;
      rect(l[5] - tw / 2, l[6] - 44, tw, 15, 7);
      fill(20);
      textAlign(CENTER, CENTER);
      text("SIGUIENTE", l[5], l[6] - 37);
    }
  }
  int enc = lugarMapaEncima();
  if (enc >= 0 && !pinPermitido(enc)) {
    float[] l = lugaresMapa[enc];
    textFont(fuenteUI);
    textSize(11);
    String t = "Cerrado por ahora. Primero: " + textoObjetivo();
    float w = textWidth(t) + 20;
    float tx = constrain(l[5] - w / 2, 6, width - w - 6), ty = constrain(l[6] + 22, 6, height - 30);
    fill(8, 6, 22, 240);
    rect(tx, ty, w, 24, 8);
    fill(neonAmarillo);
    textAlign(LEFT, CENTER);
    text(t, tx + 10, ty + 11);
  }
  // ir directo a donde sigue la historia
  if (obj >= 0 && !popupAbierto && !telefonoAbierto && !pausaAbierta) {
    String t = textoIrA(obj);
    textFont(fuenteUI);
    textSize(14);
    float w = min(330, textWidth(t) + 40);
    float b = 0.5 + 0.5 * sin(frameCount * 0.08);
    noStroke();
    fill(neonAmarillo, 30 * b);
    rect(10, 432, w + 16, 56, 16);
    botonNeon(t, 18, 440, w, 40, neonAmarillo, false);
  }
}

boolean clickGuiaMapa() {
  int obj = escenaObjetivo();
  if (obj >= 0) {
    String t = textoIrA(obj);
    textFont(fuenteUI);
    textSize(14);
    float w = min(330, textWidth(t) + 40);
    if (encima(18, 440, w, 40)) {
      if (obj == ESC_CASA) irACasa(false);
      else entrarLugar(obj);
      return true;
    }
  }
  int enc = lugarMapaEncima();
  if (enc >= 0 && !pinPermitido(enc)) {
    flotar("Primero: " + textoObjetivo(), mouseX, mouseY - 20, neonAmarillo);
    sonar(7);
    return true;
  }
  return false;
}

// un anillo amarillo debajo de quien sigue en la historia (en los lugares)
void dibujarGuiaLugar() {
  if (!esCaminable(scene) || charlaActiva != null || situacionAbierta()) return;
  Lugar L = lugares.get(scene);
  if (L == null) return;
  for (Interactivo it : L.inter) {
    if (it.ausente || !tieneAlgoImportante(it)) continue;
    float r = 46 + 6 * sin(frameCount * 0.12);
    noFill();
    stroke(neonAmarillo, 200);
    strokeWeight(2.5);
    ellipse(it.ix, it.iy + 2, r, r * 0.35);
    noStroke();
  }
}

// ------------------------------------- 2. CULPA Y AMBIENTE -------------------------------------
int culpa = 0;
int inicioCulpa = 0;
int avisoCulpa = 0;
int[] umbralCulpa = {3, 5, 7};
int[] quienCulpa = {0, 5, 5};   // Ruben, Profe Lucia, Profe Lucia
String[] textoCulpa = {
  "Oye, espera. Te he visto estos dias. Esto todavia tiene arreglo, pero no va a durar para siempre.",
  "Se lo que esta pasando en Conecta, y se que tu estas en medio. No tiene que terminar asi. Mi puerta esta abierta.",
  "Ya no te voy a perseguir. Solo piensa esto esta noche: a quien le estas haciendo caso?"
};
String[][] fraseGente = {
  {"Mira, esa es la persona de la que te hable.", "Cuidado con lo que dices aqui cerca.", "Yo no dije nada. No quiero salir en tu proxima publicacion.", "Que valor el tuyo, salir asi a la calle."},
  {"Viste lo ultimo en Conecta?", "Hoy esta pesado el dia.", "No me distraigas, estoy respondiendo algo.", "Dicen que @chismes_11B sabe todo de todos."},
  {"Buen dia!", "Todo tranquilo por aqui.", "Hola! Que bueno que pases.", "Hoy hasta da gusto salir."}
};
String[][] susurroShawn = {
  {"Lo viste? Yo tambien lo vi... y me calle.", "Todavia estas a tiempo.", "Mirame. Asi termine."},
  {"Te estas pareciendo a ellos.", "Cada vez que compartes, alguien deja de venir.", "No hagas lo que yo no hice."},
  {"Ya casi no te reconozco.", "Al final te vas a quedar solo con la pantalla.", "Nadie va a decir nada. Como conmigo."}
};

void sumarCulpa() {
  culpa++;
  if (avisoCulpa < 3 && culpa >= umbralCulpa[avisoCulpa]) {
    avisar(nombreSec[quienCulpa[avisoCulpa]], textoCulpa[avisoCulpa], neonMorado);
    avisoCulpa++;
  }
}

boolean rutaMala() {
  return culpa >= 3 || nivelAmbiente() == 0;
}

int nivelCulpa() {
  return min(2, culpa / 2);
}

float tShawnSusurro = 0;
int susurroActual = 0;

void dibujarAtmosfera() {
  if (!esExploracion(scene) && scene != 1) return;
  int amb = nivelAmbiente();
  noStroke();
  if (amb == 0) {
    float f = frameCount % 300 < 4 ? 30 : 0;   // a veces la luz parpadea
    fill(26, 4, 30, 95 + f);
    rect(0, 0, width, height);
  } else if (amb == 2) {
    fill(255, 210, 120, 16);
    rect(0, 0, width, height);
    if (frameCount % 12 == 0 && !pausaAbierta) agregarParticula(new Particula(random(width), random(80, height), random(-0.2, 0.2), random(-0.5, -0.2), random(90, 160), random(2, 3.5), color(255, 240, 180), 6));
  }
  if (!esCaminable(scene) || pausaAbierta || telefonoAbierto || charlaActiva != null || situacionAbierta()) return;
  // la gente murmura (o saluda) al pasar
  int cada = amb == 0 ? 260 : (amb == 2 ? 520 : 0);
  if (cada > 0 && frameCount % cada == 0) {
    Lugar L = lugares.get(scene);
    ArrayList<Interactivo> gente = new ArrayList<Interactivo>();
    for (Interactivo it : L.inter) if (it.tipo == 0 && !it.ausente && !tieneAlgoImportante(it)) gente.add(it);
    if (gente.size() > 0) {
      Interactivo it = gente.get(int(random(gente.size())));
      flotantes.add(new TextoFlotante(fraseGente[amb][int(random(4))], it.ix, it.iy - 98, amb == 0 ? color(230, 190, 220) : color(255), 12, 220, true));
    }
  }
  // Shawn susurra si vas por mal camino
  if (rutaMala()) {
    tShawnSusurro++;
    if (tShawnSusurro > 1100) {
      tShawnSusurro = 0;
      susurroActual = int(random(3));
    }
    if (tShawnSusurro < 260) {
      float a = min(1, tShawnSusurro / 40.0) * min(1, (260 - tShawnSusurro) / 40.0);
      dibujarFantasma(735, 300, a);
      fill(220, 235, 255, 230 * a);
      textFont(fuenteUI);
      textSize(12);
      textAlign(RIGHT, CENTER);
      text("Shawn: \"" + susurroShawn[nivelCulpa()][susurroActual] + "\"", 700, 250);
    }
  }
}

// La capucha esconde el rostro incluso cuando Shawn habla.
void dibujarFantasma(float fx, float pies, float a) {
  pushStyle();
  tint(255, 255 * constrain(a, 0, 1));
  boolean dibujado = dibujarPersonaNova("Shawn", fx, pies, 0);
  popStyle();
  if (dibujado) return;
  float b = sin(frameCount * 0.06) * 4;
  noStroke();
  fill(57, 47, 101, 220 * a);
  ellipse(fx, pies - 73 + b, 37, 38);
  beginShape();
  vertex(fx - 22, pies - 63 + b);
  vertex(fx + 22, pies - 63 + b);
  for (int k = 0; k <= 4; k++) vertex(fx + 28 - k * 14, pies - 9 + b + (k % 2 == 0 ? 0 : -8));
  endShape(CLOSE);
  fill(10, 8, 21, 235 * a);
  quad(fx, pies - 88 + b, fx + 13, pies - 74 + b, fx, pies - 61 + b, fx - 13, pies - 74 + b);
}

// ------------------------------------- 3. SHAWN -------------------------------------
boolean tieneMensajeShawn = false;
Interactivo npcShawn = null;

void prepararShawn() {
  npcShawn = new Interactivo(450, 330, "Shawn", 5);
  npcShawn.charla = new Charla("Shawn", new String[] {
    "Shawn: ...Tu puedes verme? Hace dos años que nadie me ve.",
    "Shawn: No te quedes callado como yo. Vi lo que le hacian a alguien en Conecta, y despues me lo hicieron a mi. Nadie dijo nada.",
    "Shawn: Guarda este mensaje. Al final sabras que hacer."
  });
  Lugar L = lugares.get(ESC_CALLEJON);
  if (L != null) L.agregar(npcShawn);
}

void actualizarShawn() {
  if (npcShawn != null) npcShawn.ausente = !(momento == 3 && dia <= 1);
}

boolean hablarConShawn(Interactivo it) {
  if (it != npcShawn) return false;
  abrirCharla(npcShawn.charla);
  if (!tieneMensajeShawn) {
    tieneMensajeShawn = true;
    avisar("Mensaje de Shawn", "\"No te quedes callado como yo.\" (Se desbloqueo la Capa de Shawn en la tienda)", color(200, 215, 255));
  }
  return true;
}

// ------------------------------------- 4. LA NOCHE EN EL CELULAR -------------------------------------
String[][] nocheFeed = {
  {"Lo que compartiste hoy llego a 300 personas. @chismes_11B lo republico con un comentario: \"gracias por el material\".", "Hoy fue un dia raro en Conecta. @chismes_11B publico algo y lo borro a los dos minutos.", "Hoy nadie hablo mal de nadie en el grupo del salon. Alguien pregunto por que."},
  {"Te etiquetaron en 14 comentarios. No lees ninguno. Los lees todos.", "El barrio comenta lo de hoy. Tu nombre aparece dos veces, sin mala intencion. Por ahora.", "Una vecina escribio: \"al menos alguien aqui piensa antes de publicar\"."},
  {"Mañana es la eleccion. @chismes_11B publico: \"todo esto es gracias a ustedes\". Tu nombre esta en la lista de quienes mas comparten.", "Mañana es la eleccion. Nadie sabe quien esta detras de @chismes_11B. Todos creen saberlo.", "Mañana es la eleccion. Por primera vez en dias, tu celular no suena."}
};
String[][] nocheSofiRQ = {
  {"Sofi te bloqueo.", "Sofi esta escribiendo... Sofi elimino un mensaje.", "Sofi: \"Estas despiert@?\"  Visto a las 2:14.", "Sofi: \"Gracias por hoy. En serio.\""},
  {"Sofi te elimino de sus contactos. Su foto ya no aparece.", "Le escribes a Sofi. Visto. Nada mas.", "Nota de voz de Sofi, 0:04. Solo se oye que respira y la corta.", "Sofi: \"Hay algo que tengo que contarte. Despues.\""},
  {"Buscas a Sofi en Conecta: Este usuario ya no existe.", "Sofi esta escribiendo... escribiendo... Nada.", "Nota de voz de Sofi a medianoche: \"Ya no se en quien confiar.\"", "Sofi: \"Pase lo que pase mañana, gracias por quedarte.\""}
};
String[] susurroNoche = {
  "Shawn, desde la ventana: \"Yo tambien miraba el celular a esta hora.\"",
  "Shawn: \"Ya viste lo que causaste hoy?\"",
  "Shawn: \"Mañana todavia puedes elegir distinto. Yo ya no.\""
};
String[] comentarioTi = {"@anonimo: y tu, que vas a hacer esta vez?", "@anonimo: te estamos viendo.", "@anonimo: ya sabemos como terminas tu.", "@anonimo: comparte, como siempre."};

int faseNoche = 0;        // 0 el celular en la cama, 1 el resumen del dia
boolean insomnio = false;
boolean noPuedesDormir = false;
int vecesApagoCelular = 0;

int nivelSofiNoche() {
  if (relacionSofi < 20) return 0;
  if (relacionSofi < 35) return 1;
  if (relacionSofi < 65) return 2;
  return 3;
}

void empezarNoche() {
  faseNoche = 0;
  insomnio = nivelAmbiente() == 0 || culpa >= 5;
  noPuedesDormir = false;
}

void dibujarNocheCelular() {
  int d = min(dia, 2);
  background(6, 6, 14);
  noStroke();
  // la luz del celular en la cara
  for (int i = 6; i >= 1; i--) {
    fill(120, 160, 255, 6);
    ellipse(width / 2, 250, 300 + i * 70, 420 + i * 60);
  }
  float px = 230, py = 18, pw = 340, ph = 400;
  fill(18, 16, 28);
  rect(px, py, pw, ph, 28);
  fill(10, 10, 20);
  rect(px + 12, py + 12, pw - 24, ph - 24, 20);
  textFont(fuenteUI);
  fill(150, 150, 170);
  textAlign(CENTER, TOP);
  textSize(36);
  text(insomnio && noPuedesDormir ? "02:14" : "23:47", width / 2, py + 26);
  // conecta
  fill(25, 25, 40);
  rect(px + 24, py + 86, pw - 48, 112, 12);
  fill(#9FD3FF);
  textAlign(LEFT, TOP);
  textSize(11);
  text("conecta", px + 38, py + 94);
  fill(235);
  textSize(13);
  text(nocheFeed[d][nivelAmbiente()], px + 38, py + 112, pw - 76, 80);
  // mensajes
  fill(25, 25, 40);
  rect(px + 24, py + 208, pw - 48, 78, 12);
  fill(colorSofi);
  textSize(11);
  text("mensajes", px + 38, py + 216);
  fill(235);
  textSize(13);
  text(nocheSofiRQ[d][nivelSofiNoche()], px + 38, py + 234, pw - 76, 50);
  if (culpa >= 3) {
    fill(neonRosa, 200);
    textSize(11);
    text(comentarioTi[(culpa + d) % 4], px + 38, py + 298, pw - 76, 30);
  }
  if (rutaMala()) {
    dibujarFantasma(680, 300, 0.7 + 0.3 * sin(frameCount * 0.05));
    fill(220, 235, 255, 200);
    textAlign(CENTER, TOP);
    textSize(13);
    text(susurroNoche[d], 590, 380, 190, 60);
  }
  if (noPuedesDormir) {
    fill(neonRosa);
    textAlign(CENTER, CENTER);
    textSize(13);
    text("No puedes dormir. Vuelves a mirar el celular.", width / 2, 436);
    botonNeon("Intentar dormir", 180, 452, 200, 38, neonMorado, false);
    botonNeon("Apagar el celular", 420, 452, 200, 38, neonVerde, frameCount % 60 < 30);
  } else {
    botonNeon(insomnio ? "Intentar dormir" : "Dormir", 300, 446, 200, 42, neonMorado, frameCount % 60 < 30);
  }
}

void clickNocheCelular() {
  if (noPuedesDormir) {
    if (encima(180, 452, 200, 38)) {
      // sigues sin poder dormir... pero al final caes
      noPuedesDormir = false;
      insomnio = false;
      faseNoche = 1;
      tFinDia = 0;
    } else if (encima(420, 452, 200, 38)) {
      vecesApagoCelular++;
      noPuedesDormir = false;
      insomnio = false;
      faseNoche = 1;
      tFinDia = 0;
      cambiarRelacionSofi(2);
      sonar(13);
    }
    return;
  }
  if (encima(300, 446, 200, 42)) {
    if (insomnio) {
      noPuedesDormir = true;
      sonar(3);
    } else {
      faseNoche = 1;
      tFinDia = 0;
    }
  }
}

// ------------------------------------- 5. FINALES -------------------------------------
String[] tituloFinalRQ = {"EL LIMBO", "EN EQUILIBRIO", "EL VIAJE", "EL ULTIMO REFUGIO"};
String[] textoFinalRQ = {
  "Sofi se fue sin despedirse. Anoche entendiste quien alimento a @chismes_11B: cada cosa que compartiste le dio fuerza. La cuenta sigue activa. Tu tambien.",
  "La eleccion paso y nadie aclaro nada. Kevin borro su cuenta esa misma noche y nunca pudiste probar que fue el. Cada vez que te saluda, sonrie un poco de mas.",
  "Camila manejaba @chismes_11B por envidia, y las pruebas que juntaste la expusieron. La ciudad respira, pero los videos siguen circulando en algun lado. Eso no se borra.",
  "Sofi te lo confeso: ella creo @chismes_11B para defenderse y se le salio de las manos. Tu le ayudaste sin saberlo. Siguen juntos, y ninguno de los dos duerme bien."
};
String[] epilogoBien = {
  "El conserje Ruben ahora saluda a todos por su nombre.",
  "Tomas ya tiene amigos en el salon.",
  "Don Ernesto les enseña a sus vecinos a detectar estafas.",
  "Luna volvio a casa gracias a los vecinos.",
  "Daniel ahora pide permiso antes de grabar a alguien.",
  "La profe Lucia uso tu respuesta en su clase."
};
String[] epilogoMal = {
  "Ruben se resbalo en el piso que todos grababan. El video sigue circulando.",
  "Tomas dejo el colegio a mitad de año. Su pupitre ya lo ocupa otro.",
  "Don Ernesto perdio sus ahorros.",
  "De Luna solo aparecio el collar.",
  "El video que Daniel te grabo se hizo viral. Todavia lo comparten.",
  "La profe Lucia pregunto por ti tres veces. Despues dejo de preguntar."
};
String[] silencioLineas = {
  "Sofi dejo el colegio en junio.",
  "Su cuenta dice: Este usuario ya no existe.",
  "@chismes_11B te mando un mensaje: \"Gracias por todo\".",
  "Tomas. Don Ernesto. Luna. Ya nadie pregunta.",
  "Nadie va a hablar de esto.",
  "Tomas el celular. Escribes: \"Hoy fue un buen dia :)\"",
  "Publicado. Le gusta a 1 persona: a ti."
};
String[] cierreJuicio = {
  "Shawn: \"Al menos ahora lo sabes. Yo nunca tuve esa oportunidad.\"",
  "Shawn: \"Entonces no hay nada mas que decir.\" Y se va."
};
boolean finalSecretoElegido = false;
boolean vistoJuicio = false, vistoSilencio = false, vistoSecreto = false;
float tEscenaFinal = 0;
int respuestaJuicio = -1;

int contarBienSec() {
  int n = 0;
  for (boolean b : secBien) if (b) n++;
  return n;
}

boolean finalSecretoDisponible() {
  return tienePrueba[0] && tienePrueba[1] && tienePrueba[2] && tieneMensajeShawn && contarBienSec() >= 4 && relacionSofi >= 40;
}

float promedioAmbiente() {
  return 50 + (confiabilidad + impacto) * 0.25 - viralidad * 0.5 + (relacionSofi - 50) * 0.2 - culpa * 3;
}

int indiceFinalRQ() {
  int a = nivelAmbiente();
  if (a == 0 && relacionSofi >= 65) return 3;
  return a;
}

boolean esSilencio() {
  return promedioAmbiente() < 25 && relacionSofi < 25;
}

// se llama al principio de irAlFinal (Escenarios.pde): primero estas escenas, despues los resultados
boolean desviarFinal() {
  if (finalSecretoElegido && !vistoSecreto) {
    tEscenaFinal = 0;
    scene = ESC_FINAL_SECRETO;
    return true;
  }
  if (!finalSecretoElegido && esSilencio() && !vistoSilencio) {
    tEscenaFinal = 0;
    empezarAnimFinal(3, ESC_SILENCIO);   // (Finales.pde)
    return true;
  }
  if (!finalSecretoElegido && indiceFinalRQ() == 0 && !vistoJuicio) {
    tEscenaFinal = 0;
    respuestaJuicio = -1;
    scene = ESC_JUICIO;
    return true;
  }
  return false;
}

void dibujarJuicio() {
  background(5, 5, 8);
  if (!pausaAbierta) tEscenaFinal++;
  dibujarFantasma(width / 2, 110, 0.9);
  textFont(fuenteUI);
  fill(190);
  textAlign(CENTER, TOP);
  textSize(15);
  text("Shawn: \"Antes de terminar, mira lo que hiciste.\"", width / 2, 118);
  int visibles = min(9, int(tEscenaFinal / 30));
  textSize(12);
  for (int i = 0; i < visibles; i++) {
    String hecho = "No estuviste.";
    fill(130);
    if (sitElegida[i] >= 0) {
      hecho = textoOpcionSit(i, sitElegida[i]);
      fill(puntosDe(i, sitElegida[i]) > 0 ? #8FE3A0 : #F28B8B);
    }
    text(nombreDia[i / 3] + "  -  " + nombreMomento[i % 3] + ":   " + hecho, width / 2, 146 + i * 22);
  }
  if (tEscenaFinal < 300) return;
  fill(255);
  textSize(20);
  text("Valio la pena?", width / 2, 356);
  if (respuestaJuicio == -1) {
    botonNeon("No", 230, 392, 160, 44, neonCian, false);
    botonNeon("Si", 410, 392, 160, 44, neonRosa, false);
    return;
  }
  fill(220, 235, 255);
  textSize(15);
  text(cierreJuicio[respuestaJuicio], width / 2, 392);
  botonNeon("Continuar", 300, 432, 200, 44, neonMorado, frameCount % 60 < 30);
}

void clickJuicio() {
  if (tEscenaFinal < 300) {
    tEscenaFinal = 300;
    return;
  }
  if (respuestaJuicio == -1) {
    if (encima(230, 392, 160, 44)) respuestaJuicio = 0;
    else if (encima(410, 392, 160, 44)) respuestaJuicio = 1;
    return;
  }
  if (encima(300, 432, 200, 44)) {
    vistoJuicio = true;
    irAlFinal();
  }
}

void dibujarSilencio() {
  background(5, 5, 8);
  if (!pausaAbierta) tEscenaFinal++;
  int visibles = min(silencioLineas.length, int(tEscenaFinal / 110) + 1);
  textFont(fuenteUI);
  fill(190);
  textAlign(CENTER, TOP);
  textSize(18);
  for (int i = 0; i < visibles; i++) text(silencioLineas[i], width / 2, 60 + i * 46);
  if (visibles == silencioLineas.length) {
    fill(110);
    textSize(12);
    text("Si algo asi te pasa a ti o a alguien, habla con un adulto de confianza.", width / 2, 400);
    botonNeon("Continuar", 300, 430, 200, 44, neonMorado, false);
  }
}

void clickSilencio() {
  if (tEscenaFinal < silencioLineas.length * 110) tEscenaFinal = silencioLineas.length * 110;
  else if (encima(300, 430, 200, 44)) {
    vistoSilencio = true;
    irAlFinal();
  }
}

void dibujarFinalSecreto() {
  if (!pausaAbierta) tEscenaFinal++;
  background(#F3E7CF);
  noStroke();
  fill(#E0CFA8);
  rect(0, 330, width, 170);
  // todos en la plaza, sin celulares
  dibujarSofiCuerpo(330, 360, frameCount * 0.05, false);   // (Sofi.pde)
  dibujarNPCCuerpo(420, 360, #3A7BD5, #1E1E1E, frameCount * 0.05 + 1, false);
  dibujarNPCCuerpo(500, 360, #FF8C3C, #141414, frameCount * 0.05 + 2, false);
  dibujarFantasma(640, 360, 0.6);
  textFont(fuenteUI);
  fill(#7A5CC8);
  textAlign(CENTER, TOP);
  textSize(16);
  text("FINAL SECRETO", width / 2, 24);
  tituloNeon("DESCONECTADO", width / 2, 70, 44, color(40));
  textFont(fuenteUI);
  fill(40);
  textSize(14);
  text("Apagaste el celular y lo dijiste en voz alta: Kevin abrio @chismes_11B, Sofi la uso para defenderse y tu la hiciste crecer. Nadie salio limpio. "
    + "Pero por primera vez nadie miro una pantalla. Shawn, desde lejos, dejo de esperar: esta vez alguien hablo.", 120, 104, 560, 110);
  fill(80);
  textSize(12);
  text("Dias repetidos: " + diasRepetidos + "   -   Insignias: " + contarBienSec() + "/6   -   Relacion con Sofi: " + int(relacionSofi), width / 2, 222);
  if (tEscenaFinal > 90) botonNeon("Ver los resultados", 290, 430, 220, 46, #7A5CC8, frameCount % 60 < 30);
}

void clickFinalSecreto() {
  if (tEscenaFinal > 90 && encima(290, 430, 220, 46)) {
    vistoSecreto = true;
    desbloquear(9);
    irAlFinal();
  } else if (tEscenaFinal <= 90) tEscenaFinal = 90;
}

void dibujarEpilogo() {
  if (!pausaAbierta) tEscenaFinal++;
  int k = indiceFinalRQ();
  color[] fondo = {#15161F, #1A1D2C, #241F1B, #2A1520};
  background(finalSecretoElegido ? #2A2440 : fondo[k]);
  textFont(fuenteUI);
  fill(180);
  textAlign(CENTER, TOP);
  textSize(13);
  text("LA VERDAD DE @chismes_11B", width / 2, 18);
  tituloNeon(finalSecretoElegido ? "DESCONECTADO" : tituloFinalRQ[k], width / 2, 56, 34, finalSecretoElegido ? #B4A0FF : (k == 2 ? neonAmarillo : (k == 0 ? color(150) : neonRosa)));
  textFont(fuenteUI);
  fill(230);
  textSize(13);
  String t = finalSecretoElegido ? "Kevin la abrio, Sofi la uso para defenderse y tu la hiciste crecer. Lo dijiste en voz alta, y por eso todo cambio." : textoFinalRQ[k];
  text(t, 110, 84, 580, 70);
  fill(colorSofi);
  text(epilogoSofi[nivelSofi()], 110, 150, 580, 40);
  // lo que paso con cada persona
  fill(10, 10, 25, 220);
  rect(110, 192, 580, 196, 12);
  textAlign(LEFT, TOP);
  textSize(12);
  for (int i = 0; i < 6; i++) {
    float a = constrain((tEscenaFinal - 20 - i * 15) / 15.0, 0, 1);
    boolean bien = secBien[i];
    fill(bien ? #8FE3A0 : #F28B8B, 255 * a);
    text((bien ? "+  " : "-  ") + (bien ? epilogoBien[i] : epilogoMal[i]), 130, 204 + i * 30, 540, 28);
  }
  botonNeon("Ver tu historial", 110, 418, 180, 48, neonAmarillo, false);
  botonNeon("Nueva partida", 310, 418, 180, 48, neonRosa, false);
  botonNeon("Seguir explorando", 510, 418, 180, 48, neonCian, false);
}

void clickEpilogo() {
  if (encima(110, 418, 180, 48)) {
    historialScroll = 0;
    scene = ESC_HISTORIAL;
  } else if (encima(310, 418, 180, 48)) {
    reiniciarPartida();
    scene = 0;
  } else if (encima(510, 418, 180, 48)) {
    empezarPostJuego();   // Nova despues de la eleccion (PostJuego.pde)
    scene = 1;
  }
}

// opcion secreta del miercoles (situacion 8): "Apagar el celular"
String textoOpcionSit(int s, int o) {
  if (o == 4) return "Apagar el celular y decirlo todo en voz alta.";
  return opcionSit[s][o];
}

float puntosDe(int s, int o) {
  return o == 4 ? 20 : puntosSit[s][o];
}

float relacionDe(int s, int o) {
  return o == 4 ? 15 : relacionSit[s][o];
}

String consecuenciaDe(int s, int o) {
  if (o == 4) return "Apagas el celular. Antes, escribes una sola cosa: \"Mañana en la plaza. Sin pantallas. Tengo algo que contar.\"";
  return consecuenciaSit[s][o];
}

// ------------------------------------- 6. ROPA (outfits de Red Quest) -------------------------------------
String[] nombreRopa = {"Bufanda roja", "Sudadera Conecta", "Overol de Ruben", "Capa de Shawn", "Chaqueta de estrellas"};
String[] descRopa = {
  "Una bufanda tejida, roja como las alertas de Conecta. Abriga y combina con todo.",
  "La sudadera oficial de Conecta. Ironica, comoda y azul.",
  "El overol de trabajo del conserje Ruben. Te lo regala si lo ayudaste con los conos.",
  "Una capa palida que brilla un poco. Solo la tiene quien escucho a Shawn.",
  "La chaqueta de la campaña de Sofi. Brilla con estrellitas cuando caminas."
};
int[] precioRopa = {40, 80, 0, 0, 150};
color[] colorRopa = {#C8283C, #4856E8, #E07B39, #DDE6F5, #F2C230};
boolean[] tengoRopa = new boolean[5];
int ropaPuesta = -1;
boolean modoRopa = false;
int ropaElegida = 0;

boolean ropaDisponible(int i) {
  if (i == 2) return secBien[0];
  if (i == 3) return tieneMensajeShawn;
  return true;
}

String requisitoRopa(int i) {
  if (i == 2) return "Ayuda al conserje Ruben (lunes en la mañana, Cafeteria)";
  if (i == 3) return "Escucha a Shawn (una noche, Callejon de los murales)";
  return "";
}

void dibujarRopaTienda() {
  for (int i = 0; i < nombreRopa.length; i++) {
    float cx = cardX(i), cy = cardY(i), cw = 172, chh = 96;
    boolean s = encima(cx, cy, cw, chh);
    boolean elegido = i == ropaElegida;
    color c = colorRopa[i];
    float lev = s ? -3 : 0;
    noStroke();
    fill(14, 10, 32, 235);
    rect(cx, cy + lev, cw, chh, 14);
    stroke(c, elegido ? 255 : (s ? 200 : 110));
    strokeWeight(elegido ? 2.5 : 1.5);
    noFill();
    rect(cx, cy + lev, cw, chh, 14);
    noStroke();
    // un muñequito con la ropa
    fill(c, 40);
    ellipse(cx + 40, cy + 44 + lev, 60, 60);
    fill(#F1C9A5);
    ellipse(cx + 40, cy + 26 + lev, 16, 16);
    fill(c);
    rect(cx + 30, cy + 34 + lev, 20, 24, 4);
    if (i == 0) {
      fill(#C8283C);
      rect(cx + 30, cy + 33 + lev, 20, 6, 3);
    }
    if (i == 3) {
      fill(#DDE6F5, 160);
      triangle(cx + 26, cy + 34 + lev, cx + 54, cy + 34 + lev, cx + 40, cy + 70 + lev);
    }
    if (i == 4) {
      fill(255);
      ellipse(cx + 36, cy + 42 + lev, 3, 3);
      ellipse(cx + 45, cy + 50 + lev, 3, 3);
    }
    textFont(fuenteUI);
    textAlign(LEFT, TOP);
    textSize(12);
    fill(255);
    text(nombreRopa[i], cx + 76, cy + 12 + lev, 92, 32);
    textSize(11);
    if (tengoRopa[i]) {
      fill(neonVerde);
      text(ropaPuesta == i ? "PUESTA" : "TUYA", cx + 76, cy + 62 + lev);
    } else if (!ropaDisponible(i)) {
      fill(150);
      text("bloqueada", cx + 76, cy + 62 + lev);
    } else if (precioRopa[i] == 0) {
      fill(neonVerde);
      text("REGALO", cx + 76, cy + 62 + lev);
    } else {
      dibujarMoneda(cx + 83, cy + 68 + lev, 14, false);
      textAlign(LEFT, CENTER);
      textSize(14);
      fill(monedas >= precioRopaFinal(i) ? color(255, 230, 120) : neonRojo);
      text(str(precioRopaFinal(i)), cx + 96, cy + 67 + lev);
    }
  }
  // detalle
  int i = ropaElegida;
  float px = 236, py = 400, pw = 546, ph = 88;
  panelNeon(px, py, pw, ph, colorRopa[i]);
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(14);
  fill(colorRopa[i]);
  text(nombreRopa[i], px + 16, py + 10);
  textSize(11);
  fill(225);
  text(ropaDisponible(i) ? descRopa[i] : "Bloqueada: " + requisitoRopa(i), px + 16, py + 32, 330, 50);
  if (!tengoRopa[i]) {
    boolean puede = ropaDisponible(i);
    botonNeon(!puede ? "Bloqueada" : (precioRopa[i] == 0 ? "Recibir regalo" : "Comprar  " + precioRopaFinal(i)), px + 366, py + 12, 166, 30, puede ? #FFB400 : color(120), false);
  } else {
    botonNeon(ropaPuesta == i ? "Quitartela" : "Ponertela", px + 366, py + 12, 166, 30, ropaPuesta == i ? neonRosa : neonVerde, false);
  }
}

int precioRopaFinal(int i) {
  return tiendaOnline ? ceil(precioRopa[i] * (1 + COMISION_ONLINE)) : precioRopa[i];
}

boolean clickRopaTienda() {
  for (int i = 0; i < nombreRopa.length; i++) {
    if (encima(cardX(i), cardY(i), 172, 96)) {
      ropaElegida = i;
      return true;
    }
  }
  int i = ropaElegida;
  if (!encima(236 + 366, 400 + 12, 166, 30)) return true;
  if (tengoRopa[i]) {
    ropaPuesta = ropaPuesta == i ? -1 : i;
    fraseTendero = ropaPuesta == i ? "Te queda increible! " + nombreRopa[i] + " puesta." : "Listo, te la quitaste.";
    letrasTendero = 0;
    guardarDatos();
    return true;
  }
  if (!ropaDisponible(i)) {
    sonar(7);
    return true;
  }
  int p = precioRopaFinal(i);
  if (monedas < p) {
    sonar(7);
    fraseTendero = "Te faltan " + (p - monedas) + " NovaCoins para la " + nombreRopa[i] + ".";
    letrasTendero = 0;
    return true;
  }
  monedas -= p;
  pulsoMonedas = 1;
  tengoRopa[i] = true;
  ropaPuesta = i;
  sonar(5);
  explosionConfeti(cardX(i) + 86, cardY(i) + 40, 50);
  fraseTendero = "Te queda increible! Ya la tienes puesta.";
  letrasTendero = 0;
  guardarDatos();
  return true;
}

// el personaje con su ropa (reemplaza image(actual, ...) en todas las escenas)
void dibujarJugadorConRopa() {
  actualizarPasoJugadorNova();
  float cx = x + anchoPersonaje / 2;
  float ondea = sin(frameCount * 0.1) * 2;
  if (ropaPuesta == 3) {   // la capa: una parte detras...
    noStroke();
    fill(#DDE6F5, 170);
    quad(cx - 12, y + 10, cx + 12, y + 10, cx + 22 + ondea, y + 48, cx - 22 - ondea, y + 48);
  }
  dibujarBaseJugadorNova();
  if (ropaPuesta == 3) {   // ...y las puntas que se ven a los lados, brillando un poco
    fill(#DDE6F5, 140 + 50 * sin(frameCount * 0.08));
    triangle(cx - 12, y + 12, cx - 22 - ondea, y + 48, cx - 13, y + 48);
    triangle(cx + 12, y + 12, cx + 22 + ondea, y + 48, cx + 13, y + 48);
    fill(#9D8CD9);
    rect(cx - 10, y + 13, 20, 3, 2);
  }
  if (ropaPuesta == 1 || ropaPuesta == 2 || ropaPuesta == 4) {
    tint(colorRopa[ropaPuesta], 110);
    dibujarBaseJugadorNova();
    noTint();
  }
  if (ropaPuesta == 0) {
    noStroke();
    fill(#C8283C);
    rect(cx - 8, y + 15, 16, 4, 2);
    rect(cx + 3, y + 17, 4, 9, 2);
  }
  if (ropaPuesta == 4 && frameCount % 10 == 0 && (moverArriba || moverAbajo || moverIzquierda || moverDerecha)) {
    agregarParticula(new Particula(cx + random(-10, 10), y + random(10, 40), random(-0.3, 0.3), random(-0.6, -0.2), 30, 3, #F2C230, 6));
  }
}

String textoGuardadoRopa() {
  String t = "";
  for (boolean b : tengoRopa) t += b ? "1" : "0";
  return t + ";" + ropaPuesta;
}

void cargarGuardadoRopa(String a, String b) {
  for (int i = 0; i < min(a.length(), tengoRopa.length); i++) tengoRopa[i] = a.charAt(i) == '1';
  ropaPuesta = int(trim(b));
  if (ropaPuesta < -1 || ropaPuesta >= tengoRopa.length) ropaPuesta = -1;
}

// ------------------------------------- REINICIO -------------------------------------
void reiniciarRuta() {
  culpa = 0;
  avisoCulpa = 0;
  tieneMensajeShawn = false;
  finalSecretoElegido = false;
  vistoJuicio = vistoSilencio = vistoSecreto = false;
  vecesApagoCelular = 0;
  diasRepetidos = 0;
  postJuego = false;   // (PostJuego.pde)
  grietasListas = false;
}

String textoIrA(int obj) {
  if (dia >= 3) return "Ir a votar  >";
  String n = nombreEscenaCorto(obj);
  if (n.startsWith("el ")) return "Ir al " + n.substring(3) + "  >";
  return "Ir a " + n + "  >";
}
