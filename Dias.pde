// =====================================================================================
//  DIAS.pde -> los dias de Red Quest dentro de Nova, y Sofi
//   - La semana: LUNES, MARTES y MIERCOLES, cada uno con MAÑANA, MEDIODIA, TARDE y NOCHE.
//     El JUEVES son las elecciones.
//   - El tiempo avanza cuando tomas decisiones importantes (2 decisiones = el siguiente momento).
//     Las sorpresas del mapa, los minijuegos y la tienda no mueven el reloj.
//   - De noche aparece "Dormir" en el mapa: ves el resumen del dia y pasas al siguiente.
//   - Sofi (del 11B) es candidata al Consejo de Juventud. Tu relacion con ella cambia
//     con lo que le dices y con como actuas en Conecta.
//  Escena 72 = fin del dia.
// =====================================================================================

final int ESC_FIN_DIA = 72;

String[] nombreDia = {"LUNES", "MARTES", "MIERCOLES", "JUEVES"};
String[] nombreMomento = {"MAÑANA", "MEDIODIA", "TARDE", "NOCHE"};
int[] horaMomento = {7 * 60, 12 * 60, 16 * 60, 20 * 60};

int dia = 0;            // 0 lunes ... 3 jueves (elecciones)
int momento = 0;        // 0 mañana ... 3 noche
int decisionesMomento = 0;
final int DECISIONES_POR_MOMENTO = 2;
boolean avisoNoche = false;

// para el resumen del fin del dia
float inicioV, inicioC, inicioI, inicioS;
int inicioMonedas, inicioDecisiones;
float tFinDia = 0;

// ------------------------------------- SOFI -------------------------------------
float relacionSofi = 50;   // 0 a 100
float hudS = 50;
final color colorSofi = #FF6E96;
Interactivo[] sofiPorDia = new Interactivo[3];
String[] lugarSofi = {"el salon 10B", "el Paseo de Campaña", "el Parque Central"};

String[] saludoSofi = {
  "Sofi: ...Hola. No tengo mucho que decirte. Ya vi lo que has andado compartiendo.",
  "Sofi: Hola! Que bueno encontrarte por aqui.",
  "Sofi: Que bueno verte! Necesitaba hablar con alguien de confianza."
};
String[][] nocheSofi = {
  {"Sofi: Hoy fue un dia raro. Prefiero no hablar.", "Sofi: Mejor me desconecto un rato. Buenas noches.", "Sofi: ..."},
  {"Sofi: Gracias por lo de hoy. Mañana sigue la campaña.", "Sofi: Dia largo, eh. Descansa.", "Sofi: Mañana es el gran dia. Que nervios!"},
  {"Sofi: Hoy senti que no estaba sola. Gracias de verdad.", "Sofi: Eres de las pocas personas que verifica antes de compartir. Se nota.", "Sofi: Pase lo que pase mañana, gracias por estar."}
};
String[][] mananaSofi = {
  {"Buenos dias! Hoy me inscribo oficialmente al Consejo de Juventud. Te veo en el salon 10B, no me dejes sola :)", "", ""},
  {"Ayer alguien dijo cosas de mi en Conecta. No se si fuiste tu...", "Buenos dias! Hoy estare en el Paseo de Campaña repartiendo volantes.", "Buenos dias! Hoy estare en el Paseo de Campaña. Pasa a saludar :D"},
  {"Hoy estare en el Parque. Si quieres hablar, ahi estoy.", "Ultimo dia de campaña! Estare en el Parque Central.", "Ultimo dia de campaña!! Te espero en el Parque Central, necesito tu opinion."},
  {"Hoy son las elecciones.", "Hoy son las elecciones! Nos vemos en la Plaza de la Votacion.", "HOY ES EL DIA! Nos vemos en la Plaza de la Votacion. Gracias por todo."}
};
String[] epilogoSofi = {
  "Sofi perdio el Consejo de Juventud. Despues de todo lo que se dijo en Conecta, dejo de hablarte.",
  "Sofi quedo segunda en el Consejo de Juventud. Dice que el otro año lo intenta otra vez... ojala contigo.",
  "Sofi gano el Consejo de Juventud! En su discurso dijo: 'gracias a quien me ayudo a defender la verdad'."
};

int nivelSofi() {
  if (relacionSofi < 35) return 0;
  if (relacionSofi < 65) return 1;
  return 2;
}

void cambiarRelacionSofi(float d) {
  if (abs(d) < 0.01) return;
  relacionSofi = constrain(relacionSofi + d, 0, 100);
  flotar((d > 0 ? "+" : "") + int(d) + " Sofi", width / 2 + 120, height * 0.36 + 44, colorSofi);
}

// las 3 apariciones de Sofi (una por dia, en distinto lugar)
Interactivo crearSofi(int d) {
  String[][] lineas = {
    {"", "Sofi: Me lance al Consejo de Juventud. Quiero que los del colegio tengamos voz en las elecciones de Nova.", "Sofi: Pero ya empezaron a decir cosas de mi en Conecta... Me ayudarias con la campaña?"},
    {"", "Sofi: Alguien subio a Conecta que copie mis propuestas de otro colegio. Es mentira: las escribimos con mi grupo.", "Sofi: Ya lo compartieron 300 personas... Que hago?"},
    {"", "Sofi: Mañana son las elecciones. Tengo el discurso listo, pero me tiemblan las manos.", "Sofi: Crees que la gente de Nova vota por propuestas... o por chismes?"}
  };
  String[][] ops = {
    {"Claro, cuenta conmigo. Con la verdad por delante.", "Mmm... no me gusta meterme en politica.", "Si me consigues seguidores, hago memes de tus rivales."},
    {"Muestra tus borradores con fecha: esa es la prueba.", "Responde con un video furioso, que se vea que estas brava.", "No digas nada, ya se les olvidara."},
    {"Por propuestas, si alguien las explica bien. Te ayudo con datos oficiales.", "Por chismes. Asi es esto.", "Ni idea... pero pase lo que pase, estoy contigo."}
  };
  // {viralidad, confiabilidad, impacto, relacion con Sofi}
  float[][][] ef = {
    {{0, 4, 6, 12}, {0, 0, -1, -4}, {8, -6, 0, -10}},
    {{0, 6, 4, 12}, {6, -3, 0, -4}, {0, 0, -2, -3}},
    {{2, 4, 8, 10}, {0, -2, -2, -6}, {0, 2, 2, 8}}
  };
  String[][] resp = {
    {"Sofi: Gracias! En serio. Con la verdad por delante, prometido.", "Sofi: Esta bien... Si cambias de idea, aqui estoy.", "Sofi: Memes de los rivales? No. Asi no quiero ganar."},
    {"Sofi: Tienes razon! Subi las fotos de los borradores con fecha... y ya hay gente pidiendo disculpas.", "Sofi: Lo subi... y ahora dicen que soy agresiva. Creo que eso no ayudo.", "Sofi: Ok... pero el rumor sigue creciendo. Ojala tengas razon."},
    {"Sofi: Gracias! Voy a poner los datos de inscripcion oficiales en mi discurso.", "Sofi: ...Ojala te equivoques.", "Sofi: Eso es justo lo que necesitaba escuchar."}
  };
  float[][] pos = {{690, 300}, {400, 330}, {470, 430}};
  Charla ch = new Charla("Sofi (candidata)", lineas[d]).con(ops[d], ef[d], resp[d], "Sofi: Nos vemos por Nova. Y cuidado con lo que compartes, eh.");
  Interactivo it = persona(pos[d][0], pos[d][1], "Sofi", #E85D75, #4A2C1A, ch);
  return it;
}

void prepararSofi() {
  int[] dondeEsta = {ESC_SALON, ESC_PASEO, ESC_PARQUE};
  for (int d = 0; d < 3; d++) {
    sofiPorDia[d] = crearSofi(d);
    Lugar L = lugares.get(dondeEsta[d]);
    if (d == 2) interParque.add(sofiPorDia[d]);
    else if (L != null) L.agregar(sofiPorDia[d]);
  }
  actualizarSofi();
}

// Sofi solo esta en su lugar el dia que le toca
void actualizarSofi() {
  for (int d = 0; d < 3; d++) if (sofiPorDia[d] != null) sofiPorDia[d].ausente = d != dia;
  actualizarPostJuego();   // despues del final manda quien esta en Nova (PostJuego.pde)
}

// el saludo cambia segun como te llevas con ella
void prepararCharlaSofi(Interactivo it) {
  if (!it.nombre.equals("Sofi") || it.charla == null) return;
  it.charla.lineas[0] = saludoSofi[nivelSofi()];
}

void mensajeSofi(String t, int retraso) {
  if (t == null || t.equals("")) return;
  Mensaje m = new Mensaje();
  m.de = "Sofi";
  m.texto = t;
  m.llega = frameCount + retraso;
  mensajesPendientes.add(m);
}

// ------------------------------------- EL RELOJ -------------------------------------
void prepararDias() {
  dia = 0;
  momento = 0;
  decisionesMomento = 0;
  relojJuego = horaMomento[0] + 30;
  relacionSofi = 50;
  hudS = 50;
  avisoNoche = false;
  guardarInicioDia();
  actualizarSofi();
  mensajeSofi(mananaSofi[0][0], 300);
}

void guardarInicioDia() {
  inicioV = viralidad;
  inicioC = confiabilidad;
  inicioI = impacto;
  inicioS = relacionSofi;
  inicioMonedas = monedas;
  inicioDecisiones = decisionesTomadas;
  inicioCulpa = culpa;
}

// el reloj camina solo, pero no pasa al siguiente momento sin decisiones
void avanzarReloj() {
  float tope = momento < 3 ? horaMomento[momento + 1] - 10 : 23 * 60 + 55;
  if (dia >= 3) tope = 18 * 60;
  relojJuego = min(relojJuego + 0.03, tope);
}

// se llama cuando cambian las barras por una decision de verdad
void decisionImportante(boolean buena) {
  if (dia >= 3) return;
  // como actuas tambien le llega a Sofi (un poquito)
  if (!ultimaFueDeSofi) cambiarRelacionSofi(buena ? 2 : -3);
  ultimaFueDeSofi = false;
  // (fase 2) el reloj ya no avanza con cualquier decision: solo con las situaciones de Conecta (Situaciones.pde)
}
boolean ultimaFueDeSofi = false;

// decide si un cambio de barras cuenta como decision (no: mapa, minijuegos, tienda, gadgets...)
boolean cuentaComoDecision() {
  return !sinMonedasPorCambio && scene != 0 && scene != 1 && !esMinijuego(scene) && scene != ESC_TIENDA && scene != ESC_RULETA && scene != ESC_FIN_DIA && scene != ESC_FINAL && scene != ESC_FIN_GRAVE;
}

String textoMomento() {
  if (dia >= 3) return "JUEVES  -  ELECCIONES";
  return nombreDia[dia] + "  -  " + nombreMomento[momento];
}

int diasElecciones() {
  return max(0, 3 - dia);
}

// se llama cada cuadro desde vidaDespuesDeDibujar
void actualizarDias() {
  actualizarHistoria();   // quien aparece hoy (Situaciones.pde)
  actualizarShawn();      // (Ruta.pde)
  hudS = lerp(hudS, relacionSofi, 0.08);
  actualizarSofi();
  if (scene == 1 && escenaObjetivo() != ESC_CASA && !popupAbierto && !telefonoAbierto && !pausaAbierta) {
    float b = 0.5 + 0.5 * sin(frameCount * 0.08);
    noStroke();
    fill(neonMorado, 40 * b);
    rect(616, 432, 178, 56, 16);
    botonNeon("Ir a casa  >", 624, 440, 162, 40, neonMorado, false);
    if (momento == 3) dibujarLuna(646, 460, 11);
    else dibujarCasita(646, 460);   // (Casa.pde)
  }
}

boolean puedeDormir() {
  return momento == 3 && dia < 3;
}

boolean clickDormir() {
  if (scene == 1 && escenaObjetivo() != ESC_CASA && encima(624, 440, 162, 40)) {
    irACasa(false);   // ahora se duerme en la cama de tu cuarto (Casa.pde)
    return true;
  }
  return false;
}

void dibujarLuna(float lx, float ly, float r) {
  noStroke();
  fill(255, 240, 190);
  ellipse(lx, ly, r * 2, r * 2);
  fill(neonMorado);
  ellipse(lx + r * 0.6, ly - r * 0.3, r * 1.6, r * 1.6);
}

// ------------------------------------- FIN DEL DIA (escena 72) -------------------------------------
void irAFinDelDia() {
  pararMovimiento();
  tFinDia = 0;
  scene = ESC_FIN_DIA;
  sonar(12);
  empezarNoche();   // primero la noche en el celular (Ruta.pde)
}

void dibujarFinDelDia() {
  if (faseNoche == 0) {
    dibujarNocheCelular();   // (Ruta.pde)
    return;
  }
  if (!pausaAbierta) tFinDia++;
  // cielo de noche sobre Nova
  degradado(0, 0, width, height, color(6, 8, 30), color(40, 14, 60));
  noStroke();
  for (int i = 0; i < 70; i++) {
    fill(255, 120 + 120 * sin(frameCount * 0.04 + i));
    rect(hsh(i * 3.1) * width, hsh(i * 7.7) * 300, 2, 2);
  }
  dibujarLuna(680, 80, 34);
  for (int i = 0; i < 16; i++) {
    float bw = 30 + hsh(i * 1.9) * 40, bh = 60 + hsh(i * 2.7) * 120;
    fill(14, 10, 32);
    rect(i * 52 - 10, height - bh, bw + 14, bh);
    fill(255, 210, 140, 150);
    for (int k = 0; k < 4; k++) if (hsh(i * 13 + k) > 0.55) rect(i * 52 + 4 + (k % 2) * 14, height - bh + 14 + (k / 2) * 22, 6, 9);
  }
  tituloNeon("FIN DEL " + nombreDia[dia], width / 2, 52, 38, neonMorado);
  panelNeon(150, 92, 500, 300, neonMorado);
  textFont(fuenteUI);
  textAlign(LEFT, CENTER);
  int decHoy = decisionesTomadas - inicioDecisiones;
  int monHoy = monedas - inicioMonedas;
  String[] etiquetas = {"Decisiones de hoy", "NovaCoins", "Confiabilidad", "Impacto", "Viralidad"};
  String[] valores = {str(decHoy), (monHoy >= 0 ? "+" : "") + monHoy, signo(confiabilidad - inicioC), signo(impacto - inicioI), signo(viralidad - inicioV)};
  color[] cols = {color(230), neonAmarillo, neonCian, neonAmarillo, neonRosa};
  for (int i = 0; i < etiquetas.length; i++) {
    float a = constrain((tFinDia - 10 - i * 8) / 10.0, 0, 1);
    textSize(14);
    fill(200, 255 * a);
    text(etiquetas[i], 180, 120 + i * 28);
    fill(cols[i], 255 * a);
    textAlign(RIGHT, CENTER);
    text(valores[i], 620, 120 + i * 28);
    textAlign(LEFT, CENTER);
  }
  // relacion con Sofi
  float a = constrain((tFinDia - 60) / 15.0, 0, 1);
  fill(colorSofi, 255 * a);
  textSize(14);
  text("Relacion con Sofi", 180, 268);
  fill(40, 36, 60, 255 * a);
  rect(340, 262, 230, 12, 6);
  fill(colorSofi, 255 * a);
  rect(340, 262, 230 * relacionSofi / 100.0 * a, 12, 6);
  textAlign(RIGHT, CENTER);
  fill(255, 255 * a);
  text(int(relacionSofi) + "  " + signo(relacionSofi - inicioS), 620, 268);
  // el mensaje de Sofi antes de dormir
  if (tFinDia > 80) {
    float b = constrain((tFinDia - 80) / 15.0, 0, 1);
    fill(30, 24, 60, 230 * b);
    rect(180, 292, 440, 60, 12);
    fill(colorSofi, 255 * b);
    textAlign(LEFT, TOP);
    textSize(11);
    text(dia < 2 ? "Mañana, " + nombreDia[dia + 1] : "Mañana: las elecciones", 194, 300);
    fill(240, 255 * b);
    textSize(13);
    text(dia < 2 ? "Sofi estara en " + lugarSofi[dia + 1] + ". Culpa: " + culpa + (culpa >= 3 ? " (Nova se esta oscureciendo)" : "") : "Las urnas abren en la Plaza de la Votacion. Culpa: " + culpa, 194, 316, 412, 34);
  }
  if (tFinDia > 100) botonNeon(dia < 2 ? "Dormir hasta el " + nombreDia[dia + 1] : "Dormir... mañana son las elecciones", 220, 408, 360, 48, neonMorado, frameCount % 60 < 30);
}

void clickFinDelDia() {
  if (faseNoche == 0) {
    clickNocheCelular();
    return;
  }
  if (tFinDia > 100 && encima(220, 408, 360, 48)) empezarDiaNuevo();
  else if (tFinDia < 100) tFinDia = 100;
}

void teclaFinDelDia() {
  if (faseNoche == 0) return;
  if (key == ENTER || key == RETURN || key == ' ') {
    if (tFinDia > 100) empezarDiaNuevo();
    else tFinDia = 100;
  }
}

void empezarDiaNuevo() {
  dia++;
  momento = 0;
  decisionesMomento = 0;
  situacionesHoy = 0;
  avisoNoche = false;
  relojJuego = horaMomento[0] + 30;
  guardarInicioDia();
  actualizarSofi();
  empezarCineDia();   // la tarjeta del dia y despiertas en tu cama (Casa.pde)
  sonar(13);
  if (dia >= 3) {
    bannerTexto = "JUEVES  -  DIA DE ELECCIONES";
    avisar("Elecciones!", "Las urnas abrieron. Ve a la Plaza de la Votacion cuando estes list@.", neonAmarillo);
  } else {
    bannerTexto = nombreDia[dia] + "  -  " + nombreMomento[0];
    avisar("Nuevo dia", "Hoy Sofi estara en " + lugarSofi[dia] + ".", colorSofi);
  }
  bannerVida = 170;
  mensajeSofi(mananaSofi[min(dia, 3)][nivelSofi()], 400);
}
