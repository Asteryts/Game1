// =====================================================================================
//  RESPONSABLE.pde -> el uso responsable de las redes, hecho mecanica de juego
//   1. CONSECUENCIAS QUE VUELVEN: lo que compartes se riega por el mapa (con un contador de
//      personas alcanzadas), los afectados te escriben a la app Mensajes del telefono y algunos
//      personajes cambian segun lo que hiciste (Dani deja de ir al colegio, Don Pacho cierra...).
//   2. LA PAUSA ANTES DE COMPARTIR: antes de cada "compartir" aparece una tarjeta con tres
//      preguntas (quien lo publica, cuando, hay pruebas). Puedes compartir igual o arrepentirte.
//   3. EL HISTORIAL: al final, cada decision que tomaste, que paso y la leccion de la vida real.
// =====================================================================================

// ------------------------------------- DATOS DE CADA DECISION -------------------------------------
// clave (el nombre empieza asi), leccion, quien escribe si salio mal, su mensaje,
// quien escribe si salio bien, su mensaje, y las 3 respuestas de la pausa (quien, cuando, pruebas)
String[][] datosDecisiones = {
  {"Kevin", "Un deepfake 'de broma' que no se aclara sigue siendo desinformacion.",
    "Kevin", "Bro... me llego una demanda por el video de Ramirez. Todos creen que fue real.",
    "Kevin", "Mi video explicando los deepfakes ya tiene 80 mil vistas. Gracias por la idea!",
    "Un influencer que quiere vistas", "Hoy, inventado ahora mismo", "Ninguna: es un filtro de cara"},
  {"Abuela Rosa", "Las cadenas que piden urgencia casi nunca son ciertas: busca la fuente oficial.",
    "Abuela Rosa", "Mijo, el agua estaba bien... y tu prima cancelo el cumpleaños del niño por esa cadena.",
    "Abuela Rosa", "Ya le enseñe a todo el grupo de la familia a buscar el comunicado. Gracias!",
    "Una cadena sin autor", "Sin fecha", "Ninguna: 'me lo dijo la vecina'"},
  {"Ingeniera Ada", "Borrar todo lo dudoso tambien hace daño: el contexto y las fuentes ayudan mas que la censura.",
    "Ingeniera Ada", "NOVA borro la denuncia real de una vecina. Tenemos que revisar eso.",
    "Ingeniera Ada", "Las etiquetas con contexto estan funcionando. La gente pregunta antes de compartir.",
    "", "", ""},
  {"B-07", "Las granjas de bots fabrican tendencias falsas: reportarlas protege a todos.",
    "B-07", "BZZT. TENDENCIA #FUERARAMIREZ CREADA. HUMANOS REALES QUE LA ESCRIBIERON: 0.",
    "Ingeniera Ada", "Gracias por reportar la granja de bots. Cerramos 50 cuentas falsas.",
    "50 cuentas falsas", "Creadas hoy", "Ninguna"},
  {"Tono", "Antes de avisarle a 200 personas, revisa la cuenta oficial.",
    "Tono", "Perdi la mitad de los pedidos de hoy por el rumor de la avenida.",
    "Tono", "Le pase el aviso real de Transito a los repartidores. Todo bien!",
    "Alguien en un semaforo", "No se sabe", "Ninguna"},
  {"Señora Carmen", "Un video de 9 segundos puede contar la historia al reves: busca el completo.",
    "Señora Carmen", "Sali en todos los noticieros con la pancarta... y el video estaba cortado. Que verguenza.",
    "Señora Carmen", "Mi cartel de 'Queremos pruebas' salio en Nova Noticias!",
    "Un video anonimo", "Sin fecha ni lugar", "9 segundos cortados de un video de 4 minutos"},
  {"Bruno", "Si te pagan por compartir algo, no es informacion: es propaganda.",
    "Clemencia (candidata)", "Vi que compartiste el meme sobre mi. Nada de eso es cierto.",
    "Bruno", "Lei las propuestas de los otros candidatos... estoy pensando cosas.",
    "Una campaña que paga por compartir", "Hoy", "Ninguna: los memes son inventados"},
  {"Pili", "Juzgar una propuesta por un meme es dejar que otros piensen por ti.",
    "Pili", "El meme de los carros ya lo vieron 20 mil personas. El folleto, 12.",
    "Pili", "Gracias por leer la propuesta! Pasasela a alguien mas.",
    "", "", ""},
  {"Tomas", "Cortar un video para que se vea peor es manipular, aunque cada segundo sea real.",
    "Tomas", "Por mi video cortado hubo peleas en la protesta. Lo voy a borrar.",
    "Lucia (Nova Noticias)", "Usamos el video completo de Tomas para aclarar lo que paso. Gracias!",
    "Tu dron", "Hoy, en la protesta", "Solo 5 segundos sin contexto"},
  {"Don Pacho", "Un rumor contra otro no apaga el miedo: lo duplica.",
    "Don Pacho", "Tuve que cerrar el puesto. Nadie compra fruta en el mercado.",
    "Don Pacho", "Hoy vendi todo! Pase por su mango gratis.",
    "Tu primo, en un audio", "Sin fecha", "Ninguna"},
  {"Yuli", "Nadie regala celulares: si te piden la contraseña, es una trampa.",
    "Yuli", "Tu cuenta mando el enlace falso a 300 contactos. Cambia la contraseña ya.",
    "Yuli", "Por tu reporte, Conecta bloqueo el enlace falso.",
    "", "", ""},
  {"Entrenador Rafa", "Cancelar 'por si acaso' por un audio tambien es dejar que el rumor gane.",
    "Valentina", "Se cancelo el torneo y no llovio nada. Los niños estaban tristes.",
    "Entrenador Rafa", "Ganamos el primer partido! Gracias por confirmar.",
    "", "", ""},
  {"Maya", "Una acusacion pintada en una pared sigue siendo una acusacion sin pruebas.",
    "Ramirez (candidato)", "Alguien pinto 'ladron' sobre mi en el barrio. No hay ninguna denuncia.",
    "Maya", "El mural salio en el periodico del colegio!",
    "Un desconocido que paga", "Hoy", "Ninguna"},
  {"El Filtrador", "Una filtracion sin origen puede ser un montaje: llevala a periodistas.",
    "Lucia (Nova Noticias)", "Los documentos que publicaste estaban hechos con IA. Tu nombre esta en todas partes.",
    "Lucia (Nova Noticias)", "Gracias por traernos la USB. Hicimos la nota con contexto.",
    "Un desconocido con capucha", "No se sabe", "Documentos sin firma ni origen"},
  {"Dani", "Burlarse de alguien en redes duele de verdad, aunque sea 'un chiste'.",
    "Coordinadora Gladys", "Dani no ha vuelto al colegio. Estamos preocupados.",
    "Dani", "Gracias por ayudarme. Hoy volvi al salon.",
    "", "", ""},
  {"Profe Hernan", "Cada reenvio cuenta: un rumor que nadie comparte se muere solo.",
    "", "", "", "", "", "", ""},
  {"Vale", "Si compartiste algo que hizo daño, corregirlo y pedir perdon tambien se comparte.",
    "Dani", "Vale nunca me pidio perdon. La foto sigue por ahi.",
    "Vale", "Dani y yo hicimos un video juntos explicando lo de la maqueta.",
    "", "", ""},
  {"Sebas", "Un blog sin autor no es una fuente.",
    "Sebas", "Saque 1.0 en el trabajo. La profe dijo 'fuente no confiable'.",
    "Sebas", "Saque 5.0! Gracias por ayudarme con las fuentes.",
    "", "", ""},
  {"Doña Tere", "Callar ante un bulo tambien deja que crezca.",
    "Doña Tere", "Hoy botamos 40 almuerzos. Nadie quiere comer por el video.",
    "Doña Tere", "La fila llega hasta el pasillo! Le guarde un postre.",
    "", "", ""},
  {"Camilo", "Antes de boicotear a alguien, confirma que el video sea de aqui.",
    "Doña Tere", "Unos estudiantes me estan insultando por un video que ni siquiera es de aqui.",
    "", "",
    "Una cuenta de videos virales", "Hace años, en otra ciudad", "No: las bandejas ni siquiera son de aqui"},
  // personajes del colegio (Lab.pde)
  {"Mateo", "Una foto tomada sin permiso no se comparte, aunque de seguidores.",
    "Dani", "Por que todos tienen mi foto? Yo no hice nada.",
    "Mateo", "Le avise a Dani. Me dio las gracias.",
    "Alguien que tomo una foto sin permiso", "Hoy, en el recreo", "Solo una maleta abierta"},
  {"Doña Marta", "'Me lo conto mi primo' no es una fuente.",
    "Don Lucho", "Se cancelo la jornada del parque por la alerta. No vino nadie.",
    "Don Lucho", "La jornada del parque sigue en pie. Gracias por preguntar por la fuente!",
    "Una cuenta sin foto ni nombre", "No se sabe", "Ninguna, solo 'mil compartidos'"},
  {"Julián", "Una pagina creada ayer y sin autor no es una noticia.",
    "Ramirez (candidato)", "Me acusan de querer cerrar el colegio. Yo estudie ahi.",
    "", "",
    "Una pagina creada ayer, sin autor", "Ayer", "Ninguna"},
  {"Sofía", "Ganar con un rumor tambien es perder: la confianza no vuelve facil.",
    "Sofia", "Mi candidata gano puntos... pero la gente ya no le cree a nadie.",
    "", "",
    "Una campaña politica", "Hoy", "'No me consta si es real'"},
  {"Camila", "Si sabes la verdad, decirla frena el rumor.",
    "Camila", "Debi decir que era una maqueta. Ahora dicen que Dani es espia.",
    "Camila", "Lo aclare en el grupo del salon. Ya nadie habla del casillero!",
    "", "", ""},
  {"Álex", "No todo es un complot: a veces es un chisme que crecio solo.",
    "", "", "", "", "", "", ""},
  {"Nico", "Compartir si esta bien cuando lo que compartes tiene pruebas y contexto.",
    "", "",
    "Nico", "Tu hilo con pruebas lo compartio Nova Noticias!",
    "Tu, con capturas y fuentes", "Hoy, con fecha", "Si: NOVA rastreo el origen"},
  // decisiones del barrio y la alcaldia (Lab.pde)
  {"Junta Vecinal", "Un video sin fuente ni fecha no se comparte como 'urgente'.",
    "Clemencia (candidata)", "Me estan insultando en el barrio por un video que esta cortado.",
    "Armando", "La Junta confirmo que el video estaba editado. Gracias por ayudar.",
    "Un mensaje reenviado en el grupo vecinal", "Sin fecha", "Ninguna fuente"},
  {"Debora", "Difundir que 'habra protestas' puede crear el miedo que dice anunciar.",
    "Debora", "Mucha gente no salio a la calle por miedo a las 'protestas'.",
    "Debora", "Fuiste a la plaza y no habia nada raro. Lo avise en el grupo.",
    "Reportes vecinales sin firma", "No se sabe", "Ninguna"},
  {"Asamblea", "Escuchar y mediar tambien es usar bien tu voz.",
    "", "", "Benito", "Gracias por ayudar a que la asamblea se escuchara.",
    "", "", ""},
  {"Alcaldia", "Hablar mal de alguien por un rumor lo convierte en tu rumor.",
    "Clemencia (candidata)", "Lo que dijiste en la protesta ya esta en todos los grupos.",
    "Clemencia (candidata)", "Gracias por defenderme con argumentos y no con gritos.",
    "Rumores en la protesta", "Ahora mismo", "Ninguna"},
  {"Conecta", "Compartir sin revisar le da alas a un bulo; verificar lo frena.",
    "", "", "", "", "", "", ""},
  {"Rumor en la calle", "Preguntar 'de donde salio?' frena mas rumores que cualquier algoritmo.",
    "", "", "", "", "", "", ""}
};

String[] datosDe(String quien) {
  for (String[] d : datosDecisiones) if (quien.startsWith(d[0])) return d;
  return null;
}

// ------------------------------------- HISTORIAL -------------------------------------
class Decision {
  String quien, que, consecuencia, leccion, hora;
  boolean buena, compartio, pausa;
  int alcance;
}

class Mensaje {
  String de, texto, hora;
  int llega;          // frame en que llega (los pendientes)
}

class Difusion {
  float ox, oy, alcance, maximo;
  boolean apagando;
  String que;
  int aviso = 0;      // ultimo aviso de "ya llego a X personas"
}

class SaltoRumor {
  float x0, y0, x1, y1, t;
  boolean verde;
}

ArrayList<Decision> historial = new ArrayList<Decision>();
ArrayList<Mensaje> mensajes = new ArrayList<Mensaje>();
ArrayList<Mensaje> mensajesPendientes = new ArrayList<Mensaje>();
ArrayList<Difusion> difusiones = new ArrayList<Difusion>();
ArrayList<SaltoRumor> saltosRumor = new ArrayList<SaltoRumor>();
HashMap<String, Boolean> recuerdos = new HashMap<String, Boolean>();
ArrayList<String> pausasPremiadas = new ArrayList<String>();
int mensajesSinLeer = 0;
int vecesDetenido = 0;
float historialScroll = 0;

// guarda una decision: el historial, el rumor en el mapa, el mensaje que llegara y lo que recuerdan
void anotarDecision(String quien, String que, boolean buena, boolean compartio, String consecuencia) {
  String[] d = datosDe(quien);
  Decision dec = new Decision();
  dec.quien = quien;
  dec.que = que;
  dec.buena = buena;
  dec.compartio = compartio;
  dec.hora = textoHora();
  dec.leccion = d != null ? d[1] : "";
  if (consecuencia == null || consecuencia.equals("")) {
    String msj = d == null ? "" : (buena ? d[5] : d[3]);
    consecuencia = !msj.equals("") ? msj : (buena ? "Ayudaste a frenar el rumor." : "El rumor siguio creciendo.");
  }
  dec.consecuencia = consecuencia;
  if (compartio && !buena) {
    Difusion f = new Difusion();
    float[] o = origenEnMapa();
    f.ox = o[0];
    f.oy = o[1];
    f.maximo = int(random(400, 900) + viralidad * 25);
    f.alcance = 12;
    f.que = recortar(que, 40);
    difusiones.add(f);
    dec.alcance = int(f.maximo);
  } else if (buena) {
    // verificar o frenar algo apaga el rumor mas reciente que siga activo
    for (int i = difusiones.size() - 1; i >= 0; i--) {
      if (!difusiones.get(i).apagando) {
        difusiones.get(i).apagando = true;
        break;
      }
    }
  }
  historial.add(dec);
  // el mensaje de alguien afectado (o agradecido) llega en 15 a 35 segundos
  if (d != null) {
    String de = buena ? d[4] : d[2];
    String txt = buena ? d[5] : d[3];
    if (!de.equals("") && !txt.equals("")) {
      Mensaje m = new Mensaje();
      m.de = de;
      m.texto = txt;
      m.llega = frameCount + int(random(900, 2100));
      mensajesPendientes.add(m);
    }
    recuerdos.put(d[0], buena);
  }
}

boolean recuerda(String clave, boolean valor) {
  return recuerdos.containsKey(clave) && recuerdos.get(clave) == valor;
}

// en que parte del mapa empieza a regarse un rumor (segun donde estas)
float[] origenEnMapa() {
  if (esBarrio(scene) || scene == ESC_MERCADO || scene == ESC_CANCHA || scene == ESC_CALLEJON) return new float[] {656, 108};
  if (esColegio(scene) || (scene >= ESC_PASILLO && scene <= ESC_CAFETERIA)) return new float[] {118, 160};
  if (scene == 8 || scene == 11 || scene == 24 || scene == ESC_AVENIDA || scene == ESC_PASEO) return new float[] {672, 372};
  if (scene == ESC_PARQUE) return new float[] {330, 330};
  if (scene == ESC_CENTRO) return new float[] {454, 50};
  if (scene == 1 && eventoPopup != null) return new float[] {eventoPopup.ex, eventoPopup.ey};
  return new float[] {400, 250};
}

int personasAlcanzadas() {
  int n = 0;
  for (Difusion f : difusiones) n += int(f.alcance);
  return n;
}

int rumoresActivos() {
  int n = 0;
  for (Difusion f : difusiones) if (!f.apagando) n++;
  return n;
}

// cada cuadro: los rumores crecen y llegan los mensajes pendientes
void actualizarResponsable() {
  for (Difusion f : difusiones) {
    if (f.apagando) continue;
    f.alcance += (f.maximo - f.alcance) * 0.0012 + 0.3;
    f.alcance = min(f.alcance, f.maximo);
    int hito = int(f.alcance / 500) * 500;
    if (hito >= 500 && hito > f.aviso) {
      f.aviso = hito;
      avisar("Conecta", "Lo que compartiste (\"" + f.que + "\") ya llego a " + hito + " personas.", neonRosa);
    }
  }
  aplicarRecuerdos();
  boolean sePuedeAvisar = !esMinijuego(scene) && !cargaActiva && revisionActiva == null;
  for (int i = mensajesPendientes.size() - 1; i >= 0 && sePuedeAvisar; i--) {
    Mensaje m = mensajesPendientes.get(i);
    if (frameCount < m.llega) continue;
    m.hora = textoHora();
    mensajes.add(m);
    mensajesSinLeer++;
    mensajesPendientes.remove(i);
    avisar("Mensaje de " + m.de, recortar(m.texto, 80), #50B4FF);
  }
}

// en el mapa: el rumor saltando de lugar en lugar (rosa) o apagandose (verde)
void dibujarDifusiones() {
  boolean libre = !pausaAbierta && !telefonoAbierto && !popupAbierto;
  for (Difusion f : difusiones) {
    int cada = f.apagando ? 90 : max(8, 30 - int(f.alcance / 150));
    if (libre && frameCount % cada == 0 && saltosRumor.size() < 40) {
      SaltoRumor s = new SaltoRumor();
      float[] desde = random(1) < 0.5 ? new float[] {f.ox, f.oy} : pinAlAzar();
      float[] hasta = pinAlAzar();
      s.x0 = desde[0];
      s.y0 = desde[1];
      s.x1 = hasta[0];
      s.y1 = hasta[1];
      s.verde = f.apagando;
      saltosRumor.add(s);
    }
  }
  noStroke();
  for (int i = saltosRumor.size() - 1; i >= 0; i--) {
    SaltoRumor s = saltosRumor.get(i);
    if (libre) s.t += 0.022;
    if (s.t >= 1) {
      saltosRumor.remove(i);
      continue;
    }
    float px = lerp(s.x0, s.x1, s.t), py = lerp(s.y0, s.y1, s.t) - sin(s.t * PI) * 60;
    color c = s.verde ? neonVerde : neonRosa;
    for (int k = 1; k <= 6; k++) {
      float tt = max(0, s.t - k * 0.025);
      fill(c, 150 - k * 22);
      ellipse(lerp(s.x0, s.x1, tt), lerp(s.y0, s.y1, tt) - sin(tt * PI) * 60, 12 - k, 12 - k);
    }
    fill(c, 70);
    ellipse(px, py, 26, 26);
    fill(c);
    ellipse(px, py, 12, 12);
    fill(255);
    ellipse(px, py, 4, 4);
    if (s.t > 0.9) {
      noFill();
      stroke(c, 255 * (1 - s.t) * 10);
      strokeWeight(2);
      ellipse(s.x1, s.y1, (s.t - 0.9) * 300, (s.t - 0.9) * 120);
      noStroke();
    }
  }
  // contador abajo a la izquierda
  if (difusiones.size() == 0) return;
  int activos = rumoresActivos();
  float b = 0.6 + 0.4 * sin(frameCount * 0.08);
  fill(8, 6, 22, 220);
  rect(10, height - 62, 300, 50, 10);
  stroke(activos > 0 ? neonRosa : neonVerde, 200 * b);
  strokeWeight(1.5);
  noFill();
  rect(10, height - 62, 300, 50, 10);
  noStroke();
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(12);
  fill(activos > 0 ? neonRosa : neonVerde);
  text(activos > 0 ? "Tus rumores circulando: " + activos : "Tus rumores ya se apagaron", 22, height - 56);
  fill(230);
  textSize(11);
  text("Personas alcanzadas por lo que compartiste: " + nf(personasAlcanzadas(), 0), 22, height - 36);
}

float[] pinAlAzar() {
  float[] l = lugaresMapa[int(random(lugaresMapa.length))];
  return new float[] {l[5], l[6]};
}

// ------------------------------------- LA PAUSA ANTES DE COMPARTIR -------------------------------------
interface Accion {
  void hacer();
}

class Revision {
  String clave, titulo;
  String[] respuestas = new String[3];
  boolean[] ok = new boolean[3];
  Accion siCompartir;
  float t = 0;
}

Revision revisionActiva = null;
boolean saltarRevision = false;
String[] preguntasRevision = {"Quien lo publica?", "Cuando se publico?", "Hay pruebas?"};

void pedirRevision(String clave, String titulo, String quien, boolean okQ, String cuando, boolean okC, String pruebas, boolean okP, Accion siCompartir) {
  Revision r = new Revision();
  r.clave = clave;
  r.titulo = titulo;
  r.respuestas[0] = quien;
  r.respuestas[1] = cuando;
  r.respuestas[2] = pruebas;
  r.ok[0] = okQ;
  r.ok[1] = okC;
  r.ok[2] = okP;
  r.siCompartir = siCompartir;
  revisionActiva = r;
  pararMovimiento();
}

// la pausa con los datos de un personaje (si no hay datos, las respuestas tipicas de un bulo)
void pedirRevisionDe(String quien, String titulo, Accion siCompartir) {
  String[] d = datosDe(quien);
  boolean conDatos = d != null && !d[6].equals("");
  boolean seguro = d != null && d[0].equals("Nico");
  pedirRevision(quien, titulo,
    conDatos ? d[6] : "No se sabe quien lo invento", seguro,
    conDatos ? d[7] : "Sin fecha", seguro,
    conDatos ? d[8] : "Ninguna", seguro, siCompartir);
}

boolean revisionTodoBien() {
  return revisionActiva.ok[0] && revisionActiva.ok[1] && revisionActiva.ok[2];
}

void dibujarRevision() {
  if (revisionActiva == null) return;
  Revision r = revisionActiva;
  if (!pausaAbierta) r.t++;
  noStroke();
  fill(4, 2, 14, 210);
  rect(0, 0, width, height);
  boolean todoBien = revisionTodoBien();
  color borde = r.t < 110 ? neonAmarillo : (todoBien ? neonVerde : neonRojo);
  panelNeon(130, 60, 540, 380, borde);
  tituloNeon("ANTES DE COMPARTIR...", width / 2, 92, 24, neonAmarillo);
  textFont(fuenteUI);
  textAlign(CENTER, TOP);
  textSize(14);
  fill(235);
  text("\"" + recortar(r.titulo, 110) + "\"", 160, 116, 480, 44);
  for (int i = 0; i < 3; i++) {
    float y = 170 + i * 58;
    float aparece = constrain((r.t - 20 - i * 30) / 12.0, 0, 1);
    if (aparece <= 0) {
      fill(40, 36, 60);
      rect(170, y, 460, 48, 10);
      fill(120);
      textAlign(LEFT, CENTER);
      textSize(13);
      text(preguntasRevision[i] + "   ...", 220, y + 24);
      continue;
    }
    color c = r.ok[i] ? neonVerde : neonRojo;
    fill(red(c) * 0.15, green(c) * 0.15, blue(c) * 0.15, 240 * aparece);
    rect(170, y, 460, 48, 10);
    fill(c, 255 * aparece);
    ellipse(196, y + 24, 26, 26);
    stroke(15);
    strokeWeight(3);
    if (r.ok[i]) {
      line(189, y + 24, 194, y + 30);
      line(194, y + 30, 204, y + 18);
    } else {
      line(190, y + 18, 202, y + 30);
      line(202, y + 18, 190, y + 30);
    }
    noStroke();
    textAlign(LEFT, TOP);
    textSize(11);
    fill(200, 255 * aparece);
    text(preguntasRevision[i], 222, y + 6);
    textSize(13);
    fill(255, 255 * aparece);
    text(r.respuestas[i], 222, y + 22, 400, 24);
  }
  if (r.t >= 110) {
    textAlign(CENTER, CENTER);
    textSize(14);
    fill(todoBien ? neonVerde : neonRojo);
    text(todoBien ? "Todo en orden: tiene autor, fecha y pruebas." : "Tiene señales de bulo. Seguro que quieres compartirlo?", width / 2, 352);
    botonNeon(todoBien ? "Compartir" : "Compartir igual", 170, 376, 220, 46, neonRosa, false);
    botonNeon("Mejor no compartir", 410, 376, 220, 46, neonCian, false);
  } else {
    textAlign(CENTER, CENTER);
    textSize(11);
    fill(150);
    text("Revisando... (clic para ver todo)", width / 2, 400);
  }
}

void decidirRevision(boolean compartir) {
  Revision r = revisionActiva;
  revisionActiva = null;
  if (compartir) {
    if (r.siCompartir != null) r.siCompartir.hacer();
    return;
  }
  // se arrepintio
  if (revisionTodoBien(r)) {
    flotar("Era confiable: podias compartirlo", width / 2, 200, neonAmarillo);
    return;
  }
  vecesDetenido++;
  flotar("Bien pensado!", width / 2, 200, neonVerde);
  chispas(width / 2, 220, neonVerde, 40);
  Decision dec = new Decision();
  dec.quien = r.clave;
  dec.que = "Te detuviste antes de compartir: \"" + recortar(r.titulo, 60) + "\"";
  dec.buena = true;
  dec.pausa = true;
  dec.hora = textoHora();
  dec.consecuencia = "El rumor no paso por tus manos.";
  dec.leccion = "Detenerse unos segundos antes de compartir es el mejor filtro que existe.";
  historial.add(dec);
  if (!pausasPremiadas.contains(r.clave)) {   // el premio solo una vez por cada cosa
    pausasPremiadas.add(r.clave);
    confiabilidad += 3;
  }
  if (vecesDetenido >= 3) desbloquear(19);
}

boolean revisionTodoBien(Revision r) {
  return r.ok[0] && r.ok[1] && r.ok[2];
}

boolean clickRevision() {
  if (revisionActiva == null) return false;
  if (revisionActiva.t < 110) {
    revisionActiva.t = 110;
    return true;
  }
  if (encima(170, 376, 220, 46)) decidirRevision(true);
  else if (encima(410, 376, 220, 46)) decidirRevision(false);
  return true;
}

boolean teclaRevision() {
  if (revisionActiva == null) return false;
  if (key == ESC) {
    key = 0;
    decidirRevision(false);
    return true;
  }
  if (revisionActiva.t < 110) {
    if (key == ENTER || key == RETURN || key == ' ') revisionActiva.t = 110;
    return true;
  }
  if (key == '1' || key == 's' || key == 'S') decidirRevision(true);
  else if (key == '2' || key == 'n' || key == 'N') decidirRevision(false);
  return true;
}

// ------------------------------------- LAS DECISIONES DEL JUEGO ORIGINAL (Lab.pde) -------------------------------------
// se llama al principio de mousePressed: anota la decision y, si es "compartir", abre la pausa primero.
// Si en la pausa eliges compartir igual, el clic se repite y el codigo original hace lo de siempre.
int[] opcionBuenaColegio = {1, -1, 1, 1, 1, 0, 1, 0};
boolean[][] comparteColegio = {{true, false}, {false, false}, {true, false}, {true, false}, {true, false}, {false, false}, {false, false}, {true, false}};

boolean revisarClickOriginal() {
  if (saltarRevision) {
    saltarRevision = false;
    return false;
  }
  final int mx = mouseX, my = mouseY;
  String quien = null, que = null;
  boolean buena = false, comparte = false;
  // personajes del colegio
  if (mostrarDialogo && paginter && npcHablando >= 0) {
    int op = -1;
    if (mx > 100 && mx < 350 && my > 440 && my < 470) op = 0;
    else if (mx > 400 && mx < 650 && my > 440 && my < 470) op = 1;
    if (op < 0) return false;
    quien = nombresNpc[npcHablando];
    que = opcionesNpc[npcHablando][op];
    buena = opcionBuenaColegio[npcHablando] == op;
    comparte = comparteColegio[npcHablando][op];
  }
  // menus del barrio (Junta, Debora, Asamblea)
  else if ((scene == 19 && md1) || (scene == 21 && md2) || (scene == 23 && md3)) {
    if (mx < 35 || mx > 765) return false;
    int op = my >= 340 && my <= 378 ? 0 : my >= 385 && my <= 423 ? 1 : my >= 430 && my <= 468 ? 2 : -1;
    if (op < 0) return false;
    String[][] textos = {{"Compartir noticia urgente", "Verificar informacion oficial", "Ignorar la situacion"},
      {"Difundir rumor de protestas", "Investigar en la plaza principal", "Ignorar reportes vecinales"},
      {"Apoyar postura de asamblea", "Actuar como mediador", "Retirarse del lugar"}};
    int menu = scene == 19 ? 0 : scene == 21 ? 1 : 2;
    quien = menu == 0 ? "Junta Vecinal" : menu == 1 ? "Debora" : "Asamblea (Benito)";
    que = textos[menu][op];
    buena = menu == 2 ? op < 2 : op == 1;
    comparte = menu < 2 && op == 0;
  }
  // la decision de la alcaldia
  else if (scene == 11) {
    int op = -1;
    for (int i = 0; i < opciones.length; i++) if (mx > 70 && mx < 730 && my > 330 + i * 52 && my < 372 + i * 52) op = i;
    if (op < 0) return false;
    quien = "Alcaldia";
    que = opciones[op];
    buena = op == 0;
    comparte = op == 2;
  }
  if (quien == null) return false;
  final String fQuien = quien, fQue = que;
  final boolean fBuena = buena, fComparte = comparte;
  if (comparte) {
    pedirRevisionDe(quien, que, new Accion() {
      public void hacer() {
        anotarDecision(fQuien, fQue, fBuena, fComparte, "");
        saltarRevision = true;   // el clic se repite, ahora sin pausa
        mouseX = mx;
        mouseY = my;
        mousePressed();
      }
    }
    );
    return true;
  }
  anotarDecision(quien, que, buena, false, "");
  return false;
}

// ------------------------------------- PANTALLA DEL HISTORIAL (escena 67) -------------------------------------
void dibujarHistorial() {
  background(8, 5, 20);
  fondoArcade(neonMorado);
  tituloNeon("TU HISTORIAL EN NOVA", width / 2, 40, 32, neonCian);
  // resumen
  int buenas = 0, compartidos = 0;
  for (Decision d : historial) {
    if (d.buena) buenas++;
    if (d.compartio && !d.buena) compartidos++;
  }
  String[] titulos = {"Decisiones", "Buenas decisiones", "Rumores compartidos", "Veces que te detuviste"};
  String[] valores = {str(historial.size()), str(buenas), compartidos + " (" + personasAlcanzadas() + " pers.)", str(vecesDetenido)};
  color[] cs = {neonCian, neonVerde, neonRosa, neonAmarillo};
  for (int i = 0; i < 4; i++) {
    float x = 30 + i * 187;
    noStroke();
    fill(10, 8, 26, 230);
    rect(x, 66, 177, 52, 10);
    fill(cs[i]);
    rect(x, 66, 4, 52, 10, 0, 0, 10);
    textFont(fuenteUI);
    textAlign(LEFT, TOP);
    textSize(10);
    fill(190);
    text(titulos[i], x + 14, 74);
    textSize(16);
    fill(cs[i]);
    text(valores[i], x + 14, 90);
  }
  // la lista
  float top = 130, alto = 280, fila = 74;
  float total = historial.size() * fila;
  historialScroll = constrain(historialScroll, 0, max(0, total - alto));
  clip(30, top, 740, alto);
  if (historial.size() == 0) {
    textAlign(CENTER, CENTER);
    textSize(14);
    fill(200);
    text("Todavia no tomaste decisiones en Nova. Sal a explorar!", width / 2, top + 120);
  }
  for (int i = 0; i < historial.size(); i++) {
    Decision d = historial.get(i);
    float y = top + i * fila - historialScroll;
    if (y < top - fila || y > top + alto) continue;
    color c = d.pausa ? neonAmarillo : (d.buena ? neonVerde : neonRojo);
    fill(14, 10, 32, 235);
    rect(30, y, 740, fila - 6, 10);
    fill(c);
    rect(30, y, 5, fila - 6, 10, 0, 0, 10);
    textAlign(LEFT, TOP);
    textSize(11);
    fill(c);
    text((i + 1) + ".  " + d.quien + "   -   " + d.hora + (d.alcance > 0 ? "   -   llego a " + d.alcance + " personas" : ""), 46, y + 6);
    fill(240);
    textSize(12);
    text("Elegiste: " + d.que, 46, y + 22, 710, 16);
    fill(200);
    text("Que paso: " + d.consecuencia, 46, y + 38, 710, 16);
    fill(neonAmarillo);
    textSize(11);
    if (!d.leccion.equals("")) text("En la vida real: " + d.leccion, 46, y + 54, 710, 14);
  }
  noClip();
  if (total > alto) {
    fill(255, 60);
    float a = alto * alto / total;
    rect(774, top + (alto - a) * historialScroll / max(1, total - alto), 4, a, 2);
  }
  // cierre
  textAlign(CENTER, CENTER);
  textFont(fuenteUI);
  textSize(14);
  fill(neonCian);
  text("Y tu? Que harias distinto en tu celular mañana?", width / 2, 428);
  botonNeon("< Volver al final", 160, 448, 220, 40, neonCian, false);
  botonNeon("Nueva partida", 420, 448, 220, 40, neonRosa, false);
}

void clickHistorial() {
  if (encima(160, 448, 220, 40)) scene = ESC_FINAL;
  else if (encima(420, 448, 220, 40)) {
    reiniciarPartida();
    scene = 0;
  }
}

// lo que pasa en el mundo segun lo que recuerdan los personajes
void aplicarRecuerdos() {
  Lugar ps = lugares.get(ESC_PASILLO);
  if (ps != null) {
    for (Interactivo it : ps.inter) {
      // Dani deja de ir al colegio si te burlaste o si Vale se quedo callada
      if (it.nombre.equals("Dani")) it.ausente = recuerda("Dani", false) || recuerda("Vale", false);
    }
  }
}

// Gladys y Don Pacho cuentan lo que paso
Charla charlaSegunRecuerdos(Interactivo it) {
  if (it.nombre.equals("Coordinadora Gladys") && (recuerda("Dani", false) || recuerda("Vale", false))) {
    return new Charla("Coordinadora Gladys", new String[] {
      "Dani no ha vuelto al colegio desde lo de la foto. Sus papas dicen que no quiere salir de la casa.",
      "Un 'chiste' en redes puede volverse algo muy pesado para quien lo vive. Ojala lo pensemos antes de reirnos."
    });
  }
  if (it.nombre.equals("Coordinadora Gladys") && recuerda("Dani", true)) {
    return new Charla("Coordinadora Gladys", new String[] {
      "Gracias por ayudar a Dani. En la asamblea vamos a contar su historia (con su permiso) para que no se repita."
    });
  }
  if (it.nombre.equals("Don Pacho") && recuerda("Don Pacho", false)) {
    return new Charla("Don Pacho", new String[] {
      "...El puesto esta cerrado, joven. El audio contra la competencia asusto a todo el mercado.",
      "Ahora nadie compra fruta. Ni la mia, ni la de nadie."
    });
  }
  return null;
}

void reiniciarResponsable() {
  historial.clear();
  mensajes.clear();
  mensajesPendientes.clear();
  difusiones.clear();
  saltosRumor.clear();
  recuerdos.clear();
  pausasPremiadas.clear();
  mensajesSinLeer = 0;
  vecesDetenido = 0;
  historialScroll = 0;
  revisionActiva = null;
}
