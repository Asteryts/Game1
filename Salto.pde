// =====================================================================================
//  SALTO.pde -> minijuego 66 "Salto con la Mano" (usa la camara de Camara.pde)
//  Corres por los techos de Nova. Levanta la mano por encima de la linea para SALTAR las pilas
//  de bulos y agarrar los datos verificados que flotan. Sin camara: ESPACIO, W, flecha o clic.
// =====================================================================================

class ObstaculoS {
  float ox, oy, w, h;
  int tipo;          // 0 pila de bulos (salta), 1 dato verificado (agarralo), 2 bulo volador (no lo toques)
  boolean tomado = false;
}

ArrayList<ObstaculoS> obstaculosS = new ArrayList<ObstaculoS>();
final float SUELO_S = 400;              // donde pisa el corredor
final float LINEA_SALTO = 0.42;         // la mano tiene que subir por encima de este % de la camara
float corredorY = SUELO_S, corredorVY = 0, velocidadS = 6, distanciaS = 0, spawnS = 60, tiempoS = 60, invencibleS = 0;
int vidasS = 3, datosS = 0, saltosS = 0;
boolean pidioSalto = false, manoArribaAntes = false;
float desplazaFondoS = 0;

void resetSalto() {
  obstaculosS.clear();
  corredorY = SUELO_S;
  corredorVY = 0;
  velocidadS = 6;
  distanciaS = 0;
  spawnS = 60;
  tiempoS = 60;
  invencibleS = 0;
  vidasS = 3;
  datosS = 0;
  saltosS = 0;
  pidioSalto = false;
}

boolean enElSuelo() {
  return corredorY >= SUELO_S - 0.5;
}

void saltar() {
  if (enElSuelo()) {
    corredorVY = -13.5;
    saltosS++;
    for (int i = 0; i < 8; i++) agregarParticula(new Particula(180 + random(-10, 10), SUELO_S, random(-2, 2), random(-2, -0.5), 25, random(5, 9), color(200, 190, 220), 5));
  }
}

void dibujarSalto() {
  if (esperandoCamara(9)) return;
  leerMovimiento();
  boolean jugando = jugandoAhora();
  // ---- fondo: la ciudad del menu moviendose (pixel art) ----
  empezarFondoPixel();
  image(cieloMenu, 0, 0);
  float d = desplazaFondoS;
  float w0 = capaLejos.width - 160, w1 = capaMedia.width - 160, w2 = capaCerca.width - 160;
  image(capaLejos, -(d * 0.15 % w0), -40);
  image(capaLejos, -(d * 0.15 % w0) + w0, -40);
  image(capaMedia, -(d * 0.35 % w1), -30);
  image(capaMedia, -(d * 0.35 % w1) + w1, -30);
  image(capaCerca, -(d * 0.7 % w2), -40);
  image(capaCerca, -(d * 0.7 % w2) + w2, -40);
  // el techo por donde corres
  noStroke();
  fill(40, 30, 60);
  rect(0, SUELO_S + 10, width, height);
  fill(70, 56, 96);
  rect(0, SUELO_S + 4, width, 10);
  for (float xx = -(d % 60); xx < width; xx += 60) {
    fill(55, 44, 78);
    rect(xx, SUELO_S + 20, 30, 6);
    fill(neonCian, 120);
    rect(xx + 40, SUELO_S + 6, 6, 4);
  }
  // obstaculos
  for (ObstaculoS o : obstaculosS) {
    if (o.tomado) continue;
    if (o.tipo == 0) {
      for (int k = 0; k < o.h / 18; k++) {
        fill(k % 2 == 0 ? color(200, 50, 70) : color(240, 80, 100));
        rect(o.ox + (k % 2) * 3, SUELO_S - 18 - k * 18 + 10, o.w, 17, 3);
        fill(255);
        rect(o.ox + 8 + (k % 2) * 3, SUELO_S - 12 - k * 18 + 10, o.w - 16, 3);
      }
      fill(neonAmarillo);
      ellipse(o.ox + o.w / 2, SUELO_S - o.h - 2, 18, 18);
      fill(30);
      textFont(fuenteUI);
      textSize(12);
      textAlign(CENTER, CENTER);
      text("!", o.ox + o.w / 2, SUELO_S - o.h - 3);
    } else if (o.tipo == 1) {
      float b = sin(frameCount * 0.15 + o.ox) * 4;
      fill(neonVerde, 60);
      ellipse(o.ox, o.oy + b, 40, 40);
      fill(neonVerde);
      ellipse(o.ox, o.oy + b, 24, 24);
      fill(20);
      textFont(fuenteUI);
      textSize(13);
      textAlign(CENTER, CENTER);
      text("v", o.ox, o.oy + b - 1);
    } else {
      float b = sin(frameCount * 0.2 + o.ox) * 5;
      fill(60);
      rect(o.ox - 16, o.oy - 4 + b, 32, 8, 4);
      fill(neonRojo);
      ellipse(o.ox, o.oy + b, 10, 10);
      fill(200, 200, 220, 120);
      ellipse(o.ox - 18, o.oy - 7 + b, 18, 4);
      ellipse(o.ox + 18, o.oy - 7 + b, 18, 4);
    }
  }
  terminarFondoPixel();
  // ---- el corredor (tu sprite de siempre) ----
  boolean parpadea = invencibleS > 0 && frameCount % 8 < 4;
  if (!parpadea) {
    noStroke();
    fill(0, 90);
    ellipse(180, SUELO_S + 6, 50 - (SUELO_S - corredorY) * 0.1, 10);
    float rebote = enElSuelo() ? abs(sin(distanciaS * 0.08)) * 3 : 0;
    image(derecha, 130, corredorY - altoPersonaje - rebote, anchoPersonaje, altoPersonaje);
  }
  cabeceraJuego(9);
  textFont(fuenteUI);
  textSize(11);
  fill(modoMouse ? neonAmarillo : neonVerde);
  textAlign(LEFT, CENTER);
  text(msjCamara, 14, height - 12);
  // ---- la camara en una esquina, con la linea para saltar ----
  float vx = width - 250, vy = 88, vw = 236, vh = 148;
  if (!modoMouse && vistaCam != null) {
    fill(10, 8, 26, 220);
    rect(vx - 4, vy - 4, vw + 8, vh + 8, 8);
    image(vistaCam, vx, vy, vw, vh);
    float ly = vy + vh * LINEA_SALTO;
    stroke(neonAmarillo);
    strokeWeight(2);
    line(vx, ly, vx + vw, ly);
    noStroke();
    if (manoDetectada) {
      fill(neonCian);
      ellipse(vx + manoX / width * vw, vy + manoY / height * vh, 10, 10);
    }
    textSize(10);
    fill(neonAmarillo);
    textAlign(LEFT, BOTTOM);
    text("sube la mano aqui", vx + 4, ly - 2);
  }
  if (estadoJuego == 0) {
    if (modoMouse) pantallaInstrucciones(9);
    else {
      noStroke();
      fill(10, 8, 26, 215);
      rect(40, 80, 440, 230, 14);
      tituloNeon(nombresJuegos[9], 260, 110, 26, coloresJuegos[9]);
      textFont(fuenteUI);
      textSize(13);
      fill(230);
      textAlign(LEFT, TOP);
      text(instruccionesJuegos[9], 60, 135, 400, 120);
      fill(pielCalibrada ? neonVerde : neonAmarillo);
      text(pielCalibrada ? "Piel calibrada (C para repetir)" : "Para calibrar: pon la palma en el centro de la camara y presiona C", 60, 262, 400, 40);
      if (frameCount % 50 < 35) {
        fill(coloresJuegos[9]);
        textSize(15);
        textAlign(CENTER, CENTER);
        text("ENTER o clic para empezar", 260, 340);
      }
    }
    return;
  }
  if (estadoJuego == 3) {
    pantallaResultados(9);
    return;
  }
  avanzarCuenta();
  if (jugando) {
    // ¿saltar? camara: la mano subio por encima de la linea. Sin camara: tecla o clic
    boolean manoArriba = !modoMouse && manoDetectada && manoY < height * LINEA_SALTO;
    if ((manoArriba && !manoArribaAntes) || (manoArriba && enElSuelo()) || pidioSalto) saltar();
    manoArribaAntes = manoArriba;
    pidioSalto = false;
    corredorVY += 0.62;
    corredorY += corredorVY;
    if (corredorY > SUELO_S) {
      corredorY = SUELO_S;
      corredorVY = 0;
    }
    tiempoS -= 1 / 60.0;
    velocidadS = min(13, 6 + (60 - tiempoS) * 0.12);
    distanciaS += velocidadS;
    desplazaFondoS += velocidadS;
    puntaje = int(distanciaS / 20) + datosS * 25;
    if (invencibleS > 0) invencibleS--;
    spawnS -= velocidadS;
    if (spawnS <= 0) {
      ObstaculoS o = new ObstaculoS();
      float r = random(1);
      o.tipo = r < 0.62 ? 0 : r < 0.86 ? 1 : 2;
      o.ox = width + 40;
      if (o.tipo == 0) {
        o.w = random(36, 52);
        o.h = 18 * int(random(2, 4));
      } else if (o.tipo == 1) {
        o.oy = random(250, 320);
        o.w = 24;
        o.h = 24;
      } else {
        o.oy = random(270, 300);
        o.w = 36;
        o.h = 14;
      }
      obstaculosS.add(o);
      spawnS = random(280, 460);
    }
    // choques (el corredor ocupa mas o menos x 160-200)
    float cx0 = 160, cx1 = 200, cy0 = corredorY - 44, cy1 = corredorY;
    for (int i = obstaculosS.size() - 1; i >= 0; i--) {
      ObstaculoS o = obstaculosS.get(i);
      o.ox -= velocidadS;
      if (o.ox < -80) {
        obstaculosS.remove(i);
        continue;
      }
      if (o.tomado) continue;
      boolean toca;
      if (o.tipo == 0) toca = cx1 > o.ox + 4 && cx0 < o.ox + o.w - 4 && cy1 > SUELO_S - o.h + 6;
      else toca = dist(180, corredorY - 22, o.ox, o.oy) < 30;
      if (!toca) continue;
      if (o.tipo == 1) {
        o.tomado = true;
        datosS++;
        chispas(o.ox, o.oy, neonVerde, 25);
        flotar("+25 dato verificado", o.ox, o.oy - 26, neonVerde);
      } else if (invencibleS <= 0) {
        vidasS--;
        invencibleS = 70;
        sacudida = 12;
        colorDestello = neonRojo;
        destello = 100;
        flotar(o.tipo == 0 ? "Te tropezaste con un bulo!" : "Te pico un bulo volador!", 180, corredorY - 70, neonRojo);
      }
    }
    if (tiempoS <= 0 || vidasS <= 0) {
      if (tiempoS <= 0 && vidasS > 0) desbloquear(18);
      terminarJuego();
      return;
    }
  }
  for (int i = 0; i < 3; i++) {
    fill(i < vidasS ? neonRosa : color(60, 50, 80));
    float hx = 30 + i * 28, hy = 80;
    ellipse(hx - 5, hy, 12, 12);
    ellipse(hx + 5, hy, 12, 12);
    triangle(hx - 11, hy + 2, hx + 11, hy + 2, hx, hy + 14);
  }
  fill(40, 36, 60);
  rect(130, 76, 380, 8, 4);
  fill(coloresJuegos[9]);
  rect(130, 76, 380 * max(0, tiempoS) / 60.0, 8, 4);
  fill(255);
  textFont(fuenteUI);
  textSize(12);
  textAlign(LEFT, CENTER);
  text(int(max(0, tiempoS)) + " s   -   datos: " + datosS, 130, 96);
  if (estadoJuego == 1) pantallaCuenta();
}
