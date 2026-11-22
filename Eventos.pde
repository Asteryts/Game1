// =====================================================================================
//  EVENTOS.pde -> cosas aleatorias que pasan en el MAPA
//  Cada vez que vuelves al mapa es distinto: pueden aparecer rumores sueltos, datos curiosos,
//  retos relampago (un minijuego al azar), gatos callejeros y dilemas (encuestas flash, celulares
//  perdidos, peleas en comentarios, capturas editadas, premios falsos y musicos callejeros).
//  Ademas pasan pajaros, un dron de Conecta, nubes, a veces llueve y suben hashtags de los barrios.
// =====================================================================================

class EventoMapa {
  float ex, ey, vida, anim = 0;
  int tipo;       // 0 rumor, 1 dato curioso, 2 reto relampago, 3 gato, 4 a 9 dilemas (ver nombresEvento)
  int variante;
}

ArrayList<EventoMapa> eventosMapa = new ArrayList<EventoMapa>();
float proximoEvento = 90;
boolean popupAbierto = false;
EventoMapa eventoPopup = null;
int popupFase = 0;          // 0 pregunta, 1 resultado
String popupTexto = "";
int rumoresPremiados = 0;   // los rumores del mapa solo mueven estadisticas las primeras veces
int gatosVistos = 0;
boolean lluviaMapa = false;
float[] dron = {-100, 120, 0};          // x, y, activo
float[][] bandada = new float[6][2];
float bandadaX = -200, bandadaY = 100;
float nubesOff = 0;

String[] nombresEvento = {"Rumor suelto", "Dato curioso", "Reto relampago", "Gato callejero",
  "Encuesta flash", "Celular perdido", "Pelea en comentarios", "Captura editada", "Premio falso", "Musico callejero"};
color[] coloresEvento = {#FF3CC8, #00F0FF, #FFDC3C, #FF8C3C, #9650FF, #50B4FF, #FF6E3C, #FFB43C, #C8FF3C, #FF8CDC};
// que tan seguido sale cada tipo (mismo orden que nombresEvento)
float[] pesoEvento = {20, 12, 12, 8, 9, 8, 9, 9, 8, 5};

// ------------------------------------- DILEMAS DEL MAPA (tipos 4 a 9) -------------------------------------
// cada tipo tiene su leccion, cuanto mueve cada opcion {viralidad, confiabilidad, impacto} y 2 situaciones.
// La opcion A es la que hace daño (o la graciosa, en el musico) y la B la responsable.
String[] leccionesDilema = {
  "Una encuesta en redes mide lo que la gente cree, no lo que es verdad.",
  "La privacidad de los demas se respeta aunque nadie te este viendo.",
  "En una pelea de comentarios nadie gana: la calma y las fuentes, si.",
  "Una captura de pantalla se edita en segundos: busca siempre la publicacion original.",
  "Nadie regala premios por mensaje: si te piden datos o que compartas, es una trampa.",
  ""
};
float[][][] efectosDilema = {
  {{6, -4, -3}, {0, 3, 3}},
  {{0, -6, -4}, {0, 5, 5}},
  {{6, -5, -4}, {0, 3, 4}},
  {{10, -8, -6}, {0, 5, 4}},
  {{4, -6, -6}, {0, 4, 3}},
  {{0, 0, 0}, {0, 0, 0}}
};
// texto, opcion A, opcion B, que pasa con A, que pasa con B, A es compartir ("1"/"0"),
// y si A es compartir: las respuestas de la pausa (quien, cuando, pruebas)
String[][][] situacionesDilema = {
  { // 4 encuesta flash
    {"Conecta lanza una encuesta: 'Crees que el video de Clemencia comprando votos es real?'",
      "Votar 'Si, se ve clarito'", "Votar 'No se, no hay fuente'",
      "El 71% voto 'si'. Ahora la encuesta se comparte como si fuera una prueba.",
      "Tu voto suma al 29% que pide fuentes. Una periodista cita ese dato en Nova Noticias.", "0", "", "", ""},
    {"Encuesta en el grupo del colegio: 'Dani es espia de la constructora? Si / No'",
      "Votar 'Si, obvio'", "Votar 'Eso es un invento'",
      "La encuesta se vuelve viral y Dani la ve. Le duele mas que la foto.",
      "Varios compañeros cambian su voto al ver el tuyo. Alguien cierra la encuesta.", "0", "", "", ""}
  },
  { // 5 celular perdido
    {"Encuentras un celular en una banca. Esta desbloqueado y tiene los chats abiertos.",
      "Revisar sus chats", "Llevarlo a objetos perdidos",
      "Lees conversaciones que no te tocaban. Si alguien hiciera eso con tu celular, como te sentirias?",
      "Su dueña, Valentina, lo recupera esa misma tarde y te escribe para darte las gracias.", "0", "", "", ""},
    {"Un celular suena en el piso del bus. En la pantalla: 'Mama (12 llamadas perdidas)'.",
      "Mirar sus fotos", "Contestar y avisar",
      "Era el celular de Tomas. El nunca sabra que viste sus fotos... pero tu si.",
      "La mama de Tomas respira aliviada. El pasa a recogerlo en un rato.", "0", "", "", ""}
  },
  { // 6 pelea en comentarios
    {"En una publicacion de Conecta, dos vecinos se insultan por las elecciones. Ya van 300 comentarios.",
      "Insultar tambien", "Pedir calma con una fuente",
      "Tu comentario recibe 40 'me enoja'. La pelea sigue hasta la madrugada.",
      "Un vecino lee la fuente y borra su insulto. El hilo se calma.", "0", "", "", ""},
    {"Alguien comento: 'Los del barrio de la cancha son todos unos mentirosos'.",
      "Responder con otro insulto", "Reportar y responder bien",
      "Ahora son dos barrios peleando. Nadie recuerda por que empezo.",
      "El comentario se borra y tres personas te dan la razon. Con respeto se gana mas.", "0", "", "", ""}
  },
  { // 7 captura editada
    {"Te llega una captura: Ramirez 'publicando' que va a cerrar el colegio. La fecha dice 31 de febrero.",
      "Reenviar la captura", "Buscar la publicacion real",
      "La captura llega a 3 grupos. Alguien nota la fecha imposible... demasiado tarde.",
      "El 31 de febrero no existe y la publicacion original tampoco. Era un montaje.", "1",
      "Una captura sin enlace", "31 de febrero (no existe)", "No hay publicacion original"},
    {"Una captura de un 'mensaje' de Clemencia insultando a los votantes. La letra no es la de Conecta.",
      "Reenviar la captura", "Buscar la publicacion real",
      "Medio barrio ya cree que Clemencia insulto a los votantes. Ella nunca escribio eso.",
      "En el perfil de Clemencia no existe ese mensaje. Avisas al grupo que es falso.", "1",
      "Una captura reenviada muchas veces", "Sin fecha", "La letra ni siquiera es la de Conecta"}
  },
  { // 8 premio falso
    {"Mensaje: 'Ganaste un bono de 500.000 de la Alcaldia! Escribe tu documento y tu contraseña'.",
      "Poner mis datos", "Ignorar y reportar",
      "No habia bono: ahora alguien tiene tus datos y esta escribiendole a tus contactos.",
      "La Alcaldia confirma que no regala bonos por mensaje. Tu reporte bloquea el numero.", "0", "", "", ""},
    {"Un enlace dice: 'Gana entradas para el concierto del domingo! Solo compartelo con 20 amigos'.",
      "Compartir con 20 amigos", "Revisar quien lo organiza",
      "No habia concierto. Tus 20 amigos ahora reciben mensajes de spam por tu culpa.",
      "El 'organizador' es una cuenta creada ayer. Avisas a tus amigos que no caigan.", "1",
      "Un numero desconocido", "Sin fecha", "Ninguna: no hay ningun concierto anunciado"}
  },
  { // 9 musico callejero (solo para divertirse)
    {"Un musico toca acordeon en la esquina. Su cancion se llama 'No me compartas sin leerme'.",
      "Dar una moneda", "Pedir una cancion",
      "Te sonrie y toca mas fuerte. Un par de personas se detienen a escuchar.",
      "Te dedica 'El corrido del bulo'. Hasta los perros del barrio bailan.", "0", "", "", ""},
    {"Una chica canta rap en la plaza: 'Si no tiene fuente, no lo pases, pariente'.",
      "Aplaudir", "Pedirle otra",
      "La gente se une a los aplausos. Ella te hace un saludo con la gorra.",
      "Improvisa una estrofa sobre ti: 'Ese si verifica, ese si sabe'. Todos se rien.", "0", "", "", ""}
  }
};
int[] dilemasPremiados = new int[6];   // cada tipo de dilema solo mueve estadisticas las primeras 3 veces

String[] situacionDilema(EventoMapa e) {
  String[][] s = situacionesDilema[e.tipo - 4];
  return s[e.variante % s.length];
}
String[] hashtags = {"#Escandalo", "#NovaDecide", "#YLaFuente?", "#FueraBulos", "#Elecciones", "#Verifica", "#Chisme", "#ParqueSi"};

// texto del rumor, que pasa si lo repites, que pasa si preguntas
String[][] rumoresMapa = {
  {"Alguien grita en la esquina: 'Van a cobrar por entrar al parque desde mañana!'", "La gente deja de ir al parque... y no era cierto.", "Le preguntas de donde lo saco: 'Me lo dijo alguien en un bus'. Nadie lo confirma. Rumor frenado."},
  {"Un señor en la parada del bus: 'Dicen que las votaciones se pasan para el viernes!'", "Varias personas casi no van a votar el jueves.", "Revisas la Registraduria: las votaciones siguen siendo el jueves."},
  {"Un grupo de chicos: 'El Cafe 404 lo van a cerrar porque vende cafe con IA'", "El cafe pierde clientes por un chiste mal entendido.", "Le escribes al cafe: era un meme. Ellos mismos lo aclaran con humor."},
  {"Un audio en el grupo del barrio: 'Se cayo un puente en la avenida, no salgan!'", "El panico llena el grupo. El puente esta perfecto.", "Miras las camaras de Transito: el puente esta bien. Avisas al grupo."},
  {"Una cuenta sin foto: 'Gonzalo tiene 14 carros, por eso quiere la ciclorruta... ironia'", "El chiste se vuelve 'noticia' y nadie entiende nada.", "Buscas la declaracion de bienes oficial: Gonzalo tiene una bicicleta."},
  {"Una vecina por la ventana: 'Van a cortar la luz en todo Nova el dia de las elecciones!'", "Medio barrio compra velas y planea no salir a votar.", "La empresa de energia dice que no hay ningun corte programado."},
  {"Un repartidor: 'En el Mercado estan regalando celulares, pero solo hoy!'", "Una multitud llega al mercado. No hay celulares, solo un enlace falso.", "Le preguntas a Yuli, la del mercado: es la misma estafa del enlace."},
  {"Un audio anonimo: 'El agua de la llave de Nova tiene un quimico raro, no la tomen'", "La gente compra agua embotellada a precios absurdos.", "Salud Nova publica los analisis del agua: todo esta normal."},
  {"Un chico en la esquina: 'El colegio va a cerrar una semana por una plaga de ratas'", "Varios papas no mandan a sus hijos al colegio.", "La coordinadora Gladys desmiente: no hay ratas ni cierre."}
};

String[] datosCuriosos = {
  "Dato: los mensajes falsos se comparten mas rapido que los verdaderos, porque suelen ser mas sorprendentes.",
  "Dato: si una noticia no tiene fecha, autor ni fuente, es mejor no compartirla hasta saber mas.",
  "Dato: la mayoria de bulos usan palabras como URGENTE, COMPARTE YA o ANTES DE QUE LO BORREN.",
  "Dato: una foto real puede usarse con una historia falsa. Busca siempre la imagen original.",
  "Dato: preguntar 'quien lo dijo?' frena mas rumores que cualquier algoritmo.",
  "Dato: la lectura lateral es abrir otra pestaña para averiguar quien esta detras de una pagina.",
  "Dato: una encuesta en redes no es una prueba: solo vota quien la ve y quiere votar.",
  "Dato: los bots publican a toda hora, sin dormir. Las personas, no.",
  "Dato: si un titular te da mucha rabia, respira: esta hecho para que compartas sin pensar.",
  "Dato: activar la verificacion en dos pasos protege tu cuenta aunque alguien sepa tu contraseña."
};

String[] respuestasGato = {
  "El gato ronronea y se acuesta panza arriba. Confia en ti. Eso ya es mas de lo que Nova confia en Conecta.",
  "El gato acepta un pedacito de tu arepa y te sigue dos cuadras. Luego se aburre y se va. Clasico."
};

// puntos de calles del mapa donde pueden aparecer cosas (el mapa es 800x500)
float[][] puntosEventos() {
  ArrayList<float[]> l = new ArrayList<float[]>();
  for (int xx = 40; xx < 760; xx += 40) if (abs(xx - 528) > 30) l.add(new float[] {xx, 247});
  for (int yy = 40; yy < 470; yy += 40) if (abs(yy - 247) > 25) l.add(new float[] {528, yy});
  float[][] extra = {{200, 330}, {250, 410}, {600, 300}, {470, 280}, {120, 360}, {700, 470}, {300, 160}};
  for (float[] e : extra) l.add(e);
  return l.toArray(new float[0][]);
}

float[][] puntosMapa = null;

void alEntrarAlMapa() {
  if (puntosMapa == null) puntosMapa = puntosEventos();
  lluviaMapa = random(1) < 0.25;
  eventosMapa.clear();
  int n = int(random(1, 3));
  for (int i = 0; i < n; i++) nuevoEvento();
  proximoEvento = random(400, 700);
  if (random(1) < 0.6) {
    bandadaX = -60;
    bandadaY = random(60, 300);
  }
  for (int i = 0; i < bandada.length; i++) {
    bandada[i][0] = -abs(i - bandada.length / 2) * 16 - (i % 2) * 4;
    bandada[i][1] = (i - bandada.length / 2) * 12;
  }
}

void nuevoEvento() {
  if (puntosMapa == null) puntosMapa = puntosEventos();
  if (eventosMapa.size() >= (gadgetActivo(2) ? 5 : 3)) return;   // con el Radar de Eventos (Tienda.pde) caben 5
  EventoMapa e = new EventoMapa();
  // se elige el tipo al azar, segun su peso
  float total = 0;
  for (float p : pesoEvento) total += p;
  float r = random(total);
  e.tipo = 0;
  for (int k = 0; k < pesoEvento.length; k++) {
    if (r < pesoEvento[k]) {
      e.tipo = k;
      break;
    }
    r -= pesoEvento[k];
  }
  e.variante = int(random(100));
  for (int intento = 0; intento < 10; intento++) {
    float[] p = puntosMapa[int(random(puntosMapa.length))];
    boolean libre = true;
    for (EventoMapa o : eventosMapa) if (dist(o.ex, o.ey, p[0], p[1]) < 60) libre = false;
    if (libre) {
      e.ex = p[0] + random(-6, 6);
      e.ey = p[1] + random(-6, 6);
      break;
    }
  }
  if (e.ex == 0) return;
  e.vida = random(900, 1500);
  eventosMapa.add(e);
}

// se llama desde dibujarMapaVivo (escena 1)
void eventosDelMapa() {
  boolean libre = !pausaAbierta && !telefonoAbierto && !popupAbierto;
  if (escenaAnterior == 1 && puntosMapa == null) alEntrarAlMapa();
  noStroke();
  // sombras de nubes
  if (libre) nubesOff += 0.25;
  for (int i = 0; i < 4; i++) {
    float nx = (hsh(i * 3.3) * width + nubesOff * (0.6 + i * 0.2)) % (width + 300) - 150;
    fill(10, 10, 40, 35);
    ellipse(nx, 80 + i * 110, 220, 80);
    ellipse(nx + 70, 70 + i * 110, 160, 60);
  }
  // lluvia
  if (lluviaMapa && libre) {
    for (int i = 0; i < 3; i++) agregarParticula(new Particula(random(-60, width), random(-20, 0), 2, random(9, 12), 55, 1, color(170, 190, 255), 1));
  }
  // hashtags que suben de los barrios
  if (libre && frameCount % 110 == 0) {
    float[] p = puntosMapa != null ? puntosMapa[int(random(puntosMapa.length))] : new float[] {400, 250};
    flotantes.add(new TextoFlotante(hashtags[int(random(hashtags.length))], p[0], p[1] - 10, color(255), 11, 140, true));
  }
  // dron de Conecta
  if (libre) {
    if (dron[2] == 0 && random(1) < 0.002) {
      dron[0] = -40;
      dron[1] = random(80, 420);
      dron[2] = 1;
    }
    if (dron[2] == 1) {
      dron[0] += 1.6;
      dron[1] += sin(frameCount * 0.05) * 0.6;
      if (dron[0] > width + 40) dron[2] = 0;
    }
  }
  if (dron[2] == 1) {
    fill(0, 60);
    ellipse(dron[0] + 10, dron[1] + 26, 26, 8);
    fill(50);
    rect(dron[0] - 10, dron[1] - 3, 20, 6, 3);
    fill(200, 200, 220, 130);
    ellipse(dron[0] - 14, dron[1] - 5, 14, 4);
    ellipse(dron[0] + 14, dron[1] - 5, 14, 4);
    fill(frameCount % 20 < 10 ? neonRosa : neonCian);
    ellipse(dron[0], dron[1], 4, 4);
    fill(neonRosa, 30);
    triangle(dron[0], dron[1], dron[0] - 18, dron[1] + 40, dron[0] + 18, dron[1] + 40);
  }
  // bandada de pajaros
  if (bandadaX > -100 && bandadaX < width + 100) {
    if (libre) {
      bandadaX += 1.8;
      bandadaY += sin(frameCount * 0.02) * 0.3;
    }
    stroke(20, 20, 30);
    strokeWeight(2);
    noFill();
    for (float[] b : bandada) {
      float bx = bandadaX + b[0], by = bandadaY + b[1];
      float ala = sin(frameCount * 0.3 + b[1]) * 4;
      line(bx - 6, by - ala, bx, by);
      line(bx, by, bx + 6, by - ala);
    }
    noStroke();
  }
  // eventos (aparecen y desaparecen solos)
  if (libre) {
    proximoEvento--;
    if (proximoEvento <= 0) {
      nuevoEvento();
      proximoEvento = random(500, 900) * (gadgetActivo(2) ? 0.45 : 1);
    }
  }
  EventoMapa sobreEv = null;
  for (int i = eventosMapa.size() - 1; i >= 0; i--) {
    EventoMapa e = eventosMapa.get(i);
    if (libre) e.vida--;
    e.anim = lerp(e.anim, e.vida > 40 ? 1 : 0, 0.12);
    if (e.vida <= 0 && e.anim < 0.03) {
      eventosMapa.remove(i);
      continue;
    }
    boolean s = dist(mouseX, mouseY, e.ex, e.ey - 14) < 18 && !popupAbierto && !telefonoAbierto && !pausaAbierta;
    if (s) sobreEv = e;
    dibujarEvento(e, s);
  }
  if (sobreEv != null) {
    textFont(fuenteUI);
    textSize(12);
    String t = nombresEvento[sobreEv.tipo];
    float w = textWidth(t) + 20;
    fill(8, 6, 22, 235);
    rect(sobreEv.ex - w / 2, sobreEv.ey - 62, w, 24, 8);
    fill(coloresEvento[sobreEv.tipo]);
    textAlign(CENTER, CENTER);
    text(t, sobreEv.ex, sobreEv.ey - 51);
  }
}

void dibujarEvento(EventoMapa e, boolean s) {
  float b = sin(frameCount * 0.1 + e.variante) * 3;
  float esc = e.anim * (s ? 1.2 : 1);
  color c = coloresEvento[e.tipo];
  pushMatrix();
  translate(e.ex, e.ey);
  scale(esc);
  noStroke();
  float r = (frameCount * 0.9 + e.variante * 7) % 40;
  noFill();
  stroke(c, 200 - r * 5);
  strokeWeight(2);
  ellipse(0, 2, r * 1.2, r * 0.45);
  noStroke();
  fill(c, 50);
  ellipse(0, -14 + b, 40, 40);
  fill(15, 10, 32);
  stroke(c);
  strokeWeight(2);
  ellipse(0, -14 + b, 28, 28);
  noStroke();
  fill(c);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  if (e.tipo == 0) {
    rect(-8, -21 + b, 16, 11, 3);
    triangle(-5, -10 + b, 0, -10 + b, -7, -5 + b);
    fill(15, 10, 32);
    textSize(10);
    text("!", 0, -16 + b);
  } else if (e.tipo == 1) {
    textSize(16);
    text("i", 0, -15 + b);
  } else if (e.tipo == 2) {
    beginShape();
    for (int k = 0; k < 10; k++) {
      float a = -HALF_PI + k * PI / 5;
      float rr = k % 2 == 0 ? 10 : 4.5;
      vertex(cos(a) * rr, -14 + b + sin(a) * rr);
    }
    endShape(CLOSE);
  } else if (e.tipo == 3) {
    ellipse(0, -12 + b, 16, 13);
    triangle(-8, -16 + b, -6, -24 + b, -2, -18 + b);
    triangle(8, -16 + b, 6, -24 + b, 2, -18 + b);
    fill(15, 10, 32);
    ellipse(-3, -13 + b, 2.5, 3);
    ellipse(3, -13 + b, 2.5, 3);
  } else if (e.tipo == 4) {   // encuesta: barras
    rect(-8, -14 + b, 4, 8);
    rect(-2, -20 + b, 4, 14);
    rect(4, -17 + b, 4, 11);
  } else if (e.tipo == 5) {   // celular
    rect(-5, -23 + b, 10, 18, 2);
    fill(15, 10, 32);
    rect(-3, -21 + b, 6, 12);
  } else if (e.tipo == 6) {   // dos globos que pelean
    rect(-10, -22 + b, 11, 8, 2);
    rect(-1, -14 + b, 11, 8, 2);
    fill(15, 10, 32);
    textSize(8);
    text("!", -4.5, -19 + b);
    text("!", 4.5, -11 + b);
  } else if (e.tipo == 7) {   // una foto con tijera
    rect(-8, -20 + b, 16, 12, 2);
    fill(15, 10, 32);
    triangle(-6, -10 + b, -1, -16 + b, 3, -10 + b);
    stroke(c);
    strokeWeight(1.5);
    line(-9, -6 + b, 9, -22 + b);
    noStroke();
  } else if (e.tipo == 8) {   // un regalo
    rect(-8, -16 + b, 16, 10, 1);
    rect(-9, -19 + b, 18, 4, 1);
    fill(15, 10, 32);
    rect(-1, -19 + b, 2, 13);
  } else {   // una nota musical
    ellipse(-3, -9 + b, 7, 6);
    rect(0, -23 + b, 2, 14);
    rect(0, -23 + b, 7, 3);
  }
  popMatrix();
}

// ------------------------------------- VENTANITA DEL EVENTO -------------------------------------
void abrirPopup(EventoMapa e) {
  eventoPopup = e;
  popupAbierto = true;
  popupFase = 0;
  e.vida = 0;
  if (e.tipo == 0) popupTexto = rumoresMapa[e.variante % rumoresMapa.length][0];
  else if (e.tipo == 1) popupTexto = datosCuriosos[e.variante % datosCuriosos.length];
  else if (e.tipo == 2) popupTexto = "Reto relampago! Un juego sorpresa te espera: " + nombresJuegos[e.variante % nombresJuegos.length] + ". Te le mides?";
  else if (e.tipo == 3) popupTexto = "Un gato callejero se te acerca, te mira fijamente y maulla. Parece que quiere algo.";
  else popupTexto = situacionDilema(e)[0];
}

String[] botonesPopup() {
  if (popupFase == 1) return new String[] {"Listo"};
  if (eventoPopup.tipo == 0) return new String[] {"Repetirlo", "Preguntar de donde salio"};
  if (eventoPopup.tipo == 1) return new String[] {"Interesante!"};
  if (eventoPopup.tipo == 2) return new String[] {"A jugar!", "Ahora no"};
  if (eventoPopup.tipo == 3) return new String[] {"Acariciarlo", "Darle de tu arepa"};
  String[] s = situacionDilema(eventoPopup);
  return new String[] {s[1], s[2]};
}

// donde va cada boton de la ventanita: {x, ancho}
float[] botonPopup(int i, int n) {
  if (n == 1) return new float[] {width / 2 - 100, 200};
  return new float[] {150 + i * 255, 245};
}

// 0 = la opcion A, 1 = la opcion B de un dilema del mapa
void aplicarDilema(int i) {
  int k = eventoPopup.tipo - 4;
  String[] s = situacionDilema(eventoPopup);
  if (dilemasPremiados[k] < 3) {
    float[] e = efectosDilema[k][i];
    viralidad += e[0];
    confiabilidad += e[1];
    impacto += e[2];
  }
  dilemasPremiados[k]++;
  popupTexto = s[3 + i];
  popupFase = 1;
  if (eventoPopup.tipo == 9) {   // el musico es solo para divertirse
    reaccionSpriteNova("Músico callejero");
    chispas(width / 2, 220, coloresEvento[9], 30);
    return;
  }
  anotarDecision("Mapa: " + nombresEvento[eventoPopup.tipo], s[1 + i], i == 1, i == 0 && s[5].equals("1"), popupTexto);
  historial.get(historial.size() - 1).leccion = leccionesDilema[k];
  if (i == 1) chispas(width / 2, 220, neonVerde, 30);
}

void dibujarPopupMapa() {
  if (!popupAbierto) return;
  noStroke();
  fill(0, 150);
  rect(0, 0, width, height);
  color c = coloresEvento[eventoPopup.tipo];
  panelNeon(130, 130, 540, 230, c);
  tituloNeon(nombresEvento[eventoPopup.tipo].toUpperCase(), width / 2, 160, 22, c);
  textFont(fuenteUI);
  textSize(15);
  fill(235);
  textAlign(CENTER, TOP);
  String personaje = eventoPopup.tipo == 3 ? "Gato callejero" : eventoPopup.tipo == 9 ? "Músico callejero" : "";
  int modo = popupFase == 0 ? SPRITE_HABLA : modoSpriteNova(personaje);
  boolean conSprite = !personaje.isEmpty() && dibujarSpriteNova(personaje, 196, 274, 1.12, modo, 0);
  text(popupTexto, conSprite ? 236 : 160, 188, conSprite ? 392 : 480, 100);
  String[] bs = botonesPopup();
  for (int i = 0; i < bs.length; i++) {
    float[] b = botonPopup(i, bs.length);
    botonNeon(bs[i], b[0], 300, b[1], 42, i == 0 ? c : neonCian, false);
  }
}

boolean clickPopupMapa() {
  String[] bs = botonesPopup();
  for (int i = 0; i < bs.length; i++) {
    float[] b = botonPopup(i, bs.length);
    if (!encima(b[0], 300, b[1], 42)) continue;
    if (popupFase == 1 || eventoPopup.tipo == 1) {
      popupAbierto = false;
    } else if (eventoPopup.tipo == 0) {
      String[] r = rumoresMapa[eventoPopup.variante % rumoresMapa.length];
      if (i == 0) {   // repetirlo: antes, la pausa (Responsable.pde)
        pedirRevision("Rumor en la calle", r[0], "Alguien en la calle", false, "No se sabe", false, "Ninguna", false, new Accion() {
          public void hacer() {
            aplicarRumorMapa(0);
          }
        }
        );
      } else {
        aplicarRumorMapa(1);
      }
    } else if (eventoPopup.tipo == 2) {
      popupAbierto = false;
      if (i == 0) lanzarJuego(escenasJuegos[eventoPopup.variante % escenasJuegos.length], false);
    } else if (eventoPopup.tipo == 3) {
      reaccionSpriteNova("Gato callejero");
      popupTexto = respuestasGato[i];
      popupFase = 1;
      gatosVistos++;
      desbloquear(16);
      chispas(width / 2, 220, neonAmarillo, 30);
    } else {
      // los dilemas: si la opcion A es compartir, primero la pausa (Responsable.pde)
      final String[] s = situacionDilema(eventoPopup);
      if (i == 0 && s[5].equals("1")) {
        pedirRevision("Mapa: " + nombresEvento[eventoPopup.tipo], s[0], s[6], false, s[7], false, s[8], false, new Accion() {
          public void hacer() {
            aplicarDilema(0);
          }
        }
        );
      } else {
        aplicarDilema(i);
      }
    }
    return true;
  }
  return true;   // el clic fuera de los botones no hace nada mientras la ventanita esta abierta
}

// 0 = repetir el rumor, 1 = preguntar de donde salio
void aplicarRumorMapa(int i) {
  String[] r = rumoresMapa[eventoPopup.variante % rumoresMapa.length];
  boolean cuenta = rumoresPremiados < 10;
  rumoresPremiados++;
  if (i == 0) {
    if (cuenta) {
      viralidad += 5;
      confiabilidad -= 4;
      impacto -= 3;
    }
    popupTexto = r[1];
  } else {
    if (cuenta) {
      confiabilidad += 3;
      impacto += 2;
    }
    popupTexto = r[2];
  }
  popupFase = 1;
  anotarDecision("Rumor en la calle", i == 0 ? "Repetir: " + r[0] : "Preguntar de donde salio: " + r[0], i == 1, i == 0, popupTexto);
}

boolean clickEventoMapa() {
  for (EventoMapa e : eventosMapa) {
    if (e.vida > 0 && dist(mouseX, mouseY, e.ex, e.ey - 14) < 18) {
      abrirPopup(e);
      return true;
    }
  }
  return false;
}
