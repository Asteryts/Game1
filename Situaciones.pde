// =====================================================================================
//  SITUACIONES.pde -> la historia de Red Quest dentro de Nova (fase 2 de la union)
//   - 9 situaciones (3 por dia). Cada una la cuenta una "persona importante" (con "!")
//     en un lugar de Nova. Te dice "mira tu Conecta" y ahi decides.
//     Solo estas situaciones mueven el reloj: mañana -> mediodia -> tarde -> noche.
//   - Algunas opciones son tan graves que el juego se acaba ahi (escena 73): puedes repetir el dia.
//   - Pruebas: 3 objetos que desbloquean la mejor opcion del miercoles. Se ganan superando
//     la meta de un minijuego (o ayudando a Tomas). Se ven en la app "Pruebas" del celular.
//   - 6 personajes secundarios (solo en la mañana o en la noche): una decision corta y una insignia.
// =====================================================================================

final int ESC_FIN_GRAVE = 73;

// ------------------------------------- LAS 9 SITUACIONES -------------------------------------
String[] mensajeroSit = {"Andres", "Sofi", "Kevin", "Doña Marta", "Mateo", "Luis", "Camila", "Asesor rival", "Sofi"};
int[] lugarSit = {57, 58, 45, 54, 56, 55, 59, 53, 45};   // pasillo, salon, parque, mercado, callejon, cancha, biblioteca, paseo, parque
String[] nombreLugarSit = {"el pasillo del colegio", "el salon 10B", "el Parque Central", "el Mercado", "el Callejon de los murales", "la Cancha", "la Biblioteca del colegio", "el Paseo de Campaña", "el Parque Central"};
String[] avisoSit = {
  "Ya viste la foto que subieron de Sofi? Mira tu Conecta.",
  "Subi mi idea de la feria de reciclaje... pero mira los comentarios.",
  "Te escribi por Conecta. Revisa, es una oferta buenisima.",
  "Dicen en Conecta que van a cerrar el parque! Mira, mira.",
  "Te mande un mensaje privado. Es sobre Sofi.",
  "Ya publique el torneo en Conecta. Miralo!",
  "Se esta volviendo viral un video de Sofi. Miralo en Conecta.",
  "Revisa tu Conecta. Te tengo una propuesta.",
  "Me ayudas con la jornada de inscripcion para votar? La publique en Conecta."
};
String[] autorSit = {"@chismes_11B", "@feria_colegio", "@kevin_popular", "@noticias_del_barrio", "@mateo_cuadra7", "@torneo_cancha", "@la_verdad_joven", "@campaña_rival", "@sofi_candidata"};
String[] publicacionSit = {
  "JAJAJA miren a Sofi dormida en clase de quimica. Ni se dio cuenta de que le tome la foto.",
  "Sofi propuso una feria de reciclaje. Comentarios: \"que idea tan aburrida\", \"nadie va a ir\".",
  "(Mensaje privado) Pasame tu contraseña de Conecta y te consigo 5.000 seguidores.",
  "URGENTE!!! Van a cerrar el parque de la cuadra 5. Compartan antes de que lo borren!!!",
  "(Mensaje privado) Que le pasa a Sofi? La vi llorando. Cuentame, no le digo a nadie.",
  "Torneo el sabado en la cancha. Solo los de la cuadra 3, los de la cuadra 8 NO.",
  "MIREN: video de Sofi diciendo que los jovenes del sur son \"unos vagos\". (el video esta editado)",
  "(Mensaje privado) Te pagamos si creas cuentas falsas y comentas cosas malas de Sofi.",
  "Me ayudan a mover en Conecta una jornada para que los jovenes se inscriban a votar?"
};
String[][] opcionSit = {
  {"Compartirla, es solo un chiste.", "Reportar la foto y avisarle a Sofi.", "No hacer nada.", ""},
  {"Insultar a los que se burlan.", "Reirme para no quedar mal.", "Defender la idea con respeto.", ""},
  {"Negarme y proteger mi cuenta.", "Darle una contraseña vieja.", "Darsela, es mi amigo.", ""},
  {"Compartirlo ya.", "Hacer un meme del rumor.", "Verificar la fuente antes de publicar.", ""},
  {"Contarle todo.", "Decir que no me corresponde contarlo.", "Dar pistas con una carita triste.", ""},
  {"Crear un grupo solo para \"los de siempre\".", "Ir sin decir nada.", "Proponer abrir el torneo a todo el barrio.", ""},
  {"Compartirlo con \"sera cierto?\".", "No hacer nada.", "Buscar el original y reportar el montaje.", "Mostrar la captura del chat de @chismes_11B: ellos editaron el video."},
  {"Rechazarlo y reportarlo.", "Aceptar, pero solo una cuenta.", "Aceptar el trato completo.", "Rechazarlo y entregar el volante como prueba a los organizadores."},
  {"Solo darle \"me gusta\".", "Crear la campaña #ConectaTuVoz.", "Decir que quien no vote es un ignorante.", "Crear #ConectaTuVoz con los datos oficiales de inscripcion."}
};
int[][] puntosSit = {
  {-14, 14, -4, 0}, {-6, -10, 13, 0}, {11, -5, -13, 0}, {-12, -7, 13, 0}, {-14, 12, -6, 0},
  {-11, -4, 12, 0}, {-14, -5, 15, 18}, {13, -8, -15, 16}, {-3, 15, -9, 18}
};
int[][] relacionSit = {
  {-20, 15, -6, 0}, {3, -15, 12, 0}, {0, 0, -10, 0}, {0, 0, 3, 0}, {-25, 16, -10, 0},
  {-3, 0, 5, 0}, {-20, -8, 15, 18}, {8, -8, -15, 10}, {-6, 12, -4, 14}
};
String[][] consecuenciaSit = {
  {"La foto llego a 300 personas. Sofi se siente traicionada.", "Conecta retiro la foto. Sofi te agradecio por avisarle.", "La foto siguio circulando. No ayudaste.", ""},
  {"La discusion se volvio una pelea de insultos.", "Mas gente se burlo y Sofi retiro su propuesta.", "Veinte compañeros apoyaron la feria. Sofi la va a liderar.", ""},
  {"Tu cuenta quedo protegida.", "Alguien entro a tu cuenta y dio \"me gusta\" a publicaciones ofensivas.", "Desde tu cuenta se burlaron de Sofi. Ella cree que fuiste tu.", ""},
  {"El rumor era falso y causo peleas entre vecinos.", "Tu meme hizo que la mentira llegara mas lejos.", "Era falso. Publicaste la aclaracion y el rumor se detuvo.", ""},
  {"Medio barrio supo la historia. Sofi no te habla.", "Cuidaste la privacidad de Sofi y ella te lo agradecio.", "Tus pistas alimentaron el chisme.", ""},
  {"El barrio quedo dividido.", "La publicacion ofensiva quedo ahi. Callar tambien es aceptar.", "El torneo reunio a jovenes de todas las cuadras.", ""},
  {"El montaje gano credibilidad y Sofi recibio insultos.", "El video siguio circulando sin que nadie lo desmintiera.", "El montaje fue eliminado y miles vieron la verdad.",
    "La captura del lunes probo que el video se hizo en el colegio. Conecta lo borro y Sofi recupero su campaña."},
  {"La campaña rival fue sancionada. La eleccion fue justa.", "Conecta detecto la cuenta falsa y la conecto contigo.", "Las cuentas falsas llenaron de odio los comentarios de Sofi.",
    "Con el volante como prueba, los organizadores sancionaron a la campaña rival de inmediato."},
  {"Un \"me gusta\" no movio a nadie.", "Cientos de jovenes se inscribieron a votar.", "Tu publicacion ofendio a muchos y le quito apoyo a la jornada.",
    "Con datos oficiales nadie dudo de la campaña. Mas de mil jovenes se inscribieron."}
};
int[] opcionGrave = {-1, -1, 2, -1, 0, -1, -1, 2, -1};
String[] tituloGrave = {"", "", "TE ROBARON LA CUENTA", "", "SOFI YA NO CONFIA EN TI", "", "", "CONECTA SUSPENDIO TU CUENTA", ""};
String[] pistaGrave = {
  "", "", "Nunca compartas tu contraseña, ni con amigos. Activa la verificacion en dos pasos.", "",
  "Un secreto de Sofi no es tuyo para contarlo. Preguntale a ella si necesita ayuda.", "", "",
  "Las cuentas falsas son un engaño. Si te ofrecen algo asi, guarda la prueba y denuncialo.", ""
};
int[] pruebaNecesaria = {-1, -1, -1, -1, -1, -1, 0, 1, 2};
// las opciones que son "compartir" pasan por la pausa de antes de compartir: {situacion, opcion}
int[][] opcionesQueComparten = {{0, 0}, {3, 0}, {3, 1}, {6, 0}};
String[][] revisionSit = {   // {quien, cuando, pruebas} (todas con señales de bulo)
  {"@chismes_11B: cuenta anonima", "Hoy, en clase, sin permiso de Sofi", "Ninguna: es una burla, no una noticia"},
  {}, {},
  {"@noticias_del_barrio: cuenta creada hace 2 dias", "Sin fecha ni comunicado oficial", "Ninguna: solo \"compartan antes de que lo borren\""},
  {}, {},
  {"@la_verdad_joven: cuenta nueva", "Sin fecha. Nadie sabe de cuando es", "9 segundos cortados; el video original no aparece"},
  {}, {}
};

boolean[] sitResuelta = new boolean[9];
int[] sitElegida = {-1, -1, -1, -1, -1, -1, -1, -1, -1};
int situacionesHoy = 0;   // cuantas ya se resolvieron hoy (0..3)

// ------------------------------------- PRUEBAS -------------------------------------
String[] nombrePrueba = {"Captura de pantalla", "Volante rival", "Guia de inscripcion"};
String[] descPrueba = {
  "Una captura del chat de @chismes_11B: van a editar videos de Sofi. Camila sale entre los contactos frecuentes.",
  "Un volante de la campaña rival. Atras, a mano: \"K. ya entrego lo del lunes. Pago el viernes\".",
  "La guia oficial para votar. Entre las hojas hay un borrador de @chismes_11B... con la letra de Sofi."
};
int[] juegoPrueba = {6, 2, 3};   // Foto Trucada, Caza Bots, Rastreo de Fuentes
boolean[] tienePrueba = new boolean[3];

void darPrueba(int k, String como) {
  if (k < 0 || k >= tienePrueba.length || tienePrueba[k]) return;
  tienePrueba[k] = true;
  avisar("Nueva prueba: " + nombrePrueba[k], como + " Mirala en la app Pruebas del celular.", #46DC64);
  sonar(4);
}

// se llama al terminar un minijuego (Minijuegos.pde)
void revisarPruebaPorJuego(int idx) {
  for (int k = 0; k < juegoPrueba.length; k++) {
    if (juegoPrueba[k] == idx && puntaje >= umbralPremio[idx]) darPrueba(k, "Superaste la meta de " + nombresJuegos[idx] + ".");
  }
}

// ------------------------------------- PERSONAJES SECUNDARIOS -------------------------------------
String[] nombreSec = {"Conserje Ruben", "Tomas", "Don Ernesto", "Valentina", "Daniel", "Profe Lucia"};
int[] diaSec = {0, 0, 1, 1, 2, 2};
int[] momentoSec = {0, 3, 0, 3, 0, 3};   // 0 = solo en la mañana, 3 = solo en la noche
int[] lugarSec = {60, 53, 54, 55, 52, 53};   // cafeteria, paseo, mercado, cancha, avenida, paseo
String[] nombreLugarSec = {"la Cafeteria del colegio", "el Paseo de Campaña", "el Mercado", "la Cancha", "la Avenida Central", "el Paseo de Campaña"};
String[] textoSec = {
  "El piso esta mojado y todos pasan corriendo para grabarse resbalando. Me ayudas a poner los conos?",
  "Soy nuevo en el colegio. No me agregaron al grupo del salon en Conecta... y vi que hablan de mi.",
  "Mijo, me llego un mensaje: 'Ganaste un celular! Envia tus datos'. Lo respondo?",
  "Se me perdio mi perrita, Luna. Me ayudas a compartir su foto en Conecta?",
  "Hola! Estoy grabando un video para mi canal. Te puedo grabar y subirlo sin avisarle a nadie?",
  "Han sido dias intensos con la eleccion. Que aprendiste de Conecta estos tres dias?"
};
String[] opcionSecA = {"Ayudarle con los conos.", "Agregarlo y defenderlo.", "Decirle que es una estafa.", "Compartir la foto de Luna.", "Pedirle que no grabe sin permiso.", "Que pensar antes de publicar importa."};
String[] opcionSecB = {"Seguir de largo.", "Ignorarlo.", "Decirle que lo responda.", "No tengo tiempo.", "Dejar que grabe.", "Nada, es solo una app."};
String[] respuestaSecA = {
  "Gracias! Eres el primero que me ayuda en todo el año.",
  "Gracias... nadie habia hecho eso por mi. Ah, mira lo que encontre en ese chat, te puede servir.",
  "Uy! Casi les mando mis datos. Gracias, mijo.",
  "Gracias! Ya varios vecinos estan buscando a Luna.",
  "Tienes razon. No subo nada sin permiso.",
  "Esa es la mejor respuesta que he escuchado hoy."
};
String[] respuestaSecB = {"...Ya veo. Como siempre.", "Ah... esta bien.", "Bueno, ya lo respondo entonces.", "Ah, bueno... entiendo.", "Genial! Ya lo subi.", "Mmm... ojala lo pienses mejor."};
String[] insignia = {"Ayudante", "Bienvenida", "Antiestafas", "Buen vecino", "Privacidad", "Reflexion"};
int[] pruebaDeSec = {-1, 0, -1, -1, -1, -1};   // Tomas te da la captura de pantalla
boolean[] secHecho = new boolean[6];
boolean[] secBien = new boolean[6];
Interactivo[] npcSec = new Interactivo[6];
Charla[] charlaSec = new Charla[6];

// ------------------------------------- PREPARAR -------------------------------------
Interactivo[] npcSit = new Interactivo[9];

void prepararHistoria() {
  // las personas importantes nuevas (Kevin y Sofi ya existen en Nova)
  String[][] frase = {
    {"Andres: Hoy todo el mundo esta pegado a Conecta. Alguien ha dejado de seguir a @chismes_11B? Nadie."},
    {}, {},
    {"Doña Marta: En este barrio todo se sabe por Conecta, mijo."},
    {"Mateo: Sofi estaba rara ayer... tu sabes algo?"},
    {"Luis: El sabado hay torneo. Juegas?"},
    {"Camila: Estoy escribiendo un articulo sobre noticias falsas. Se mas de @chismes_11B de lo que crees."},
    {"Asesor rival: Mi candidato tiene que ganar como sea."},
    {}
  };
  color[] ropa = {#3A7BD5, 0, 0, #7D4E9E, #2E8B57, #D9534F, #20A39E, #2F2F3A, 0};
  color[] pelo = {#1E1E1E, 0, 0, #BFBFBF, #2B1B10, #6B3E1E, #A0522D, #333333, 0};
  float[][] pos = {{430, 300}, {0, 0}, {0, 0}, {130, 440}, {330, 420}, {230, 420}, {480, 430}, {530, 450}, {0, 0}};
  for (int s = 0; s < 9; s++) {
    npcSit[s] = null;
    if (frase[s].length == 0) continue;
    Interactivo it = persona(pos[s][0], pos[s][1], mensajeroSit[s], ropa[s], pelo[s], new Charla(mensajeroSit[s], frase[s]));
    npcSit[s] = it;
    Lugar L = lugares.get(lugarSit[s]);
    if (L != null) L.agregar(it);
  }
  // los secundarios nuevos (Tomas y Valentina ya existen en Nova)
  color[] ropaS = {#5B7F95, 0, #8B6F47, 0, #7FDBDA, #4F7942};
  color[] peloS = {#7A7A7A, 0, #E0E0E0, 0, #C46A2B, #6B3E1E};
  float[][] posS = {{430, 300}, {0, 0}, {680, 440}, {0, 0}, {300, 300}, {450, 165}};
  for (int k = 0; k < 6; k++) {
    charlaSec[k] = new Charla(nombreSec[k], new String[] {nombreSec[k] + ": " + textoSec[k]})
      .con(new String[] {opcionSecA[k], opcionSecB[k]}, new float[][] {{0, 3, 4}, {k == 4 ? 4 : 1, -2, -3}},
      new String[] {nombreSec[k] + ": " + respuestaSecA[k], nombreSec[k] + ": " + respuestaSecB[k]}, null);
    npcSec[k] = null;
    if (k == 1 || k == 3) continue;
    Interactivo it = persona(posS[k][0], posS[k][1], nombreSec[k], ropaS[k], peloS[k], new Charla(nombreSec[k], new String[] {nombreSec[k] + ": Hola."}));
    npcSec[k] = it;
    Lugar L = lugares.get(lugarSec[k]);
    if (L != null) L.agregar(it);
  }
  actualizarHistoria();
}

void reiniciarHistoria() {
  for (int s = 0; s < 9; s++) {
    sitResuelta[s] = false;
    sitElegida[s] = -1;
  }
  for (int k = 0; k < 6; k++) {
    secHecho[k] = false;
    secBien[k] = false;
  }
  for (int k = 0; k < 3; k++) tienePrueba[k] = false;
  situacionesHoy = 0;
  sitAbierta = -1;
}

// quien esta y quien no, segun el dia y el momento
void actualizarHistoria() {
  for (int s = 0; s < 9; s++) if (npcSit[s] != null) npcSit[s].ausente = s / 3 != dia;
  for (int k = 0; k < 6; k++) if (npcSec[k] != null) npcSec[k].ausente = !secDisponible(k) && !(secHecho[k] && diaSec[k] == dia);
}

int situacionActual() {
  if (dia >= 3 || situacionesHoy >= 3) return -1;
  return dia * 3 + situacionesHoy;
}

boolean secDisponible(int k) {
  return diaSec[k] == dia && momento == momentoSec[k] && !secHecho[k];
}

// el "!" encima de quien tiene algo importante para ti
boolean tieneAlgoImportante(Interactivo it) {
  int s = situacionActual();
  if (s >= 0 && it.nombre.equals(mensajeroSit[s]) && scene == lugarSit[s]) return true;
  for (int k = 0; k < 6; k++) if (secDisponible(k) && it.nombre.equals(nombreSec[k]) && scene == lugarSec[k]) return true;
  return false;
}

// se llama al hablar con alguien (Escenarios.pde). Devuelve true si era parte de la historia
boolean interactuarHistoria(Interactivo it) {
  int s = situacionActual();
  if (s >= 0 && it.nombre.equals(mensajeroSit[s]) && scene == lugarSit[s]) {
    abrirSituacion(s);
    return true;
  }
  for (int k = 0; k < 6; k++) {
    if (secDisponible(k) && it.nombre.equals(nombreSec[k]) && scene == lugarSec[k]) {
      Charla c = charlaSec[k];
      c.terminada = false;
      abrirCharla(c);
      return true;
    }
  }
  return false;
}

// cuando eliges en la charla de un secundario (Escenarios.pde -> aplicarEleccionCharla)
void alElegirCharlaHistoria(Charla c, int i) {
  for (int k = 0; k < 6; k++) {
    if (c != charlaSec[k]) continue;
    if (k == 3 && i == 0) reaccionSpriteNova("Luna");
    secHecho[k] = true;
    secBien[k] = i == 0;
    if (i != 0) sumarCulpa();   // (Ruta.pde)
    if (i == 0) {
      avisar("Insignia: " + insignia[k], nombreSec[k] + " no lo va a olvidar.", #46DC64);
      if (pruebaDeSec[k] >= 0) darPrueba(pruebaDeSec[k], nombreSec[k] + " te la mando.");
    }
  }
}

// ------------------------------------- CONECTA: LA SITUACION ABIERTA -------------------------------------
int sitAbierta = -1;
int estadoSit = 0;        // 0 te avisan, 1 la publicacion y las opciones, 2 lo que paso
int opcionTomada = -1;
float letrasSit = 0;
float[] cambiosSit = new float[4];   // viralidad, confiabilidad, impacto, Sofi

void abrirSituacion(int s) {
  sitAbierta = s;
  estadoSit = 0;
  opcionTomada = -1;
  letrasSit = 0;
  pararMovimiento();
  sonar(3);
}

boolean situacionAbierta() {
  return sitAbierta >= 0;
}

int opcionesVisibles(int s) {
  if (s == 8 && finalSecretoDisponible()) return 5;   // la opcion secreta (Ruta.pde)
  return opcionSit[s][3].equals("") ? 3 : 4;
}

boolean opcionBloqueada(int s, int o) {
  return o == 3 && pruebaNecesaria[s] >= 0 && !tienePrueba[pruebaNecesaria[s]];
}

boolean comparteOpcion(int s, int o) {
  for (int[] c : opcionesQueComparten) if (c[0] == s && c[1] == o) return true;
  return false;
}

void elegirOpcionSit(final int o) {
  final int s = sitAbierta;
  if (s < 0 || estadoSit != 1 || o < 0 || o >= opcionesVisibles(s) || opcionBloqueada(s, o)) return;
  if (comparteOpcion(s, o)) {
    String[] r = revisionSit[s];
    pedirRevision(autorSit[s] + s, publicacionSit[s], r[0], false, r[1], false, r[2], false, new Accion() {
      public void hacer() {
        aplicarOpcionSit(s, o);
      }
    }
    );
    return;
  }
  aplicarOpcionSit(s, o);
}

void aplicarOpcionSit(int s, int o) {
  float pts = puntosDe(s, o);
  if (pts <= 0) sumarCulpa();   // (Ruta.pde)
  if (o == 4) finalSecretoElegido = true;
  float v0 = viralidad, c0 = confiabilidad, i0 = impacto;
  if (pts >= 0) {
    confiabilidad += pts * 0.6;
    impacto += pts * 0.5;
  } else {
    viralidad += -pts * 0.6;
    confiabilidad += pts * 0.3;
  }
  viralidad = constrain(viralidad, 0, 100);
  confiabilidad = constrain(confiabilidad, 0, 100);
  impacto = constrain(impacto, 0, 100);
  cambiosSit[0] = viralidad - v0;
  cambiosSit[1] = confiabilidad - c0;
  cambiosSit[2] = impacto - i0;
  cambiosSit[3] = relacionDe(s, o) * 0.8;
  cambiarRelacionSofi(cambiosSit[3]);
  ultimaFueDeSofi = true;   // ya se cambio la relacion: que no se cuente doble
  sitElegida[s] = o;
  opcionTomada = o;
  estadoSit = 2;
  letrasSit = 0;
  anotarDecision(autorSit[s], textoOpcionSit(s, o), pts > 0, comparteOpcion(s, o) && pts < 0, consecuenciaDe(s, o));
}

// despues de ver lo que paso
void cerrarSituacion() {
  int s = sitAbierta;
  sitAbierta = -1;
  if (s < 0) return;
  if (opcionGrave[s] == sitElegida[s]) {
    irAFinGrave(s);
    return;
  }
  sitResuelta[s] = true;
  situacionesHoy++;
  avanzarMomentoHistoria();
}

void avanzarMomentoHistoria() {
  if (momento >= 3) return;
  momento++;
  relojJuego = max(relojJuego, horaMomento[momento]);
  bannerTexto = nombreDia[dia] + "  -  " + nombreMomento[momento];
  bannerVida = 170;
  sonar(2);
  if (momento == 3 && !avisoNoche) {
    avisoNoche = true;
    avisar("Ya es de noche", "Cuando quieras, vuelve a casa y duerme en tu cama para pasar al " + nombreDia[dia + 1] + ".", neonMorado);
  }
}

String textoObjetivo() {
  if (postJuego) return textoObjetivoPost();   // (PostJuego.pde)
  if (dia >= 3) return "Ve a la Plaza de la Votacion";
  int s = situacionActual();
  if (s >= 0) return "Habla con " + mensajeroSit[s] + " en " + nombreLugarSit[s];
  for (int k = 0; k < 6; k++) if (secDisponible(k)) return nombreSec[k] + " te busca en " + nombreLugarSec[k];
  return "Ya es de noche: vuelve a casa a dormir";
}

// ------------------------------------- DIBUJO -------------------------------------
void dibujarSituacion() {
  if (sitAbierta < 0) return;
  int s = sitAbierta;
  if (!pausaAbierta && revisionActiva == null) letrasSit += 1.6;
  noStroke();
  if (estadoSit == 0) {
    // te avisan en persona
    fill(0, 100);
    rect(0, 0, width, height);
    float bx = 30, by = 350, bw = 740, bh = 135;
    fill(8, 6, 22, 238);
    rect(bx, by, bw, bh, 14);
    stroke(neonRosa, 200);
    strokeWeight(2);
    noFill();
    rect(bx, by, bw, bh, 14);
    noStroke();
    fill(neonRosa);
    rect(bx + 20, by - 16, 170, 32, 10);
    fill(20);
    textFont(fuenteUI);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(mensajeroSit[s], bx + 105, by - 1);
    String t = avisoSit[s];
    int n = min(int(letrasSit), t.length());
    if (n < t.length()) sonarVoz(mensajeroSit[s]);
    fill(240);
    textSize(17);
    textAlign(LEFT, TOP);
    text(t.substring(0, n), bx + 26, by + 28, bw - 52, 70);
    if (n >= t.length()) {
      botonNeon("Abrir Conecta  >", bx + bw - 220, by + bh - 50, 196, 38, neonRosa, frameCount % 50 < 25);
    }
    return;
  }
  // el celular con Conecta
  fill(0, 150);
  rect(0, 0, width, height);
  float px = 200, py = 14, pw = 400, ph = 472;
  fill(18, 16, 28);
  rect(px, py, pw, ph, 30);
  stroke(80, 80, 110);
  strokeWeight(2);
  noFill();
  rect(px + 2, py + 2, pw - 4, ph - 4, 28);
  noStroke();
  float sx = px + 12, sy = py + 12, sw = pw - 24, sh = ph - 24;
  fill(14, 10, 30);
  rect(sx, sy, sw, sh, 22);
  fill(neonRosa);
  rect(sx, sy, sw, 40, 22, 22, 0, 0);
  fill(255);
  textFont(fuenteUI);
  textSize(17);
  textAlign(CENTER, CENTER);
  text("Conecta", sx + sw / 2, sy + 20);
  // la publicacion
  float cy = sy + 52;
  fill(30, 26, 52);
  rect(sx + 10, cy, sw - 20, 120, 12);
  fill(neonRosa);
  ellipse(sx + 32, cy + 22, 26, 26);
  fill(255);
  textSize(13);
  textAlign(LEFT, CENTER);
  text(autorSit[s], sx + 52, cy + 22);
  textSize(10);
  fill(160);
  text(textoHora(), sx + sw - 70, cy + 22);
  fill(235);
  textSize(13);
  textAlign(LEFT, TOP);
  text(publicacionSit[s], sx + 22, cy + 42, sw - 44, 60);
  fill(170);
  textSize(10);
  text("<3 " + (120 + s * 37) + "     comentarios " + (18 + s * 11) + "     compartido " + (40 + s * 23), sx + 22, cy + 100);
  if (estadoSit == 1) {
    fill(200);
    textSize(13);
    textAlign(LEFT, CENTER);
    text("Que haces?", sx + 14, cy + 140);
    for (int o = 0; o < opcionesVisibles(s); o++) {
      float paso = opcionesVisibles(s) > 4 ? 50 : 60, altoO = opcionesVisibles(s) > 4 ? 44 : 52;
      float oy = cy + 156 + o * paso;
      boolean bloq = opcionBloqueada(s, o);
      boolean enc = !bloq && encima(sx + 10, oy, sw - 20, altoO) && revisionActiva == null;
      color c = o == 4 ? #B4A0FF : (o == 3 ? #46DC64 : neonCian);
      fill(enc ? color(red(c) * 0.25, green(c) * 0.25, blue(c) * 0.25) : color(24, 20, 44));
      stroke(bloq ? color(90) : c, enc ? 255 : 140);
      strokeWeight(enc ? 2.5 : 1.5);
      rect(sx + 10, oy, sw - 20, altoO, 10);
      noStroke();
      fill(bloq ? color(110) : c);
      textSize(13);
      textAlign(CENTER, CENTER);
      text(str(o + 1), sx + 28, oy + altoO / 2);
      fill(bloq ? color(130) : color(240));
      textAlign(LEFT, CENTER);
      textSize(12);
      if (bloq) {
        int p = pruebaNecesaria[s];
        text("[Bloqueada] Necesitas: " + nombrePrueba[p] + ". Se gana superando la meta de " + nombresJuegos[juegoPrueba[p]] + ".", sx + 44, oy + 6, sw - 66, 42);
      } else text(textoOpcionSit(s, o), sx + 44, oy + 4, sw - 66, altoO - 6);
    }
    return;
  }
  // estadoSit == 2: lo que paso
  int o = opcionTomada;
  boolean grave = opcionGrave[s] == o;
  boolean buena = puntosDe(s, o) > 0;
  color c = grave ? neonRojo : (buena ? neonVerde : neonRosa);
  fill(c, 40);
  rect(sx + 10, cy + 134, sw - 20, 170, 12);
  fill(c);
  textSize(12);
  textAlign(LEFT, TOP);
  text("Elegiste: " + textoOpcionSit(s, o), sx + 24, cy + 144, sw - 48, 34);
  String t = consecuenciaDe(s, o);
  int n = min(int(letrasSit), t.length());
  fill(245);
  textSize(15);
  text(t.substring(0, n), sx + 24, cy + 182, sw - 48, 80);
  // cambios
  String[] lab = {"Viralidad", "Confiabilidad", "Impacto", "Sofi"};
  color[] cols = {neonRosa, neonCian, neonAmarillo, colorSofi};
  float xx = sx + 24;
  textSize(11);
  for (int k = 0; k < 4; k++) {
    if (abs(cambiosSit[k]) < 0.5) continue;
    String e = lab[k] + " " + (cambiosSit[k] > 0 ? "+" : "") + int(cambiosSit[k]);
    fill(cols[k]);
    text(e, xx, cy + 276);
    xx += textWidth(e) + 14;
  }
  if (n >= t.length()) botonNeon(grave ? "Continuar..." : "Continuar  >", sx + sw / 2 - 90, sy + sh - 62, 180, 44, grave ? neonRojo : neonCian, frameCount % 50 < 25);
}

boolean clickSituacion() {
  if (sitAbierta < 0) return false;
  if (estadoSit == 0) {
    if (letrasSit < avisoSit[sitAbierta].length()) letrasSit = 999;
    else {
      estadoSit = 1;
      sonar(3);
    }
    return true;
  }
  float px = 200, py = 14, pw = 400, ph = 472;
  float sx = px + 12, sy = py + 12, sw = pw - 24, sh = ph - 24;
  float cy = sy + 52;
  if (estadoSit == 1) {
    int nv = opcionesVisibles(sitAbierta);
    for (int o = 0; o < nv; o++) if (encima(sx + 10, cy + 156 + o * (nv > 4 ? 50 : 60), sw - 20, nv > 4 ? 44 : 52)) elegirOpcionSit(o);
    return true;
  }
  if (letrasSit < consecuenciaDe(sitAbierta, opcionTomada).length()) letrasSit = 999;
  else if (encima(sx + sw / 2 - 90, sy + sh - 62, 180, 44)) cerrarSituacion();
  return true;
}

boolean teclaSituacion() {
  if (sitAbierta < 0) return false;
  if (key == ESC) key = 0;
  boolean enter = key == ENTER || key == RETURN || key == ' ' || key == 'e' || key == 'E';
  if (estadoSit == 0 && enter) {
    if (letrasSit < avisoSit[sitAbierta].length()) letrasSit = 999;
    else estadoSit = 1;
  } else if (estadoSit == 1 && key >= '1' && key <= '5') elegirOpcionSit(key - '1');
  else if (estadoSit == 2 && enter) {
    if (letrasSit < consecuenciaDe(sitAbierta, opcionTomada).length()) letrasSit = 999;
    else cerrarSituacion();
  }
  return true;
}

// ------------------------------------- FINAL GRAVE (escena 73) -------------------------------------
int sitGrave = -1;
float tGrave = 0;
int diasRepetidos = 0;

void irAFinGrave(int s) {
  sitGrave = s;
  tGrave = 0;
  pararMovimiento();
  cerrarCharla();
  empezarAnimFinal(s == 2 ? 0 : (s == 4 ? 1 : 2), ESC_FIN_GRAVE);   // primero su animacion (Finales.pde)
  sonar(9);
}

void dibujarFinGrave() {
  if (!pausaAbierta) tGrave++;
  background(12, 4, 8);
  noStroke();
  // estatica de pantalla rota
  for (int i = 0; i < 160; i++) {
    fill(random(40, 90), random(10, 30), random(20, 40), 120);
    rect(random(width), random(height), random(2, 30), 2);
  }
  stroke(neonRojo, 60);
  strokeWeight(2);
  line(120, 40, 380, 260);
  line(380, 260, 300, 470);
  line(380, 260, 700, 330);
  noStroke();
  int s = sitGrave;
  float a = constrain(tGrave / 30.0, 0, 1);
  tituloNeon("FIN", width / 2, 70, 30, color(200, 200 * a));
  tituloNeon(tituloGrave[s], width / 2, 120, 36, neonRojo);
  panelNeon(130, 170, 540, 200, neonRojo);
  textFont(fuenteUI);
  textAlign(CENTER, TOP);
  textSize(15);
  fill(240);
  text(consecuenciaSit[s][sitElegida[s]], 160, 190, 480, 60);
  fill(neonAmarillo);
  textSize(13);
  text("CONSEJO", width / 2, 258);
  fill(230);
  textSize(14);
  text(pistaGrave[s], 160, 280, 480, 60);
  fill(170);
  textSize(11);
  text("Si algo asi te pasa a ti o a alguien, habla con un adulto de confianza.", 160, 340, 480, 30);
  if (tGrave > 60) {
    botonNeon("Repetir el " + nombreDia[dia], 170, 400, 220, 48, neonCian, frameCount % 60 < 30);
    botonNeon("Menu principal", 410, 400, 220, 48, neonRosa, false);
  }
}

void clickFinGrave() {
  if (tGrave <= 60) return;
  if (encima(170, 400, 220, 48)) repetirDia();
  else if (encima(410, 400, 220, 48)) {
    repetirDia();
    scene = 0;
  }
}

// vuelve todo a como estaba al empezar el dia
void repetirDia() {
  diasRepetidos++;
  viralidad = inicioV;
  confiabilidad = inicioC;
  impacto = inicioI;
  relacionSofi = inicioS;
  culpa = inicioCulpa;
  monedas = inicioMonedas;
  monedasVista = monedas;
  prevViral = viralidad;
  prevConf = confiabilidad;
  prevImp = impacto;
  hudV = viralidad;
  hudC = confiabilidad;
  hudI = impacto;
  hudS = relacionSofi;
  momento = 0;
  decisionesMomento = 0;
  avisoNoche = false;
  relojJuego = horaMomento[0] + 30;
  situacionesHoy = 0;
  for (int s = dia * 3; s < dia * 3 + 3; s++) {
    sitResuelta[s] = false;
    sitElegida[s] = -1;
  }
  for (int k = 0; k < 6; k++) if (diaSec[k] == dia) {
    secHecho[k] = false;
    secBien[k] = false;
  }
  if (dia < 3 && sofiPorDia[dia] != null) {
    sofiPorDia[dia].charla.terminada = false;
    sofiPorDia[dia].hablado = false;
  }
  scene = 1;
  bannerTexto = nombreDia[dia] + "  -  otra vez";
  bannerVida = 170;
}

void teclaFinGrave() {
  if ((key == ENTER || key == RETURN) && tGrave > 60) repetirDia();
}

// ------------------------------------- APP "PRUEBAS" DEL CELULAR -------------------------------------
void appPruebas(float sx, float cy, float sw, float ch) {
  cabeceraApp("Pruebas", #46DC64, sx, cy, sw);
  textFont(fuenteUI);
  for (int k = 0; k < 3; k++) {
    float by = cy + 40 + k * 84;
    boolean t = tienePrueba[k];
    fill(t ? color(24, 50, 40) : color(26, 22, 44), 240);
    rect(sx + 10, by, sw - 20, 78, 10);
    fill(t ? #46DC64 : color(110));
    rect(sx + 10, by, 6, 78, 10, 0, 0, 10);
    textAlign(LEFT, TOP);
    textSize(12);
    fill(t ? 255 : color(170));
    text((t ? "" : "??? ") + nombrePrueba[k], sx + 24, by + 5);
    textSize(9);
    fill(t ? color(215) : color(150));
    String d = t ? descPrueba[k] : "Supera la meta de " + nombresJuegos[juegoPrueba[k]] + (k == 0 ? " o ayuda a alguien nuevo en el colegio." : ".") + " Sirve para el miercoles.";
    text(d, sx + 24, by + 22, sw - 46, 54);
  }
  float iy = cy + 40 + 3 * 84 + 4;
  textAlign(LEFT, TOP);
  textSize(11);
  fill(200);
  text("Insignias", sx + 14, iy);
  for (int k = 0; k < 6; k++) {
    float ix = sx + 30 + (k % 3) * 78, iyy = iy + 30 + (k / 3) * 34;
    boolean t = secBien[k];
    fill(t ? #46DC64 : color(50, 46, 70));
    ellipse(ix, iyy, 18, 18);
    fill(t ? 235 : color(110));
    textSize(9);
    textAlign(LEFT, CENTER);
    text(t ? insignia[k] : "???", ix + 12, iyy);
  }
}
