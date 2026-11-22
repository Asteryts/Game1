// =====================================================================================
//  POSTJUEGO.pde -> Nova despues de las elecciones ("Seguir explorando" en el epilogo)
//   - Tus estadisticas quedan congeladas: ya votaron, lo hecho, hecho esta.
//   - La ciudad cambia segun tu final: se ve distinta y la gente habla distinto.
//       tono 0 = buen final (Filtro de Nova / Ciudadano consciente)
//       tono 1 = final gris  (Espectador silencioso)
//       tono 2 = mal final   (Agente del caos)
//       tono 3 = final secreto (Desconectado)
//   - "ruina" (0 a 1) mide que tan malas fueron tus decisiones: entre mas alta,
//     peor se ve la pantalla (rojo, estatica, grietas, lluvia, parpadeos).
// =====================================================================================

boolean postJuego = false;
int tonoFinal = 1;
int verdadFinal = 0;          // 0 limbo, 1 equilibrio, 2 viaje, 3 refugio, 4 desconectado
float ruina = 0;
float[] statsCongeladas = new float[4];   // viralidad, confiabilidad, impacto, Sofi
String[] nombreTono = {"NOVA DECIDIO CON DATOS", "NOVA SIGUE IGUAL", "NOVA SE ROMPIO", "NOVA DESCONECTADA"};

void empezarPostJuego() {
  postJuego = true;
  verdadFinal = finalSecretoElegido ? 4 : indiceFinalRQ();
  if (finalSecretoElegido) tonoFinal = 3;
  else if (finalTipo == 0 || finalTipo == 2) tonoFinal = 0;
  else if (finalTipo == 1) tonoFinal = 2;
  else tonoFinal = 1;
  ruina = constrain((viralidad - confiabilidad * 0.7 - impacto * 0.5 + culpa * 10 + (50 - relacionSofi) * 0.4 + 30) / 100.0, 0, 1);
  if (tonoFinal == 0) ruina = min(ruina, 0.25);
  if (tonoFinal == 3) ruina = 0;
  statsCongeladas[0] = viralidad;
  statsCongeladas[1] = confiabilidad;
  statsCongeladas[2] = impacto;
  statsCongeladas[3] = relacionSofi;
  bannerTexto = nombreTono[tonoFinal];
  bannerVida = 200;
  avisar("Nova despues de la eleccion", "Tus estadisticas quedaron fijas. Recorre la ciudad: la gente recuerda lo que hiciste.", colorAnim[4 + finalTipo]);
}

// se llama al principio de vigilarEstadisticas: nada puede mover las barras
void congelarEstadisticas() {
  if (!postJuego) return;
  viralidad = statsCongeladas[0];
  confiabilidad = statsCongeladas[1];
  impacto = statsCongeladas[2];
  relacionSofi = statsCongeladas[3];
  prevViral = viralidad;
  prevConf = confiabilidad;
  prevImp = impacto;
}

String textoObjetivoPost() {
  return "Final: " + titulosFinal[finalTipo] + "  -  mira como quedo Nova";
}

// ------------------------------------- QUIEN ESTA EN LA CIUDAD -------------------------------------
// despues del final: las personas de la historia estan en sus lugares... o ya no estan
void actualizarPostJuego() {
  if (!postJuego) return;
  for (int s = 0; s < 9; s++) if (npcSit[s] != null) npcSit[s].ausente = false;
  for (int k = 0; k < 6; k++) if (npcSec[k] != null) npcSec[k].ausente = !secBien[k] && (k == 1 || k == 3);   // Tomas se fue del colegio, Luna no volvio
  // Sofi: en el Parque, salvo si se fue (limbo) o si ya no te habla
  for (int d = 0; d < 3; d++) if (sofiPorDia[d] != null) sofiPorDia[d].ausente = !(d == 2 && verdadFinal != 0 && nivelSofi() > 0);
  if (npcShawn != null) npcShawn.ausente = tonoFinal == 3;   // en el final secreto, Shawn por fin descansa
}

// ------------------------------------- LO QUE DICE LA GENTE -------------------------------------
String[][] gentePost = {
  {"Viste? Esta vez la gente pregunto de donde salian las cosas antes de compartirlas.", "En mi grupo de la cuadra ahora nadie reenvia nada sin fuente. Que alivio.", "Gano quien explico mejor sus propuestas. Asi deberia ser siempre.", "Hasta los memes de Conecta estan amables hoy. Raro, pero bonito."},
  {"Ya votamos. Y todo sigue igual, como siempre.", "Dicen que hubo mucho rumor, pero bueno... ya paso, no?", "Yo vi todo en Conecta y no dije nada. Total, nadie hace nada.", "Mañana sale otro chisme y nos olvidamos de este."},
  {"No me hables. Por gente que comparte sin pensar estamos asi.", "Mi tia dejo de hablarle a media cuadra por un video falso.", "Ya nadie cree en nada. Ni en las noticias, ni en los vecinos.", "Ganó el que mas grito. Felicidades, Nova.", "Tu eres el de las publicaciones, verdad? Mejor me voy."},
  {"Anoche dejamos los celulares en la caja de la plaza. Hablamos hasta tarde.", "Es raro mirar a la gente a los ojos en vez de a una pantalla. Me gusta.", "Shawn... alguien dijo su nombre en voz alta por fin.", "Hoy nadie revisa Conecta cada cinco minutos. Se siente ligero."}
};

String lineaPostPara(Interactivo it) {
  String n = it.nombre;
  int t = tonoFinal;
  if (n.equals("Sofi")) {
    String[] sofi = {
      "",
      "Sofi: Gane... o perdi, ya no importa tanto. Kevin borro su cuenta y nadie dijo nada. Tu crees que fue el?",
      "Sofi: Camila manejaba @chismes_11B. Gracias por juntar las pruebas. Por fin puedo respirar.",
      "Sofi: Lo que te conte en la banca... quedate con eso, si? Todavia me cuesta dormir.",
      "Sofi: Sin celulares la plaza se ve enorme. Gracias por decirlo en voz alta. Me salvaste a mi tambien."
    };
    return sofi[verdadFinal];
  }
  if (n.equals("Kevin")) return t == 2 ? "Kevin: 5.000 seguidores y ninguno me saluda. Esto se puso feo." : (verdadFinal == 1 ? "Kevin: Que? Yo no se nada de ninguna cuenta. (Sonrie un poco de mas.)" : "Kevin: Ya no compro seguidores. Prefiero amigos que existan.");
  if (n.equals("Camila")) return verdadFinal == 2 ? "Camila: ...No tengo nada que decirte. Ya todos saben lo que hice." : "Camila: Mi articulo sobre noticias falsas salio ayer. " + (t == 2 ? "Nadie lo leyo." : "Lo leyo medio colegio.");
  if (n.equals("Andres")) return t == 2 ? "Andres: La foto de Sofi la siguen pasando. Ya ni me sorprende." : "Andres: Despues de todo esto, deje de seguir a @chismes_11B. Y no fui el unico.";
  if (n.equals("Doña Marta")) return t == 2 ? "Doña Marta: El parque nunca lo iban a cerrar, mijo. Pero la pelea entre vecinos si quedo." : "Doña Marta: Ahora antes de creerle a Conecta, le pregunto a la junta. Asi me enseño usted.";
  if (n.equals("Mateo")) return t == 2 ? "Mateo: Todo el barrio sabe lo de Sofi. Y todos saben quien lo conto." : "Mateo: Lo de Sofi no era mio para contarlo. Gracias por frenarme.";
  if (n.equals("Luis")) return t == 0 || t == 3 ? "Luis: El torneo fue de todas las cuadras. El proximo lo hacemos aun mas grande!" : "Luis: El torneo quedo para los de siempre. Que aburrido.";
  if (n.equals("Asesor rival")) return t == 2 ? "Asesor rival: Te dije que se ganaba como fuera. (Sonrie.)" : "Asesor rival: ...Esta bien. Ganar asi no valia la pena.";
  for (int k = 0; k < 6; k++) if (n.equals(nombreSec[k])) return nombreSec[k] + ": " + (secBien[k] ? epilogoBien[k] : epilogoMal[k]);
  if (n.equals("Shawn")) return "Shawn: " + (t == 2 ? "Te dije que pasaria esto. Ahora eres como yo." : "Ya no tienes que quedarte callado. Yo tampoco.");
  String[] pool = gentePost[t];
  return it.nombre + ": " + pool[abs(it.nombre.hashCode()) % pool.length];
}

// al hablar con alguien despues del final (Escenarios.pde -> interactuar)
boolean interactuarPostJuego(Interactivo it) {
  if (!postJuego || it.tipo != 0 && !it.nombre.equals("Shawn")) return false;
  String l = lineaPostPara(it);
  if (l.equals("")) return false;
  abrirCharla(new Charla(it.nombre, new String[] {l}));
  return true;
}

// ------------------------------------- COMO SE VE LA CIUDAD -------------------------------------
float[][] grietas = new float[10][4];
boolean grietasListas = false;

void dibujarCiudadFinal() {
  if (!postJuego || !(esExploracion(scene) || scene == 1)) return;
  noStroke();
  float t = frameCount;
  if (tonoFinal == 0) {   // ciudad que celebra: luz tibia, guirnaldas y papelitos
    fill(255, 210, 120, 22);
    rect(0, 0, width, height);
    for (int i = 0; i <= 20; i++) {
      float gx = i * 40, gy = 6 + sin(i * 0.8) * 4;
      color[] cs = {neonRosa, neonCian, neonAmarillo, neonVerde};
      fill(cs[i % 4], 200);
      triangle(gx, gy, gx + 14, gy, gx + 7, gy + 12);
    }
    if (frameCount % 6 == 0 && !pausaAbierta) {
      color[] cs = {neonRosa, neonCian, neonAmarillo, neonVerde};
      Particula p = new Particula(random(width), -8, random(-0.4, 0.4), random(0.8, 1.4), 300, 6, cs[int(random(4))], 3);
      p.giro = random(-0.08, 0.08);
      agregarParticula(p);
    }
  } else if (tonoFinal == 1) {   // gris: todo apagado, como si nada hubiera pasado
    fill(70, 70, 80, 70 + 60 * ruina);
    rect(0, 0, width, height);
    if (frameCount % 3 == 0 && !pausaAbierta) agregarParticula(new Particula(random(width), random(80, height), random(-0.2, 0.2), random(-0.2, 0.1), random(120, 220), random(14, 26), color(180, 180, 190), 7));
  } else if (tonoFinal == 3) {   // desconectada: calma, estrellas y luz suave
    fill(120, 90, 200, 26);
    rect(0, 0, width, height);
    for (int i = 0; i < 30; i++) {
      fill(255, 240, 200, 120 + 100 * sin(t * 0.05 + i));
      rect(hsh(i * 4.1) * width, 70 + hsh(i * 7.7) * 120, 2, 2);
    }
  }
  if (tonoFinal == 2 || ruina > 0.35) dibujarRuina(tonoFinal == 2 ? max(ruina, 0.45) : (ruina - 0.35) * 1.2);
  // el sello del final arriba
  textFont(fuenteUI);
  textSize(9);
  textAlign(CENTER, CENTER);
  fill(0, 150);
  rect(width / 2 - 95, 486, 190, 14, 7);
  fill(colorAnim[4 + finalTipo]);
  text("FINAL: " + titulosFinal[finalTipo] + "  -  ESTADISTICAS FIJAS", width / 2, 492);
}

// la pantalla se pone peor entre peores fueron tus decisiones (r de 0 a 1)
void dibujarRuina(float r) {
  r = constrain(r, 0, 1);
  noStroke();
  // rojo y desteñido
  fill(60, 0, 10, 50 + 90 * r);
  rect(0, 0, width, height);
  fill(30, 30, 30, 40 * r);
  rect(0, 0, width, height);
  // lluvia
  stroke(170, 170, 200, 60 + 60 * r);
  strokeWeight(1);
  for (int i = 0; i < 40 + 80 * r; i++) {
    float rx = (hsh(i * 2.3) * width + frameCount * 3) % width, ry = (hsh(i * 5.1) * height + frameCount * (9 + 4 * r)) % height;
    line(rx, ry, rx - 3, ry + 10);
  }
  noStroke();
  // estatica
  for (int i = 0; i < 60 + 260 * r; i++) {
    fill(random(120, 255), random(30, 90 * r + 30));
    rect(random(width), random(height), random(1, 4), 1);
  }
  // lineas de television vieja
  fill(0, 30 + 40 * r);
  for (int y2 = (frameCount % 4); y2 < height; y2 += 4) rect(0, y2, width, 1);
  // a veces la imagen se corre (glitch)
  if (random(1) < 0.04 + 0.12 * r) {
    for (int i = 0; i < 1 + int(3 * r); i++) {
      int gy = int(random(height)), gh = int(random(4, 20));
      copy(0, gy, width, gh, int(random(-30, 30) * r), gy, width, gh);
    }
  }
  // grietas en la pantalla (aparecen con mas ruina)
  if (!grietasListas) {
    for (int i = 0; i < grietas.length; i++) {
      grietas[i][0] = random(1) < 0.5 ? random(0, 160) : random(640, 800);
      grietas[i][1] = random(1) < 0.5 ? random(0, 120) : random(380, 500);
      grietas[i][2] = random(TWO_PI);
      grietas[i][3] = random(40, 120);
    }
    grietasListas = true;
  }
  stroke(255, 180 * r);
  strokeWeight(1.5);
  int nGrietas = int(grietas.length * r);
  for (int i = 0; i < nGrietas; i++) {
    float gx = grietas[i][0], gy = grietas[i][1], a = grietas[i][2], l = grietas[i][3];
    float mx = gx + cos(a) * l * 0.5, my = gy + sin(a) * l * 0.5;
    line(gx, gy, mx, my);
    line(mx, my, mx + cos(a + 0.6) * l * 0.5, my + sin(a + 0.6) * l * 0.5);
    line(mx, my, mx + cos(a - 0.5) * l * 0.4, my + sin(a - 0.5) * l * 0.4);
  }
  noStroke();
  // parpadeo a negro cuando la ruina es muy alta
  if (r > 0.7 && frameCount % 180 < 4) {
    fill(0, 200);
    rect(0, 0, width, height);
  }
  // los rumores siguen flotando
  if (frameCount % int(80 - 50 * r) == 0 && !pausaAbierta && esCaminable(scene)) {
    String[] rum = {"@chismes_11B", "COMPARTE YA", "URGENTE!!!", "mentira", "#Escandalo"};
    flotantes.add(new TextoFlotante(rum[int(random(rum.length))], random(80, 720), random(120, 360), neonRojo, 12, 160, true));
  }
}
