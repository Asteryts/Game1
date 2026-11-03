//Hola, no se les ocurra borrar mis comentarios
//aqui se definen los colores, perdon por el desorden mas abajo
//por cierto elimine la escena de santiago porque me confundia pero cuando mezclen el codigo pues ponen todas obviamente
//GENTE DESCUBRI COMO ORGANIZARLO AUTOMATICAMENTE, ES CON CTRL+T

/* =====================================================================================
   CODIGO UNIFICADO (Alcaldia + Barrio + Colegio)
   MAPA DE ESCENAS (los numeros marcados con * fueron cambiados para evitar choques):

   0  menu                      1  mapa                       2  creditos
   3  telefono                  4  estadisticas (barras)      5  BARRIO 1 (plaza / puerta)
   6  poster del barrio         7  COLEGIO calle 1            8  ALCALDIA dialogo con candidatos
   9  volviendo                 10 resultado del poster       11 ALCALDIA opciones (Clemencia)
   12 resultado alcaldia        13 en construccion            14 resultado colegio
   15 BARRIO 2 (Chisme Vio)    16 BARRIO 3 (Lola)            17 COLEGIO calle 4
   18 BARRIO 1 (Armando)        19 BARRIO 1 (Junta)           20 BARRIO 2 (Aquiles)
   21 BARRIO 2 (Debora)         22 BARRIO 3 (Elsa)            23 BARRIO 3 (Benito)
   24* alcaldia (hall con empleado)           (antes 16 en el codigo de la alcaldia)
   25* COLEGIO calle 2                        (antes 15 en el codigo del colegio)
   26* COLEGIO calle 3                        (antes 16 en el codigo del colegio)
   27* COLEGIO Cafe 404                        (antes 18 en el codigo del colegio)
   28* intro "Llegas a tu barrio"              (antes 5 en alcaldia y colegio)
   29* intro "ALCALDIA DE NOVA"                (antes 8 en el codigo del colegio)
   30* Compartir / Verificar (Ramirez)         (antes 11 en el codigo del colegio)
   31* resultado de Compartir / Verificar      (antes 12 en el codigo del colegio)
   32* "Estas investigando un nuevo caso"      (antes 8 en el codigo del barrio)
   33* "Ya se registro la respuesta"           (antes 10 en el codigo del barrio)
   34* "Resultado guardado correctamente"      (antes 12 en el codigo del barrio)
   35* "Accion procesada"                      (antes 14 en el codigo del barrio)
   36* estadisticas con numeros                (antes 4 en el codigo del barrio)
   ===================================================================================== */

// Variable de colores
color gris = color(64, 64, 64);                                 //aqui se crea una variable llamada color gris y se le asigna un color con los valores rgb (creo que asi se llamaban)
color boton = color(255, 255, 255);                            //aqui pero para el color del boton
color negro = color(0, 0, 0);                                  //lo mismo pero en color negro
color rojoOscuro = color(139, 0, 0);

// ------------------------------------- ALCALDIA -------------------------------------
float npcX = 350, npcY = 200, npcW = 50, npcH = 100;
boolean cercaNPC = false;
boolean hablando = false;

boolean choca(float px, float py, float rx, float ry, float rw, float rh) {
  return px < rx + rw &&
         px + anchoPersonaje > rx &&
         py < ry + rh &&
         py + altoPersonaje > ry;
}

void decidirAlcaldia(int opcion) {
  decC = opcion;
 if (opcion == 1) {            // defender a Clemencia
    viralidad = viralidad + 10;
    confiabilidad = confiabilidad + 5;
    impacto = impacto + 15;
  } else if (opcion == 2) {     // no intervenir
    impacto = impacto - 5;
  } else {                      // hablar mal de ella
    viralidad = viralidad + 20;
    confiabilidad = confiabilidad - 20;
    impacto = impacto - 10;
  }
  scene = 12;
}

// Diálogos de la escena 8
String[] quien = {
  "",
  "Benito Juarez (Alcalde)",
  "Clemencia (Candidata B)",
  "Patroclo (Candidato A)",
  "Gonzalo Gonzales (Candidato C)"
};

String[] linea = {
  "La plaza principal de la Alcaldía de Nova está atestada de manifestantes con pancartas. El video falso del barrio y el meme escolar provocaron un polvorín digital.",
  "(Con megáfono) ¡Ciudadanos de Nova, mantengan la calma! ¡La candidata Clemencia va a ser penalizada por sus acciones!",
  "¡No le crean al alcalde! ¡Patroclo y Benito han estado difamándome para acabar con mi candidatura!",
  "¡Mentira! Clemencia planeaba comprar votos y solo los manipula para salirse con la suya.",
  "¡Yo solo quería proponer una ciclorruta, pero el algoritmo de las redes sociales en Nova está arruinando la democracia!"
};

// Opciones de la escena 11
String[] opciones = {
  "Decides hablar públicamente y defender a la candidata Clemencia.",
  "No intervienes en el transcurso de las elecciones.",
  "Hablas mal de la candidata con las demás personas que se encuentran en la protesta."
};

int dialogoIdx = 0;

// ------------------------------------- IMAGENES Y FUENTE -------------------------------------
// Variable Imagen y fuente
PImage foto, foto1, telefonoImg, mapaImg, menuImg, calle1, calle2, calle3, calle4, cafe1;            //se declaran variables para almacenar las imagenes
PImage alcaldia, empleado, candidatos;
//Variables para las imagenes del barrio
PImage pB1;
PImage fB1;
PImage fB2;
PFont fuente;                                                //esta para una tipografica como la  de payrus o arial

//Las imagenes de los sprites del personaje
PImage arriba, abajo, izquierda, derecha;
//este que era?
PImage actual; //olvidenlo ya me acorde era de un npc que puse pero estaba tan feo que lo borre jajajajaj

// Variable escenario
int scene = 0;                                                //aqui se declara una variable (obviamente de tipo entera que es la que muestra/controla la pantalla en la que empieza el usuario
int origenTelefono = -1; // Esta variable es para recordar de que escena viene al abrir el telefono

// ------------------------------------- COLISIONES -------------------------------------
// Parte para colisiones colegio
float obsX = 0, obsY = 0, obsW = 800, obsH = 94;             // barrera
// Las dimenciones del personaje principal y se le asigna su valor
float anchoPersonaje = 100; //Ancho de empanada
float altoPersonaje = 50;//esta horrible santiago

// (el arreglo "obstaculos" de la alcaldia era identico a este, por eso solo se deja uno)
float[][] obstaculoscolegio1 = {
  {480, 0, 400, 190},     // fila de edificios de arriba
  {0, 0, 350, 190},      
  {0, 300, 40, 200},    // fila de edificios de abajo
  {0, 330, 340, 200},   
  {500, 320, 100, 200},  
  {750, 320, 340, 200},
  {0, 0, 800, 94}    // tope
};
// escena dos del colegio
float[][] obstaculoscolegio2 = {
  
  // Nota importante, las sumas son porque me di cuenta que la imagen al ser PNG, los espacio que no se ven los cuenta, entonces las sumas son el margen del espacio blanco al personaje /---[ ]---/
  {0, 0, 150, 150},      // fila de edificios tiendas
  {300, 0, 10, 150},      // fila de edificios tienda
  {480, 0, 320, 137},      
  {0, 330, 300, 132},    // fila de edificios de abajo
  {509+35, 330, 320, 100},   
  {585+35, 299, 320, 100},  
                                // limites
    {835, 0, 1, 500},
  {0, 0, 105-30, 500},     
  {0, 0, 800, 0},    // tope superior
  {0, 500, 800, 0}    // tope inferior
};

// Escena tres del colegio
float [][] obstaculoscolegio3 = {
  {0,0,293-45,400}, // parte izquierda completa
  {0,0,245-45,500},
  {404+30,310,230-35,150},
  {393+30,0,300-35,150},
  
  
  
  //limites
  {0, 500, 800, 0},
  {835, 0, 1, 500},
  
};
// Escena 4 del colegio
float [][] obstaculoscolegio4 = {
  {465+30,219,30,400},
  {470+30,230,400,400},
  {0,212,344-30,103},
  {0,212,315-30,400},
  {0,80,800,0},
  {0,0,319-30,123},
  {450+30,0,319-30,123},
  
  //limites
  {770, 0, 1, 500},
  {0,0,209-30,400},
};

// escena cafe1

float [][] obstaculosCafe1 = {
  {0, 470, 260, 0},
  {0, 0, 430, 222},
  {0, 0, 800, 174},

  
  //limites
  {0, 0, 30, 500},
  {745+30, 0, 30, 500},
  {624+30, 457, 30, 500},
  {680+30, 400, 30, 500},
  {717+30, 0, 30, 500},
  //
  {624+30, 176, 30, 80},
  {680+30, 207, 30, 60},
  {717+30, 230, 30, 60},
  {450, 470, 500, 30},
  //
  {70-30, 207, 30, 60},
  {130-30, 230, 30, 60},

};

// obstaculos alcaldia
float[][] obstaculos2 = {
  {0,   0,   800, 114},   // edificio de arriba
  {0,   114, 356, 84},    // multitud izquierda
  {472, 114, 328, 84},    // multitud derecha
  {0,   198, 212, 48},
  {596, 198, 204, 48},
  {0,   246, 324, 70},
  {516, 246, 284, 70},
  {0,   316, 352, 114},
  {470, 316, 330, 114},
  {0,   430, 236, 70},
  {608, 430, 192, 70},
  {350, 225, 40,  50}     // empleado
};

float[][] obstaculosActuales;

float[] Zonacambio = {0, 0, 0 , 800, };
float[] Zonacambio2 = {780+30, 205, 790 , 80};
float[] Zonacambio3 = {345-30,20,100,0};
float[] Zonacambio4 = {745,473,100,100};
float[] Zonacambio5 = {0,500,800,2};
float[] Zonacambio6 = {745,473,100,100};
float[] Zonacafe1 = {566+30,133,0,9};

// cubo de interaccion
// Cubo de interacción (x, y, ancho, alto)
// (el ultimo numero de cada fila es la escena, ya con los numeros nuevos: 25 = calle2, 26 = calle3, 27 = cafe)
float[][] npcs = {
{600, 441, 40, 40, 7},
{646, 150, 40, 40, 26},
{240, 435, 40, 40, 26},
{120, 151, 40, 40, 25},
{730, 450, 40, 40, 25},
{320, 359, 40, 40, 17},
{305, 181, 40, 40, 27},
{610, 290, 40, 40, 27},


};

String[] nombresNpc = {
  "Mateo (10°B)",
  "Don Lucho",
  "Doña Marta",
  "Julián",
  "Sofía (Campaña)",
  "Camila",
  "Álex (Café 404)",
  "Nico (Mesa 3)"};
String[][] dialogosNpc = {
// 1. Calle (solo): Estudiante del colegio
  {
    "Ey! ¿Ya abriste Conecta? Subieron una foto de Dani en el recreo sin que se diera cuenta.",
    "Me la reenvio el primo de Vale. Dicen que Dani estaba escondiendo algo raro en su casillero.",
    "En la foto solo se ve su maleta abierta, pero ya lleva cien comentarios inventando mil teorias.",
    "Si la comparto ahora fijo gano seguidores, aunque Dani ni sabe que es tendencia. ¿La resubo?"
  },

  // 2. Calle: Vecino del Barrio
  {
    "Buenas! Estoy moviendo en Conecta la jornada \"Recuperemos el parque\" y el torneo de microfutbol.",
    "Necesitamos voluntarios para pintar las canchas, pero los jovenes solo miran retos virales absurdos.",
    "Ademas, desde hace media hora los vecinos dejaron de confirmar asistencia. Algo raro estan leyendo.",
  },

  // 3. Calle: Vecina del rumor de la urbanización
  {
    "Ni pierda tiempo con lo del torneo! Me lo conto mi primo, que se lo conto la amiga de su sobrina.",
    "En el colegio filtraron los planos secretos de una urbanizacion privada que va a tumbar el parque.",
    "La cuenta que lo subio no tiene foto ni nombre real, pero lleva mil compartidos. Por algo sera!",
    "Voy a mandar la alerta al grupo del barrio para cancelar todo. ¿Me ayudas a difundir el aviso?"
  },

  // 4. Calle: Ciudadano/votante indignado
  {
    "Esto es el colmo! Faltan siete dias para las elecciones y mire lo que me acaba de salir en Conecta.",
    "El titular dice clarito: \"URGENTE: el candidato Ramirez quiere cerrar el colegio\" para vender el lote.",
    "Dicen que el alcalde Benito Camelo ya firmo el permiso en secreto. Me lo mando un tio por mensaje.",
    "El enlace viene de una pagina creada ayer y sin autor, pero con tanta gente brava debe ser verdad.",
    "Iba a votar por Ramirez, pero ahora pienso etiquetarlo exigiendo que renuncie. ¿Lo publicamos ya?"
  },

  // 5. Calle: Voluntaria de campaña
  {
    "Hola! Reparto volantes de Clemencia, aunque Patroclo y Eltransmilenio tambien andan buscando votos.",
    "Con el escandalo del colegio y el parque, la campaña de Ramirez cayo diez puntos en un par de horas.",
    "No me consta si la noticia es real o un montaje, pero en politica el que pega primero gana tendencia.",
    "Si impulsamos la etiqueta contra Ramirez ahora mismo, barremos el domingo. ¿Nos das un empujoncito?"
  },

  // 6. Antes del bartender: Camila, estudiante
  {
    "Que risa como exageran todo en Conecta. De una foto borrosa en el recreo ya armaron una novela.",
    "La hermana de mi mejor amiga jura que en el casillero de Dani habia planos de una constructora.",
    "Yo estuve ahi: era solo su maqueta de geografia. Pero nadie lee si el chisme suena escandaloso.",
    "Estan pidiendo pruebas en el grupo del salon. ¿Les aclaro que es una maqueta o dejo que hablen?"
  },

  // 7. Café 404: Recepcionista/bartender
  {
    "Bienvenido al Cafe 404. Toma asiento, te veo agitado. ¿Que pasa alla afuera que todos miran el celular?",
    "A ver si te sigo el hilo: me cuentas que todo empezo con una foto de Dani en el recreo sin su permiso.",
    "Y que al cruzar la calle ese chisme ya era un plan para tumbar el parque y cerrar el colegio con Ramirez.",
    "Me resumiste el caos de media ciudad en un minuto. Con todo eso que me cuentas, ¿tu que crees que paso?",
    "Sea por malicia o descuido, asi funciona Conecta: cada quien le suma su propio miedo antes de compartir.",
    "Hace un rato consulte a NOVA, el asistente de IA, y rastreo todo desde la maqueta hasta el titular falso.",
    "NOVA me recordo la regla: mirar quien publica, cuando crearon la cuenta y si existe alguna prueba real.",
    "Gracias por pasar a contarme. Termina tu cafe y sal a decidir que compartes, que en Nova tu eres el filtro."
  },

  // 8. Café 404 (sentado en mesa): Cliente joven
  {
    "Estoy tomando cafe mientras veo como Conecta arde con lo del colegio, el parque y las elecciones.",
    "Un amigo me juro que el candidato Patroclo pago para volver tendencia la foto del casillero de Dani.",
    "Pero le pregunte a NOVA y mostro que el rumor crecio solo porque medio barrio compartio sin leer.",
    "Arme un hilo mostrando como la maqueta termino en crisis politica. ¿Lo publico o ya da igual?"
  }
};

// Textos de los 2 botones
String[][] opcionesNpc = {
  {"Compartir la foto", "No subir y avisar"},     // 1. Mateo
  {"", ""},                                         // 2. Don Lucho (sin decisión)
  {"Difundir la alerta", "Pedir fuente real"},  // 3. Doña Marta
  {"Publicar reclamo ya", "Revisar la página"}, // 4. Julián
  {"Impulsar la etiqueta", "Frenar sin pruebas"},       // 5. Sofía
  {"Aclarar que es maqueta", "Dejar correr el rumor"},  // 6. Camila
  {"Alguien manipula todo", "Se exagero el chisme"},        // 7. Álex
  {"Subir hilo con pruebas", "Dejar el tema así"}    // 8. Nico (sentado en el café)
};


int[] paginaOpciones = {4, -1, 4, 5, 4, 4, 4, 4};  // btw esto se refiere a la pagina en la que aparecen las opcciones
int npcCerca = -1;            // numero de personaje que tenga al lado
int npcHablando = -1;          // con quien esta halando
float margenInteraccion = 20;    // los pixeles de margen extra a los que se le puede hablar al personaje, como el area 

// Zona de interacción (un poco más grande que el cubo, para detectar "cercanía")
// recorre todo los personajes, esta zona lo que hace es crear la zona que es un poco mas grande que el cubo para detectarla :)
int buscarNpcCerca() {
  for (int i = 0; i < npcs.length; i++) {
    if (npcs[i][4] != scene) continue;
    float[] zona = {
      npcs[i][0] - margenInteraccion,
      npcs[i][1] - margenInteraccion,
      npcs[i][2] + margenInteraccion * 2,
      npcs[i][3] + margenInteraccion * 2
    };
    if (estaEnZona(x, y, zona)) {
      return i;
    }
  }
  return -1;
}


//  Dialogos del cubo



int paginaActual = 0;                  // Pagina actual del dialogo
boolean paginter = false;              // pagina interaccion, osea si es true significa que esta en la pagina de escoger

                                                              //en este acso empieza en la pantalla 0 que es la de jugar

// Otra variable mas no me acordaba de que era hasta que empece a releer el codigo para escribir los comentarios jajaja
int decC = 0;                                                  //esta  es para registrar las ultimas desiciones que toma el jugador en cada escena

 // Variables de estadisticas
// Las variables y el numero que se le asignan para inicializar, son los de los stats obviamente y todos empiezan en 0
float viralidad = 0;                                                //se crea una variable de tipo float para las estadisticas, en este caso son puntaje de viralidad
float confiabilidad = 0;                                          //esta para puntaje de confiabilidad
float impacto = 0;                                                //este para el impacto

// Vector que almacena los datos del usuario att: gaby
//Un vector que guarda 15 desisiones max.
int[] dec = new int[15];                                              //aqui se crea un vector para 10 elementos en la que se guardan las decisiones
int idDec = 0;                                                         //este es para controlar la posision dentro del vector (va a aumentar en uno)

//obviamente para mover el personaje
int pD18=0;//este lo explico mas abajo pero corresponde a la escena 18 pero es para el progreso de dialogo de la escena 18
boolean moverArriba =false; //aqui va un booleano, esto lo que quiere decir es que esta variable empieza siendo falso
boolean moverAbajo= false;//osea por ejemplo el personaje ahora mismo no se esta moviendo pero si se presiona la tecla de mover hacia abajo pummm, se vuelve verdadero
boolean moverIzquierda=false;                                          // movimientos
boolean moverDerecha=false;

// Variabl de x
float x = 0;                                                              // coordenadas movimiento
//Variable de y
float y = 0;
// Variable de la velocidad original y la otra para mas abajo cuando se use el shift
float velocidadBase = 3.5;
float velocidad = 3.5;                                                     // velocidad movimiento

boolean bComp = false;//para comprobar
String mensajeMapa = "";//el nombre ya lo dice jajajaja

// Variables para coordenadas del mouse
// Declara una variable y le asigna su valor inicial.
float mouseXCoord = 0;
// Declara una variable y le asigna su valor inicial.
float mouseYCoord = 0;

// ------------------------------------- BARRIO -------------------------------------
//Estas son unas varuables que cree para la puerta y lo que sucede en la primera parte del barrio
int pD1 = 0; //esta se parece a la de mas arriba que significa paso de dialogo pero me dio pereza escribirla toda jajaja, esta es para el dialogo 1 y sube a medida que el jugador presiona e
boolean tLl = false;//esta es para la llave, empieza el falso porque el jugador al principio no tiene llave
boolean llEnt = false;//esta tambien empieza en falso porque pss significa llave entregada y hasta que no se hable con el personaje pues no va a obtener la llave
boolean pDes = false;//esta es para la puerta desbloqueada que no hace falta explicar porque empieza en falso
boolean mostrarDialogo = true; //esta myestra el dialogo cuando el personaje spawnea (tambien lo usa el colegio para las cajas de dialogo de los NPC)
String textoDialogo = "T/N: No, no, no... Esto no me puede estar pasando! \nComo voy a perder la llave justo cuando estoy a punto de entrar a Nova?";

// Estas controlan la conversacion y el cuadro que salta abajo
boolean a1=false;//estos son indicadores para saber si ya hable con cada personaje, obviamente inicialisan en falso, cuando se habla cambia de color a verde
boolean a2=false;
boolean a3=false;
boolean md1=false;//esta es la que muestra el cuadro de desisiones que despues voy a editar porque no he terminado esa parte
String m2="Presiona E para hablar con Armando.";//estos los voy a eliminar pero pues es el cuadro de presionar e para hablar con los personaje
String m3="Presiona E para hablar con la Junta.";

//aqui descubri algo, tuve una iluminacion divida y me di cuenta que usando , podia juntar todos en una misma linea de codigo
boolean b1 = false, b2 = false, b3 = false;
boolean md2 = false;
String m4="Presiona E para hablar con El Chisme Vio.";
String m5 = "Presiona E para hablar con Aquiles";
String m6="Presiona E para hablar con Debora";

boolean c1 =false, c2=false, c3=false;
boolean md3= false;
String m7="Presiona E para hablar con Lola";
String m8 ="Presiona E para hablar con Elsa";
String m9="Presiona E para hablar con Benito";


//la fuente del juego que a una persona se le ocurrio poner una llamada cyberpunkwaifus
void setup(){                                                                      //esta es una funcion que se ejecuta una sola vez

  size(800, 500);            //el tamaño de la ventana
  fuente = createFont("CyberpunkWaifus (1).ttf", 32);//carga la fuente
  if (fuente != null) {                                                        //esta no estoy segura de borrarla pero la puse por si acaso que es que verifica si la fuente cargo porque cuando intentaba no me cargaba
    textFont(fuente);                                                            //aqui se aplica como determinada/obligatoria

  }
  
  // imagenes para el movimiento del personaje
  arriba = loadImage("up.png");
  abajo = loadImage("down.png");
  izquierda = loadImage("left.png");
  derecha = loadImage("right.png");
  
  
  
  // Las imagenes y sus respectivos nombres y formatos
  foto = loadImage("Ciudad nova.png");                                              //ya se, muy creativa con los nombres pero estos no los puse yo, los de mas abajo si
  foto1 = loadImage("campaing.png");
  telefonoImg = loadImage("cel.jpg"); 
  mapaImg = loadImage("mapa.jpg");
  menuImg = loadImage("menu.jpg");
  calle1 = loadImage("calle1.jpg");
  calle2 = loadImage("calle2.jpg");  
  calle3 = loadImage("calle3.png");
  calle4 = loadImage("calle4.png");
  cafe1 = loadImage("cafe1.jpg");
  alcaldia = loadImage("alcaldia.jpeg");
  empleado = loadImage("empleado.png");
  candidatos = loadImage("candidatos.png");
  pB1 = loadImage("PuertaBarrio1.jpg");
  fB1 = loadImage("fondo1barrio.jpg");
  fB2 = loadImage("fondo2barrio.jpg");
  if (pB1 == null) {
    println("ERROR: No se encontró la imagen PuertaBarrio1.jpg. Verifica que esté en la carpeta /data.");
  } else {
    println("Imagen PuertaBarrio1.jpg cargada correctamente.");
  }
  
  x = width/2;
  y = height/2;
  actual = abajo;
  vidaSetup();   // (v2.0) prepara el menu animado, telefono, minijuegos, escenarios nuevos... (ver Vida.pde)
}

boolean hayColision(float px, float py) {
  for (float[] obs : obstaculosActuales) {
    if (px < obs[0] + obs[2] &&
        px + anchoPersonaje > obs[0] &&
        py < obs[1] + obs[3] &&
        py + altoPersonaje > obs[1]) {
      return true;
    }
  }
  return false;
}

 /* Es un poco dificil de entender pero se trata de comparar si el muñeco|personaje se superpondria con la pared al moverse a esa posicion, si lo hace, no sigue y se queda sin moverse, si no lo hace, continua
 ejemplo, imagina que el personaje quiere dar un paso al frente de una pared, lo que se hace aqui es ok tengo este valor al que se va a mover el personaje, si se moviera aqui, se superpondria con la pared?
 si la respuesta es si, no lo deja moverse, si la respuesta en no, sigue moviendose, esto lo va haciendo cada vez tocamos wasd para movernos, compara los espacion y mira si se superponen
 */
 
 boolean hayColision2(float px, float py) {
  // Solo los pies del personaje (30x18) para que quepa por los pasillos
  float hx = px + 35, hy = py + 30, hw = 30, hh = 18;
  for (float[] obs : obstaculos2) {
    if (hx < obs[0] + obs[2] &&
        hx + hw > obs[0] &&
        hy < obs[1] + obs[3] &&
        hy + hh > obs[1]) {
      return true;
    }
  }
  return false;
}

boolean estaEnZona(float px, float py, float[] zona) {
  return px < zona[0] + zona[2] &&
         px + anchoPersonaje > zona[0] &&
         py < zona[1] + zona[3] &&
         py + altoPersonaje > zona[1];
 

}
// variable importante para las interacciones el los dialogos


void keyPressed() {                                                          //movimiento del personaje
  if (vidaKeyPressed()) return;   // (v2.0) pausa, telefono, menu, minijuegos y escenas nuevas
  if (key == 'w' || key == 'W') {
    moverArriba = true;
    actual = arriba;
  }
  if (key == 's' || key == 'S') {
    moverAbajo = true;
    actual = abajo;
  }
  if (key == 'a' || key == 'A') {
    moverIzquierda = true;
    actual = izquierda;
  }
  if (key == 'd' || key == 'D') {
    moverDerecha = true;
    actual = derecha;
  }
  if (keyCode == SHIFT) {
    velocidad = 7.0;
  }
  
  // ------------------ ALCALDIA (escena 24 y 8) ------------------
  if ((key == 'e' || key == 'E') && scene == 24) {
  if (hablando) {
    scene = 8;
    dialogoIdx = 0;       // empieza el diálogo desde el principio
    hablando = true;      // y queda activo en la escena 8
    moverArriba = moverAbajo = moverIzquierda = moverDerecha = false;
  } else if (cercaNPC) {
    hablando = true;
  }
}
if ((key == 'e' || key == 'E') && scene == 8 && hablando) {
  dialogoIdx++;
  if (dialogoIdx >= linea.length) {
    hablando = false;     // terminó el diálogo
  }
}

  // ------------------ COLEGIO ------------------
    // Interacción con el cubo
  if ((key == 'e' || key == 'E') && npcCerca != -1 && !mostrarDialogo) {
    mostrarDialogo = true;
    npcHablando = npcCerca;
    paginaActual = 0;
  }
  

  
  // Avanzar diálogo
  // (se agrego npcHablando != -1 porque "mostrarDialogo" tambien lo usa el barrio y sin esto el juego se caia al dar Enter)
  if (key == ENTER || key == RETURN) {
    if (mostrarDialogo && !paginter && npcHablando != -1) {
      paginaActual++;
      if (paginaActual == paginaOpciones[npcHablando]) {
        paginter = true;                          // llegó la página de elegir
      } else if (paginaActual >= dialogosNpc[npcHablando].length) {
        mostrarDialogo = false;                   // se acabaron las páginas
        paginaActual = 0;
        npcHablando = -1;
      }
    }
  }

  // ------------------ BARRIO ------------------
  // La interaccion para presionar e
  if (key == 'e' || key == 'E') {

    if (scene == 5 && pD1 == 0 && mostrarDialogo && dist(x, y, 301, 394) >= 80) {
      mostrarDialogo = false;
      return;
    }

    if (scene == 5) {
      boolean enZonaBasuraPrincipal = (x >= 50 && x <= 150 && y >= 320 && y <= 430);
      boolean enZonaBasuraSecundaria = (x >= 620 && x <= 720 && y >= 320 && y <= 430);
      float dSol = dist(x, y, 301, 394);

      boolean enZonaPuerta = (x + anchoPersonaje >= 262 && x <= 529 && y + altoPersonaje >= 100 && y <= 270);

      if (dSol < 80) {
        mostrarDialogo = true;

        if (pD1 == 0) {
          pD1 = 1;
        }

        switch(pD1) {
        case 1:
          textoDialogo = "NPC: Oye! Estas buscando algo o tienes algun problema con la basura de Nova?\nPorque, si buscas algo de valor, \ncreo que llegaste un poquito tarde.";
          pD1 = 2;
          break;
        case 2:
          textoDialogo = "T/N: Jaja, muy gracioso. \nPerdi la llave que necesito para entrar a la ciudad. \nEs plateada y tiene un llavero azul.\nCreo que la tire aqui por accidente.";
          pD1 = 3;
          break;
        case 3:
          textoDialogo = "NPC: Tu llave? que descuidado. \nBueno, eso sí es un problema. Sin ella no te van a dejar pasar por la entrada principal.\nY no te recomiendo intentar saltarte la puerta. \nLos guardias no son precisamente amables.";
          pD1 = 4;
          break;
        case 4:
          textoDialogo = "T/N: Gracias por el consejo... Eso creo. \nNo habrás visto una por aquí?\nNpc: Ahora que lo dices, hace un rato vi a un trabajador recogiendo algunas cosas de estos contenedores. \nPuede que todavia no se haya llevado todo. Espera, voy a mirar.";
          pD1 = 5;
          break;
        case 5:
          textoDialogo = "NPC: Es esta? Tiene un llavero azul, así que supongo que tienes suerte.";
          tLl = true;
          pD1 = 6;
          break;
        case 6:
          textoDialogo = "T/N: Si!, esa es! No sabes el favor que me acabas de hacer. \nPense que tendria que pasarme toda la tarde buscando.";
          pD1 = 7;
          break;
        case 7:
          textoDialogo = "NPC: No hay de que. Aunque, si vas a quedarte en Nova, te recomiendo que te prepares.\nUltimamente la ciudad está bastante... peculiar.";
          pD1 = 8;
          break;
        case 8:
          textoDialogo = "T/N: Peculiar en que sentido?\nNPC: En el sentido de que todo el mundo esta discutiendo por las elecciones. \nAbres el telefono y encuentras acusaciones, videos, capturas de pantalla \ny personas peleando con desconocidos como si se conocieran de toda la vida. \nYa ni siquiera sé qué creer.";
          pD1 = 9;
          break;
        case 9:
          textoDialogo = "T/N: Tan grave es la situacion?\nNPC: No se si grave, pero si bastante extraña. Ayer vi una publicacion que acusaba a uno de \nlos candidatos de hacer algo ilegal. \nHoy vi otra que decia exactamente lo contrario. Y lo peor es que la gente comparte todo sin preguntarse de donde salio.";
          pD1 = 10;
          break;
        case 10:
          textoDialogo = "T/N: Tal vez solo sea una discusion politica mas.\nNPC: Eso pense al principio. \nPero cuando un rumor llega a todos los grupos de whatsapp, \ndeja de ser una simple discusion. Puede terminar afectando a personas que ni siquiera tienen \noportunidad de defenderse.";
          pD1 = 11;
          break;
        case 11:
          textoDialogo = "NPC: Hablando de eso, acaban de mandar algo nuevo al grupo vecinal. \nParece que esta vez el asunto involucra directamente a una de las candidatas.\nT/N: Y que dice?\nSolomeo: Todavía no lo he visto bien. Entra a Nova y revisa el grupo. \nSeguro que para cuando llegues ya habra veinte versiones distintas de la misma historia.";
          pD1 = 12;
          llEnt = true;
          a1 = true;
          break;
        case 12:
          textoDialogo = "Ya tienes la llave. Dirigete a la entrada de Nova para abrir la puerta.";
          break;
        }
      } else if (enZonaBasuraPrincipal) {
        mostrarDialogo = true;
        if (!tLl) {
          textoDialogo = "Revisas la basura, pero no encuentras la llave por tu cuenta. Prueba hablar con Solomeo.";
        } else {
          textoDialogo = "Ya revisaste aqui y NPC encontro la llave por ti.";
        }
      } else if (enZonaBasuraSecundaria) {
        mostrarDialogo = true;
        textoDialogo = "Revisaste este contenedor: Solo hay periodicos viejos con rumores de la ciudad.";
      } else if (enZonaPuerta) {
        if (llEnt && tLl) {
          pDes = true;
          mostrarDialogo = false;
          scene = 18;
          x = width / 2;
          y = height - 80;
        } else {
          mostrarDialogo = true;
          textoDialogo = "La puerta esta cerrada. Necesitas hablar con Solomeo para obtener la llave.";
        }
      }
    }

    if (scene == 18) {
      boolean enCajaBasura = (x >= 100 && x <= 220 && y >= 100 && y <= 220);
      float distArmando = dist(x, y, 292, 369);

      if (distArmando < 80) {
        a2 = true;

        // Para que el texto se oculte
        if (pD18 >= 18) {
          mostrarDialogo = false;
          return;
        }

        mostrarDialogo = true;

        switch(pD18) {
        case 0:
          textoDialogo = "Armando: Buenos días. Bienvenido a Nova. Soy Armando Esteban Quito, \ndirector de la junta vecinal. ¿En qué puedo ayudarte?";
          pD18 = 1;
          break;
        case 1:
          textoDialogo = "T/N: Buenos días. Acabo de llegar a la ciudad y quería informarme un poco... \nEscuché que últimamente hay bastante discusión por las elecciones.";
          pD18 = 2;
          break;
        case 2:
          textoDialogo = "Armando: Veo que te han dado la bienvenida con las noticias habituales. \nSí, atravesamos una temporada electoral bastante complicada.";
          pD18 = 3;
          break;
        case 3:
          textoDialogo = "Armando: Lo que debería ser una oportunidad para debatir propuestas se ha \nconvertido en una competencia por ver quién desacredita primero al otro.";
          pD18 = 4;
          break;
        case 4:
          textoDialogo = "T/N: ¿Se refiere a las discusiones entre los candidatos?";
          pD18 = 5;
          break;
        case 5:
          textoDialogo = "Armando: No solamente entre ellos. El problema también está en los ciudadanos. \nUna persona publica una acusación, otra la comparte sin comprobarla y todos discuten.";
          pD18 = 6;
          break;
        case 6:
          textoDialogo = "El teléfono de Armando vibra repetidamente. Él suspira y revisa sus notificaciones.\nArmando: Precisamente, acaba de llegar un mensaje al grupo vecinal. Esto no puede ser...";
          pD18 = 7;
          break;
        case 7:
          textoDialogo = "T/N: ¿Qué sucedió?";
          pD18 = 8;
          break;
        case 8:
          textoDialogo = "Armando: Alguien compartió un video en el que aparentemente aparece Clemencia, \nla candidata B, participando en una supuesta compra de votos.";
          pD18 = 9;
          break;
        case 9:
          textoDialogo = "T/N: ¿Y se sabe si el video es real?";
          pD18 = 10;
          break;
        case 10:
          textoDialogo = "Armando: Eso es lo que me preocupa. La publicación no incluye fuente ni explica \ncuándo se grabó, pero ya hay vecinos exigiendo que sea retirada de las elecciones.";
          pD18 = 11;
          break;
        case 11:
          textoDialogo = "T/N: ¿No podría ser cierto?";
          pD18 = 12;
          break;
        case 12:
          textoDialogo = "Armando: Podría existir una acusación que merezca investigarse, pero no darla por cierta \nsin pruebas. Un fragmento editado puede cambiar la interpretación de una situación.";
          pD18 = 13;
          break;
        case 13:
          textoDialogo = "T/N: Entonces, ¿qué piensa hacer?";
          pD18 = 14;
          break;
        case 14:
          textoDialogo = "Armando: Solicitaré que la junta ayude a verificar la información antes de empeorar. \nNo puedo impedir que compartan mensajes, pero pido no confundir rapidez con verdad.";
          pD18 = 15;
          break;
        case 15:
          textoDialogo = "Armando muestra la pantalla del grupo 'Nova Vecindarios Unidos':\nArmando: Mira la cantidad de mensajes. Algunos la creen culpable, otros dicen que es trampa.";
          pD18 = 16;
          break;
        case 16:
          textoDialogo = "T/N: Parece que todos quieren tener la razón antes de saber qué ocurrió.";
          pD18 = 17;
          break;
        case 17:
          textoDialogo = "Armando: Exactamente. Y ahora tú también viste la publicación. Puedes extender el rumor, \nintentar comprobar la información o apartarte del asunto. ¡Ve a la Junta a la izquierda!";
          pD18 = 18;
          break;
        }
      } else if (enCajaBasura) {
        mostrarDialogo = true;
        textoDialogo = "Encontraste una caja abandonada: Contiene volantes sobre la junta vecinal.";
      }
    }
    if (scene == 19) {
      boolean enZonaPapeles = (x >= 500 && x <= 650 && y >= 100 && y <= 220);
      float distJunta = dist(x, y, width/2, height/2);
      if (distJunta < 80) {
        a3 = true;
        md1 = true;
      } else if (enZonaPapeles) {
        mostrarDialogo = true;
        textoDialogo = "Hay notas en el suelo: Son actas firmadas por los vecinos del sector.";
      }
    }
    if (scene == 15) {
      boolean enObjetoChisme = (x >= 500 && x <= 650 && y >= 250 && y <= 350);
      float distChisme = dist(x, y, 205, 205);
      if (distChisme < 80) {
        b1 = true;
        mostrarDialogo = true;
        textoDialogo = "El Chisme Vio: ¡Ve arriba y a la izquierda para obtener más reportes!";
      } else if (enObjetoChisme) {
        mostrarDialogo = true;
        textoDialogo = "Revisaste un cartel roto: Anuncia eventos comunitarios cancelados.";
      }
    }
    if (scene == 20) {
      boolean enBasuraAquiles = (x >= 100 && x <= 220 && y >= 280 && y <= 380);
      float distAquiles = dist(x, y, width/2, height/2);
      if (distAquiles < 80) {
        b2 = true;
        mostrarDialogo = true;
        textoDialogo = "Aquiles Castro: ¡Habla con Debora a la izquierda!";
      } else if (enBasuraAquiles) {
        mostrarDialogo = true;
        textoDialogo = "Basurero del parque: Hay botellas plásticas reciclables descartadas.";
      }
    }
    if (scene == 21) {
      boolean enObjetoDebora = (x >= 550 && x <= 680 && y >= 280 && y <= 380);
      float distDebora = dist(x, y, width/2, height/2);
      if (distDebora < 80) {
        b3 = true;
        md2 = true;
      } else if (enObjetoDebora) {
        mostrarDialogo = true;
        textoDialogo = "Encontraste una carpeta tirada: Contiene reportes detallados del vecindario.";
      }
    }

    if (scene == 16) {
      boolean enBasuraLola = (x >= 500 && x <= 620 && y >= 250 && y <= 350);
      float distLola = dist(x, y, 205, 205);
      if (distLola < 80) {
        c1 = true;
        mostrarDialogo = true;
        textoDialogo = "Lola Mento: ¡Aún faltan testimonios en la zona!";
      } else if (enBasuraLola) {
        mostrarDialogo = true;
        textoDialogo = "Caja de herramientas abandonada: Esta zona está llena de escombros de construcción.";
      }
    }

    if (scene == 22) {
      boolean enObjetoElsa = (x >= 100 && x <= 220 && y >= 100 && y <= 200);
      float distElsa = dist(x, y, width/2, height/2);
      if (distElsa < 80) {
        c2 = true;
        mostrarDialogo = true;
        textoDialogo = "Elsa Pito: ¡Ve a la izquierda para el último testimonio!";
      } else if (enObjetoElsa) {
        mostrarDialogo = true;
        textoDialogo = "Muro con grafiti: Un mensaje pide más justicia y transparencia ciudadana.";
      }
    }

    if (scene == 23) {
      boolean enObjetoBenito = (x >= 550 && x <= 680 && y >= 100 && y <= 200);
      float distBenito = dist(x, y, width/2, height/2);

      if (distBenito < 80) {
        c3 = true;
        md3 = true;
      } else if (enObjetoBenito) {
        mostrarDialogo = true;
        textoDialogo = "Prueba";
      }
    }
  }
}

void keyReleased() {                                                          // controlar el movimiento
  vidaKeyReleased();   // (v2.0) las flechas tambien sueltan el movimiento
  if (key == 'w' || key == 'W') moverArriba = false;
  if (key == 's' || key == 'S') moverAbajo = false;
  if (key == 'a' || key == 'A') moverIzquierda = false;
  if (key == 'd' || key == 'D') moverDerecha = false;
  if (keyCode == SHIFT) {
    velocidad = velocidadBase;
  }
}

void mouseMoved() {
  mouseXCoord = mouseX;
  mouseYCoord = mouseY;
}

void mouseReleased() {
}

void DnpcDialog() {
                                                                              // dibujar personajes de la escena actual
  if (npcHablando >= 0) npcHablado[npcHablando] = true;   // (v2.0) para quitarle el "!" al que ya te hablo
  for (int i = 0; i < npcs.length; i++) {
    if (npcs[i][4] != scene) continue;
    // aqui se agrega un if para los diferentes personajes
    // (v2.0) el cubo cian ahora es un personaje animado; el cubo de interaccion sigue siendo el mismo
    dibujarNPC(npcs[i][0] + npcs[i][2]/2, npcs[i][1] + npcs[i][3], ropaNPC[i], peloNPC[i], i * 1.7, !npcHablado[i] && paginaOpciones[i] != -1, nombresNpc[i]);
  }

  // buscar quién está cerca
  npcCerca = buscarNpcCerca();

  // mensaje "Presiona E"
  if (npcCerca != -1 && !mostrarDialogo) {
    fill(255);
    textAlign(CENTER);
    textSize(16);
    text("Presiona E para hablar", npcs[npcCerca][0] + npcs[npcCerca][2]/2, npcs[npcCerca][1] - 70);
  }

  // caja de texto
  if (mostrarDialogo && !paginter && npcHablando != -1 && npcs[npcHablando][4] == scene) {
    fill(0);
    stroke(255);
    strokeWeight(4);
    rect(40, 380, 720, 100, 8);
    noStroke();
    fill(255);
    textAlign(LEFT, TOP);
    textSize(18);
    text(dialogosNpc[npcHablando][paginaActual], 60, 415, 680, 60);
    textAlign(RIGHT, BOTTOM);
    textSize(12);
    text("Enter para continuar", 740, 470);
  }

  // caja de opciones
  if (mostrarDialogo && paginter && npcHablando != -1 && npcs[npcHablando][4] == scene) {
  // caja de opciones
    fill(0);
    stroke(255);
    strokeWeight(4);
    rect(40, 380, 720, 100, 8);

    noStroke();
    fill(255);
    textAlign(LEFT, TOP);
    textSize(18);
    text("¿Qué quieres responder?", 60, 395);

    // Opción 1 (izquierda)
    fill(0);
    stroke(255);
    strokeWeight(2);
    rect(100, 440, 250, 30, 6);
    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text(opcionesNpc[npcHablando][0], 225, 455);

    // Opción 2 (derecha)
    fill(0);
    stroke(255);
    strokeWeight(2);
    rect(400, 440, 250, 30, 6);
    noStroke();
    fill(255);
    textAlign(CENTER, CENTER);
    text(opcionesNpc[npcHablando][1], 525, 455);
  }
}

void CerrarDialogo() {
  mostrarDialogo = false;   // no hay caja abierta
  paginter = false;           // ya no es la página de opciones
  paginaActual = 0;          // el próximo diálogo empieza desde el primer texto
  npcHablando = -1;         // ya no hablas con nadie
}

void elegirOpcion(int opcion) {
    // npcHablando = quién habla, opcion = 0 (izquierda) o 1 (derecha)

  if (npcHablando == 0) {              // Mateo
    if (opcion == 0) {                 // "Compartir la foto"
      viralidad += 15;
      confiabilidad -= 10;
      impacto -= 10;
    } else {                           // "No subir y avisar"
      viralidad -= 5;
      confiabilidad += 15;
      impacto += 10;
    }

  // (v2.0) OJO: los numeros estaban corridos uno (Doña Marta es la 2, no la 3, y Nico es el 7, no el 8),
  // por eso Doña Marta no daba puntos y la opcion de Nico nunca se usaba. Ya quedaron bien.
  } else if (npcHablando == 2) {       // Doña Marta
    if (opcion == 0) {                 // "Difundir la alerta"
      viralidad += 20;
      confiabilidad -= 15;
      impacto -= 15;
    } else {                           // "Pedir fuente real"
      viralidad -= 5;
      confiabilidad += 15;
      impacto += 15;
    }

  } else if (npcHablando == 3) {       // Julián
    if (opcion == 0) {                 // "Publicar reclamo ya"
      viralidad += 25;
      confiabilidad -= 20;
      impacto -= 20;
    } else {                           // "Revisar la página"
      confiabilidad += 20;             // la viralidad no cambia
      impacto += 15;
    }

  } else if (npcHablando == 4) {       // Sofía
    if (opcion == 0) {                 // "Impulsar la etiqueta"
      viralidad += 25;
      confiabilidad -= 20;
      impacto -= 25;
    } else {                           // "Frenar sin pruebas"
      viralidad -= 10;
      confiabilidad += 20;
      impacto += 20;
    }

  } else if (npcHablando == 5) {       // Camila
    if (opcion == 0) {                 // "Aclarar que es maqueta"
      viralidad += 5;
      confiabilidad += 20;
      impacto += 15;
    } else {                           // "Dejar correr el rumor"
      viralidad += 15;
      confiabilidad -= 15;
      impacto -= 10;
    }

  } else if (npcHablando == 6) {       // Álex (Café 404)
    if (opcion == 0) {                 // "Alguien manipula todo"
      viralidad += 5;                  // (v2.0) creer en un complot tambien es engancharse al chisme
      confiabilidad -= 5;
    } else {                           // "Se exageró el chisme"
      confiabilidad += 10;
      impacto += 5;
    }

  } else if (npcHablando == 7) {       // Nico (Mesa 3)
    if (opcion == 0) {                 // "Subir hilo con pruebas"
      viralidad += 15;
      confiabilidad += 25;
      impacto += 25;
    } else {                           // "Dejar el tema así"
      viralidad -= 5;
      confiabilidad -= 5;
      impacto -= 10;
    }
  }

  // las barras de estadísticas no se salgan de 0 a 100
  viralidad = constrain(viralidad, 0, 100);
  confiabilidad = constrain(confiabilidad, 0, 100);
  impacto = constrain(impacto, 0, 100);

  paginter = false;                                          // ya no es la página de elegir
  if (paginaActual >= dialogosNpc[npcHablando].length) {
    CerrarDialogo();                                         // no le quedan páginas: se despide
  }                                                          // si le quedan (Álex), el diálogo sigue
}

//este es un bucle infinito que dibuja una pantalla de cuadro obviamente, ni modo que draw sea volar
void draw() {       //esta es una funcion que se ejecuta en buble

npcCerca = -1;
if (vidaAntesDeDibujar()) return;   // (v2.0) transiciones, sacudidas y escenas nuevas (menu, minijuegos, parque...)

//aqui esta la pantalla
  // El if, este me encanta y lo uso en casi todas partes, te amo if
  if (scene == 0){                                                                    //aqui es una condicion que nos dice que si la escena es 0 (osea el menu principal)
    if (menuImg != null) {                                                            //y que si aqui la imagen del menu si existe
      image(menuImg, 0, 0, width, height);                                              //entonces se dibuja el menu 
    } else {                                                                          //pero como lo cambiamos por una imagen entonces es posible que lo borre
      background(gris);
    }//aca otro if porque porque no no ajjaja esta es para la imagen del menu
    //basicamente esta diciendo que la escena uno es la del menu y que pues ahi se va a poner esa imagen
  } else if (scene == 18) {// aqui un si no, espera era sino en español? bueno si no si la escena es la 18
    if (fB1 != null) {//esta es la variable de la imagen uno o bueno fondo del barrio 1 que esta en los archivos, aqui revisa que si este
      image(fB1, 0, 0, width, height);//porque si no se traba todo el juego asi que si no esta pues se pinta de colot rojo
    } else {
      background(rojoOscuro);
      fondoBarrio(18);   // (v2.0) si no esta la imagen, se dibuja un barrio de noche (Fondos.pde)
    }
  } else if (scene == 19) {//aqui lo mismo pero con la escena del barrio 2
    if (fB2 != null) {//por cierto, lo puse rojo porque antes de colocar las imagenes tenia el fondo rojo y me dio pereza cambiarlo jajajja
      image(fB2, 0, 0, width, height);//asi que deje el rojo
    } else {
      background(rojoOscuro);
      fondoBarrio(19);   // (v2.0)
    }
    // Como no, mis amores, los if
  } else if (scene==9||scene == 3 ||scene==15||scene==16||scene==20||scene==21||scene==22||scene==23) {
    //bueno en esta es obvio pero pues todo color black
    //aqui es si la escena es la 9 o la tres que es el telefono entonces el fondo va a ser negro
    background(negro);
    if (esBarrio(scene)) fondoBarrio(scene);   // (v2.0) las calles del barrio ya no son una pantalla negra
  } else if (scene == 5) {
  } else {                                                                                  //para otras escenas
    background(gris);                                                                  //el fondo va a ser gris
  }
  
  //ajustitos
  //Los amo if, bueno esta es la escena del menu otra vez, perdon por el desorden chicos
  if (scene == 0){                                                                            //si la escena es 0 no se requieren mas elementos extras
  } else if (scene == 1){                                                                  //si la escena es 1 (que es la ciudad)
    if (mapaImg != null) {                                                                //y si la imagen de mapa existe
      image(mapaImg, 0, 0, width, height);      //se dibuja, este if tambien evita en parte que se trabe el juego como pasaba mucho antes
    }
    if (mensajeMapa != "") {//esto va a servir mas adelante
      fill(255, 100, 100);
      textSize(18);
      textAlign(CENTER);
      text(mensajeMapa, width / 2, 470);
    }
    dibujarMapaVivo();   // (v2.0) carros que se mueven, pines de los lugares y lugares nuevos
  } else if(scene == 2) {                                                                 //aqui son los cresitos
    background(gris);                                                                    //y solo se pinta el fondo de gris, despues agregamos lo que va a haber ahi
    //El primer boton de volver y mi pesadilla porque lo repito como 1000 veces en el codigo mas abajo
    //mi peor pesadilla de ahora en adelante... el boton volver
    fill(boton);                                                                              //color para el boton
    rect(25, 20, 50, 30, 8);                                                                    //aqui es para que sea como redondo
    fill(gris);                                                                              //aqui es para el texto
    textSize(14);                                                                            //el tamaño de la fuente
    textAlign(CENTER);                                                                        //para que se alinee al centro (se escribe alinee?)
    text("Volver", 50, 40);                                                                    //para que escriba volver dentro del boton
    
    //la imagen del telefono todo horrendo que ahorita cambio
  } else if(scene == 3) { 
    // Pues esto es lo mismo de las imagenes pero con la imagen del telefono todo horrendo jajaja
    if (telefonoImg != null) {                                                                    //que revise si la imagen carga en la escena 3
      imageMode(CENTER);                                                                      //aqui es para que se cambie el modo de dibujo de la imagen evidentemente al centro
      image(telefonoImg, width/2, height/2, 350, 525);                                          //estos son los ajustes para que se haga mas grande o mas pequeño
      imageMode(CORNER);                                                                         //aqui lo reinicia pero en la esquina superior (derecha o izquierda?)
      //olvidenlo ya vi, es izquierda
    }
    
    // Comprueba una condición o calcula un valor que se usará más adelante.
    //por cierto creo que no explique pero el || significa o, gracias profe por explicar en algoritmia 1
    boolean esEscenaBarrio = (origenTelefono == 5 || origenTelefono == 18 || origenTelefono == 19 ||origenTelefono == 15 || origenTelefono == 20 || origenTelefono == 21 ||origenTelefono == 16 || origenTelefono == 22 || origenTelefono == 23);
    if (!esEscenaBarrio) {//Esta la puse larga porque despues me pierdo y si la acorto se me olvida lo mismo que las de origen de telefono es para que el jugador pues
      //boton de volver x2
      fill(boton);
      rect(25, 20, 50, 30, 8);//pues no se salga del barrio cuando usa el boton de volver cuando esta en el telefono, pero al final me harte porque se me trababa todo
      fill(gris);
      textSize(14);
      textAlign(CENTER);
      text("Volver", 50, 40);//y lo elimine asi que lo mas probable es que lo coloque otra vez despues cuaando sepa como arreglarlo
    }
    
    //Estos de aqui son los botones de las estadisticas que van pero cuando le undes a stats en el telefono
  } else if (scene == 4){ 
    textAlign(CENTER);
    fill(gris);
    rect(180, 110, 400, 260, 10);
    
    textSize(20);                         
    fill(boton);
    text("Viralidad", 240, 150);
    
    //barra de fondo de viralidad
    fill(boton);
    rect(200, 160, 360, 18, 4);         
    rect(200, 160, viralidad * 3.6, 18, 4); 

    fill(boton);
    text("Confiabilidad", 260, 220);
    
    //aqui va la barra de fondo de confiabilidad
    fill(boton);
    rect(200, 230, 360, 18, 4);      
    rect(200, 230, confiabilidad * 3.6, 18, 4); 

//lo mismo que los otros dos de arriba
    fill(boton);
    text("Impacto", 240, 290);
    
    fill(boton);
    rect(200, 300, 360, 18, 4);      
    rect(200, 300, impacto * 3.6, 18, 4); 
    
    //este es un boton auxiliar que va en el menu de estadisticas
    fill(boton);
    rect(725, 20, 50, 30, 8);
    fill(gris);
    textSize(10);
    text("Telefono", 750, 40);
    
    //otra vez el volver
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);

    //Aqui empieza el barrio 1 con el primer personaje que es salomeo pero lo tengo como npc aunque en algunas partes del codigo lo tengo otra vez como salomeo
    //Esperen lo voy a poner en grande
    //---------------------------------------------------------------------------------------
    //                                  BARRIO 1
    //---------------------------------------------------------------------------------------
  } else if (scene == 5) {  //comprueba la imagen otra vez como todas porque cuando no lo hago y no cargan se me explota el pc
    if (pB1 != null) {
      image(pB1, 0, 0, width, height);
    } else {
      background(30);
      fondoEntrada();   // (v2.0) la muralla y la puerta de Nova dibujadas con codigo
    }

    // Se que esto parece escrito en una antigua lengua china pero tiene una explicacion lo prometo no me maten
    float nx = x;
    float ny = y;//estas son temporales y se les asigna la posision actual de la x y y del personaje
    if (moverArriba) {
      ny -= velocidad;
      actual = arriba;
    }//aqui se revisa que tecla esta presionando para los sprites
    if (moverAbajo) {
      ny += velocidad;
      actual = abajo;
    }//basicamente lo que hace es que cambia los sprites dependiendo a la tecla que se le unda
    if (moverIzquierda) {
      nx -= velocidad;
      actual = izquierda;
    }//es un poco complejo pero se le esta restndo velocidad a la posision en este caso horizontal. Como en processing
    if (moverDerecha) {
      nx += velocidad;
      actual = derecha;
    }//el punto 0,0 esta por arriba a la izquierda entonces hay que subir para restar pixeles, con el + es lo mismo pero al contrario
    //osea por ejemplo este: if (moverAbajo) { ny += velocidad; actual = abajo; } suma velocidad a la posision ny para bajar por la pantalla y se coloca el sprite de abajo
    //no se si me entendi
    //basicamente lee las direcciones a tiempo real que se presionan y nx y ny calculan el paso siguiente para que el personaje gire del lado correcto cambiando su sprite actual

    boolean enZonaPuerta = (nx + anchoPersonaje >= 262 && nx <= 529 && ny + altoPersonaje >= 100 && ny <= 270);

    if (llEnt&& enZonaPuerta) {//adivinen que es esto, pues obviamente la puerta. Por cierto && es un y
      pDes = true;//aqui explico mejor,
      mostrarDialogo = false;
      scene = 18;
      x =width /2;
      y=height-80;
      return;//este es para decirle al codigo basicamente basta, ya se cambio de escena y se movio el personaje y ahi cierra el draw. Si no se leyera toda la funcion hasta abajo
      //basicamente no se detendria. Si eso pasa el personaje se traba como me paso y me toco buscar como solucionarlo jajaja. Tambien se agrega en especifico para la puerta . si no lo pongo se dibujan cosas
      //De la primera parte del return
    }

    if (!llEnt) {
      if (enZonaPuerta) {
        nx = x;
        ny = y;
      }
    }

    float dSol = dist(nx, ny, 301, 394);
    boolean zBas = (nx >= 50 && nx <= 150 && ny >= 320 && ny <= 430);
    boolean zBas2 = (nx >= 620 && nx <= 720 && ny >= 320 && ny <= 430);

    if (dSol > 90 && !zBas && !zBas2 && !enZonaPuerta && pD1 > 0) {
      mostrarDialogo = false;
    }

    x = nx;
    y = ny;
    if (x < 0) x = 0;
    if (x > width - anchoPersonaje) x = width - anchoPersonaje;
    if (y < 0) y = 0;
    if (y > height - altoPersonaje) y = height - altoPersonaje;

    fill(a1 ? color(100, 255, 100) : 255);// el "?" es un operador ternario, se usa para operaciones sencillas. Reemplaza al if pero no se puede usar mucho, porque? porque lo intente
    //y me perdi asi que no mas puse un if en otras partes. Practicamente lo que dice es: Si esta de tal color se pinta de ese, si no pues del otro
    stroke(255);
    strokeWeight(2);
    dibujarNPC(301, 419, #5A8C50, #9A9A9A, 0.5, !a1, "Salomeo");   // (v2.0) antes era un cuadro blanco
    noStroke();
    image(actual, x, y, anchoPersonaje, altoPersonaje);
    if (mostrarDialogo) {
      fill(20, 20, 25, 230);
      stroke(255);
      strokeWeight(2);
      rect(30, 370, 740, 110, 10);
      noStroke();
      fill(255);
      textSize(12);
      textAlign(LEFT);
      text(textoDialogo, 45, 395);
      fill(255, 215, 0);
      textSize(11);
      textAlign(RIGHT);
      if (pD1 == 0) {
        text("[Muévete o presiona 'E' para continuar]", 750, 465);
      } else if (dSol < 90 && pD1 < 12) {
        text("[Presiona 'E' para hablar con Salomeo]", 750, 465);
      }
    }
  } else if (scene == 18) {
    float nx = x;
    float ny = y;
    if (moverArriba) {
      ny -= velocidad;
      actual = arriba;
    }//aplica lo mismo de arriba
    if (moverAbajo) {
      ny += velocidad;
      actual = abajo;
    }
    if (moverIzquierda) {
      nx -= velocidad;
      actual = izquierda;
    }
    if (moverDerecha) {
      nx += velocidad;
      actual = derecha;
    }
    if (ny > height) {
      scene = 5;
      y = 10;
    } else if (nx < 0) {
      scene = 19;
      x = width - 70;
    } else if (nx > width - anchoPersonaje) {
      irAEscena(ESC_MERCADO, 1);   // (expansion) a la derecha ahora esta el Mercado del Barrio
      return;
    } else {
      x = nx;
      y = ny;
      if (x < 0) x = 0;
      if (x > width - anchoPersonaje) x = width - anchoPersonaje;
      if (y < 0) y = 0;
      if (y > height - altoPersonaje) y = height - altoPersonaje;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);
    fill(a2 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(292, 394, #3C4C8C, #222222, 1.1, !a2, "Armando");   // (v2.0)
    noStroke();

    if (mostrarDialogo) {
      fill(20, 20, 25, 230);
      stroke(255);
      strokeWeight(2);
      rect(30, 370, 740, 110, 10);
      noStroke();
      fill(255);
      textSize(12);
      textAlign(LEFT);
      text(textoDialogo, 45, 395);

      fill(255, 215, 0);
      textSize(11);
      textAlign(RIGHT);
      float distArmandoCheck = dist(x, y, 292, 369);//aqui es para verificar la distancia, tambien se puede utilizar "abs". El dist se usa para verificar la distancia entre el jugado y el npc
      //me refiero a que por ejemplo  x y y es la posision actual de mi personaje y el 292, 369 del npc
      if (distArmandoCheck < 90) {
        text("[Presiona 'E' para continuar]", 750, 465);
      }
    }
  } else if (scene == 19) {
    float nx = x;
    float ny = y;
    if (!md1) {//aqui es basicamente si el menu de opciones no esta abierto entonces
      if (moverArriba) {//bueno aqui es basicamente subir y bajar y ya
        ny -= velocidad;
        actual = arriba;
      }
      if (moverAbajo) {//bueno e izquierda y derecha
        ny += velocidad;//ya me aburri de narrar porque el resto es basico
        actual = abajo;
      }
      if (moverIzquierda) {
        nx -= velocidad;
        actual = izquierda;
      }
      if (moverDerecha) {
        nx += velocidad;
        actual = derecha;
      }

      if (nx > width) {
        scene = 18;
        x = 10;
      } else {
        x = nx;
        y = ny;
        if (x < 0) x = 0;
        if (x > width - anchoPersonaje) x = width - anchoPersonaje;
        if (y < 0) y = 0;
        if (y > height - altoPersonaje) y = height - altoPersonaje;
      }
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);

    fill(a3 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(width/2, height/2 + 25, #8C3C64, #643C28, 2.2, !a3, "Junta Vecinal");   // (v2.0)
    noStroke();
    if (!md1) {
      if (mostrarDialogo) {
        fill(20, 20, 25, 230);
        stroke(255);
        strokeWeight(2);
        rect(30, 390, 740, 85, 10);
        noStroke();
        fill(255);
        textSize(14);
        textAlign(LEFT);
        text(textoDialogo != "" ? textoDialogo : m3, 50, 430);
      }
    } else {
      fill(15, 15, 20, 240);
      stroke(255);
      strokeWeight(2);
      rect(20, 310, 760, 170, 8);

      fill(255, 215, 0);
      textAlign(LEFT);
      textSize(13);
      text("Que decides hacer?", 35, 330);

      stroke(255);
      strokeWeight(1);
      fill(30);
      rect(35, 340, 730, 38, 5);
      fill(30);
      rect(35, 385, 730, 38, 5);
      fill(30);
      rect(35, 430, 730, 38, 5);
      noStroke();
      fill(255);
      textSize(12);
      text("1. Compartir noticia urgente (+Viralidad, -Confiabilidad)", 45, 363);//despues arreglo esto no mas lo estaba probando
      text("2. Verificar informacion oficial (+Confiabilidad, -Viralidad)", 45, 408);
      text("3. Ignorar la situacion (-Impacto)", 45, 453);//por cierto lo puse para guiarme que baja y que sube pero luego lo borro
    }
  } else if (scene == 15) {
    float nx = x;
    float ny = y;
    if (moverArriba) {
      ny -= velocidad;
      actual = arriba;
    }
    if (moverAbajo) {
      ny += velocidad;
      actual = abajo;
    }
    if (moverIzquierda) {
      nx -= velocidad;
      actual = izquierda;
    }
    if (moverDerecha) {
      nx += velocidad;
      actual = derecha;
    }

    if (ny < 0) {
      scene = 20;
      y = height - 70;
    } else {
      x = nx;
      y = ny;
      if (x < 0) x = 0;
      if (x > width - anchoPersonaje) x = width - anchoPersonaje;
      if (y < 0) y = 0;
      if (y > height - altoPersonaje) y = height - altoPersonaje;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);

    fill(b1 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(205, 230, #DC8C28, #E6C878, 7.7, !b1, "El Chisme Vio");   // (v2.0)
    noStroke();
    if (mostrarDialogo) {
      fill(20, 20, 25, 230);
      stroke(255);
      strokeWeight(2);
      rect(30, 390, 740, 85, 10);
      noStroke();
      fill(255);
      textSize(14);
      textAlign(LEFT);
      text(textoDialogo != "" ? textoDialogo : m4, 50, 430);
    }

    // Barrio 2
  } else if (scene == 20) {
    float nx = x;
    float ny = y;
    if (moverArriba) {
      ny -= velocidad;
      actual = arriba;
    }
    if (moverAbajo) {
      ny += velocidad;
      actual = abajo;
    }
    if (moverIzquierda) {
      nx -= velocidad;
      actual = izquierda;
    }
    if (moverDerecha) {
      nx += velocidad;
      actual = derecha;
    }

    if (ny > height) {
      scene = 15;
      y = 10;
    } else if (nx < 0) {
      scene = 21;
      x = width - 70;
    } else {
      x = nx;
      y = ny;
      if (x < 0) x = 0;
      if (x > width - anchoPersonaje) x = width - anchoPersonaje;
      if (y < 0) y = 0;
      if (y > height - altoPersonaje) y = height - altoPersonaje;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);
    fill(b2 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(width/2, height/2 + 25, #2896A0, #141414, 3.3, !b2, "Aquiles");   // (v2.0)
    noStroke();

    if (mostrarDialogo) {
      fill(20, 20, 25, 230);
      stroke(255);
      strokeWeight(2);
      rect(30, 390, 740, 85, 10);
      noStroke();
      fill(255);
      textSize(14);
      textAlign(LEFT);
      text(textoDialogo != "" ? textoDialogo : m5, 50, 430);
    }

    //bario 2 sigue
  } else if (scene == 21) {
    float nx = x;
    float ny = y;
    if (!md2) {
      if (moverArriba) {
        ny -= velocidad;
        actual = arriba;
      }
      if (moverAbajo) {
        ny += velocidad;
        actual = abajo;
      }
      if (moverIzquierda) {
        nx -= velocidad;
        actual = izquierda;
      }
      if (moverDerecha) {
        nx += velocidad;
        actual = derecha;
      }
      if (nx > width) {
        scene = 20;
        x = 10;
      } else {
        x = nx;
        y = ny;
        if (x < 0) x = 0;
        if (x > width - anchoPersonaje) x = width - anchoPersonaje;
        if (y < 0) y = 0;
        if (y > height - altoPersonaje) y = height - altoPersonaje;
      }
    }
    image(actual, x, y, anchoPersonaje, altoPersonaje);
    fill(b3 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(width/2, height/2 + 25, #B44678, #8C3C1E, 4.4, !b3, "Debora");   // (v2.0)
    noStroke();

    if (!md2) {
      if (mostrarDialogo) {
        fill(20, 20, 25, 230);
        stroke(255);
        strokeWeight(2);
        rect(30, 390, 740, 85, 10);
        noStroke();
        fill(255);
        textSize(14);
        textAlign(LEFT);
        text(textoDialogo != "" ? textoDialogo : m6, 50, 430);
      }
    } else {
      fill(15, 15, 20, 240);
      stroke(255);
      strokeWeight(2);
      rect(20, 310, 760, 170, 8);

      fill(255, 215, 0);
      textAlign(LEFT);
      textSize(13);
      text("¿Qué decides hacer?", 35, 330);

      stroke(255);
      strokeWeight(1);
      fill(30);
      rect(35, 340, 730, 38, 5);
      fill(30);
      rect(35, 385, 730, 38, 5);
      fill(30);
      rect(35, 430, 730, 38, 5);
      noStroke();

      fill(255);
      textSize(12);
      text("1. Difundir rumor de protestas", 45, 363);
      text("2. Investigar en la plaza principal", 45, 408);
      text("3. Ignorar reportes vecinales", 45, 453);
    }

    //bario 3
  } else if (scene == 16) {
    float nx = x;
    float ny = y;
    if (moverArriba) {
      ny -= velocidad;
      actual = arriba;
    }
    if (moverAbajo) {
      ny += velocidad;
      actual = abajo;
    }
    if (moverIzquierda) {
      nx -= velocidad;
      actual = izquierda;
    }
    if (moverDerecha) {
      nx += velocidad;
      actual = derecha;
    }

    if (ny < 0) {
      scene = 22;
      y = height - 70;
    } else {
      x = nx;
      y = ny;
      if (x < 0) x = 0;
      if (x > width - anchoPersonaje) x = width - anchoPersonaje;
      if (y < 0) y = 0;
      if (y > height - altoPersonaje) y = height - altoPersonaje;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);

    fill(c1 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(205, 230, #E6B43C, #3C2814, 8.8, !c1, "Lola Mento");   // (v2.0)
    noStroke();

    if (mostrarDialogo) {
      fill(20, 20, 25, 230);
      stroke(255);
      strokeWeight(2);
      rect(30, 390, 740, 85, 10);
      noStroke();
      fill(255);
      textSize(14);
      textAlign(LEFT);
      text(textoDialogo != "" ? textoDialogo : m7, 50, 430);
    }
  } else if (scene == 22) {
    float nx = x;
    float ny = y;
    if (moverArriba) {
      ny -= velocidad;
      actual = arriba;
    }
    if (moverAbajo) {
      ny += velocidad;
      actual = abajo;
    }
    if (moverIzquierda) {
      nx -= velocidad;
      actual = izquierda;
    }
    if (moverDerecha) {
      nx += velocidad;
      actual = derecha;
    }
    if (ny > height) {
      scene = 16;
      y = 10;
    } else if (nx < 0) {
      scene = 23;
      x = width - 70;
    } else {
      x = nx;
      y = ny;
      if (x < 0) x = 0;
      if (x > width - anchoPersonaje) x = width - anchoPersonaje;
      if (y < 0) y = 0;
      if (y > height - altoPersonaje) y = height - altoPersonaje;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);
    fill(c2 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(width/2, height/2 + 25, #6E50B4, #DCDCDC, 5.5, !c2, "Elsa Pito");   // (v2.0)
    noStroke();

    if (mostrarDialogo) {
      fill(20, 20, 25, 230);
      stroke(255);
      strokeWeight(2);
      rect(30, 390, 740, 85, 10);
      noStroke();
      fill(255);
      textSize(14);
      textAlign(LEFT);
      text(textoDialogo != "" ? textoDialogo : m8, 50, 430);
    }
  } else if (scene == 23) {
    float nx = x;
    float ny = y;
    if (!md3) {
      if (moverArriba) {
        ny -= velocidad;
        actual = arriba;
      }
      if (moverAbajo) {
        ny += velocidad;
        actual = abajo;
      }
      if (moverIzquierda) {
        nx -= velocidad;
        actual = izquierda;
      }
      if (moverDerecha) {
        nx += velocidad;
        actual = derecha;
      }

      if (nx > width) {
        scene = 22;
        x = 10;
      } else {
        x = nx;
        y = ny;
        if (x < 0) x = 0;
        if (x > width - anchoPersonaje) x = width - anchoPersonaje;
        if (y < 0) y = 0;
        if (y > height - altoPersonaje) y = height - altoPersonaje;
      }
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);
    fill(c3 ? color(100, 255, 100) : 255);
    stroke(255);
    dibujarNPC(width/2, height/2 + 25, #283C78, #B4B4B4, 6.6, !c3, "Benito");   // (v2.0)
    noStroke();

    if (!md3) {
      if (mostrarDialogo) {
        fill(20, 20, 25, 230);
        stroke(255);
        strokeWeight(2);
        rect(30, 390, 740, 85, 10);
        noStroke();
        fill(255);
        textSize(14);
        textAlign(LEFT);
        text(textoDialogo != "" ? textoDialogo : m9, 50, 430);
      }
    } else {
      fill(15, 15, 20, 240);
      stroke(255);
      strokeWeight(2);
      rect(20, 310, 760, 170, 8);

      fill(255, 215, 0);
      textAlign(LEFT);
      textSize(13);
      text("Que decides hacer?", 35, 330);

      stroke(255);
      strokeWeight(1);
      fill(30);
      rect(35, 340, 730, 38, 5);
      fill(30);
      rect(35, 385, 730, 38, 5);
      fill(30);
      rect(35, 430, 730, 38, 5);
      noStroke();
      fill(255);
      textSize(12);
      text("1. Apoyar postura de asamblea", 45, 363);
      text("2. Actuar como mediador", 45, 408);
      text("3. Retirarse del lugar", 45, 453);
    }
    //lo mismo de alla que combrueba que la imagen exista
    // (escena 28: antes era la 5 en el codigo de la alcaldia y del colegio)
  } else if (scene == 28){ 
    background(negro);
    if (foto != null) {
      image(foto, 150, 50, 530, 250);
    }
    
    //aqui empieza la escena del barrio
    textAlign(LEFT);
    fill(boton);
    textSize(20);
    text("Llegas a tu barrio despues de un largo dia de clases \nte pones a pensar que hacer", 200, 325);
    //se dibuja el boton de continuar
    noStroke();
    fill(0);
    rect(510, 415, 150, 60);

    stroke(255);
    strokeWeight(4);
    rect(510, 415, 150, 60);
    
    noStroke();
    fill(boton);
    textSize(25);
    text("Continuar", 530, 450);
    //el de volver
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);
    //se carga la imagen que es la del evento del poster
  } else if (scene == 6) {
    background(negro);
    if (foto1 != null) {
      image(foto1, 150, 50, 530, 250);
    }
    //me canse de narrar, solo voy a narrar cuando lo necesite de verdad
    textAlign(LEFT);
    fill(boton);
    textSize(20);
    text("Continuas por la calles del barrio y encuentras un poster... \nQue decides hacer?", 150, 325);
    
    fill(0);
    rect(515, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(515, 415, 150, 60);
    
    noStroke();
    fill(boton);
    textSize(25);
    text("Compartir", 530, 450);
   
    fill(0);
    rect(95, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(95, 415, 150, 60);
    
    noStroke();
    fill(boton);
    textSize(25);
    text("Ignorar", 120, 450);
    
    fill(0);
    rect(305, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(305, 415, 150, 60);
    
    noStroke();
    fill(boton);
    textSize(25);
    text("Volver", 325, 450);
    
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);
    //escena/evento del colegio
  } else if (scene == 7) {                                                                    ///////////
    /* background(negro);
    
    fill(gris);
    rect(150, 50, 530, 250, 10);
    fill(boton);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("COLEGIO", 415, 120);

    textAlign(LEFT);
    textSize(18);
    text("Un compañero publicó la imagen de otro \nestudiante en el descanso sin su permiso.\nElige qué harás:", 170, 180);
    
    //boton de hablar
    fill(0);
    rect(100, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(100, 415, 150, 60);
    noStroke();
    fill(boton);
    textSize(22);
    textAlign(CENTER, CENTER);
    text("Hablar", 175, 445);
    
    //boton de ignorar
    fill(0);
    rect(325, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(325, 415, 150, 60);
    noStroke();
    fill(boton);
    textSize(22);
    text("Ignorar", 400, 445);
    
    //boton de compartir      
    fill(0);
    rect(550, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(550, 415, 150, 60);
    noStroke();
    fill(boton);
    textSize(22);
    text("Compartir", 625, 445);
    
    //boton canson de volver
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Volver", 50, 35);
    */
    //si la escena es la 8 (la de la alcaldia)
        
        obstaculosActuales = obstaculoscolegio1;
    image(calle1, 0, 0, width, height);

    // Movimiento (se pausa mientras hablas)
    if (!mostrarDialogo) {
      float nuevaX = x;
      float nuevaY = y;

      if (moverArriba)    nuevaY -= velocidad;
      if (moverAbajo)     nuevaY += velocidad;
      if (moverIzquierda) nuevaX -= velocidad;
      if (moverDerecha)   nuevaX += velocidad;

      if (!hayColision(nuevaX, y)) x = nuevaX;
      if (!hayColision(x, nuevaY)) y = nuevaY;
    }

    if (estaEnZona(x, y, Zonacambio)) {
      CerrarDialogo();
      scene = 25;
      x = 700;
      y = (height/2) - 20;
    }

    // Dibuja al personaje en su posicion actual, con la imagen correspondiente
    image(actual, x, y, anchoPersonaje, altoPersonaje);


    DnpcDialog();
    

  } else if (scene == 8) {
  if (alcaldia != null) {
    image(alcaldia, 0, 0, width, height);
  } else {
    fondoAlcaldia();   // (v2.0) plaza con multitud animada si no esta alcaldia.jpeg
  }

  // Movimiento (bloqueado mientras hay diálogo)
  if (!hablando) {
    float nuevaX = x;
    float nuevaY = y;
    if (moverArriba)    nuevaY -= velocidad;
    if (moverAbajo)     nuevaY += velocidad;
    if (moverIzquierda) nuevaX -= velocidad;
    if (moverDerecha)   nuevaX += velocidad;
    if (!hayColision2(nuevaX, y)) x = nuevaX;
    if (!hayColision2(x, nuevaY)) y = nuevaY;
  }

  // Personaje y NPCs
  image(actual, x, y, anchoPersonaje, altoPersonaje);
  noStroke();
  if (empleado != null) image(empleado, 350, 215, 40, 60); else dibujarNPC(370, 275, #3C5AA0, #282828, 3, false, "Empleado");   // (v2.0) sin la imagen el juego se cerraba
  if (candidatos != null) image(candidatos, 347, 145, 120, 60); else dibujarCandidatos();   // (v2.0)
  rectMode(CORNER);

  if (hablando) {
    // Cuadro de diálogo
    fill(0, 220);
    stroke(255);
    strokeWeight(3);
    rect(50, 340, 700, 130, 10);
    noStroke();

    // Nombre de quien habla
    textAlign(LEFT);
    if (!quien[dialogoIdx].equals("")) {
      fill(255, 200, 0);
      textSize(18);
      text(quien[dialogoIdx], 70, 365);
    }

    // Texto (con ajuste automático dentro de la caja)
    fill(boton);
    textSize(17);
    text(linea[dialogoIdx], 70, 375, 660, 70);

    // Indicador
    textSize(14);
    text("Presiona E para continuar (" + (dialogoIdx + 1) + "/" + linea.length + ")", 70, 458);
  } else {
    // Botón continuar (solo cuando terminó el diálogo)
    fill(0);
    stroke(255);
    strokeWeight(4);
    rect(510, 415, 150, 60);
    noStroke();
    fill(boton);
    textAlign(LEFT);
    textSize(25);
    text("Continuar", 530, 450);
  }

  // Botón volver
  fill(boton);
  rect(25, 20, 50, 30, 8);
  fill(gris);
  textSize(14);
  textAlign(CENTER);
  text("Volver", 50, 40);

//el de volver que no hace nada porque no lo he programado pero bueno
  } else if (scene == 9) {

    fill(boton);
    textSize(24);
    textAlign(CENTER);
    text("Volviendo...", width/2, height/2);
    
    //Ay ya boton canson
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    text("Volver", 50, 40);

  } else if (scene == 10){ //aqui es el resultado de la decision que se escogio en el barrio
    background(negro);
    fill(gris);
    rect(100, 40, 600, 400);
    
    fill(255);
    textSize(25);
    textAlign(LEFT);
    
    //si se escogio la primera decision
    if (decC == 1) { 
      textSize(22);
      text("Compartiste la publicacion sin verificar.\nLa viralidad sube, pero pierdes confiabilidad.", 130, 130, 550, 200);
    } else {
      textSize(22);
      text("Decidiste ignorar la publicacion.\nSigue circulando, pero tu no ayudaste a propagarla.", 130, 130, 550, 200);
    }
    
    //volver
    fill(0);
    rect(150, 340, 150, 60, 8);
    stroke(255);
    strokeWeight(4);
    rect(150, 340, 150, 60, 8);
    noStroke();
    fill(boton);
    textAlign(CENTER);
    textSize(22);
    text("Volver", 225, 375);

    //continuar
    fill(0);
    rect(500, 340, 150, 60, 8);
    stroke(255);
    strokeWeight(4);
    rect(500, 340, 150, 60, 8);
    noStroke();
    fill(boton);
    text("Continuar", 575, 375);

    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    text("Volver", 50, 40);

    //la alcaldia
  } else if (scene == 11) {
  if (alcaldia != null) {
    image(alcaldia, 0, 0, width, height);
  } else {
    fondoAlcaldia();   // (v2.0) plaza con multitud animada si no esta alcaldia.jpeg
  }

  // Personaje y NPCs (el personaje se queda quieto mientras decides)
  image(actual, x, y, anchoPersonaje, altoPersonaje);
  noStroke();
  if (empleado != null) image(empleado, 350, 215, 40, 60); else dibujarNPC(370, 275, #3C5AA0, #282828, 3, false, "Empleado");   // (v2.0) sin la imagen el juego se cerraba
  if (candidatos != null) image(candidatos, 347, 145, 120, 60); else dibujarCandidatos();   // (v2.0)
  rectMode(CORNER);

  // Cuadro de diálogo
  fill(0, 220);
  stroke(255);
  strokeWeight(3);
  rect(50, 290, 700, 195, 10);
  noStroke();

  fill(255, 200, 0);
  textAlign(LEFT);
  textSize(18);
  text("¿Qué decides hacer?", 70, 315);

  // Opciones
  for (int i = 0; i < opciones.length; i++) {
    float by = 330 + i * 52;
    boolean sobre = mouseX > 70 && mouseX < 730 && mouseY > by && mouseY < by + 42;

    fill(sobre ? color(80) : color(0));
    stroke(255);
    strokeWeight(2);
    rect(70, by, 660, 42, 8);

    noStroke();
    fill(boton);
    textAlign(LEFT, CENTER);
    textSize(15);
    text((i + 1) + ". " + opciones[i], 85, by + 21);
  }

  // Botón volver
  fill(boton);
  rect(25, 20, 50, 30, 8);
  fill(gris);
  textSize(14);
  textAlign(CENTER);
  text("Volver", 50, 40);
} else if (scene == 12) { 
    background(negro);
    rectMode(CORNER);
    textAlign(LEFT);
    fill(gris);
    rect(100, 40, 600, 400);
    
    //lo que pasa
    fill(255);
    textSize(25);
    fill(255);
textAlign(LEFT);
textSize(22);
if (decC == 1) {
  text("Defendiste a Clemencia en tus redes sociales.\nTu voz gana impacto y la gente empieza a escucharte.", 130, 130, 540, 150);
} else if (decC == 2) {
  text("Decidiste no intervenir.\nLa protesta sigue su curso sin tu participación.", 130, 130, 540, 150);
} else if (decC == 3) {
  text("Hablaste mal de la candidata en la protesta.\nLa viralidad sube, pero pierdes confiabilidad.", 130, 130, 540, 150);
}

fill(boton);
rect(25, 20, 50, 30, 8);
fill(gris);
textSize(14);
textAlign(CENTER);
text("Volver", 50, 40);

} else if (scene == 13) {
    background(negro);
    textAlign(CENTER);
    fill(boton);
    textSize(32);
    text("En construcción", width/2, height/2);
    
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    text("Volver", 50, 40);
    
  } else if (scene == 14) { 
    background(negro);
    rectMode(CORNER);
    textAlign(LEFT);
    
    fill(gris);
    rect(100, 40, 600, 280, 10);

    fill(255);
    textSize(20);
    
    if (decC == 1) {
      text("Hablaste con tu compañero y resolvieron\nel malentendido de forma pacífica.", 130, 80, 540, 150);
    } else if (decC == 2) {
      text("Decidiste ignorar la situación.\nEl problema sigue su curso.", 130, 80, 540, 150);
    } else if (decC == 3) {
      text("Compartiste la foto sin pensar.\nAumenta la viralidad, pero dañas la convivencia.", 130, 80, 540, 150);
    }

    textSize(16);
    fill(boton);
    text("Viralidad: " + int(viralidad) + " | Confiabilidad: " + int(confiabilidad) + " | Impacto: " + int(impacto), 130, 230);
    
    fill(0);
    rect(325, 340, 150, 50, 8);
    stroke(255);
    strokeWeight(2);
    rect(325, 340, 150, 50, 8);
    noStroke();
    fill(boton);
    textSize(18);
    textAlign(CENTER, CENTER);
    text("Continuar", 400, 365);
    
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("Volver", 50, 35);
    
  } else if (scene == 17){
    
    obstaculosActuales = obstaculoscolegio4;
    
     image(calle4, 0, 0, width, height);

        // Movimiento (se pausa mientras hablas)
    if (!mostrarDialogo) {
      float nuevaX = x;
      float nuevaY = y;

      if (moverArriba)    nuevaY -= velocidad;
      if (moverAbajo)     nuevaY += velocidad;
      if (moverIzquierda) nuevaX -= velocidad;
      if (moverDerecha)   nuevaX += velocidad;

      if (!hayColision(nuevaX, y)) x = nuevaX;
      if (!hayColision(x, nuevaY)) y = nuevaY;
    }

    if (estaEnZona(x, y, Zonacambio5)) {
      CerrarDialogo();
      scene = 26;
      x = 300;
      y = 20;
    }
    
    if (estaEnZona(x, y, Zonacambio4)) {
      CerrarDialogo();
      scene = 25;
      x = 360;
      y = 40;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);

    DnpcDialog();

    // ------------------- ALCALDIA (hall con el empleado), antes escena 16 -------------------
    //alcaldia
    }else if (scene == 24) { 
      
    if (alcaldia != null) {                   //se verifica si la imagen existe
      image(alcaldia, 0, 0, width, height);                                              
    } else {
      fondoAlcaldia();   // (v2.0)
    }
    noStroke();
    if (empleado != null) image(empleado, 350, 215, 40, 60); else dibujarNPC(370, 275, #3C5AA0, #282828, 3, false, "Empleado");   // (v2.0) sin la imagen el juego se cerraba

  float nuevaX = x;
  float nuevaY = y;
  if (moverArriba)    nuevaY -= velocidad;
  if (moverAbajo)     nuevaY += velocidad;
  if (moverIzquierda) nuevaX -= velocidad;
  if (moverDerecha)   nuevaX += velocidad;

  // colisiones
    if (!hayColision2(nuevaX, y)) x = nuevaX;
    if (!hayColision2(x, nuevaY)) y = nuevaY;

  // Personaje
  image(actual, x, y, anchoPersonaje, altoPersonaje);

 cercaNPC = choca(x, y, npcX - 30, npcY - 30, npcW + 60, npcH + 60);
  if (cercaNPC && !hablando) {
    fill(boton);
    textAlign(CENTER);
    textSize(18);
    text("Presiona E para hablar", npcX + npcW/2, npcY - 15);
  }

  // Botón volver
  fill(boton);
  rect(25, 20, 50, 30, 8);
  fill(gris);
  textSize(14);
  textAlign(CENTER);
  text("Volver", 50, 40);    
  
  // Cuadro de diálogo
  if (hablando) {
    fill(0, 220);
    stroke(255);
    strokeWeight(3);
    rect(50, 340, 700, 130, 10);
    noStroke();
    fill(boton);
    textAlign(LEFT); 
    textSize(20);
    text("Holaa!! Bienvenidx a la alcandia!!\nPuedes pasar para informarte sobre las elecciones...", 70, 375);
    textSize(14);
    text("Presiona E para continuar", 70, 455);
  }

  // ------------------- COLEGIO calle 2 (antes escena 15) -------------------
  } else if (scene == 25){
   
    obstaculosActuales = obstaculoscolegio2;
    
 image(calle2, 0, 0, width, height);

    // Movimiento (se pausa mientras hablas)
    if (!mostrarDialogo) {
      float nuevaX = x;
      float nuevaY = y;

      if (moverArriba)    nuevaY -= velocidad;
      if (moverAbajo)     nuevaY += velocidad;
      if (moverIzquierda) nuevaX -= velocidad;
      if (moverDerecha)   nuevaX += velocidad;

      if (!hayColision(nuevaX, y)) x = nuevaX;
      if (!hayColision(x, nuevaY)) y = nuevaY;
    }

    if (estaEnZona(x, y, Zonacambio2)) {
      CerrarDialogo();
      scene = 7;
      x = 100;
      y = height/2;
    }
    
    if (estaEnZona(x, y, Zonacambio3)) {
      CerrarDialogo();
      scene = 26;
      x = 720;
      y = 400;
    }
    
    if (estaEnZona(x, y, Zonacafe1)) {
      CerrarDialogo();
      scene = 27;
      x = 310;
      y = 400;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);

    DnpcDialog();
    
  // ------------------- COLEGIO calle 3 (antes escena 16) -------------------
  } else if (scene == 26){
    
        obstaculosActuales = obstaculoscolegio3;
    
 image(calle3, 0, 0, width, height);

    // Movimiento (se pausa mientras hablas)
    if (!mostrarDialogo) {
      float nuevaX = x;
      float nuevaY = y;

      if (moverArriba)    nuevaY -= velocidad;
      if (moverAbajo)     nuevaY += velocidad;
      if (moverIzquierda) nuevaX -= velocidad;
      if (moverDerecha)   nuevaX += velocidad;

      if (!hayColision(nuevaX, y)) x = nuevaX;
      if (!hayColision(x, nuevaY)) y = nuevaY;
    }

    if (estaEnZona(x, y, Zonacambio3)) {
      CerrarDialogo();
      scene = 17;
      x = 300;
      y = 440;
    }
    
    if (estaEnZona(x, y, Zonacambio4)) {
      CerrarDialogo();
      scene = 25;
      x = 360;
      y = 40;
    }

    image(actual, x, y, anchoPersonaje, altoPersonaje);

    DnpcDialog();
  
  // ------------------- COLEGIO Cafe 404 (antes escena 18) -------------------
  } else if (scene == 27) {
     background(#000000);
    
     obstaculosActuales = obstaculosCafe1;
    
     image(cafe1, 50, 90, 700, 400);

        // Movimiento (se pausa mientras hablas)
    if (!mostrarDialogo) {
      float nuevaX = x;
      float nuevaY = y;

      if (moverArriba)    nuevaY -= velocidad;
      if (moverAbajo)     nuevaY += velocidad;
      if (moverIzquierda) nuevaX -= velocidad;
      if (moverDerecha)   nuevaX += velocidad;

      if (!hayColision(nuevaX, y)) x = nuevaX;
      if (!hayColision(x, nuevaY)) y = nuevaY;
    }

    if (estaEnZona(x, y, Zonacambio5)) {
      CerrarDialogo();
      scene = 25;
      x = 534;
      y = 155;
    }
    


    image(actual, x, y, anchoPersonaje, altoPersonaje);

    DnpcDialog();

  // ------------------- escena 29: intro alcaldia del colegio (antes escena 8) -------------------
  } else if (scene == 29) {                                                        /////////////////////////
    background(negro);
    rectMode(CORNER);
    
    fill(gris);
    rect(150, 50, 530, 250, 10);
    fill(boton);
    textAlign(CENTER, CENTER);
    textSize(28);
    text("ALCALDIA DE NOVA", 415, 180);

    textAlign(LEFT);
    fill(boton);
    textSize(20);
    text("Llegas a la alcaldia en plena campaña electoral. \nHay carteles por todas partes y la gente habla de las elecciones.", 150, 325);
    

    noStroke();
    fill(0);
    rect(510, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(510, 415, 150, 60);
    fill(boton);
    textSize(25);
    text("Continuar", 530, 450);

    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);

  // ------------------- escena 30: compartir / verificar (antes escena 11 del colegio) -------------------
  } else if (scene == 30) { 
    background(negro);
    rectMode(CORNER);
    
    fill(gris);
    rect(150, 50, 530, 250, 10);
    fill(boton);
    textAlign(LEFT);
    textSize(16);
    text("Conecta - publicacion", 170, 80);
    textSize(18);
    text("\"URGENTE: el candidato Ramirez\nquiere cerrar el colegio.\"", 170, 130);

    fill(boton);
    textSize(20);
    text("Que decides hacer?", 150, 325);

    fill(0);
    rect(510, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(510, 415, 150, 60);
    fill(boton);
    textSize(25);
    text("Compartir", 530, 450);

    fill(0);
    rect(100, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(100, 415, 150, 60);
    fill(boton);
    textSize(25);
    text("Verificar", 120, 450);

    fill(0);
    rect(305, 415, 150, 60);
    stroke(255);
    strokeWeight(4);
    rect(305, 415, 150, 60);
    fill(boton);
    textSize(25);
    text("Volver", 325, 450);

    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);

  // ------------------- escena 31: resultado compartir / verificar (antes escena 12 del colegio) -------------------
  } else if (scene == 31) { 
    background(negro);
    rectMode(CORNER);
    textAlign(LEFT);
    fill(gris);
    rect(100, 40, 600, 400);
    
    //lo que pasa
    fill(255);
    textSize(25);
    if (decC == 1) { 
      textSize(22);
      text("Compartiste la noticia sin verificar.\nLa viralidad sube, pero pierdes confiabilidad.", 130, 130);
    } else if (decC == 2) { 
      textSize(22);
      text("Verificaste la fuente antes de actuar.\nTu confiabilidad y tu impacto suben.", 130, 130);
    }
    
    textSize(16);
    text("Viralidad: " + int(viralidad) + " | Confiabilidad: " + int(confiabilidad) + " | Impacto: " + int(impacto), 130, 300);
    
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);

  // ------------------- escenas del codigo del barrio que chocaban con numeros de las otras -------------------
  // escena 32 (antes escena 8 del barrio)
  } else if (scene == 32) {
    background(negro);
    if (foto != null) {
      image(foto, 150, 50, 530, 250);
    }
    textAlign(LEFT);
    fill(boton);
    textSize(20);
    text("Estas investigando un nuevo caso...\nQue deseas hacer?", 150, 325);

    fill(0);
    stroke(255);
    strokeWeight(4);
    rect(510, 415, 150, 60);
    noStroke();
    fill(boton);
    textSize(25);
    text("Aceptar", 535, 450);
    fill(0);
    rect(25, 20, 50, 30, 8);
    stroke(255);
    strokeWeight(2);
    rect(25, 20, 50, 30, 8);
    noStroke();
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);
  // escena 33 (antes escena 10 del barrio)
  } else if (scene == 33) {
    background(negro);
    fill(gris);
    rect(100, 40, 600, 400);
    fill(255);
    textSize(25);
    textAlign(LEFT);
    text("Ya se registro la respuesta", 130, 130, 550, 200);

    fill(0);
    rect(150, 340, 150, 60, 8);
    stroke(255);
    strokeWeight(4);
    rect(150, 340, 150, 60, 8);
    noStroke();
    fill(boton);
    textAlign(CENTER);
    textSize(22);
    text("Volver", 225, 375);
    fill(0);
    rect(500, 340, 150, 60, 8);
    stroke(255);
    strokeWeight(4);
    rect(500, 340, 150, 60, 8);
    noStroke();
    fill(boton);
    text("Continuar", 575, 375);
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    text("Volver", 50, 40);
  // escena 34 (antes escena 12 del barrio)
  } else if (scene == 34) {
    background(negro);
    rectMode(CORNER);
    textAlign(LEFT);
    fill(gris);
    rect(100, 40, 600, 400);
    fill(255);
    textSize(22);
    text("Resultado guardado correctamente.", 130, 130);
    textSize(16);
    text("Viralidad: " + int(viralidad) + "  Confiabilidad: " + int(confiabilidad) + "  Impacto: " + int(impacto), 130, 300);
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);
  // escena 35 (antes escena 14 del barrio)
  } else if (scene == 35) {
    background(negro);
    rectMode(CORNER);
    textAlign(LEFT);
    fill(gris);
    rect(100, 40, 600, 280, 10);
    fill(255);
    textSize(20);
    text("Acción procesada.", 130, 80, 540, 150);
    textSize(16);
    fill(boton);
    text("Viralidad: " + int(viralidad) + " | Confiabilidad: " + int(confiabilidad) + " | Impacto: " + int(impacto), 130, 230);
    fill(0);
    rect(325, 340, 150, 50, 8);
    stroke(255);
    strokeWeight(2);
    rect(325, 340, 150, 50, 8);
    noStroke();
    fill(boton);
    textAlign(CENTER);
    textSize(20);
    text("Continuar", 400, 372);
    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    text("Volver", 50, 40);
  // escena 36 (antes escena 4 del barrio): estadisticas con numeros
  } else if (scene == 36) {
    textAlign(CENTER);
    fill(gris);
    rect(180, 90, 440, 320, 10);

    textSize(22);
    fill(boton);
    text("ESTADISTICAS DEL JUGADOR", width/2, 125);
    //no mas es lo del texto que va en las estadisticas, este no lo cree yo
    textSize(18);
    textAlign(LEFT);
    text("Viralidad: " + int(viralidad), 210, 170);
    rect(210, 180, 360, 16, 4);
    rect(210, 180, viralidad * 3.6, 16, 4);

    text("Confiabilidad: " + int(confiabilidad), 210, 235);
    rect(210, 245, 360, 16, 4);
    rect(210, 245, confiabilidad * 3.6, 16, 4);

    text("Impacto: " + int(impacto), 210, 300);
    rect(210, 310, 360, 16, 4);
    rect(210, 310, impacto * 3.6, 16, 4);

    fill(boton);
    rect(25, 20, 50, 30, 8);
    fill(gris);
    textSize(14);
    textAlign(CENTER);
    text("Volver", 50, 40);
  }
  
  
  


vidaDespuesDeDibujar();   // (v2.0) clima, particulas, HUD, telefono, pausa, avisos y transiciones
if (!modoDebug) return;   // (v2.0) las coordenadas ahora salen solo con F3, asi no ensucian el juego

// Sistema para ver las coordenadas del mouse
fill(255, 0, 0);
noStroke();
ellipse(mouseX, mouseY, 6, 6);  // un puntito rojo donde está el mouse

fill(255);
textAlign(LEFT);
textSize(14);
text(mouseX + ", " + mouseY, mouseX + 10, mouseY - 10);  // muestra el número al lado del mouse

  //estas son las coodenadas del mouse para saber donde poner los personajes y eso. Despues lo borro
  fill(255, 255, 0);
  textSize(12);
  textAlign(LEFT, TOP);
  text("X: " + int(mouseXCoord) + " | Y: " + int(mouseYCoord), 10, 10);
}



//estos son los que detectan los clics, en algunos se usa mouseClicked y en otros mouse pressed porque mousePressed es mucho mas rapido
//pero por ejemplo si hay dos volver en la misma escena se traba y cumplen la misma funcion cuando no debe
void mouseClicked() {
  if (ignorarClick || pausaAbierta || telefonoAbierto || scene == 0 || scene == 2 || scene >= 40) return;   // (v2.0) ese clic ya se uso
  if (scene == 2 && mouseX > 25 && mouseX < 75 && mouseY > 20 && mouseY < 50) {
    scene = 0; 
    return;
  }
  
  // Para el resto de pantallas que usan el botón de volver estándar, regresan al mapa (scene = 1)
  if (scene != 0 && scene != 2 && mouseX > 25 && mouseX < 75 && mouseY > 20 && mouseY < 50) {
    CerrarDialogo();   // (agregado al unir) cierra cualquier dialogo del colegio que haya quedado abierto
    scene = 1; 
    return;
  }
}

void mousePressed() {
  ignorarClick = false;
  if (vidaMousePressed()) {   // (v2.0) menu nuevo, telefono, pausa, minijuegos, mapa vivo...
    ignorarClick = true;
    return;
  }
  if (mostrarDialogo && paginter) {
    if (mouseX > 100 && mouseX < 350 && mouseY > 440 && mouseY < 470) {
      elegirOpcion(0);       // botón de la izquierda
    } else if (mouseX > 400 && mouseX < 650 && mouseY > 440 && mouseY < 470) {
      elegirOpcion(1);       // botón de la derecha
    }
    return;
  }
  
  if (scene == 0) {
    // este es el que corresponde a jugar
    if (mouseX > 300 && mouseX < 500 && mouseY > 200 && mouseY < 270) {
      scene = 1; 
    } 
    // este a los creditos
    else if (mouseX > 300 && mouseX < 500 && mouseY > 290 && mouseY < 360) {
      scene = 2; 
    } 
    // el de salir que pues obviamente sale, ni modo que entra
    else if (mouseX > 300 && mouseX < 500 && mouseY > 380 && mouseY < 450){
      exit(); 
    }
    
    //estos en la seleccion de escena
  } else if (scene == 1) {
    //colegio
    if (mouseX > 30 && mouseX < 270 && mouseY > 140 && mouseY < 310) {
      scene = 7; 
      // (agregado al unir) se deja al personaje en el centro y se cierra cualquier dialogo del barrio
      x = width/2;
      y = height/2;
      actual = abajo;
      CerrarDialogo();
    } 
    // barrio
    else if (mouseX > 580 && mouseX < 780 && mouseY > 50 && mouseY < 230) {
      scene = 5; // Entrada al Barrio 1
      x = width / 2;
      y = 380;
      mostrarDialogo = (pD1 == 0);   // (agregado al unir) el dialogo inicial solo sale si aun no han hablado con Salomeo
    } 
    // Alcaldia
    else if (mouseX > 580 && mouseX < 780 && mouseY > 330 && mouseY < 480) {
    scene = 24;
    x = width/2 - anchoPersonaje/2;   // centrado, como en tu imagen
    y = 430;                          // abajo de la plaza
    actual = arriba;                  // mirando hacia el NPC
    hablando = false;
    moverArriba = moverAbajo = moverIzquierda = moverDerecha = false;
    }
    //telefono
    else if (mouseX > 750 && mouseX < 790 && mouseY > 10 && mouseY < 60) {
      scene = 3;
    }
  } else if (scene == 3) {
    boolean veniaDeBarrio = (origenTelefono == 5 || origenTelefono == 18 || origenTelefono == 19 ||origenTelefono == 15 || origenTelefono == 20 || origenTelefono == 21 ||origenTelefono == 16 || origenTelefono == 22 || origenTelefono == 23);

    if (veniaDeBarrio) {
      scene = origenTelefono;
      origenTelefono = -1;
    } else {
      if (mouseX >= 25 && mouseX <= 75 && mouseY >= 20 && mouseY <= 50) {
        scene = 1;
      }
      // botones del telefono (estadisticas y el otro)
      else if (mouseX > 320 && mouseX < 360 && mouseY > 100 && mouseY < 170){
        scene = 4; 
      }
      else if (mouseX > 390 && mouseX < 430 && mouseY > 100 && mouseY < 170){
        scene = 13; 
      }
    }
  } else if (scene == 4) {
    if (mouseX > 725 && mouseX < 775 && mouseY > 20 && mouseY < 50) {
      scene = 3;
    }
    else if (mouseX >= 25 && mouseX <= 75 && mouseY >= 20 && mouseY <= 50) {
      scene = 1;
    }
  } else if (scene == 28) {
    if (mouseX > 510 && mouseX < 660 && mouseY > 415 && mouseY < 475) {
      scene = 6;
    }
  } else if (scene == 6) {
    if (mouseX > 515 && mouseX < 665 && mouseY > 415 && mouseY < 475) {
      decC = 1;
      viralidad = viralidad + 15;
      confiabilidad = confiabilidad - 10;
      impacto = impacto + 5;
      scene = 10; 
    } else if (mouseX > 95 && mouseX < 245 && mouseY > 415 && mouseY < 475) {
      decC = 2;
      scene = 10; 
    } else if (mouseX > 305 && mouseX < 455 && mouseY > 415 && mouseY < 475) {
      scene = 13; 
    }
  } else if (scene == 7) {  
    // (estos tres botones ya no se dibujan en el colegio, asi que se dejan comentados para que
    //  un clic en esa zona no cambie las estadisticas sin querer)
    /*
    if (mouseX >= 100 && mouseX <= 250 && mouseY >= 415 && mouseY <= 475) {
      decC = 1;
      viralidad = viralidad - 5;
      confiabilidad = confiabilidad + 20;
      impacto = impacto + 10;
      // scene = 14;
      
    } 
    else if (mouseX >= 325 && mouseX <= 475 && mouseY >= 415 && mouseY <= 475) {
      decC = 2; 
      //scene = 14; 
    } 
    else if (mouseX >= 550 && mouseX <= 700 && mouseY >= 415 && mouseY <= 475) {
      decC = 3; 
      viralidad = viralidad + 20;
      confiabilidad = confiabilidad - 15;
      impacto = impacto - 10; 
      //scene = 14; 
    }
    */
  } else if (scene == 8) {
  if (!hablando && mouseX > 510 && mouseX < 660 && mouseY > 415 && mouseY < 475) {
    scene = 11;
  }
} else if (scene == 29) {
    if (mouseX > 510 && mouseX < 660 && mouseY > 415 && mouseY < 475) {
      scene = 30;
    }
  } else if (scene == 10) {
    if (mouseX >= 150 && mouseX <= 300 && mouseY >= 340 && mouseY <= 400) {
      scene = 13; 
    } else if (mouseX >= 500 && mouseX <= 650 && mouseY >= 340 && mouseY <= 400) {
      scene = 1; 
    }
  } else if (scene == 11) {
  for (int i = 0; i < opciones.length; i++) {
    float by = 330 + i * 52;
    if (mouseX > 70 && mouseX < 730 && mouseY > by && mouseY < by + 42) {
      decidirAlcaldia(i + 1);   // (v2.0) antes solo cambiaba decC y la decision no sumaba ni restaba puntos
      break;
    }
  }
} else if (scene == 30) {
    if (mouseX >= 510 && mouseX <= 660 && mouseY >= 415 && mouseY <= 475){
      decC = 1; 
      viralidad = viralidad + 20;
      confiabilidad = confiabilidad - 15;
      impacto = impacto + 5;
      scene = 31;
    } else if (mouseX >= 100 && mouseX <= 250 && mouseY >= 415 && mouseY <= 475){
      decC = 2; 
      viralidad = viralidad - 5;
      confiabilidad = confiabilidad + 15;
      impacto = impacto + 10;
      scene = 31;
    } else if (mouseX >= 305 && mouseX <= 455 && mouseY >= 415 && mouseY <= 475){
      scene = 13; 
    }
  } else if (scene == 14) {
    if (mouseX >= 325 && mouseX <= 475 && mouseY >= 340 && mouseY <= 390) {
      scene = 1; 
    }
  // (v2.0) "Ya se registro la respuesta": Continuar ahora lleva a la siguiente parte del barrio
  // (antes el barrio 2 y el barrio 3 no tenian por donde entrar)
  } else if (scene == 33) {
    if (mouseX >= 500 && mouseX <= 650 && mouseY >= 340 && mouseY <= 400) {
      scene = siguienteBarrio;
      x = width / 2 - 50;
      y = height - 120;
      actual = arriba;
      mostrarDialogo = false;
      textoDialogo = "";
    } else if ((mouseX >= 150 && mouseX <= 300 && mouseY >= 340 && mouseY <= 400) || (mouseX >= 25 && mouseX <= 75 && mouseY >= 20 && mouseY <= 50)) {
      scene = 1;
    }
  // Alcaldia
  } else if (scene == 9 || scene == 13 || scene == 32 || scene == 33 || scene == 34 || scene == 35 || scene == 36) {
    if (mouseX >= 25 && mouseX <= 75 && mouseY >= 20 && mouseY <= 50) {
      scene = 1;
    }
  }

  //desisiones
  if (scene == 19 && md1) siguienteBarrio = 15;   // (v2.0) despues de la Junta sigue la Calle del Chisme
  if (scene == 21 && md2) siguienteBarrio = 16;   // (v2.0) despues de Debora sigue la Zona en obra
  if (scene == 19 && md1) {
    if (mouseX >= 35 && mouseX <= 765) {
      if (mouseY >= 340 && mouseY <= 378) {
        viralidad += 15;
        confiabilidad -= 10;
        md1 = false;
        scene = 33;
      } else if (mouseY >= 385 && mouseY <= 423) {
        confiabilidad += 15;
        viralidad -= 5;
        md1 = false;
        scene = 33;
      } else if (mouseY >= 430 && mouseY <= 468) {
        impacto -= 10;
        md1 = false;
        scene = 33;
      }
    }
  }

  if (scene == 21 && md2) {
    if (mouseX >= 35 && mouseX <= 765) {
      if (mouseY >= 340 && mouseY <= 378) {
        viralidad += 20;
        confiabilidad -= 15;
        md2 = false;
        scene = 33;
      } else if (mouseY >= 385 && mouseY <= 423) {
        confiabilidad += 20;
        md2 = false;
        scene = 33;
      } else if (mouseY >= 430 && mouseY <= 468) {
        impacto -= 15;
        md2 = false;
        scene = 33;
      }
    }
  }

  if (scene == 23 && md3) {
    if (mouseX >= 35 && mouseX <= 765) {
      if (mouseY >= 340 && mouseY <= 378) {
        impacto += 20;
        confiabilidad += 5;
        md3 = false;
        scene = 34;
      } else if (mouseY >= 385 && mouseY <= 423) {
        confiabilidad += 15;
        impacto += 10;
        md3 = false;
        scene = 34;
      } else if (mouseY >= 430 && mouseY <= 468) {
        impacto -= 20;
        md3 = false;
        scene = 34;
      }
    }
  }
}
