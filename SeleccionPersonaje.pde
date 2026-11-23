final int ESC_ELEGIR_PERSONAJE = 82;
final int PERSONAJE_MASCULINO = 0, PERSONAJE_FEMENINO = 1;
final String[] nombresGenero = {"Masculino", "Femenino"};
final int ANCHO_TARJETA_PERSONAJE = 198, ALTO_TARJETA_PERSONAJE = 225;
final int Y_TARJETA_PERSONAJE = 128, Y_CONTINUAR_PERSONAJE = 393;
int generoPersonaje = PERSONAJE_MASCULINO;
int generoSeleccionado = PERSONAJE_MASCULINO;

void abrirSeleccionPersonaje() {
  generoSeleccionado = generoPersonaje;
  scene = ESC_ELEGIR_PERSONAJE;
}

void confirmarPersonaje() {
  crearPartidaEnSlot(generoSeleccionado);   // el personaje queda fijo en ese slot (Slots.pde)
}

float xTarjetaPersonaje(int genero) {
  return width / 2 - ANCHO_TARJETA_PERSONAJE - 16 + genero * (ANCHO_TARJETA_PERSONAJE + 32);
}

void dibujarSeleccionPersonaje() {
  dibujarFondoCiudad();
  noStroke();
  fill(10, 8, 25, 205);
  rect(0, 0, width, height);
  botonVolver();
  tituloNeon("ELIGE TU PERSONAJE", width / 2, 66, 34, neonCian);
  textFont(fuenteUI);
  textSize(13);
  textAlign(CENTER, CENTER);
  fill(neonAmarillo);
  text("Partida nueva en el slot " + (max(slotNuevo, 0) + 1) + "  -  no podras cambiar de personaje en esta partida", width / 2, 104);

  for (int i = 0; i < nombresGenero.length; i++) {
    float bx = xTarjetaPersonaje(i), cx = bx + ANCHO_TARJETA_PERSONAJE / 2;
    boolean seleccionado = i == generoSeleccionado;
    color acento = seleccionado ? neonAmarillo : #7277A7;
    panelNeon(bx, Y_TARJETA_PERSONAJE, ANCHO_TARJETA_PERSONAJE, ALTO_TARJETA_PERSONAJE, acento);
    noStroke();
    fill(37, 42, 69);
    ellipse(cx, Y_TARJETA_PERSONAJE + 99, 126, 126);
    fill(10, 9, 25, 130);
    ellipse(cx, Y_TARJETA_PERSONAJE + 159, 89, 14);
    int cuadro = seleccionado ? cuadroCaminataJugadorNova(relojSpriteNova, false) : 0;
    dibujarPoseJugadorNova(i, JUGADOR_ABAJO, cuadro, cx, Y_TARJETA_PERSONAJE + 158, 2.78);
    textFont(fuenteUI);
    textSize(20);
    textAlign(CENTER, CENTER);
    fill(seleccionado ? neonAmarillo : color(225));
    text(nombresGenero[i], cx, Y_TARJETA_PERSONAJE + 196);
  }
  botonNeon("Continuar", width / 2 - 114, Y_CONTINUAR_PERSONAJE, 228, 46, neonCian, true);
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  fill(185, 191, 216);
  text("Flechas o A / D para elegir  ·  ENTER para continuar", width / 2, 466);
}

void clickSeleccionPersonaje() {
  if (clickVolver()) {
    abrirSlots();
    return;
  }
  for (int i = 0; i < nombresGenero.length; i++) {
    if (encima(xTarjetaPersonaje(i), Y_TARJETA_PERSONAJE, ANCHO_TARJETA_PERSONAJE, ALTO_TARJETA_PERSONAJE)) {
      generoSeleccionado = i;
      return;
    }
  }
  if (encima(width / 2 - 114, Y_CONTINUAR_PERSONAJE, 228, 46)) confirmarPersonaje();
}

void teclaSeleccionPersonaje() {
  if ((key == CODED && keyCode == LEFT) || key == 'a' || key == 'A') generoSeleccionado = PERSONAJE_MASCULINO;
  else if ((key == CODED && keyCode == RIGHT) || key == 'd' || key == 'D') generoSeleccionado = PERSONAJE_FEMENINO;
  else if (key == ENTER || key == RETURN || key == ' ') {
    if (keyEvent == null || !keyEvent.isAutoRepeat()) confirmarPersonaje();
  }
}
