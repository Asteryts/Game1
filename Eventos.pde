// =====================================================================================
//  EVENTOS.pde -> cosas aleatorias que pasan en el MAPA
//  Cada vez que vuelves al mapa es distinto: pueden aparecer rumores sueltos, datos curiosos,
//  retos relampago (un minijuego al azar) o gatos callejeros. Ademas pasan pajaros, un dron
//  de Conecta, nubes, a veces llueve y suben hashtags de los barrios.
// =====================================================================================

class EventoMapa {
  float ex, ey, vida, anim = 0;
  int tipo;       // 0 rumor, 1 dato curioso, 2 reto relampago, 3 gato
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

String[] nombresEvento = {"Rumor suelto", "Dato curioso", "Reto relampago", "Gato callejero"};
color[] coloresEvento = {#FF3CC8, #00F0FF, #FFDC3C, #FF8C3C};
String[] hashtags = {"#Escandalo", "#NovaDecide", "#YLaFuente?", "#FueraBulos", "#Elecciones", "#Verifica", "#Chisme", "#ParqueSi"};

// texto del rumor, que pasa si lo repites, que pasa si preguntas
String[][] rumoresMapa = {
  {"Alguien grita en la esquina: 'Van a cobrar por entrar al parque desde mañana!'", "La gente deja de ir al parque... y no era cierto.", "Le preguntas de donde lo saco: 'Me lo dijo alguien en un bus'. Nadie lo confirma. Rumor frenado."},
  {"Un señor en la parada del bus: 'Dicen que las votaciones se pasan para el lunes!'", "Varias personas casi no van a votar el domingo.", "Revisas la Registraduria: las votaciones siguen siendo el domingo."},
  {"Un grupo de chicos: 'El Cafe 404 lo van a cerrar porque vende cafe con IA'", "El cafe pierde clientes por un chiste mal entendido.", "Le escribes al cafe: era un meme. Ellos mismos lo aclaran con humor."},
  {"Un audio en el grupo del barrio: 'Se cayo un puente en la avenida, no salgan!'", "El panico llena el grupo. El puente esta perfecto.", "Miras las camaras de Transito: el puente esta bien. Avisas al grupo."},
  {"Una cuenta sin foto: 'Gonzalo tiene 14 carros, por eso quiere la ciclorruta... ironia'", "El chiste se vuelve 'noticia' y nadie entiende nada.", "Buscas la declaracion de bienes oficial: Gonzalo tiene una bicicleta."}
};

String[] datosCuriosos = {
  "Dato: los mensajes falsos se comparten mas rapido que los verdaderos, porque suelen ser mas sorprendentes.",
  "Dato: si una noticia no tiene fecha, autor ni fuente, es mejor no compartirla hasta saber mas.",
  "Dato: la mayoria de bulos usan palabras como URGENTE, COMPARTE YA o ANTES DE QUE LO BORREN.",
  "Dato: una foto real puede usarse con una historia falsa. Busca siempre la imagen original.",
  "Dato: preguntar 'quien lo dijo?' frena mas rumores que cualquier algoritmo."
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
  if (eventosMapa.size() >= 3) return;
  EventoMapa e = new EventoMapa();
  float r = random(1);
  e.tipo = r < 0.42 ? 0 : r < 0.62 ? 1 : r < 0.84 ? 2 : 3;
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
      proximoEvento = random(500, 900);
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
  } else {
    ellipse(0, -12 + b, 16, 13);
    triangle(-8, -16 + b, -6, -24 + b, -2, -18 + b);
    triangle(8, -16 + b, 6, -24 + b, 2, -18 + b);
    fill(15, 10, 32);
    ellipse(-3, -13 + b, 2.5, 3);
    ellipse(3, -13 + b, 2.5, 3);
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
  else popupTexto = "Un gato callejero se te acerca, te mira fijamente y maulla. Parece que quiere algo.";
}

String[] botonesPopup() {
  if (popupFase == 1) return new String[] {"Listo"};
  if (eventoPopup.tipo == 0) return new String[] {"Repetirlo", "Preguntar de donde salio"};
  if (eventoPopup.tipo == 1) return new String[] {"Interesante!"};
  if (eventoPopup.tipo == 2) return new String[] {"A jugar!", "Ahora no"};
  return new String[] {"Acariciarlo", "Darle de tu arepa"};
}

void dibujarPopupMapa() {
  if (!popupAbierto) return;
  noStroke();
  fill(0, 150);
  rect(0, 0, width, height);
  color c = coloresEvento[eventoPopup.tipo];
  panelNeon(170, 140, 460, 210, c);
  tituloNeon(nombresEvento[eventoPopup.tipo].toUpperCase(), width / 2, 168, 22, c);
  textFont(fuenteUI);
  textSize(15);
  fill(235);
  textAlign(CENTER, TOP);
  text(popupTexto, 200, 196, 400, 90);
  String[] bs = botonesPopup();
  float bw = bs.length == 1 ? 180 : 190;
  for (int i = 0; i < bs.length; i++) {
    float bx = bs.length == 1 ? width / 2 - bw / 2 : 205 + i * 200;
    botonNeon(bs[i], bx, 290, bw, 42, i == 0 ? c : neonCian, false);
  }
}

boolean clickPopupMapa() {
  String[] bs = botonesPopup();
  float bw = bs.length == 1 ? 180 : 190;
  for (int i = 0; i < bs.length; i++) {
    float bx = bs.length == 1 ? width / 2 - bw / 2 : 205 + i * 200;
    if (!encima(bx, 290, bw, 42)) continue;
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
    } else {
      popupTexto = respuestasGato[i];
      popupFase = 1;
      gatosVistos++;
      desbloquear(16);
      chispas(width / 2, 220, neonAmarillo, 30);
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
