// =====================================================================================
//  CARGA.pde -> pantallas de carga con tema, al abrir un minijuego o entrar a un lugar grande
//  Se dibujan ENCIMA de la escena nueva (que espera quieta detras) durante un segundo y medio.
//  Despues de medio segundo se pueden saltar con clic o con cualquier tecla.
// =====================================================================================

boolean cargaActiva = false;
float cargaT = 0, cargaDur = 100;
int cargaJuego = -1;         // indice del minijuego (o -1 si es un lugar)
int cargaLugar = -1;         // escena del lugar
String cargaFrase = "";

// titulo, subtitulo, frase graciosa 1, frase graciosa 2 (por escena)
String[][] datosCarga(int s) {
  if (s == 1) return new String[][] {{"CIUDAD NOVA", "Conectando con Conecta...", "Despertando a los vecinos...", "Contando los rumores del dia..."}};
  if (s == 5) return new String[][] {{"BARRIO RESIDENCIAL", "Entrando al barrio...", "Buscando la llave perdida...", "Regando las matas de la Junta..."}};
  if (s == 7) return new String[][] {{"COLEGIO NOVA", "Caminando hacia el colegio...", "Sonando la campana...", "Borrando el tablero..."}};
  if (s == ESC_PASILLO) return new String[][] {{"ADENTRO DEL COLEGIO", "Abriendo la puerta principal...", "Ordenando los casilleros...", "Calentando el almuerzo..."}};
  if (s == ESC_AVENIDA) return new String[][] {{"CAMINO A LA ALCALDIA", "Saliendo a la Avenida Central...", "Pintando el paso peatonal...", "Inflando los globos de campaña..."}};
  if (s == 24) return new String[][] {{"ALCALDIA DE NOVA", "Abriendose paso en la protesta...", "Contando pancartas...", "Afinando el megafono del alcalde..."}};
  if (s == ESC_PARQUE) return new String[][] {{"PARQUE CENTRAL", "Llegando al parque...", "Dandole de comer a los patos...", "Prendiendo la fuente..."}};
  if (s == ESC_CENTRO) return new String[][] {{"CENTRO NOVA", "Despertando a la IA...", "Reiniciando los servidores...", "Enseñandole a NOVA a dudar..."}};
  if (s == ESC_ESTUDIO) return new String[][] {{"NOVA NOTICIAS", "Encendiendo las camaras...", "Maquillando a la presentadora...", "Probando el microfono... 1, 2..."}};
  if (s == ESC_PLAZA) return new String[][] {{"PLAZA DE LA VOTACION", "Abriendo las mesas de votacion...", "Revisando las urnas...", "Repartiendo los tarjetones..."}};
  if (s == ESC_FINAL) return new String[][] {{"RESULTADOS", "Contando los votos...", "Revisando cada tarjeton...", "Nova esta a punto de decidir..."}};
  if (s == ESC_MINIJUEGOS) return new String[][] {{"SALA ARCADE", "Encendiendo las maquinas...", "Soplando los cartuchos...", "Buscando monedas..."}};
  return null;
}

String[] consejosJuegos = {
  "Fijate en quien publica y desde cuando existe la cuenta.",
  "Lo verificado tiene fuente, fecha y autor. Atrapalo!",
  "Cuenta nueva + cero seguidores + cientos de posts al dia = bot.",
  "Todo rumor tiene un origen: buscalo antes de creerlo.",
  "Cada vez que un mensaje pasa de boca en boca, cambia un poquito.",
  "El torneo del barrio casi se cancela por un rumor... a cobrar penales!",
  "Una foto puede estar editada aunque parezca real.",
  "URGENTE, COMPARTE YA, ANTES DE QUE LO BORREN: palabras de bulo.",
  "Mueve solo la mano: la camara busca tu piel y tu movimiento.",
  "Levanta la mano por encima de la linea amarilla para saltar."
};

String[] frasesJuegos = {
  "Barajando titulares...", "Inflando burbujas...", "Despertando a los bots...", "Barajando las cartas...",
  "Pasando el chisme...", "Inflando el balon...", "Retocando las fotos...", "Limpiando el teclado...",
  "Calentando la camara...", "Amarrando los cordones..."
};

// se llama desde alCambiarEscena (Vida.pde)
void quizasPantallaCarga(int de, int a) {
  int idxJ = esMinijuego(a) ? idxJuego(a) : -1;
  boolean lugarGrande = (de == 1 && (a == 5 || a == 7 || a == ESC_AVENIDA || a == ESC_PARQUE || a == ESC_CENTRO || a == ESC_ESTUDIO || a == ESC_PLAZA))
    || ((de == 0 || de == ESC_INTRO) && a == 1)
    || (a == ESC_PASILLO && de == 17)
    || (a == 24 && de == ESC_PASEO)
    || a == ESC_FINAL
    || (a == ESC_MINIJUEGOS && de == 0);
  if (idxJ < 0 && !lugarGrande) return;
  cargaActiva = true;
  cargaT = 0;
  cargaDur = random(85, 115);
  cargaJuego = idxJ;
  cargaLugar = a;
  if (idxJ >= 0) cargaFrase = frasesJuegos[idxJ];
  else cargaFrase = datosCarga(a)[0][random(1) < 0.5 ? 2 : 3];
  pararMovimiento();
}

// tecla o clic durante la carga: se salta (si ya paso medio segundo). Siempre se "come" el evento
boolean entradaDuranteCarga() {
  if (!cargaActiva) return false;
  if (cargaT > 30) cargaT = cargaDur;
  return true;
}

void dibujarPantallaCarga() {
  if (!cargaActiva) return;
  if (!pausaAbierta) cargaT++;
  float p = constrain(cargaT / cargaDur, 0, 1);
  float salida = constrain((cargaT - cargaDur) / 14.0, 0, 1);   // se desvanece al final
  if (salida >= 1) {
    cargaActiva = false;
    return;
  }
  color c = cargaJuego >= 0 ? coloresJuegos[cargaJuego] : neonCian;
  // ---- fondo e ilustracion en pixel art ----
  empezarFondoPixel();
  if (cargaJuego >= 0) {
    fondoArcade(c);
  } else {
    dibujarFondoCiudadMundo();
    noStroke();
    fill(6, 3, 18, 150);
    rect(0, 0, width, height);
  }
  pushMatrix();
  translate(width / 2, 190);
  if (cargaJuego >= 0) {
    scale(1.6);
    animacionJuego(cargaJuego);
  } else {
    scale(1.4);
    iconoLugar(cargaLugar);
  }
  popMatrix();
  terminarFondoPixel();
  // ---- textos y barra (nitidos) ----
  String titulo = cargaJuego >= 0 ? nombresJuegos[cargaJuego].toUpperCase() : datosCarga(cargaLugar)[0][0];
  String sub = cargaJuego >= 0 ? "Cargando minijuego..." : datosCarga(cargaLugar)[0][1];
  String consejo = cargaJuego >= 0 ? consejosJuegos[cargaJuego] : consejosNova[(cargaLugar * 7) % consejosNova.length];
  tituloNeon(titulo, width / 2, 318, 34, c);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(14);
  fill(230);
  text(p < 0.55 ? sub : cargaFrase, width / 2, 352);
  // barra de carga hecha de bloques (pixel art)
  int bloques = 24;
  float bw = 14, bx = width / 2 - bloques * (bw + 3) / 2;
  for (int i = 0; i < bloques; i++) {
    boolean lleno = i < p * bloques;
    fill(lleno ? c : color(40, 36, 60));
    rect(bx + i * (bw + 3), 378, bw, 14);
  }
  fill(200);
  textSize(12);
  text(int(p * 100) + "%", width / 2, 404);
  // consejo
  fill(10, 8, 26, 210);
  rect(120, 426, 560, 40, 10);
  fill(neonAmarillo);
  textSize(12);
  text("CONSEJO:  " + consejo, width / 2, 446);
  if (cargaT > 30) {
    fill(150);
    textSize(10);
    text("clic o cualquier tecla para saltar", width / 2, 484);
  }
  if (salida > 0) {
    fill(0, 255 * salida);
    rect(0, 0, width, height);
  }
}

// ------------------------------------- ANIMACIONES DE CADA MINIJUEGO -------------------------------------
void animacionJuego(int i) {
  float t = frameCount * 0.06;
  color c = coloresJuegos[i];
  noStroke();
  if (i == 0) {   // una carta que va a FALSO o REAL
    float lado = sin(t) > 0 ? 1 : -1;
    pushMatrix();
    rotate(sin(t) * 0.25);
    translate(sin(t) * 40, 0);
    fill(240);
    rect(-34, -44, 68, 88, 6);
    fill(120);
    rect(-24, -30, 48, 6);
    rect(-24, -18, 40, 5);
    rect(-24, -8, 44, 5);
    fill(lado > 0 ? neonVerde : neonRojo);
    rect(-26, 12, 52, 18, 3);
    popMatrix();
  } else if (i == 1) {   // burbujas cayendo en el filtro
    for (int k = 0; k < 3; k++) {
      float y = ((t * 30 + k * 30) % 90) - 60;
      fill(k == 1 ? neonRojo : neonVerde);
      ellipse(-30 + k * 30, y, 18, 18);
    }
    fill(c);
    quad(-50, 34, 50, 34, 22, 58, -22, 58);
  } else if (i == 2) {   // bots asomandose
    for (int k = 0; k < 3; k++) {
      float sube = max(0, sin(t * 1.5 + k * 2)) * 30;
      fill(30, 26, 52);
      rect(-80 + k * 56, -10, 48, 50, 6);
      fill(150, 160, 180);
      rect(-74 + k * 56, 30 - sube, 36, 30, 5);
      fill(neonRojo);
      rect(-68 + k * 56, 38 - sube, 7, 7);
      rect(-52 + k * 56, 38 - sube, 7, 7);
    }
    fill(8, 5, 20);
    rect(-90, 40, 180, 40);
  } else if (i == 3) {   // cartas que se voltean
    for (int k = 0; k < 2; k++) {
      float g = abs(cos(t + k * 1.5));
      fill(g > 0.5 ? (k == 0 ? neonRosa : neonCian) : color(40, 30, 70));
      rect(-46 + k * 52 - 20 * g, -36, 40 * g, 72, 5);
    }
  } else if (i == 4) {   // el rumor pasando de amigo en amigo
    for (int k = 0; k < 4; k++) {
      float a = k * HALF_PI - HALF_PI;
      boolean activo = int(t * 2) % 4 == k;
      fill(activo ? coloresTR[k] : color(50, 40, 80));
      ellipse(cos(a) * 50, sin(a) * 50, activo ? 34 : 26, activo ? 34 : 26);
    }
  } else if (i == 5) {   // balon rebotando hacia el arco
    stroke(240);
    strokeWeight(4);
    noFill();
    rect(-70, -50, 140, 70);
    noStroke();
    float x = ((t * 40) % 140) - 70, y = -abs(sin(t * 3)) * 50 + 40;
    fill(250);
    ellipse(x, y, 22, 22);
    fill(30);
    ellipse(x, y, 7, 7);
  } else if (i == 6) {   // lupa pasando sobre una foto
    fill(240);
    rect(-60, -40, 120, 80, 4);
    fill(120, 180, 240);
    rect(-54, -34, 108, 48);
    fill(80, 80, 90);
    rect(-54, 14, 108, 20);
    fill(neonAmarillo);
    ellipse(-30, -20, 16, 16);
    float lx = sin(t) * 40, ly = cos(t * 1.3) * 16;
    noFill();
    stroke(c);
    strokeWeight(5);
    ellipse(lx, ly, 36, 36);
    line(lx + 13, ly + 13, lx + 28, ly + 28);
    noStroke();
  } else if (i == 7) {   // teclas que se hunden
    for (int f = 0; f < 3; f++) {
      for (int k = 0; k < 6; k++) {
        boolean baja = int(t * 4 + k * 3 + f * 5) % 9 == 0;
        fill(baja ? c : color(220));
        rect(-66 + k * 22 + f * 5, -30 + f * 22 + (baja ? 3 : 0), 18, 17, 3);
      }
    }
  } else if (i == 8) {   // una mano dandole un manotazo a un bulo
    float g = sin(t * 2);
    fill(neonRojo);
    pushMatrix();
    translate(40 + max(0, -g) * 30, -10 - max(0, -g) * 20);
    rotate(max(0, -g) * 1.2);
    rect(-28, -12, 56, 24, 12);
    popMatrix();
    pushMatrix();
    translate(-30 + g * 20, 10);
    rotate(g * 0.4);
    fill(255, 214, 170);
    rect(-16, -12, 32, 30, 6);
    for (int k = 0; k < 4; k++) rect(-16 + k * 8, -32, 6, 24, 3);
    popMatrix();
  } else if (i == 9) {   // corredor saltando una pila de bulos
    float salto = abs(sin(t * 1.8)) * 50;
    fill(70, 56, 96);
    rect(-90, 40, 180, 8);
    float ox = 60 - ((t * 40) % 150);
    fill(neonRojo);
    rect(ox, 10, 26, 30, 3);
    fill(c);
    rect(-50, 10 - salto, 22, 30, 5);
    fill(255, 214, 170);
    ellipse(-39, 2 - salto, 18, 18);
  }
}

// ------------------------------------- ICONOS DE CADA LUGAR -------------------------------------
void iconoLugar(int s) {
  float b = sin(frameCount * 0.08) * 4;
  noStroke();
  fill(neonCian, 30);
  ellipse(0, 0, 150, 150);
  if (s == 7 || s == ESC_PASILLO) {   // un libro abierto (como el letrero del colegio)
    fill(neonRosa);
    quad(-50, -24 + b, 0, -14 + b, 0, 30 + b, -50, 20 + b);
    quad(50, -24 + b, 0, -14 + b, 0, 30 + b, 50, 20 + b);
    fill(250);
    quad(-44, -18 + b, -4, -10 + b, -4, 24 + b, -44, 16 + b);
    quad(44, -18 + b, 4, -10 + b, 4, 24 + b, 44, 16 + b);
  } else if (s == 5) {   // una casa
    fill(neonRosa);
    triangle(-46, -6 + b, 0, -46 + b, 46, -6 + b);
    fill(110, 70, 140);
    rect(-36, -6 + b, 72, 50);
    fill(255, 214, 130);
    rect(-26, 4 + b, 18, 16);
    rect(8, 4 + b, 18, 16);
    fill(60, 34, 34);
    rect(-8, 22 + b, 16, 22);
  } else if (s == 24 || s == ESC_AVENIDA) {   // edificio con columnas
    fill(200, 190, 215);
    triangle(-56, -20 + b, 0, -50 + b, 56, -20 + b);
    rect(-50, -20 + b, 100, 60);
    for (int k = 0; k < 5; k++) {
      fill(240);
      rect(-42 + k * 20, -12 + b, 8, 46);
    }
  } else if (s == ESC_PARQUE) {   // un arbol
    fill(110, 75, 50);
    rect(-6, 0 + b, 12, 40);
    fill(60, 150, 90);
    ellipse(0, -18 + b, 80, 60);
    fill(90, 180, 110);
    ellipse(-14, -28 + b, 40, 30);
  } else if (s == ESC_CENTRO) {   // el orbe de NOVA
    fill(neonMorado, 80);
    ellipse(0, b, 90, 90);
    noFill();
    stroke(neonCian);
    strokeWeight(3);
    ellipse(0, b, 110, 34);
    noStroke();
    fill(neonCian);
    ellipse(0, b, 40, 40);
  } else if (s == ESC_ESTUDIO) {   // un televisor
    fill(40, 36, 60);
    rect(-56, -38 + b, 112, 76, 8);
    fill(frameCount % 40 < 20 ? neonRojo : neonRosa);
    rect(-46, -30 + b, 92, 58, 4);
    fill(255);
    textFont(fuenteUI);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("EN VIVO", 0, -2 + b);
  } else if (s == ESC_PLAZA || s == ESC_FINAL) {   // la urna con un voto entrando
    fill(220, 225, 240);
    rect(-40, -10, 80, 54, 4);
    fill(30);
    rect(-20, -6, 40, 4);
    fill(255);
    float v = (frameCount * 1.5) % 50;
    rect(-12, -50 + v, 24, 30);
  } else if (s == ESC_MINIJUEGOS) {   // un control
    fill(neonRosa);
    rect(-50, -24 + b, 100, 48, 22);
    fill(20);
    rect(-34, -4 + b, 22, 7);
    rect(-26, -12 + b, 7, 22);
    ellipse(24, -6 + b, 10, 10);
    ellipse(36, 6 + b, 10, 10);
  } else {   // el pin del mapa
    fill(neonRosa);
    ellipse(0, -16 + b, 60, 60);
    triangle(-26, 0 + b, 26, 0 + b, 0, 46 + b);
    fill(20);
    ellipse(0, -16 + b, 24, 24);
  }
}
