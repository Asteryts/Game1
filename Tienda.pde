// =====================================================================================
//  TIENDA.pde -> NovaCoins, la tienda de gadgets y la Ruleta Nova
//   - NovaCoins: se ganan en los minijuegos (segun tu puntaje) y con tus decisiones
//     (las buenas dan monedas, las malas te quitan). Se ven arriba en la pantalla.
//   - Tienda NOVA (escena 70): kioscos en el mapa, el Mercado, la Avenida y el Parque.
//     Desde el celular tambien se puede comprar online, pero con comision.
//   - Ruleta Nova (escena 71): apuesta tus monedas a Rojo / Negro (x2) o Verde (x14).
// =====================================================================================

final int ESC_TIENDA = 70;
final int ESC_RULETA = 71;
final float COMISION_ONLINE = 0.25;   // 25% extra por comprar desde el celular

int monedas = 30;               // empiezas con un poquito para curiosear la tienda
float monedasVista = 30;        // lo que muestra el contador (sube o baja poco a poco)
float pulsoMonedas = 0;         // el contador salta cuando cambia
int ultimoCambioMonedas = 0;
boolean sinMonedasPorCambio = false;   // true = el proximo cambio de estadisticas viene de un gadget, no de una decision

// monedas que vuelan hacia el contador: {x, y, tx, ty, t, retraso}
ArrayList<float[]> monedasVolando = new ArrayList<float[]>();

// ------------------------------------- GADGETS -------------------------------------
String[] nombresGadgets = {"Patines Neon", "Gafas Nocturnas", "Radar de Eventos", "Estela de Luz", "Chip x2", "Credencial de Prensa", "Megafono Vecinal", "Antena Anti-Rumor", "Seguro Anti-Bulo"};
String[] descGadgets = {
  "Caminas casi el doble de rapido por todo Nova. Ideal para llegar a la alcaldia sin perder tiempo.",
  "Ves la ciudad clarita aunque sea de noche. Adios a la pantalla oscura despues de las 7 pm.",
  "Detecta mas sorpresas en el mapa: aparecen mas seguido y caben hasta 5 a la vez.",
  "Dejas un rastro de chispas neon al caminar. No sirve para nada... pero se ve increible.",
  "Tus proximas 3 partidas de minijuegos dan el DOBLE de NovaCoins. Se gasta solo.",
  "Muestras tu credencial de verificador: +8 de Confiabilidad al instante.",
  "Organizas a los vecinos para hablar de los hechos: +8 de Impacto al instante.",
  "Apaga todos los rumores que se estan regando por el mapa. Adios cadenas falsas.",
  "La proxima decision mala no te quita NovaCoins. Se gasta solo cuando lo necesitas."
};
int[] preciosGadgets = {120, 90, 150, 60, 80, 110, 110, 70, 60};
boolean[] gadgetPermanente = {true, true, true, true, false, false, false, false, false};
color[] coloresGadgets = {#00F0FF, #3CFF96, #FFDC3C, #FF3CC8, #FF8C3C, #50B4FF, #9650FF, #FF465A, #46DC64};
int[] tengoGadget = new int[9];          // permanentes: 0/1. Consumibles: cuantos tienes
boolean[] gadgetEncendido = new boolean[9];   // los permanentes se pueden apagar y prender
int cargasX2 = 0;                        // partidas que quedan con monedas dobles

// ------------------------------------- ESTADO DE LA TIENDA -------------------------------------
boolean tiendaOnline = false;
int regresoTienda = 1;
int regresoRuleta = 1;
int gadgetElegido = 0;
String fraseTendero = "";
float letrasTendero = 0;
float dronT = -1;                 // animacion del dron que trae el paquete (compras online)
int dronGadget = 0;
float sacudidaPrecio = 0;         // el precio tiembla si no te alcanza
String[] saludosTienda = {
  "Bienvenid@ a la Tienda NOVA! Todo lo que necesitas para recorrer la ciudad con estilo.",
  "Hola de nuevo! Llegaron gadgets fresquitos. Bueno... los mismos, pero brillan mas.",
  "Psst... los Patines Neon son lo mas vendido de la semana. Pero yo no te dije nada."
};
String[] saludosOnline = {
  "Compra online desde tu celular: un dron te lo lleva donde estes. Eso si, cobra comision.",
  "NovaShop Online! Comodo, rapido... y un poquito mas caro. El dron no trabaja gratis."
};

// ------------------------------------- NOVACOINS -------------------------------------
void ganarMonedas(int n, float dx, float dy) {
  if (n == 0) return;
  monedas = max(0, monedas + n);
  pulsoMonedas = 1;
  ultimoCambioMonedas = n;
  float[] t = posContadorMonedas();
  if (n > 0) {
    for (int i = 0; i < min(14, 3 + n / 3); i++) monedasVolando.add(new float[] {dx + random(-20, 20), dy + random(-14, 14), t[0], t[1], 0, i * 3});
    flotar("+" + n + " NovaCoins", dx, dy - 20, neonAmarillo);
  } else {
    flotar(n + " NovaCoins", t[0] - 40, t[1] + 34, neonRojo);
  }
  guardarDatos();
}

// donde esta el contador en cada escena (para que las monedas vuelen hacia el)
float[] posContadorMonedas() {
  if (scene == 1) return new float[] {688, 30};
  if (scene == ESC_TIENDA || scene == ESC_RULETA) return new float[] {718, 34};
  if (scene == ESC_MINIJUEGOS) return new float[] {738, 30};
  if (esMinijuego(scene)) return new float[] {66, 78};
  return new float[] {506, 22};
}

boolean mostrarContadorMonedas() {
  return esExploracion(scene) || scene == 1 || scene == ESC_MINIJUEGOS || (esMinijuego(scene) && estadoJuego == 3);
}

// una NovaCoin dibujada (gira un poquito si gira = true)
void dibujarMoneda(float cx, float cy, float d, boolean gira) {
  float w = gira ? d * max(0.25, abs(cos(frameCount * 0.06 + cx * 0.01))) : d;
  noStroke();
  fill(120, 70, 0, 160);
  ellipse(cx + 1, cy + 2, w, d);
  fill(#FFB400);
  ellipse(cx, cy, w, d);
  fill(#FFDC3C);
  ellipse(cx, cy, w * 0.78, d * 0.78);
  fill(#FFF3A0);
  ellipse(cx - w * 0.14, cy - d * 0.16, w * 0.22, d * 0.18);
  if (w > d * 0.5) {
    fill(#B46E00);
    textFont(fuenteUI);
    textSize(d * 0.5);
    textAlign(CENTER, CENTER);
    text("N", cx, cy - d * 0.04);
  }
}

void dibujarContadorMonedas(float cx, float cy) {
  float esc = 1 + pulsoMonedas * 0.25;
  String t = str(round(monedasVista));
  textFont(fuenteUI);
  textSize(15);
  float w = max(76, textWidth(t) + 50);
  noStroke();
  fill(8, 6, 24, 215);
  rect(cx - w / 2, cy - 14, w, 28, 14);
  stroke(ultimoCambioMonedas < 0 && pulsoMonedas > 0.05 ? neonRojo : #FFB400, 150 + 100 * pulsoMonedas);
  strokeWeight(1.5);
  noFill();
  rect(cx - w / 2, cy - 14, w, 28, 14);
  noStroke();
  if (pulsoMonedas > 0.05) {
    fill(ultimoCambioMonedas < 0 ? neonRojo : #FFDC3C, 60 * pulsoMonedas);
    rect(cx - w / 2 - 4, cy - 18, w + 8, 36, 18);
  }
  pushMatrix();
  translate(cx - w / 2 + 16, cy);
  scale(esc);
  dibujarMoneda(0, 0, 20, true);
  popMatrix();
  fill(255);
  textFont(fuenteUI);
  textSize(15);
  textAlign(LEFT, CENTER);
  text(t, cx - w / 2 + 34, cy - 1);
}

// se llama cada cuadro desde vidaDespuesDeDibujar
void actualizarMonedas() {
  monedasVista = lerp(monedasVista, monedas, 0.12);
  if (abs(monedasVista - monedas) < 0.5) monedasVista = monedas;
  pulsoMonedas *= 0.93;
  if (mostrarContadorMonedas()) {
    float[] p = posContadorMonedas();
    dibujarContadorMonedas(p[0], p[1]);
  }
  // monedas volando hacia el contador
  for (int i = monedasVolando.size() - 1; i >= 0; i--) {
    float[] m = monedasVolando.get(i);
    if (m[5] > 0) {
      m[5]--;
      continue;
    }
    m[4] += 0.035;
    float t = m[4] * m[4] * (3 - 2 * m[4]);
    float mx = lerp(m[0], m[2], t), my = lerp(m[1], m[3], t) - sin(t * PI) * 60;
    dibujarMoneda(mx, my, 14, true);
    if (m[4] >= 1) {
      monedasVolando.remove(i);
      pulsoMonedas = 1;
      chispas(m[2], m[3], neonAmarillo, 3);
    }
  }
}

// monedas por terminar un minijuego (segun que tan cerca quedaste de la meta)
int monedasPorJuego(int idx, int pts, boolean premioNuevo, boolean record) {
  if (pts <= 0) return 0;
  float rendimiento = constrain(pts / (float) umbralPremio[idx], 0, 1.5);
  int n = max(1, round(rendimiento * 20));
  if (record) n += 5;
  if (premioNuevo) n += 10;
  return n;
}

String textoMonedasJuego = "";
int monedasUltimoJuego = 0;

void pagarMinijuego(int idx, boolean premioNuevo) {
  int n = monedasPorJuego(idx, puntaje, premioNuevo, nuevoRecord);
  textoMonedasJuego = "";
  if (n > 0 && cargasX2 > 0) {
    n *= 2;
    cargasX2--;
    textoMonedasJuego = "  (Chip x2!)";
  }
  monedasUltimoJuego = n;
  if (n > 0) ganarMonedas(n, width / 2, 345);
}

// monedas por decisiones: se llama desde vigilarEstadisticas cuando cambian las barras
void monedasPorDecision(float dv, float dc, float di) {
  if (sinMonedasPorCambio) {
    sinMonedasPorCambio = false;
    return;
  }
  if (scene == 0 || esMinijuego(scene) || scene == ESC_TIENDA || scene == ESC_RULETA) return;
  boolean buena = dc > 0 || di > 0;
  if (buena) {
    int n = constrain(round(4 + (max(dc, 0) + max(di, 0)) * 0.6), 4, 20);
    ganarMonedas(n, width / 2, height * 0.36 + 40);
  } else {
    int n = constrain(round(3 + (abs(min(dc, 0)) + abs(min(di, 0)) + max(dv, 0)) * 0.4), 3, 15);
    if (tengoGadget[8] > 0) {
      tengoGadget[8]--;
      avisar("Seguro Anti-Bulo", "Tu seguro te protegio: no perdiste " + n + " NovaCoins.", coloresGadgets[8]);
      guardarDatos();
      return;
    }
    if (monedas > 0) ganarMonedas(-min(n, monedas), width / 2, height * 0.36);
  }
}

// ------------------------------------- EFECTOS DE LOS GADGETS -------------------------------------
boolean gadgetActivo(int i) {
  return tengoGadget[i] > 0 && gadgetEncendido[i];
}

void aplicarGadgets() {
  velocidadBase = gadgetActivo(0) ? 6.0 : 3.5;
  if (velocidad < 6.9) velocidad = velocidadBase;   // si va con shift (7) se queda asi
}

// chispas de colores detras del personaje (gadget Estela de Luz)
void estelaAlCaminar() {
  if (!gadgetActivo(3) || !esExploracion(scene)) return;
  boolean moviendo = moverArriba || moverAbajo || moverIzquierda || moverDerecha;
  if (!moviendo || frameCount % 2 != 0) return;
  color[] cs = {neonCian, neonRosa, neonAmarillo, neonVerde, neonMorado};
  agregarParticula(new Particula(x + 50 + random(-10, 10), y + 40 + random(-6, 6), random(-0.5, 0.5), random(-1, -0.3), random(30, 50), random(3, 6), cs[int(random(cs.length))], 6));
}

void usarGadget(int i) {
  if (gadgetPermanente[i] || tengoGadget[i] <= 0) return;
  if (i == 4 || i == 8) return;   // estos se gastan solos
  tengoGadget[i]--;
  if (i == 5) {
    sinMonedasPorCambio = true;
    confiabilidad += 8;
    fraseTendero = "Credencial puesta! La gente confia mas en lo que dices. (+8 Confiabilidad)";
  } else if (i == 6) {
    sinMonedasPorCambio = true;
    impacto += 8;
    fraseTendero = "Megafono listo! Los vecinos ya estan hablando de los hechos. (+8 Impacto)";
  } else if (i == 7) {
    int n = 0;
    for (Difusion f : difusiones) if (!f.apagando) {
      f.apagando = true;
      n++;
    }
    fraseTendero = n > 0 ? "Antena encendida: apagaste " + n + " rumor(es) que se regaban por Nova." : "La antena no encontro rumores activos... por ahora. Igual la ciudad esta tranquila.";
  }
  letrasTendero = 0;
  explosionConfeti(width / 2, 200, 40);
  guardarDatos();
}

// ------------------------------------- ABRIR / CERRAR -------------------------------------
void abrirTienda(boolean online) {
  if (scene != ESC_TIENDA) regresoTienda = scene == ESC_RULETA ? regresoRuleta : scene;
  tiendaOnline = online;
  pararMovimiento();
  cerrarCharla();
  scene = ESC_TIENDA;
  String[] s = online ? saludosOnline : saludosTienda;
  fraseTendero = s[int(random(s.length))];
  letrasTendero = 0;
  dronT = -1;
}

void salirTienda() {
  scene = regresoTienda;
  pararMovimiento();
}

int precioDe(int i) {
  return tiendaOnline ? ceil(preciosGadgets[i] * (1 + COMISION_ONLINE)) : preciosGadgets[i];
}

boolean puedeComprar(int i) {
  if (gadgetPermanente[i] && tengoGadget[i] > 0) return false;
  if (!gadgetPermanente[i] && tengoGadget[i] >= 9) return false;
  return true;
}

void comprarGadget(int i) {
  if (!puedeComprar(i)) return;
  int p = precioDe(i);
  if (monedas < p) {
    sacudidaPrecio = 14;
    fraseTendero = "Uy, te faltan " + (p - monedas) + " NovaCoins. Juega minijuegos o toma buenas decisiones para ganar mas.";
    letrasTendero = 0;
    return;
  }
  monedas -= p;
  pulsoMonedas = 1;
  ultimoCambioMonedas = -p;
  if (i == 4) {
    tengoGadget[i] = 1;
    cargasX2 += 3;
  } else tengoGadget[i]++;
  if (gadgetPermanente[i]) gadgetEncendido[i] = true;
  aplicarGadgets();
  explosionConfeti(cardX(i) + 86, cardY(i) + 40, 60);
  if (tiendaOnline) {
    dronT = 0;
    dronGadget = i;
    fraseTendero = "Pedido confirmado! Pagaste " + p + " (incluye " + (p - preciosGadgets[i]) + " de comision). El dron va en camino...";
  } else {
    String[] f = {"Excelente eleccion! " + nombresGadgets[i] + " es tuyo.", "Gracias por tu compra! Que lo disfrutes por Nova.", "Vendido! Ese " + nombresGadgets[i] + " te va a quedar perfecto."};
    fraseTendero = f[int(random(f.length))];
  }
  letrasTendero = 0;
  avisar(tiendaOnline ? "NovaShop Online" : "Tienda NOVA", "Compraste: " + nombresGadgets[i] + "!", coloresGadgets[i]);
  guardarDatos();
}

// ------------------------------------- DIBUJO DE LA TIENDA -------------------------------------
float cardX(int i) {
  return 236 + (i % 3) * 182;
}

float cardY(int i) {
  return 84 + (i / 3) * 104;
}

void dibujarTienda() {
  // fondo: una tienda neon con estanterias
  background(10, 6, 24);
  noStroke();
  for (int i = 0; i < height; i += 5) {
    fill(lerpColor(color(30, 10, 50), color(8, 14, 40), i / (float) height));
    rect(0, i, width, 5);
  }
  // estanterias del fondo con cajitas brillantes
  for (int f = 0; f < 3; f++) {
    float sy = 140 + f * 110;
    fill(40, 26, 70);
    rect(0, sy, 226, 8);
    for (int k = 0; k < 5; k++) {
      color c = coloresGadgets[(k + f * 2) % coloresGadgets.length];
      float bh = 26 + ((k * 7 + f * 3) % 4) * 6;
      fill(c, 60 + 30 * sin(frameCount * 0.05 + k + f));
      rect(14 + k * 42, sy - bh, 30, bh, 4);
    }
  }
  // piso con reflejos
  fill(0, 90);
  rect(0, 430, 226, 70);
  stroke(neonMorado, 50);
  for (int i = 0; i < 6; i++) line(0, 440 + i * 10, 226, 440 + i * 10);
  noStroke();
  // letrero
  boolean parpadeo = frameCount % 240 > 230 && frameCount % 240 < 236;
  tituloNeon(tiendaOnline ? "NOVASHOP ONLINE" : "TIENDA NOVA", width / 2 + 90, 40, 34, parpadeo ? color(90) : (tiendaOnline ? neonCian : #FFB400));
  botonVolver();
  dibujarContadorMonedas(718, 34);
  if (tiendaOnline) {
    textFont(fuenteUI);
    textSize(10);
    fill(neonRosa);
    textAlign(CENTER, CENTER);
    text("Compra desde el celular: +" + round(COMISION_ONLINE * 100) + "% de comision por envio en dron", width / 2 + 90, 66);
  } else {
    textFont(fuenteUI);
    textSize(10);
    fill(200);
    textAlign(CENTER, CENTER);
    text("Precio de tienda: sin comision", width / 2 + 90, 66);
  }
  // el tendero (un robot) y lo que dice
  float fase = frameCount * 0.04;
  dibujarRobot(112, 392, fase, tiendaOnline ? "BYTE (soporte online)" : "BYTE (tendero)");
  letrasTendero = min(letrasTendero + 1.6, fraseTendero.length());
  fill(245);
  rect(16, 214, 196, 92, 12);
  triangle(96, 306, 120, 306, 108, 322);
  fill(25);
  textFont(fuenteUI);
  textSize(11);
  textAlign(LEFT, TOP);
  text(fraseTendero.substring(0, int(letrasTendero)), 26, 222, 178, 80);
  // boton a la ruleta
  botonNeon("Ruleta Nova", 30, 76, 170, 36, neonRojo, false);
  textFont(fuenteUI);
  textSize(9);
  fill(180);
  textAlign(CENTER, CENTER);
  text("duplica tus NovaCoins... o no", 115, 122);

  // tarjetas de los gadgets
  for (int i = 0; i < nombresGadgets.length; i++) dibujarTarjetaGadget(i);
  // detalle del gadget elegido
  dibujarDetalleGadget(gadgetElegido);
  // el dron que trae el pedido (compras online)
  if (dronT >= 0) {
    dronT += 1;
    float t = dronT / 150.0;
    float dx = lerp(width + 60, 400, constrain(t * 2, 0, 1));
    float dy = 180 + sin(dronT * 0.2) * 6 - (t > 0.7 ? (t - 0.7) * 600 : 0);
    if (t > 0.5) dx = 400 + (t - 0.5) * 900;
    noStroke();
    fill(60, 60, 80);
    rect(dx - 26, dy - 6, 52, 12, 6);
    fill(neonCian);
    ellipse(dx, dy, 10, 10);
    stroke(200);
    strokeWeight(2);
    float h = frameCount % 4 < 2 ? 22 : 14;
    line(dx - 24 - h / 2, dy - 10, dx - 24 + h / 2, dy - 10);
    line(dx + 24 - h / 2, dy - 10, dx + 24 + h / 2, dy - 10);
    noStroke();
    if (t < 0.5) {
      fill(#C8964E);
      rect(dx - 12, dy + 8, 24, 18, 3);
      fill(coloresGadgets[dronGadget]);
      rect(dx - 12, dy + 14, 24, 4);
    }
    if (dronT == 75) {
      chispas(400, 200, coloresGadgets[dronGadget], 30);
      fraseTendero = "Entregado! El dron dejo tu " + nombresGadgets[dronGadget] + ". Ya lo puedes usar.";
      letrasTendero = 0;
    }
    if (dronT > 150) dronT = -1;
  }
  if (sacudidaPrecio > 0) sacudidaPrecio *= 0.85;
  if (sacudidaPrecio < 0.3) sacudidaPrecio = 0;
}

void dibujarTarjetaGadget(int i) {
  float cx = cardX(i), cy = cardY(i), cw = 172, chh = 96;
  boolean s = encima(cx, cy, cw, chh);
  boolean elegido = i == gadgetElegido;
  color c = coloresGadgets[i];
  float lev = s ? -3 : 0;
  noStroke();
  if (elegido) {
    for (int k = 3; k >= 1; k--) {
      fill(c, 18);
      rect(cx - k * 3, cy - k * 3 + lev, cw + k * 6, chh + k * 6, 14 + k * 3);
    }
  }
  fill(14, 10, 32, 235);
  rect(cx, cy + lev, cw, chh, 14);
  stroke(c, elegido ? 255 : (s ? 200 : 110));
  strokeWeight(elegido ? 2.5 : 1.5);
  noFill();
  rect(cx, cy + lev, cw, chh, 14);
  noStroke();
  fill(c, 40);
  ellipse(cx + 40, cy + 44 + lev, 60, 60);
  dibujarIconoGadget(i, cx + 40, cy + 44 + lev, 1);
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(12);
  fill(255);
  text(nombresGadgets[i], cx + 76, cy + 12 + lev, 92, 32);
  // precio
  boolean tieneYa = gadgetPermanente[i] && tengoGadget[i] > 0;
  if (tieneYa) {
    fill(neonVerde);
    textSize(11);
    text(gadgetEncendido[i] ? "TUYO - activo" : "TUYO - apagado", cx + 76, cy + 62 + lev);
  } else {
    float sh = (i == gadgetElegido && sacudidaPrecio > 0) ? random(-sacudidaPrecio, sacudidaPrecio) * 0.4 : 0;
    dibujarMoneda(cx + 83 + sh, cy + 68 + lev, 14, false);
    textSize(14);
    textAlign(LEFT, CENTER);
    fill(monedas >= precioDe(i) ? color(255, 230, 120) : neonRojo);
    text(str(precioDe(i)), cx + 96 + sh, cy + 67 + lev);
    if (tiendaOnline) {
      textSize(9);
      fill(150);
      text("antes " + preciosGadgets[i], cx + 128, cy + 68 + lev);
    }
    textAlign(LEFT, TOP);
  }
  if (!gadgetPermanente[i] && tengoGadget[i] > 0) {
    fill(c);
    ellipse(cx + cw - 14, cy + 14 + lev, 22, 22);
    fill(15);
    textAlign(CENTER, CENTER);
    textSize(11);
    text(i == 4 ? str(cargasX2) : str(tengoGadget[i]), cx + cw - 14, cy + 13 + lev);
  }
  textAlign(LEFT, TOP);
  textSize(9);
  fill(150);
  text(gadgetPermanente[i] ? "permanente" : (i == 4 || i == 8 ? "se gasta solo" : "de un uso"), cx + 76, cy + 80 + lev);
}

void dibujarDetalleGadget(int i) {
  float px = 236, py = 400, pw = 546, ph = 88;
  color c = coloresGadgets[i];
  panelNeon(px, py, pw, ph, c);
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(14);
  fill(c);
  text(nombresGadgets[i], px + 16, py + 10);
  textSize(11);
  fill(225);
  text(descGadgets[i], px + 16, py + 32, 330, 50);
  // botones de la derecha
  String b1 = "";
  boolean puedeB1 = false;
  if (puedeComprar(i)) {
    b1 = "Comprar  " + precioDe(i);
    puedeB1 = true;
  } else if (gadgetPermanente[i]) b1 = "Ya es tuyo";
  else b1 = "Maximo 9";
  botonNeon(b1, px + 366, py + 12, 166, 30, puedeB1 ? #FFB400 : color(120), false);
  if (puedeB1) dibujarMoneda(px + 366 + 18, py + 27, 14, false);
  if (gadgetPermanente[i] && tengoGadget[i] > 0) {
    botonNeon(gadgetEncendido[i] ? "Apagar" : "Encender", px + 366, py + 48, 166, 30, gadgetEncendido[i] ? neonRosa : neonVerde, false);
  } else if (!gadgetPermanente[i] && i != 4 && i != 8 && tengoGadget[i] > 0) {
    botonNeon("Usar ahora (" + tengoGadget[i] + ")", px + 366, py + 48, 166, 30, neonVerde, false);
  } else if (i == 4 && cargasX2 > 0) {
    textAlign(CENTER, CENTER);
    textSize(11);
    fill(neonVerde);
    text("Te quedan " + cargasX2 + " partidas x2", px + 449, py + 63);
  } else if (i == 8 && tengoGadget[i] > 0) {
    textAlign(CENTER, CENTER);
    textSize(11);
    fill(neonVerde);
    text("Tienes " + tengoGadget[i] + " seguro(s) listos", px + 449, py + 63);
  }
}

// iconos de cada gadget (s = escala)
void dibujarIconoGadget(int i, float cx, float cy, float s) {
  pushMatrix();
  translate(cx, cy + sin(frameCount * 0.07 + i) * 2);
  scale(s);
  color c = coloresGadgets[i];
  noStroke();
  if (i == 0) {
    // patin
    fill(c);
    rect(-16, -18, 16, 22, 4);
    rect(-16, -2, 30, 10, 4);
    fill(255);
    rect(-14, -14, 12, 3);
    fill(40);
    ellipse(-10, 14, 10, 10);
    ellipse(8, 14, 10, 10);
    fill(c, 120);
    rect(-30, -6, 10, 2);
    rect(-34, 0, 14, 2);
  } else if (i == 1) {
    // gafas
    fill(30);
    rect(-24, -8, 48, 6, 3);
    fill(c);
    ellipse(-11, 4, 20, 16);
    ellipse(11, 4, 20, 16);
    fill(255, 200);
    ellipse(-14, 1, 6, 4);
    ellipse(8, 1, 6, 4);
  } else if (i == 2) {
    // radar
    noFill();
    stroke(c);
    strokeWeight(2);
    ellipse(0, 0, 40, 40);
    ellipse(0, 0, 22, 22);
    float a = frameCount * 0.08;
    line(0, 0, cos(a) * 20, sin(a) * 20);
    noStroke();
    fill(neonRosa);
    ellipse(8, -9, 6, 6);
    ellipse(-10, 6, 5, 5);
  } else if (i == 3) {
    // estela de chispas
    for (int k = 0; k < 4; k++) {
      color[] cs = {neonCian, neonRosa, neonAmarillo, neonVerde};
      fill(cs[k]);
      float sx = -18 + k * 12, sy = 10 - k * 7, r = 4 + k * 1.6;
      quad(sx, sy - r * 2, sx + r * 0.5, sy, sx, sy + r * 2, sx - r * 0.5, sy);
      quad(sx - r * 2, sy, sx, sy - r * 0.5, sx + r * 2, sy, sx, sy + r * 0.5);
    }
  } else if (i == 4) {
    // chip x2
    fill(40, 60, 50);
    rect(-18, -16, 36, 32, 4);
    fill(c);
    for (int k = 0; k < 4; k++) {
      rect(-24, -12 + k * 8, 6, 3);
      rect(18, -12 + k * 8, 6, 3);
    }
    fill(255);
    textFont(fuenteUI);
    textSize(15);
    textAlign(CENTER, CENTER);
    text("x2", 0, -1);
  } else if (i == 5) {
    // credencial
    stroke(c);
    strokeWeight(2);
    line(-8, -24, 0, -14);
    line(8, -24, 0, -14);
    noStroke();
    fill(240);
    rect(-16, -14, 32, 34, 4);
    fill(c);
    rect(-16, -14, 32, 9, 4, 4, 0, 0);
    fill(120);
    ellipse(0, 2, 12, 12);
    rect(-10, 11, 20, 3);
  } else if (i == 6) {
    // megafono
    fill(c);
    quad(-14, -6, 12, -18, 12, 18, -14, 6);
    fill(240);
    rect(-22, -6, 9, 12, 2);
    fill(255);
    rect(-12, 6, 5, 12, 2);
    noFill();
    stroke(255, 180);
    strokeWeight(2);
    arc(14, 0, 20, 26, -0.8, 0.8);
    arc(14, 0, 34, 40, -0.8, 0.8);
    noStroke();
  } else if (i == 7) {
    // antena con un rumor tachado
    fill(200);
    rect(-2, -10, 4, 30);
    triangle(-12, 20, 12, 20, 0, 6);
    fill(c);
    ellipse(0, -12, 8, 8);
    noFill();
    stroke(c);
    strokeWeight(2);
    arc(0, -12, 22, 22, -PI * 0.85, -PI * 0.15);
    arc(0, -12, 36, 36, -PI * 0.85, -PI * 0.15);
    noStroke();
  } else if (i == 8) {
    // escudo
    fill(c);
    beginShape();
    vertex(0, -20);
    vertex(18, -12);
    vertex(15, 8);
    vertex(0, 20);
    vertex(-15, 8);
    vertex(-18, -12);
    endShape(CLOSE);
    stroke(15);
    strokeWeight(4);
    line(-7, 0, -1, 7);
    line(-1, 7, 9, -6);
    noStroke();
  }
  popMatrix();
}

void clickTienda() {
  if (clickVolver()) {
    salirTienda();
    return;
  }
  if (encima(30, 76, 170, 36)) {
    abrirRuleta(regresoTienda);
    return;
  }
  for (int i = 0; i < nombresGadgets.length; i++) {
    if (encima(cardX(i), cardY(i), 172, 96)) {
      if (gadgetElegido == i) comprarGadget(i);   // doble clic en la misma tarjeta = comprar
      gadgetElegido = i;
      return;
    }
  }
  float px = 236, py = 400;
  int i = gadgetElegido;
  if (encima(px + 366, py + 12, 166, 30)) comprarGadget(i);
  else if (encima(px + 366, py + 48, 166, 30)) {
    if (gadgetPermanente[i] && tengoGadget[i] > 0) {
      gadgetEncendido[i] = !gadgetEncendido[i];
      aplicarGadgets();
      fraseTendero = nombresGadgets[i] + (gadgetEncendido[i] ? " encendido." : " apagado. Lo puedes volver a prender cuando quieras.");
      letrasTendero = 0;
      guardarDatos();
    } else usarGadget(i);
  }
}

void teclaTienda() {
  if (key == CODED) {
    if (keyCode == RIGHT) gadgetElegido = (gadgetElegido + 1) % nombresGadgets.length;
    if (keyCode == LEFT) gadgetElegido = (gadgetElegido + nombresGadgets.length - 1) % nombresGadgets.length;
    if (keyCode == DOWN) gadgetElegido = min(nombresGadgets.length - 1, gadgetElegido + 3);
    if (keyCode == UP) gadgetElegido = max(0, gadgetElegido - 3);
  } else if (key == ENTER || key == RETURN) comprarGadget(gadgetElegido);
}

// ------------------------------------- KIOSCOS (en el mapa y en los lugares) -------------------------------------
// kiosco de la tienda dibujado en un lugar (iy = donde toca el piso)
void dibujarKiosco(float kx, float ky, boolean ruleta) {
  color c = ruleta ? neonRojo : #FFB400;
  noStroke();
  fill(0, 90);
  ellipse(kx, ky + 2, 76, 14);
  // mostrador
  fill(30, 22, 50);
  rect(kx - 32, ky - 34, 64, 34, 4);
  fill(c);
  rect(kx - 32, ky - 34, 64, 4);
  // techito a rayas
  for (int k = 0; k < 4; k++) {
    fill(k % 2 == 0 ? c : color(245));
    rect(kx - 36 + k * 18, ky - 78, 18, 12);
  }
  fill(60, 50, 80);
  rect(kx - 30, ky - 66, 4, 32);
  rect(kx + 26, ky - 66, 4, 32);
  // letrero neon
  float b = 0.6 + 0.4 * sin(frameCount * 0.1 + kx);
  fill(c, 60 * b);
  rect(kx - 36, ky - 100, 72, 22, 8);
  fill(10, 8, 24);
  rect(kx - 33, ky - 98, 66, 18, 6);
  fill(c);
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  text(ruleta ? "RULETA" : "TIENDA", kx, ky - 90);
  if (ruleta) {
    // una ruletica girando en el mostrador
    pushMatrix();
    translate(kx, ky - 18);
    rotate(frameCount * 0.05);
    for (int k = 0; k < 8; k++) {
      fill(k == 0 ? neonVerde : (k % 2 == 0 ? neonRojo : color(30)));
      arc(0, 0, 26, 26, k * TWO_PI / 8, (k + 1) * TWO_PI / 8);
    }
    popMatrix();
  } else {
    dibujarMoneda(kx - 10, ky - 18, 14, true);
    dibujarIconoGadget(int(frameCount / 90) % nombresGadgets.length, kx + 12, ky - 18, 0.45);
  }
}

// kioscos en el mapa: {x, y}
float[][] kioscosMapa = {{150, 352}, {560, 292}};

int kioscoMapaEncima() {
  if (popupAbierto || telefonoAbierto || pausaAbierta) return -1;
  for (int i = 0; i < kioscosMapa.length; i++) if (dist(mouseX, mouseY, kioscosMapa[i][0], kioscosMapa[i][1] - 12) < 22) return i;
  return -1;
}

void dibujarKioscosMapa() {
  int s = kioscoMapaEncima();
  for (int i = 0; i < kioscosMapa.length; i++) {
    float kx = kioscosMapa[i][0], ky = kioscosMapa[i][1] + sin(frameCount * 0.08 + i * 2) * 2 - (s == i ? 4 : 0);
    float r = (frameCount * 0.8 + i * 25) % 46;
    noFill();
    stroke(#FFB400, 200 - r * 4);
    strokeWeight(2);
    ellipse(kx, ky + 8, r, r * 0.4);
    noStroke();
    fill(8, 6, 24, 230);
    ellipse(kx, ky - 12, 34, 34);
    stroke(#FFB400);
    strokeWeight(2);
    noFill();
    ellipse(kx, ky - 12, 34, 34);
    noStroke();
    // bolsa de compras
    fill(#FFB400);
    rect(kx - 9, ky - 16, 18, 15, 3);
    noFill();
    stroke(#FFB400);
    strokeWeight(2);
    arc(kx, ky - 16, 10, 12, PI, TWO_PI);
    noStroke();
    dibujarMoneda(kx + 12, ky - 24, 11, false);
  }
  if (s >= 0) {
    float kx = kioscosMapa[s][0], ky = kioscosMapa[s][1];
    textFont(fuenteUI);
    textSize(14);
    float w = 150;
    float tx = constrain(kx - w / 2, 6, width - w - 6), ty = ky - 74;
    fill(8, 6, 22, 235);
    rect(tx, ty, w, 40, 8);
    fill(255);
    textAlign(CENTER, TOP);
    text("Tienda NOVA", tx + w / 2, ty + 5);
    textSize(10);
    fill(#FFB400);
    text("clic para comprar gadgets", tx + w / 2, ty + 24);
  }
}

boolean clickKioscosMapa() {
  if (kioscoMapaEncima() >= 0) {
    abrirTienda(false);
    return true;
  }
  return false;
}

// ------------------------------------- RULETA NOVA (escena 71) -------------------------------------
final int CASILLAS = 15;   // 0 verde, impares rojo, pares negro
float angRuleta = 0, velRuleta = 0;
boolean girando = false;
int apuesta = 10;
int colorApostado = 0;   // 0 rojo, 1 negro, 2 verde
int resultadoRuleta = -1;
String mensajeRuleta = "";
color colorMensaje = color(255);
IntList historialRuleta = new IntList();
int perdidasSeguidas = 0;
float brilloGanar = 0;

void abrirRuleta(int regreso) {
  regresoRuleta = regreso;
  pararMovimiento();
  cerrarCharla();
  scene = ESC_RULETA;
  if (apuesta > monedas) apuesta = max(5, min(monedas, 10));
  mensajeRuleta = monedas > 0 ? "Elige color, apuesta y dale GIRAR." : "No tienes NovaCoins. Gana algunas jugando minijuegos.";
  colorMensaje = color(220);
}

void salirRuleta() {
  if (girando) return;   // primero que termine de girar
  scene = regresoRuleta;
  pararMovimiento();
}

int colorCasilla(int k) {
  return k == 0 ? 2 : (k % 2 == 1 ? 0 : 1);
}

color colorDeCasilla(int k) {
  int c = colorCasilla(k);
  return c == 2 ? color(20, 170, 80) : (c == 0 ? color(210, 30, 50) : color(25, 22, 30));
}

int casillaEnFlecha() {
  float paso = TWO_PI / CASILLAS;
  float a = (-HALF_PI - angRuleta) % TWO_PI;
  if (a < 0) a += TWO_PI;
  return int(round(a / paso)) % CASILLAS;
}

void girarRuleta() {
  if (girando) return;
  if (monedas <= 0) {
    mensajeRuleta = "No tienes NovaCoins para apostar. Juega minijuegos!";
    colorMensaje = neonRojo;
    return;
  }
  apuesta = constrain(apuesta, 1, monedas);
  monedas -= apuesta;
  pulsoMonedas = 1;
  ultimoCambioMonedas = -apuesta;
  velRuleta = random(0.30, 0.42);
  girando = true;
  resultadoRuleta = -1;
  mensajeRuleta = "Girando...";
  colorMensaje = color(220);
}

void terminarGiro() {
  girando = false;
  resultadoRuleta = casillaEnFlecha();
  historialRuleta.append(resultadoRuleta);
  if (historialRuleta.size() > 10) historialRuleta.remove(0);
  int c = colorCasilla(resultadoRuleta);
  if (c == colorApostado) {
    int mult = c == 2 ? 14 : 2;
    int premio = apuesta * mult;
    monedas += premio;
    pulsoMonedas = 1;
    ultimoCambioMonedas = premio;
    for (int i = 0; i < 12; i++) monedasVolando.add(new float[] {250 + random(-40, 40), 270 + random(-40, 40), 718, 34, 0, i * 3});
    mensajeRuleta = (c == 2 ? "VERDE!!! x14  " : "Ganaste! x2  ") + "+" + premio + " NovaCoins";
    colorMensaje = neonVerde;
    explosionConfeti(250, 200, c == 2 ? 160 : 70);
    brilloGanar = 1;
    perdidasSeguidas = 0;
  } else {
    perdidasSeguidas++;
    mensajeRuleta = "Salio " + (c == 2 ? "VERDE" : (c == 0 ? "ROJO" : "NEGRO")) + ". Perdiste " + apuesta + " NovaCoins.";
    colorMensaje = neonRojo;
    sacudida = 5;
    if (perdidasSeguidas == 3) avisar("NOVA IA", "3 perdidas seguidas. La ruleta es azar: la casa siempre gana a la larga. Quizas es hora de parar.", neonMorado);
  }
  if (apuesta > monedas) apuesta = max(1, monedas);
  guardarDatos();
}

void dibujarRuleta() {
  // fondo de casino: paño verde con luces
  background(12, 6, 14);
  noStroke();
  for (int i = 0; i < height; i += 5) {
    fill(lerpColor(color(60, 10, 30), color(10, 30, 26), i / (float) height));
    rect(0, i, width, 5);
  }
  for (int k = 0; k < 40; k++) {
    float lx = k * 20 + 10;
    boolean on = (k + frameCount / 8) % 3 == 0;
    fill(on ? #FFDC3C : color(90, 60, 20));
    ellipse(lx, 8, 7, 7);
    ellipse(lx, height - 8, 7, 7);
  }
  tituloNeon("RULETA NOVA", 560, 44, 34, neonRojo);
  botonVolver();
  dibujarContadorMonedas(718, 34);
  if (brilloGanar > 0) {
    fill(neonVerde, 50 * brilloGanar);
    rect(0, 0, width, height);
    brilloGanar *= 0.95;
  }
  // la ruleta
  float cx = 250, cy = 275, r = 160;
  if (girando && !pausaAbierta) {
    angRuleta += velRuleta;
    velRuleta *= 0.979;
    if (velRuleta < 0.0015) terminarGiro();
  }
  fill(0, 120);
  ellipse(cx + 6, cy + 10, r * 2 + 30, r * 2 + 30);
  fill(#6E4A1E);
  ellipse(cx, cy, r * 2 + 30, r * 2 + 30);
  fill(#A0742E);
  ellipse(cx, cy, r * 2 + 18, r * 2 + 18);
  float paso = TWO_PI / CASILLAS;
  for (int k = 0; k < CASILLAS; k++) {
    float a = angRuleta + k * paso;
    boolean gano = !girando && k == resultadoRuleta && frameCount % 30 < 18;
    fill(gano ? #FFDC3C : colorDeCasilla(k));
    arc(cx, cy, r * 2, r * 2, a - paso / 2, a + paso / 2, PIE);
    // separador dorado
    stroke(#E6C060);
    strokeWeight(2);
    line(cx, cy, cx + cos(a - paso / 2) * r, cy + sin(a - paso / 2) * r);
    noStroke();
    // numero
    pushMatrix();
    translate(cx + cos(a) * r * 0.82, cy + sin(a) * r * 0.82);
    rotate(a + HALF_PI);
    fill(gano ? color(20) : color(255));
    textFont(fuenteUI);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(str(k), 0, 0);
    popMatrix();
  }
  // centro
  fill(#A0742E);
  ellipse(cx, cy, r * 0.9, r * 0.9);
  fill(#6E4A1E);
  ellipse(cx, cy, r * 0.7, r * 0.7);
  pushMatrix();
  translate(cx, cy);
  rotate(angRuleta);
  fill(#E6C060);
  for (int k = 0; k < 4; k++) {
    rotate(HALF_PI);
    rect(-4, -r * 0.42, 8, r * 0.3, 4);
  }
  popMatrix();
  dibujarMoneda(cx, cy, 44, false);
  // flecha
  fill(0, 120);
  triangle(cx - 14, cy - r - 22, cx + 14, cy - r - 22, cx + 2, cy - r + 10);
  fill(#FFDC3C);
  triangle(cx - 14, cy - r - 26, cx + 14, cy - r - 26, cx, cy - r + 6);
  fill(255);
  ellipse(cx, cy - r - 20, 8, 8);

  // panel de apuestas
  float px = 460, py = 84;
  panelNeon(px, py, 320, 380, neonRojo);
  textFont(fuenteUI);
  textAlign(LEFT, TOP);
  textSize(12);
  fill(200);
  text("1. Elige un color", px + 18, py + 14);
  String[] nombresC = {"ROJO  x2", "NEGRO  x2", "VERDE  x14"};
  color[] cols = {color(210, 30, 50), color(80, 75, 95), color(20, 170, 80)};
  for (int k = 0; k < 3; k++) {
    float bx = px + 16 + k * 98;
    boolean s = colorApostado == k;
    fill(cols[k]);
    rect(bx, py + 34, 92, 40, 10);
    if (s) {
      stroke(#FFDC3C);
      strokeWeight(3);
      noFill();
      rect(bx - 2, py + 32, 96, 44, 12);
      noStroke();
    }
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(nombresC[k], bx + 46, py + 53);
  }
  textAlign(LEFT, TOP);
  textSize(12);
  fill(200);
  text("2. Cuanto apuestas", px + 18, py + 88);
  botonNeon("-", px + 16, py + 108, 44, 40, neonCian, false);
  botonNeon("+", px + 260, py + 108, 44, 40, neonCian, false);
  fill(8, 6, 20);
  rect(px + 68, py + 108, 184, 40, 10);
  dibujarMoneda(px + 120, py + 128, 22, true);
  fill(255);
  textSize(22);
  textAlign(LEFT, CENTER);
  text(str(apuesta), px + 138, py + 126);
  int[] rapidas = {10, 25, 50};
  for (int k = 0; k < 3; k++) botonNeon(str(rapidas[k]), px + 16 + k * 74, py + 156, 66, 28, #FFB400, apuesta == rapidas[k]);
  botonNeon("TODO", px + 238, py + 156, 66, 28, neonRosa, apuesta == monedas && monedas > 0);
  // girar
  boolean puede = !girando && monedas > 0;
  botonNeon(girando ? "Girando..." : "GIRAR", px + 16, py + 198, 288, 52, puede ? neonAmarillo : color(110), false);
  // mensaje
  textAlign(CENTER, CENTER);
  textSize(14);
  fill(colorMensaje);
  text(mensajeRuleta, px + 160, py + 272);
  if (!girando && resultadoRuleta >= 0) {
    textSize(11);
    fill(180);
    text("Si ganas en ROJO o NEGRO tu apuesta se duplica.", px + 160, py + 294);
  }
  // ultimos resultados
  textAlign(LEFT, CENTER);
  textSize(10);
  fill(170);
  text("Ultimos:", px + 18, py + 318);
  for (int k = 0; k < historialRuleta.size(); k++) {
    int v = historialRuleta.get(historialRuleta.size() - 1 - k);
    fill(colorDeCasilla(v));
    ellipse(px + 82 + k * 22, py + 318, 18, 18);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(9);
    text(str(v), px + 82 + k * 22, py + 317);
  }
  textAlign(CENTER, CENTER);
  textSize(10);
  fill(150);
  text("Juega con cabeza: es puro azar y a la larga la casa siempre gana.", px + 160, py + 352);
  if (!girando) botonNeon("Tienda", 20, 448, 96, 34, #FFB400, false);
}

void clickRuleta() {
  if (clickVolver()) {
    salirRuleta();
    return;
  }
  if (girando) return;
  if (encima(20, 448, 96, 34)) {
    int r = regresoRuleta;
    scene = r;   // para que la tienda vuelva al mismo lugar
    abrirTienda(false);
    return;
  }
  float px = 460, py = 84;
  for (int k = 0; k < 3; k++) if (encima(px + 16 + k * 98, py + 34, 92, 40)) colorApostado = k;
  int maxA = max(1, monedas);
  if (encima(px + 16, py + 108, 44, 40)) apuesta = max(1, apuesta - 5);
  if (encima(px + 260, py + 108, 44, 40)) apuesta = min(maxA, apuesta + 5);
  int[] rapidas = {10, 25, 50};
  for (int k = 0; k < 3; k++) if (encima(px + 16 + k * 74, py + 156, 66, 28)) apuesta = min(maxA, rapidas[k]);
  if (encima(px + 238, py + 156, 66, 28)) apuesta = maxA;
  if (encima(px + 16, py + 198, 288, 52)) girarRuleta();
}

void teclaRuleta() {
  if (key == ' ' || key == ENTER || key == RETURN) girarRuleta();
  if (girando) return;
  if (key == CODED && keyCode == UP) apuesta = min(max(1, monedas), apuesta + 5);
  if (key == CODED && keyCode == DOWN) apuesta = max(1, apuesta - 5);
  if (key == '1') colorApostado = 0;
  if (key == '2') colorApostado = 1;
  if (key == '3') colorApostado = 2;
}

// ------------------------------------- GUARDADO -------------------------------------
String textoGuardadoTienda() {
  String t = monedas + ";" + cargasX2 + ";";
  for (int i = 0; i < tengoGadget.length; i++) t += tengoGadget[i] + (i < tengoGadget.length - 1 ? "," : "");
  t += ";";
  for (boolean b : gadgetEncendido) t += b ? "1" : "0";
  return t;
}

void cargarGuardadoTienda(String l) {
  try {
    String[] p = split(trim(l), ';');
    if (p.length < 4) return;
    monedas = int(p[0]);
    monedasVista = monedas;
    cargasX2 = int(p[1]);
    String[] g = split(p[2], ',');
    for (int i = 0; i < min(g.length, tengoGadget.length); i++) tengoGadget[i] = int(g[i]);
    for (int i = 0; i < min(p[3].length(), gadgetEncendido.length); i++) gadgetEncendido[i] = p[3].charAt(i) == '1';
  }
  catch (Exception e) {
    println("No se pudieron cargar las monedas: " + e);
  }
  aplicarGadgets();
}
