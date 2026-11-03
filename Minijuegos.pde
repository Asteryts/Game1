// =====================================================================================
//  MINIJUEGOS.pde -> la Sala Arcade y los 4 minijuegos
//   41 Verificador Express   (real o bulo, con A/D)
//   42 Atrapa Bulos          (atrapa lo verificado, esquiva lo falso)
//   43 Caza Bots             (clic en los bots, no en las personas)
//   44 Rastreo de Fuentes    (memoria: une cada rumor con su origen real)
// =====================================================================================

int regresoSala = 0;        // a donde vuelve el boton "Volver" de la sala arcade
int regresoJuego = 1;       // a donde vuelve un juego abierto desde el telefono o un terminal
boolean juegoDesdeSala = true;
int estadoJuego = 0;        // 0 instrucciones, 1 cuenta regresiva, 2 jugando, 3 resultados
float cuentaJuego = 0;
int puntaje = 0;
boolean nuevoRecord = false;
String textoPremio = "";
String resumenJuego = "";
int[] records = new int[10];
boolean[] premiado = new boolean[10];
int[] umbralPremio = {700, 250, 12, 500, 600, 300, 800, 500, 250, 400};
String[] nombresJuegos = {"Verificador Express", "Atrapa Bulos", "Caza Bots", "Rastreo de Fuentes", "Telefono Roto", "Penales", "Foto Trucada", "Teclado Veloz", "Manotazo", "Salto con la Mano"};
String[] descJuegos = {
  "Real o bulo? Clasifica titulares antes de que se acabe el tiempo.",
  "Atrapa la informacion verificada y esquiva los bulos que caen.",
  "Haz clic en las cuentas bot antes de que se escondan.",
  "Voltea cartas y une cada rumor con su verdadero origen.",
  "Memoriza como pasa el rumor y repitelo sin deformarlo.",
  "Apunta, elige la fuerza y vence al portero del barrio.",
  "Encuentra las 5 cosas que cambiaron en la foto editada.",
  "Escribe las palabras antes de que se vuelvan virales.",
  "Con la CAMARA: mueve la mano para darle manotazos a los bulos.",
  "Con la CAMARA: levanta la mano para saltar las pilas de bulos."
};
String[] instruccionesJuegos = {
  "Apareceran 10 publicaciones de Conecta.\nA o FLECHA IZQUIERDA = es FALSO\nD o FLECHA DERECHA = es REAL\nFijate en quien publica y en cuando se creo la cuenta.",
  "Mueve el filtro con A/D, las flechas o el mouse.\nAtrapa las burbujas VERDES (verificado) y las DORADAS (bonus).\nEsquiva las ROJAS: cada bulo que atrapes te quita una vida.",
  "Tienes 35 segundos. Haz clic en las cuentas BOT:\ncuentas nuevas, sin foto, nombres con numeros y cero seguidores.\nSi le das a una persona real pierdes puntos y tiempo.",
  "Hay 6 rumores (rosados) y 6 origenes reales (cian).\nVoltea dos cartas a la vez y une cada rumor con su verdad.\nMenos movimientos y menos tiempo = mas puntos.",
  "El rumor pasa de amigo en amigo. Mira el orden en que hablan.\nLuego repitelo con clic o con las teclas 1, 2, 3 y 4.\nCada ronda el mensaje es mas largo. Si te equivocas, se deforma!",
  "Tienes 5 tiros. Primer clic (o ESPACIO): fija la direccion.\nSegundo clic: fija la fuerza. Mucha fuerza = por encima del arco.\nLas esquinas valen mas, pero el portero cada vez adivina mejor.",
  "Te mostramos una foto original y una version editada.\nHaz clic donde veas un cambio: colores, cosas que se movieron,\nque crecieron o que desaparecieron. Los errores restan tiempo!",
  "Caen palabras: escribelas con el teclado antes de que lleguen abajo.\nEscribe la primera letra y el juego elige esa palabra.\nSi una palabra llega al fondo, pierdes una vida.",
  "Mueve la MANO en el aire para darle manotazos a los bulos ROJOS. No toques los VERDES.\nEl juego busca tu piel: lo que se pinta de cian es tu mano (la cara y la ropa no cuentan).\nPrimero pon la palma en el cuadro y presiona C para calibrar. (Sin camara: mouse.)",
  "Corres por los techos de Nova. LEVANTA LA MANO por encima de la linea amarilla\npara saltar las pilas de bulos y esquivar los bulos voladores.\nAgarra los datos verificados (verdes). Sin camara: ESPACIO, W, flecha o clic."
};
color[] coloresJuegos = {#00F0FF, #3CFF96, #FF3CC8, #FFDC3C, #FF8C3C, #46DC64, #8C78FF, #3CDCDC, #FF5AA0, #50B4FF};

int[] escenasJuegos = {41, 42, 43, 44, 61, 62, 63, 64, 65, 66};   // ESC_VERIFICADOR ... ESC_SALTO

int idxJuego(int s) {
  for (int i = 0; i < escenasJuegos.length; i++) if (escenasJuegos[i] == s) return i;
  return 0;
}

boolean esMinijuego(int s) {
  for (int e : escenasJuegos) if (e == s) return true;
  return false;
}

void lanzarJuego(int s, boolean desdeSala) {
  juegoDesdeSala = desdeSala;
  if (!desdeSala) regresoJuego = scene;
  pararMovimiento();
  cerrarCharla();
  scene = s;
  estadoJuego = 0;
  puntaje = 0;
  nuevoRecord = false;
  textoPremio = "";
  if (esJuegoCamara(s)) pedirCamara = 3;   // se enciende la camara en unos cuadros (Camara.pde)
  desbloquear(3);
}

void empezarJuego() {
  estadoJuego = 1;
  cuentaJuego = 150;
  puntaje = 0;
  nuevoRecord = false;
  textoPremio = "";
  resumenJuego = "";
  if (scene == ESC_VERIFICADOR) resetVerificador();
  else if (scene == ESC_ATRAPA) resetAtrapa();
  else if (scene == ESC_CAZABOTS) resetCazaBots();
  else if (scene == ESC_MEMORIA) resetMemoria();
  else if (scene == ESC_MANOTAZO) resetManotazo();
  else if (scene == ESC_SALTO) resetSalto();
  else if (scene == ESC_TELROTO) resetTelefonoRoto();
  else if (scene == ESC_PENALES) resetPenales();
  else if (scene == ESC_FOTO) resetFotoTrucada();
  else if (scene == ESC_TECLADO) resetTeclado();
}

void terminarJuego() {
  estadoJuego = 3;
  int idx = idxJuego(scene);
  if (puntaje > records[idx]) {
    records[idx] = puntaje;
    nuevoRecord = true;
  }
  if (puntaje >= umbralPremio[idx] && !premiado[idx]) {
    premiado[idx] = true;
    confiabilidad += 5;
    impacto += 5;
    textoPremio = "Premio! +5 Confiabilidad  +5 Impacto";
  } else if (puntaje >= umbralPremio[idx]) {
    textoPremio = "Ya reclamaste el premio de este juego.";
  } else {
    textoPremio = "Consigue " + umbralPremio[idx] + " puntos para ganar un premio.";
  }
  if (scene == ESC_VERIFICADOR) {
    resumenJuego = aciertosV + " de 10 titulares bien clasificados";
    if (aciertosV >= 8) desbloquear(4);
  } else if (scene == ESC_ATRAPA) {
    resumenJuego = vidasA > 0 ? "Sobreviviste a la lluvia de bulos!" : "Los bulos te ganaron esta vez...";
    if (puntaje >= 300) desbloquear(11);
  } else if (scene == ESC_CAZABOTS) {
    resumenJuego = botsCB + " bots eliminados";
    if (botsCB >= 15) desbloquear(5);
  } else if (scene == ESC_MEMORIA) {
    resumenJuego = movimientosM + " movimientos en " + int(tiempoM) + " segundos";
    desbloquear(6);
  } else if (scene == ESC_TELROTO) {
    resumenJuego = "Llegaste a la ronda " + largoTR;
  } else if (scene == ESC_PENALES) {
    resumenJuego = golesP + " goles de 5 tiros";
  } else if (scene == ESC_FOTO) {
    resumenJuego = halladasF + " diferencias encontradas, " + erroresF + " errores";
  } else if (scene == ESC_TECLADO) {
    resumenJuego = vidasT > 0 ? "Ninguna palabra mas se hizo viral!" : "Demasiadas palabras virales...";
  } else if (scene == ESC_MANOTAZO) {
    resumenJuego = bulosGolpeados + " bulos sacados a manotazos" + (modoMouse ? " (con el mouse)" : "");
  } else if (scene == ESC_SALTO) {
    resumenJuego = saltosS + " saltos y " + datosS + " datos verificados" + (vidasS > 0 ? " - llegaste al final!" : "");
  }
  guardarDatos();
  explosionConfeti(width / 2, 160, nuevoRecord ? 90 : 30);
}

void salirJuego() {
  if (esJuegoCamara(scene)) apagarCamara();   // la camara solo se usa en esos juegos
  scene = juegoDesdeSala ? ESC_MINIJUEGOS : regresoJuego;
  pararMovimiento();
}

// ------------------------------------- SALA ARCADE -------------------------------------
void fondoArcade(color c) {
  background(8, 5, 20);
  noStroke();
  for (int i = 0; i < 120; i += 4) {
    fill(red(c), green(c), blue(c), map(i, 0, 120, 0, 40));
    rect(0, i, width, 4);
  }
  stroke(c, 45);
  strokeWeight(1);
  float hzn = 120;
  for (int i = -12; i <= 12; i++) line(width / 2 + i * 30, hzn, width / 2 + i * 170, height);
  float off = (frameCount * 1.2) % 40;
  for (float yy = 0; yy < 400; yy += 40) {
    float t = (yy + off) / 400.0;
    line(0, hzn + t * t * (height - hzn), width, hzn + t * t * (height - hzn));
  }
  noStroke();
}

void dibujarSalaArcade() {
  fondoArcade(neonMorado);
  tituloNeon("SALA ARCADE", width / 2, 46, 46, neonRosa);
  textFont(fuenteUI);
  textSize(13);
  fill(200);
  textAlign(CENTER, CENTER);
  text("Entrena tu ojo de verificador. Cada juego da un premio la primera vez que superas su meta.", width / 2, 84);
  for (int i = 0; i < nombresJuegos.length; i++) {
    float cx = 12 + (i % 5) * 156, cy = 102 + (i / 5) * 190, cw = 148, chh = 176;
    boolean s = encima(cx, cy, cw, chh);
    float lev = s ? -5 : 0;
    color c = coloresJuegos[i];
    noStroke();
    if (s) for (int k = 4; k >= 1; k--) {
      fill(c, 16);
      rect(cx - k * 4, cy - k * 4 + lev, cw + k * 8, chh + k * 8, 18 + k * 4);
    }
    fill(14, 10, 32, 235);
    rect(cx, cy + lev, cw, chh, 18);
    stroke(c, s ? 255 : 140);
    strokeWeight(s ? 2.5 : 1.5);
    noFill();
    rect(cx, cy + lev, cw, chh, 18);
    noStroke();
    pushMatrix();
    translate(cx + cw / 2, cy + 46 + lev);
    scale(0.56);
    iconoJuego(i, 0, 0, c);
    popMatrix();
    textFont(fuente);
    textSize(13);
    fill(c);
    textAlign(CENTER, TOP);
    text(nombresJuegos[i], cx + cw / 2, cy + 82 + lev);
    textFont(fuenteUI);
    textSize(10);
    fill(220);
    text(descJuegos[i], cx + 8, cy + 102 + lev, cw - 16, 48);
    fill(170);
    textSize(9);
    textAlign(LEFT, TOP);
    text("Record " + records[i] + (premiado[i] ? "  -  premio listo" : "  -  meta " + umbralPremio[i]), cx + 8, cy + chh - 16 + lev);
    fill(c);
    textSize(11);
    textAlign(RIGHT, TOP);
    text(s ? "JUGAR >" : "", cx + cw - 8, cy + 8 + lev);
  }
  botonVolver();
}

void iconoJuego(int i, float cx, float cy, color c) {
  float b = sin(frameCount * 0.06 + i) * 3;
  noStroke();
  fill(c, 40);
  ellipse(cx, cy + b, 90, 90);
  fill(c);
  if (i == 0) {
    pushMatrix();
    translate(cx, cy + b);
    rotate(-0.15);
    fill(240);
    rect(-24, -30, 48, 60, 6);
    fill(neonRojo);
    rect(-16, -18, 32, 6, 3);
    fill(120);
    rect(-16, -6, 26, 4);
    rect(-16, 2, 30, 4);
    fill(neonVerde);
    ellipse(14, 20, 20, 20);
    popMatrix();
  } else if (i == 1) {
    quad(cx - 30, cy - 6 + b, cx + 30, cy - 6 + b, cx + 10, cy + 20 + b, cx - 10, cy + 20 + b);
    fill(neonVerde);
    ellipse(cx - 10, cy - 26 + b * 2, 16, 16);
    fill(neonRojo);
    ellipse(cx + 14, cy - 34 - b, 14, 14);
  } else if (i == 2) {
    fill(170, 180, 200);
    rect(cx - 22, cy - 22 + b, 44, 40, 8);
    fill(15, 20, 35);
    rect(cx - 16, cy - 15 + b, 32, 22, 4);
    fill(neonRojo);
    rect(cx - 11, cy - 9 + b, 7, 7);
    rect(cx + 4, cy - 9 + b, 7, 7);
    stroke(c);
    strokeWeight(3);
    noFill();
    ellipse(cx, cy + b, 70, 70);
    line(cx - 40, cy + b, cx - 26, cy + b);
    line(cx + 26, cy + b, cx + 40, cy + b);
    noStroke();
  } else if (i == 4) {
    // telefono roto: tres amigos conectados
    stroke(c);
    strokeWeight(3);
    line(cx - 24, cy + 14 + b, cx, cy - 18 + b);
    line(cx, cy - 18 + b, cx + 24, cy + 14 + b);
    noStroke();
    fill(neonRosa);
    ellipse(cx - 24, cy + 14 + b, 22, 22);
    fill(neonCian);
    ellipse(cx, cy - 18 + b, 22, 22);
    fill(neonAmarillo);
    ellipse(cx + 24, cy + 14 + b, 22, 22);
  } else if (i == 5) {
    // penales: balon
    fill(250);
    ellipse(cx, cy + b, 52, 52);
    fill(30);
    pushMatrix();
    translate(cx, cy + b);
    rotate(frameCount * 0.02);
    ellipse(0, 0, 14, 14);
    for (int k = 0; k < 5; k++) ellipse(cos(k * TWO_PI / 5) * 18, sin(k * TWO_PI / 5) * 18, 10, 10);
    popMatrix();
  } else if (i == 6) {
    // foto trucada: dos fotos y una lupa
    fill(240);
    rect(cx - 30, cy - 20 + b, 34, 28, 3);
    rect(cx - 2, cy - 12 + b, 34, 28, 3);
    fill(120, 180, 240);
    rect(cx - 27, cy - 17 + b, 28, 16);
    fill(neonRojo);
    rect(cx + 1, cy - 9 + b, 28, 16);
    noFill();
    stroke(c);
    strokeWeight(4);
    ellipse(cx + 18, cy + 14 + b, 22, 22);
    line(cx + 26, cy + 22 + b, cx + 36, cy + 32 + b);
    noStroke();
  } else if (i == 7) {
    // teclado veloz: teclas
    for (int f = 0; f < 3; f++) {
      for (int k = 0; k < 4 - (f == 2 ? 1 : 0); k++) {
        fill(f == 1 && k == 1 ? c : color(230));
        rect(cx - 34 + k * 18 + f * 6, cy - 22 + f * 16 + b, 15, 13, 3);
      }
    }
  } else if (i == 8) {
    // manotazo: una mano y una camara
    fill(255, 214, 170);
    rect(cx - 16, cy - 6 + b, 28, 26, 5);
    for (int k = 0; k < 4; k++) rect(cx - 16 + k * 7, cy - 26 + b, 5, 22, 3);
    rect(cx + 12, cy + b, 10, 5, 2);
    fill(40);
    rect(cx + 6, cy - 34, 30, 20, 4);
    fill(c);
    ellipse(cx + 21, cy - 24, 12, 12);
    fill(neonRojo);
    ellipse(cx + 32, cy - 31, 4, 4);
  } else if (i == 9) {
    // salto con la mano: corredor saltando una pila de bulos
    fill(70, 56, 96);
    rect(cx - 40, cy + 26, 80, 6);
    fill(neonRojo);
    rect(cx + 8, cy + 6, 22, 20, 3);
    rect(cx + 11, cy - 12, 22, 18, 3);
    fill(c);
    rect(cx - 30, cy - 16 + b * 2, 18, 24, 4);
    fill(255, 214, 170);
    ellipse(cx - 21, cy - 24 + b * 2, 14, 14);
  } else {
    pushMatrix();
    translate(cx - 12, cy + b);
    rotate(-0.2);
    fill(neonRosa);
    rect(-16, -24, 32, 46, 5);
    popMatrix();
    pushMatrix();
    translate(cx + 14, cy - b);
    rotate(0.2);
    fill(neonCian);
    rect(-16, -24, 32, 46, 5);
    popMatrix();
  }
}

void clickSala() {
  if (clickVolver()) {
    scene = regresoSala;
    return;
  }
  for (int i = 0; i < nombresJuegos.length; i++) {
    if (encima(12 + (i % 5) * 156, 102 + (i / 5) * 190, 148, 176)) lanzarJuego(escenasJuegos[i], true);
  }
}

// ------------------------------------- PIEZAS COMUNES -------------------------------------
void cabeceraJuego(int idx) {
  botonVolver();
  textFont(fuente);
  textSize(26);
  fill(coloresJuegos[idx]);
  textAlign(LEFT, CENTER);
  text(nombresJuegos[idx], 132, 32);
  textFont(fuenteUI);
  textAlign(RIGHT, CENTER);
  textSize(11);
  fill(180);
  text("RECORD " + records[idx], width - 20, 20);
  fill(255);
  textSize(24);
  text(puntaje, width - 20, 44);
}

void pantallaInstrucciones(int idx) {
  panelNeon(110, 90, 580, 340, coloresJuegos[idx]);
  iconoJuego(idx, width / 2, 160, coloresJuegos[idx]);
  tituloNeon(nombresJuegos[idx], width / 2, 232, 32, coloresJuegos[idx]);
  textFont(fuenteUI);
  textSize(14);
  fill(225);
  textAlign(CENTER, TOP);
  text(instruccionesJuegos[idx], 140, 262, 520, 100);
  if (frameCount % 50 < 35) {
    fill(coloresJuegos[idx]);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Clic o ENTER para empezar", width / 2, 400);
  }
}

void pantallaCuenta() {
  int n = ceil(cuentaJuego / 50.0);
  float f = (cuentaJuego % 50) / 50.0;
  noStroke();
  fill(0, 120);
  rect(0, 0, width, height);
  tituloNeon(n > 0 ? str(n) : "YA!", width / 2, height / 2, 60 + 70 * f, neonAmarillo);
}

void pantallaResultados(int idx) {
  color c = coloresJuegos[idx];
  panelNeon(170, 80, 460, 360, c);
  tituloNeon("FIN DEL JUEGO", width / 2, 118, 30, c);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(14);
  fill(180);
  text("PUNTAJE", width / 2, 160);
  tituloNeon(str(puntaje), width / 2, 200, 54, color(255));
  if (nuevoRecord && frameCount % 30 < 20) {
    fill(neonAmarillo);
    textSize(18);
    text("NUEVO RECORD!", width / 2, 245);
  } else {
    fill(170);
    textSize(13);
    text("Record: " + records[idx], width / 2, 245);
  }
  fill(230);
  textSize(14);
  text(resumenJuego, width / 2, 275);
  fill(textoPremio.startsWith("Premio") ? neonVerde : color(170));
  textSize(13);
  text(textoPremio, width / 2, 302);
  botonNeon("Otra vez", 215, 350, 170, 48, c, false);
  botonNeon("Salir", 415, 350, 170, 48, neonRosa, false);
}

boolean jugandoAhora() {
  return estadoJuego == 2 && !pausaAbierta && !telefonoAbierto;
}

void avanzarCuenta() {
  if (estadoJuego == 1) {
    cuentaJuego--;
    if (cuentaJuego <= 0) estadoJuego = 2;
  }
}

void clickJuego() {
  if (clickVolver()) {
    salirJuego();
    return;
  }
  if (estadoJuego == 0) {
    empezarJuego();
    return;
  }
  if (estadoJuego == 3) {
    if (encima(215, 350, 170, 48)) empezarJuego();
    else if (encima(415, 350, 170, 48)) salirJuego();
    return;
  }
  if (estadoJuego != 2) return;
  if (scene == ESC_VERIFICADOR) {
    if (feedbackV > 0 && feedbackV < 110) feedbackV = 1;
    else if (encima(60, 400, 230, 54)) responderV(0);
    else if (encima(510, 400, 230, 54)) responderV(1);
  } else if (scene == ESC_CAZABOTS) clickCazaBots();
  else if (scene == ESC_MEMORIA) clickMemoria();
  else if (scene == ESC_TELROTO) clickTelefonoRoto();
  else if (scene == ESC_PENALES) accionPenales();
  else if (scene == ESC_FOTO) clickFotoTrucada();
  else if (scene == ESC_SALTO) pidioSalto = true;
}

void teclaJuego() {
  boolean enter = key == ENTER || key == RETURN || key == ' ';
  if (esJuegoCamara(scene) && estadoJuego == 0 && (key == 'c' || key == 'C')) {
    calibrarPiel();   // aprende el color de tu palma (Camara.pde)
    return;
  }
  if (estadoJuego == 0 && enter) {
    empezarJuego();
    return;
  }
  if (estadoJuego == 3 && enter) {
    empezarJuego();
    return;
  }
  boolean izq = key == 'a' || key == 'A' || (key == CODED && keyCode == LEFT);
  boolean der = key == 'd' || key == 'D' || (key == CODED && keyCode == RIGHT);
  if (scene == ESC_VERIFICADOR && estadoJuego == 2) {
    if (feedbackV > 0 && feedbackV < 110 && enter) feedbackV = 1;
    else if (izq) responderV(0);
    else if (der) responderV(1);
  }
  if (scene == ESC_ATRAPA) {
    if (izq) moverIzquierda = true;
    if (der) moverDerecha = true;
  }
  if (scene == ESC_TELROTO && estadoJuego == 2 && key >= '1' && key <= '4') pulsarTR(key - '1');
  if (scene == ESC_PENALES && estadoJuego == 2 && key == ' ') accionPenales();
  if (scene == ESC_TECLADO) teclaTeclado();
  if (scene == ESC_SALTO && estadoJuego == 2 && (key == ' ' || key == 'w' || key == 'W' || (key == CODED && keyCode == UP))) pidioSalto = true;
}

// ------------------------------------- 41 VERIFICADOR EXPRESS -------------------------------------
// titular, quien lo publica, V (real) o F (falso), por que
String[][] titulares = {
  {"URGENTE: el candidato Ramirez quiere cerrar el colegio para vender el lote", "@NovaVerdad24  -  cuenta creada ayer", "F", "Pagina sin autor, creada ayer y sin ninguna fuente oficial."},
  {"La Alcaldia publica el calendario oficial de votacion en su sitio web", "alcaldia.nova.gov  -  cuenta verificada", "V", "Viene del sitio oficial y coincide con otros medios."},
  {"Foto de Dani prueba que escondia planos secretos en su casillero", "@chismenova  -  reenviado 1.000 veces", "F", "Era una maqueta de geografia. Y la foto se tomo sin permiso."},
  {"El torneo de microfutbol del barrio sera este sabado en el parque", "Junta Vecinal Nova  -  publicacion con fotos", "V", "Lo confirma la Junta con nombre, fecha y lugar."},
  {"Video muestra a Clemencia comprando votos (sin fecha ni lugar)", "@ladenuncia  -  video de 9 segundos", "F", "Fragmento cortado, sin contexto ni fuente: señal de manipulacion."},
  {"Construiran una urbanizacion que tumbara el Parque Central", "cuenta sin foto ni nombre real", "F", "No existe ningun permiso publicado. Solo un rumor de primos y amigas."},
  {"El Cafe 404 abre hasta tarde durante la semana de elecciones", "Cafe 404  -  cuenta del negocio desde 2018", "V", "Cuenta antigua, del propio negocio, sin nada exagerado."},
  {"Compartelo antes de que lo borren! El agua del parque esta envenenada", "cadena de WhatsApp  -  autor desconocido", "F", "'Compartelo antes de que lo borren' es una tecnica clasica de bulo."},
  {"La Registraduria confirma 3 mesas de votacion nuevas en el colegio", "Registraduria Nova  -  comunicado oficial", "V", "Comunicado oficial con fecha y firma."},
  {"Patroclo pago a 500 influencers para hacer tendencia la foto de Dani", "'me lo dijo un amigo'  -  sin pruebas", "F", "Acusacion sin pruebas. NOVA mostro que el rumor crecio solo."},
  {"El debate de candidatos se transmite el jueves en Nova Noticias", "Nova Noticias  -  medio con redaccion conocida", "V", "Medio identificable con redaccion y fecha clara."},
  {"Cientificos dicen que mirar el celular 5 minutos borra la memoria", "@datocurioso_xD  -  imagen con letras rojas", "F", "Titular exagerado, sin estudio ni cientificos con nombre."},
  {"La Biblioteca de Nova lanza un taller gratuito para detectar noticias falsas", "Biblioteca Publica Nova  -  pagina oficial", "V", "Institucion real con inscripcion y horario."},
  {"Gonzalo Gonzales prohibira los carros en toda la ciudad", "meme editado  -  sin fuente", "F", "Su propuesta real es una ciclorruta, no prohibir carros."},
  {"Cierran la calle principal el domingo por la jornada electoral", "Transito Nova  -  cuenta verificada", "V", "Aviso oficial y logico para el dia de elecciones."},
  {"Encuesta secreta: un candidato ya gano con 99% de los votos", "@encuestas_reales_100  -  creada hoy", "F", "Nadie gana con 99%. Cuenta nueva y numero imposible."}
};

int[] ordenV = new int[10];
int indiceV = 0;
float tiempoCartaV = 7;
float cartaX = 0, cartaVX = 0, cartaRot = 0;
float feedbackV = 0;
boolean aciertoV = false;
int respuestaV = -1;
int comboV = 0, aciertosV = 0;

void resetVerificador() {
  IntList l = new IntList();
  for (int i = 0; i < titulares.length; i++) l.append(i);
  l.shuffle();
  for (int i = 0; i < 10; i++) ordenV[i] = l.get(i);
  indiceV = 0;
  tiempoCartaV = 7;
  cartaX = 0;
  cartaVX = 0;
  cartaRot = 0;
  feedbackV = 0;
  comboV = 0;
  aciertosV = 0;
}

void responderV(int r) {
  if (feedbackV > 0 || estadoJuego != 2) return;
  respuestaV = r;
  boolean real = titulares[ordenV[indiceV]][2].equals("V");
  aciertoV = (r == 1 && real) || (r == 0 && !real);
  if (aciertoV) {
    comboV++;
    aciertosV++;
    int pts = 100 + comboV * 15 + int(tiempoCartaV * 10);
    puntaje += pts;
    flotar("+" + pts, 680, 80, neonVerde);
    chispas(width / 2, 225, neonVerde, 30);
  } else {
    comboV = 0;
    sacudida = 10;
    colorDestello = neonRojo;
    destello = 80;
  }
  cartaVX = r == 1 ? 22 : r == 0 ? -22 : 0;
  feedbackV = 130;
}

void dibujarVerificador() {
  fondoArcade(coloresJuegos[0]);
  cabeceraJuego(0);
  if (estadoJuego == 0) {
    pantallaInstrucciones(0);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(0);
    return;
  }
  avanzarCuenta();
  if (jugandoAhora()) {
    if (feedbackV > 0) {
      feedbackV--;
      if (feedbackV < 100) {
        cartaX += cartaVX;
        cartaRot += cartaVX * 0.002;
      }
      if (feedbackV <= 0) {
        indiceV++;
        if (indiceV >= 10) {
          terminarJuego();
          return;
        }
        cartaX = 0;
        cartaVX = 0;
        cartaRot = 0;
        tiempoCartaV = max(4, 7 - indiceV * 0.3);
      }
    } else {
      tiempoCartaV -= 1 / 60.0;
      if (tiempoCartaV <= 0) responderV(-1);
    }
  }
  String[] t = titulares[ordenV[min(indiceV, 9)]];
  pushMatrix();
  translate(width / 2 + cartaX, 215);
  rotate(cartaRot);
  noStroke();
  fill(0, 100);
  rect(-226, -92, 460, 200, 16);
  fill(22, 20, 40);
  stroke(coloresJuegos[0], 150);
  strokeWeight(2);
  rect(-230, -100, 460, 200, 16);
  noStroke();
  fill(neonMorado);
  ellipse(-200, -70, 32, 32);
  fill(255);
  textFont(fuenteUI);
  textSize(13);
  textAlign(LEFT, CENTER);
  text(t[1], -176, -70);
  textSize(19);
  textAlign(LEFT, TOP);
  text(t[0], -208, -42, 416, 100);
  fill(140);
  textSize(11);
  text("Conecta   -   ♥ " + int(hsh(ordenV[indiceV % 10]) * 9000 + 100), -208, 74);
  if (feedbackV > 0) {
    boolean real = t[2].equals("V");
    color sc = real ? neonVerde : neonRojo;
    pushMatrix();
    translate(140, -50);
    rotate(-0.25);
    stroke(sc);
    strokeWeight(3);
    noFill();
    rect(-62, -20, 124, 40, 6);
    noStroke();
    fill(sc);
    textSize(24);
    textAlign(CENTER, CENTER);
    text(real ? "REAL" : "FALSO", 0, -2);
    popMatrix();
  }
  popMatrix();
  // tiempo de la carta
  if (feedbackV <= 0) {
    float f = tiempoCartaV / max(4, 7 - indiceV * 0.3);
    fill(40, 36, 60);
    rect(170, 324, 460, 8, 4);
    fill(lerpColor(neonRojo, coloresJuegos[0], f));
    rect(170, 324, 460 * f, 8, 4);
  }
  botonNeon("<  FALSO  (A)", 60, 400, 230, 54, neonRojo, false);
  botonNeon("REAL  (D)  >", 510, 400, 230, 54, neonVerde, false);
  textFont(fuenteUI);
  textAlign(CENTER, CENTER);
  textSize(16);
  fill(255);
  text((min(indiceV, 9) + 1) + " / 10", width / 2, 418);
  if (comboV > 1) {
    fill(neonAmarillo);
    textSize(13);
    text("COMBO x" + comboV, width / 2, 440);
  }
  if (feedbackV > 0) {
    tituloNeon(aciertoV ? "BIEN!" : (respuestaV == -1 ? "TIEMPO!" : "ERROR!"), width / 2, 96, 30, aciertoV ? neonVerde : neonRojo);
    noStroke();
    fill(10, 8, 26, 230);
    rect(150, 340, 500, 50, 10);
    fill(230);
    textFont(fuenteUI);
    textSize(13);
    textAlign(CENTER, CENTER);
    text(t[3], 165, 340, 470, 50);
  }
  if (estadoJuego == 1) pantallaCuenta();
}

// ------------------------------------- 42 ATRAPA BULOS -------------------------------------
class Cayendo {
  float cx, cy, vy, w, fase;
  int tipo;    // 0 verificado, 1 bulo, 2 dorado
  String t;
}

ArrayList<Cayendo> cayendo = new ArrayList<Cayendo>();
float filtroX = 400;
int vidasA = 3;
float tiempoA = 45;
float spawnA = 30;
String[] textosBuenos = {"Fuente oficial", "Dato verificado", "Comunicado", "Con pruebas", "Medio con firma", "Contexto completo"};
String[] textosBulos = {"Compartelo YA!", "Video sin contexto", "Cuenta de ayer", "99% de votos", "Me dijo un primo", "Cadena urgente"};

void resetAtrapa() {
  cayendo.clear();
  filtroX = width / 2;
  vidasA = 3;
  tiempoA = 45;
  spawnA = 30;
}

void dibujarAtrapa() {
  fondoArcade(coloresJuegos[1]);
  cabeceraJuego(1);
  if (estadoJuego == 0) {
    pantallaInstrucciones(1);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(1);
    return;
  }
  avanzarCuenta();
  textFont(fuenteUI);
  textSize(13);
  if (jugandoAhora()) {
    tiempoA -= 1 / 60.0;
    float dific = 1 + (45 - tiempoA) / 22.0;
    if (moverIzquierda) filtroX -= 8;
    if (moverDerecha) filtroX += 8;
    if (mouseX != pmouseX) filtroX = lerp(filtroX, mouseX, 0.35);
    filtroX = constrain(filtroX, 60, width - 60);
    spawnA--;
    if (spawnA <= 0) {
      Cayendo c = new Cayendo();
      float r = random(1);
      c.tipo = r < 0.1 ? 2 : r < 0.55 ? 1 : 0;
      c.t = c.tipo == 2 ? "NOVA confirma" : c.tipo == 1 ? textosBulos[int(random(textosBulos.length))] : textosBuenos[int(random(textosBuenos.length))];
      c.w = textWidth(c.t) + 44;
      c.cx = random(80, width - 80);
      c.cy = 70;
      c.vy = random(1.6, 2.6);
      c.fase = random(TWO_PI);
      cayendo.add(c);
      spawnA = random(28, 50) / dific;
    }
    for (int i = cayendo.size() - 1; i >= 0; i--) {
      Cayendo c = cayendo.get(i);
      c.cy += c.vy * dific;
      c.fase += 0.05;
      if (c.cy > 420 && c.cy < 456 && abs(c.cx - filtroX) < c.w / 2 + 50) {
        if (c.tipo == 1) {
          vidasA--;
          sacudida = 12;
          colorDestello = neonRojo;
          destello = 100;
          chispas(c.cx, c.cy, neonRojo, 30);
          flotar("BULO!", c.cx, c.cy - 30, neonRojo);
        } else {
          int pts = c.tipo == 2 ? 30 : 10;
          puntaje += pts;
          chispas(c.cx, c.cy, c.tipo == 2 ? neonAmarillo : neonVerde, 20);
          flotar("+" + pts, c.cx, c.cy - 30, c.tipo == 2 ? neonAmarillo : neonVerde);
        }
        cayendo.remove(i);
      } else if (c.cy > height + 30) {
        cayendo.remove(i);
      }
    }
    if (tiempoA <= 0 || vidasA <= 0) {
      terminarJuego();
      return;
    }
  }
  for (Cayendo c : cayendo) {
    color col = c.tipo == 0 ? neonVerde : c.tipo == 1 ? neonRojo : neonAmarillo;
    float bx = c.cx + sin(c.fase) * 4;
    noStroke();
    fill(col, 40);
    rect(bx - c.w / 2 - 5, c.cy - 20, c.w + 10, 40, 20);
    fill(20, 16, 36);
    stroke(col);
    strokeWeight(2);
    rect(bx - c.w / 2, c.cy - 15, c.w, 30, 15);
    noStroke();
    fill(col);
    ellipse(bx - c.w / 2 + 16, c.cy, 18, 18);
    fill(20);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(c.tipo == 1 ? "!" : c.tipo == 2 ? "*" : "v", bx - c.w / 2 + 16, c.cy - 1);
    fill(255);
    textSize(13);
    textAlign(LEFT, CENTER);
    text(c.t, bx - c.w / 2 + 30, c.cy - 1);
  }
  // el filtro
  noStroke();
  fill(neonCian, 40);
  quad(filtroX - 70, 418, filtroX + 70, 418, filtroX + 30, 462, filtroX - 30, 462);
  fill(15, 30, 50);
  stroke(neonCian);
  strokeWeight(2.5);
  quad(filtroX - 62, 424, filtroX + 62, 424, filtroX + 26, 458, filtroX - 26, 458);
  noStroke();
  fill(neonCian);
  textAlign(CENTER, CENTER);
  textSize(11);
  text("FILTRO", filtroX, 438);
  // vidas y tiempo
  for (int i = 0; i < 3; i++) {
    fill(i < vidasA ? neonRosa : color(60, 50, 80));
    float hx = 30 + i * 28, hy = 80;
    ellipse(hx - 5, hy, 12, 12);
    ellipse(hx + 5, hy, 12, 12);
    triangle(hx - 11, hy + 2, hx + 11, hy + 2, hx, hy + 14);
  }
  fill(40, 36, 60);
  rect(130, 76, 540, 8, 4);
  fill(coloresJuegos[1]);
  rect(130, 76, 540 * max(0, tiempoA) / 45.0, 8, 4);
  fill(255);
  textAlign(RIGHT, CENTER);
  textSize(12);
  text(int(max(0, tiempoA)) + " s", 770, 80);
  if (estadoJuego == 1) pantallaCuenta();
}

// ------------------------------------- 43 CAZA BOTS -------------------------------------
class Ranura {
  int tipo = -1;   // -1 vacia, 0 bot, 1 persona
  float vida, vidaMax, anim, golpe;
  String nombre, extra;
  boolean acertado;
  color c;
}

Ranura[] ranuras = new Ranura[9];
float tiempoCB = 35;
int botsCB = 0;
float spawnCB = 20;
String[] nombresReales = {"Valentina R.", "Don Lucho", "Profe Ines", "Camila_07", "Andres M.", "Sofia", "Doña Marta", "Julian P.", "Abuela Rosa"};
String[] extrasReales = {"Desde 2016 - 420 seguidores", "Desde 2019 - 88 seguidores", "Desde 2014 - 1.203 seguidores", "Desde 2020 - 310 seguidores"};
String[] nombresBot = {"user", "NovaVerdad", "patriota_", "noticias_ya", "real_info"};

void resetCazaBots() {
  for (int i = 0; i < ranuras.length; i++) ranuras[i] = new Ranura();
  tiempoCB = 35;
  botsCB = 0;
  spawnCB = 20;
}

float[] posRanura(int i) {
  return new float[] {125 + (i % 3) * 190, 90 + (i / 3) * 125, 170, 105};
}

void dibujarCazaBots() {
  fondoArcade(coloresJuegos[2]);
  cabeceraJuego(2);
  if (estadoJuego == 0) {
    pantallaInstrucciones(2);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(2);
    return;
  }
  avanzarCuenta();
  if (jugandoAhora()) {
    tiempoCB -= 1 / 60.0;
    float dific = 1 + (35 - tiempoCB) / 20.0;
    spawnCB--;
    if (spawnCB <= 0) {
      int inicio = int(random(9));
      for (int k = 0; k < 9; k++) {
        Ranura r = ranuras[(inicio + k) % 9];
        if (r.tipo == -1) {
          r.tipo = random(1) < 0.62 ? 0 : 1;
          r.vidaMax = random(60, 110) / dific;
          r.vida = r.vidaMax;
          r.anim = 0;
          r.golpe = 0;
          if (r.tipo == 0) {
            r.nombre = nombresBot[int(random(nombresBot.length))] + int(random(100, 99999));
            r.extra = "Creada hoy - 0 seguidores - 400 posts/dia";
          } else {
            r.nombre = nombresReales[int(random(nombresReales.length))];
            r.extra = extrasReales[int(random(extrasReales.length))];
            r.c = paletaRopa[int(random(paletaRopa.length))];
          }
          break;
        }
      }
      spawnCB = random(18, 35) / dific;
    }
    for (Ranura r : ranuras) {
      if (r.tipo < 0) continue;
      if (r.golpe > 0) {
        r.golpe--;
        if (r.golpe <= 0) r.tipo = -1;
      } else {
        r.vida--;
        r.anim = min(1, r.anim + 0.15);
        if (r.vida <= 0) r.tipo = -1;
      }
    }
    if (tiempoCB <= 0) {
      terminarJuego();
      return;
    }
  }
  for (int i = 0; i < 9; i++) {
    float[] p = posRanura(i);
    noStroke();
    fill(14, 10, 32, 220);
    rect(p[0], p[1], p[2], p[3], 12);
    stroke(coloresJuegos[2], 70);
    strokeWeight(1);
    noFill();
    rect(p[0], p[1], p[2], p[3], 12);
    noStroke();
    Ranura r = ranuras[i];
    if (r.tipo < 0) continue;
    float esc = r.golpe > 0 ? 1 : min(r.anim, constrain(r.vida / 10.0, 0, 1));
    pushMatrix();
    translate(p[0] + p[2] / 2, p[1] + p[3] / 2);
    scale(max(0.01, esc));
    fill(r.golpe > 0 ? (r.acertado ? color(30, 80, 50) : color(90, 30, 40)) : color(30, 26, 52));
    rect(-80, -48, 160, 96, 10);
    if (r.tipo == 0) {
      fill(140, 150, 170);
      ellipse(-48, -6, 46, 46);
      fill(15, 20, 35);
      rect(-62, -18, 28, 18, 4);
      fill(neonRojo);
      rect(-58, -13, 7, 7);
      rect(-45, -13, 7, 7);
      stroke(140, 150, 170);
      strokeWeight(2);
      line(-48, -29, -48, -38);
      noStroke();
      fill(neonRojo);
      ellipse(-48, -40, 6, 6);
    } else {
      fill(r.c);
      ellipse(-48, -6, 46, 46);
      fill(tonosPiel[i % tonosPiel.length]);
      ellipse(-48, -10, 26, 26);
      fill(30);
      ellipse(-53, -11, 3, 4);
      ellipse(-43, -11, 3, 4);
      noFill();
      stroke(30);
      strokeWeight(1.5);
      arc(-48, -6, 10, 7, 0, PI);
      noStroke();
    }
    fill(255);
    textFont(fuenteUI);
    textAlign(LEFT, TOP);
    textSize(12);
    text(r.nombre, -18, -36);
    fill(170);
    textSize(9);
    text(r.extra, -18, -16, 92, 40);
    if (r.golpe > 0) {
      fill(r.acertado ? neonVerde : neonRojo);
      textSize(15);
      textAlign(CENTER, CENTER);
      text(r.acertado ? "BOT ELIMINADO" : "ERA REAL!", 0, 32);
    } else {
      fill(40, 36, 60);
      rect(-70, 38, 140, 4, 2);
      fill(coloresJuegos[2]);
      rect(-70, 38, 140 * r.vida / r.vidaMax, 4, 2);
    }
    popMatrix();
  }
  fill(40, 36, 60);
  rect(130, 470, 540, 8, 4);
  fill(coloresJuegos[2]);
  rect(130, 470, 540 * max(0, tiempoCB) / 35.0, 8, 4);
  textFont(fuenteUI);
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(13);
  text("Bots: " + botsCB, 30, 474);
  textAlign(RIGHT, CENTER);
  text(int(max(0, tiempoCB)) + " s", 770, 474);
  // mira
  noFill();
  stroke(neonRosa);
  strokeWeight(2);
  ellipse(mouseX, mouseY, 30, 30);
  line(mouseX - 22, mouseY, mouseX - 8, mouseY);
  line(mouseX + 8, mouseY, mouseX + 22, mouseY);
  line(mouseX, mouseY - 22, mouseX, mouseY - 8);
  line(mouseX, mouseY + 8, mouseX, mouseY + 22);
  noStroke();
  if (estadoJuego == 1) pantallaCuenta();
}

void clickCazaBots() {
  for (int i = 0; i < 9; i++) {
    Ranura r = ranuras[i];
    float[] p = posRanura(i);
    if (r.tipo >= 0 && r.golpe == 0 && encima(p[0], p[1], p[2], p[3])) {
      r.golpe = 22;
      r.acertado = r.tipo == 0;
      if (r.acertado) {
        botsCB++;
        puntaje += 1;
        chispas(mouseX, mouseY, neonVerde, 25);
      } else {
        puntaje = max(0, puntaje - 1);
        tiempoCB -= 2;
        sacudida = 10;
        colorDestello = neonRojo;
        destello = 90;
        flotar("-2 s", mouseX, mouseY - 20, neonRojo);
      }
      return;
    }
  }
}

// ------------------------------------- 44 RASTREO DE FUENTES -------------------------------------
String[][] paresMemoria = {
  {"Foto de Dani en el recreo", "Era su maqueta de geografia"},
  {"Planos de una urbanizacion", "Cuenta sin nombre ni foto"},
  {"Ramirez cierra el colegio", "Pagina creada ayer"},
  {"Video de Clemencia", "Fragmento editado de 9 s"},
  {"Patroclo pago la tendencia", "'Me lo dijo un amigo'"},
  {"Cancelen el torneo!", "Cadena de reenvios"}
};

class CartaM {
  int par;
  boolean rumor, arriba, hecha;
  float giro = 0;
}

CartaM[] cartasM = new CartaM[12];
int primeraM = -1, segundaM = -1, movimientosM = 0, paresM = 0;
float esperaM = 0, tiempoM = 0;

void resetMemoria() {
  IntList l = new IntList();
  for (int i = 0; i < 12; i++) l.append(i);
  l.shuffle();
  for (int i = 0; i < 12; i++) {
    cartasM[i] = new CartaM();
    cartasM[i].par = l.get(i) / 2;
    cartasM[i].rumor = l.get(i) % 2 == 0;
  }
  primeraM = -1;
  segundaM = -1;
  esperaM = 0;
  movimientosM = 0;
  paresM = 0;
  tiempoM = 0;
}

float[] posCarta(int i) {
  return new float[] {56 + (i % 4) * 176, 86 + (i / 4) * 116, 160, 100};
}

void dibujarMemoria() {
  fondoArcade(coloresJuegos[3]);
  cabeceraJuego(3);
  if (estadoJuego == 0) {
    pantallaInstrucciones(3);
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(3);
    return;
  }
  avanzarCuenta();
  if (jugandoAhora()) {
    tiempoM += 1 / 60.0;
    if (esperaM > 0) {
      esperaM--;
      if (esperaM <= 0) {
        CartaM a = cartasM[primeraM], b = cartasM[segundaM];
        if (a.par == b.par && a.rumor != b.rumor) {
          a.hecha = true;
          b.hecha = true;
          paresM++;
          float[] p = posCarta(segundaM);
          chispas(p[0] + 80, p[1] + 50, neonVerde, 30);
          flotar("Origen encontrado!", p[0] + 80, p[1] + 20, neonVerde);
          if (paresM == 6) {
            puntaje = max(100, 1000 - movimientosM * 25 - int(tiempoM) * 4);
            terminarJuego();
          }
        } else {
          a.arriba = false;
          b.arriba = false;
        }
        primeraM = -1;
        segundaM = -1;
      }
    }
  }
  for (int i = 0; i < 12; i++) {
    CartaM c = cartasM[i];
    if (c == null) continue;
    float[] p = posCarta(i);
    c.giro = lerp(c.giro, (c.arriba || c.hecha) ? 1 : 0, 0.2);
    float sx = abs(cos(c.giro * PI));
    boolean frente = c.giro > 0.5;
    boolean s = encima(p[0], p[1], p[2], p[3]) && !c.arriba && !c.hecha;
    pushMatrix();
    translate(p[0] + p[2] / 2, p[1] + p[3] / 2 - (s ? 4 : 0));
    scale(max(0.02, sx), 1);
    noStroke();
    if (!frente) {
      fill(30, 24, 60);
      rect(-80, -50, 160, 100, 12);
      stroke(coloresJuegos[3], s ? 255 : 120);
      strokeWeight(2);
      noFill();
      rect(-74, -44, 148, 88, 9);
      noStroke();
      fill(coloresJuegos[3], 160);
      textFont(fuente);
      textSize(30);
      textAlign(CENTER, CENTER);
      text("?", 0, -4);
    } else {
      color col = c.rumor ? neonRosa : neonCian;
      fill(red(col) * 0.2, green(col) * 0.2, blue(col) * 0.2);
      rect(-80, -50, 160, 100, 12);
      stroke(c.hecha ? neonVerde : col);
      strokeWeight(c.hecha ? 3 : 2);
      noFill();
      rect(-80, -50, 160, 100, 12);
      noStroke();
      fill(col);
      textFont(fuenteUI);
      textSize(10);
      textAlign(CENTER, TOP);
      text(c.rumor ? "RUMOR" : "ORIGEN REAL", 0, -42);
      fill(255);
      textSize(13);
      textAlign(CENTER, CENTER);
      text(paresMemoria[c.par][c.rumor ? 0 : 1], -70, -26, 140, 70);
      if (c.hecha) {
        fill(neonVerde);
        ellipse(62, -34, 18, 18);
        stroke(20);
        strokeWeight(2);
        line(57, -34, 61, -30);
        line(61, -30, 67, -38);
        noStroke();
      }
    }
    popMatrix();
  }
  textFont(fuenteUI);
  textSize(13);
  fill(255);
  textAlign(LEFT, CENTER);
  text("Movimientos: " + movimientosM + "     Pares: " + paresM + " / 6", 56, 450);
  textAlign(RIGHT, CENTER);
  text(int(tiempoM) + " s", 744, 450);
  if (estadoJuego == 1) pantallaCuenta();
}

void clickMemoria() {
  if (esperaM > 0) return;
  for (int i = 0; i < 12; i++) {
    float[] p = posCarta(i);
    CartaM c = cartasM[i];
    if (!c.arriba && !c.hecha && encima(p[0], p[1], p[2], p[3])) {
      c.arriba = true;
      if (primeraM == -1) {
        primeraM = i;
      } else {
        segundaM = i;
        movimientosM++;
        CartaM a = cartasM[primeraM];
        esperaM = (a.par == c.par) ? 22 : 55;
      }
      return;
    }
  }
}
