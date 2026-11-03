// =====================================================================================
//  LUGARES.pde -> todos los lugares por los que se camina (motor de Escenarios.pde)
//   45 Parque Central          46 Centro NOVA
//   52 Avenida Central  -> 53 Paseo de Campana -> 24 Alcaldia     (el camino a la alcaldia)
//   18 Plaza de Armando -> 54 Mercado -> 55 Cancha / 56 Callejon  (el barrio crece)
//   17 Calle 4 (la puerta del COLEGIO) -> 57 Pasillo -> 58 Salon 10B / 59 Biblioteca / 60 Cafeteria (adentro del colegio)
//  Cada lugar tiene puertas en sus bordes (arriba, derecha, abajo, izquierda) que llevan a otra escena.
// =====================================================================================

class Lugar {
  int id;
  String nombre;
  ArrayList<Interactivo> inter = new ArrayList<Interactivo>();
  float[][] obs = {};
  int[] salidas = {-1, -1, -1, -1};                   // arriba, derecha, abajo, izquierda (-1 = pared)
  String[] etiquetas = {"", "", "", ""};
  float[][] rangos = {{0, 800}, {0, 500}, {0, 800}, {0, 500}};   // en que parte del borde esta la puerta
  float yMin = 92;
  boolean interior = false;
  int clima = 0;   // 0 nada, 1 lluvia, 2 volantes, 3 polvo de luz, 4 vapor

  Lugar(int id, String nombre) {
    this.id = id;
    this.nombre = nombre;
  }

  Lugar puerta(int dir, int destino, String etiqueta, float a, float b) {
    salidas[dir] = destino;
    etiquetas[dir] = etiqueta;
    rangos[dir][0] = a;
    rangos[dir][1] = b;
    return this;
  }

  boolean enRango(int dir, float v) {
    return v >= rangos[dir][0] && v <= rangos[dir][1];
  }

  void dibujarSalidas() {
    for (int d = 0; d < 4; d++) {
      if (salidas[d] < 0) continue;
      float m = (rangos[d][0] + rangos[d][1]) / 2;
      if (d == 0) flechaSalida(m, max(22, yMin - 18), 0, etiquetas[d]);
      else if (d == 1) flechaSalida(width - 22, m, 1, etiquetas[d]);
      else if (d == 2) flechaSalida(m, height - 20, 2, etiquetas[d]);
      else flechaSalida(22, m, 3, etiquetas[d]);
    }
  }

  void agregar(Interactivo it) {
    inter.add(it);
  }
}

HashMap<Integer, Lugar> lugares = new HashMap<Integer, Lugar>();

boolean esCaminable(int s) {
  return lugares.containsKey(s);
}

// cambia de escena por un borde (dir = por donde saliste) y te pone en la puerta del otro lado
void irAEscena(int dest, int dir) {
  cerrarCharla();
  if (dest == 1) {
    pararMovimiento();
    scene = 1;
    return;
  }
  if (esCaminable(dest)) {
    Lugar D = lugares.get(dest);
    int op = (dir + 2) % 4;
    float m = (D.rangos[op][0] + D.rangos[op][1]) / 2;
    if (D.salidas[op] < 0) {
      x = 350;
      y = 390;
    } else if (op == 0) {
      x = m - 50;
      y = D.yMin + 4;
      actual = abajo;
    } else if (op == 2) {
      x = m - 50;
      y = height - 56;
      actual = arriba;
    } else if (op == 3) {
      x = -22;
      y = m - 40;
      actual = derecha;
    } else {
      x = width - 78;
      y = m - 40;
      actual = izquierda;
    }
    scene = dest;
    return;
  }
  // escenas del codigo original
  if (dest == 24) {
    x = width / 2 - anchoPersonaje / 2;
    y = 420;
    actual = arriba;
    hablando = false;
  } else if (dest == 18) {
    x = width - anchoPersonaje - 6;
    y = constrain(y, 60, 400);
    actual = izquierda;
    mostrarDialogo = false;
  } else if (dest == 17) {   // saliendo del colegio: frente a la puerta de la Calle 4
    x = 335;
    y = 110;
    actual = abajo;
    CerrarDialogo();
  }
  scene = dest;
}

void dibujarFondoLugar(int s) {
  empezarFondoPixel();   // (pixel art) ver Pixel.pde
  dibujarFondoLugarMundo(s);
  terminarFondoPixel();
}

void dibujarFondoLugarMundo(int s) {
  if (s == ESC_PARQUE) fondoParque();
  else if (s == ESC_CENTRO) fondoCentro();
  else if (s == ESC_AVENIDA) fondoAvenida();
  else if (s == ESC_PASEO) fondoPaseo();
  else if (s == ESC_MERCADO) fondoMercado();
  else if (s == ESC_CANCHA) fondoCancha();
  else if (s == ESC_CALLEJON) fondoCallejon();
  else if (s == ESC_PASILLO) fondoPasillo();
  else if (s == ESC_SALON) fondoSalon();
  else if (s == ESC_BIBLIOTECA) fondoBiblioteca();
  else if (s == ESC_CAFETERIA) fondoCafeteria();
  else background(0);
}

// muebles que pueden quedar delante o detras del jugador (pupitres, mesas)
// delante=false: se dibujan los que estan detras del jugador; delante=true: los que lo tapan
void dibujarFrenteLugar(int s, boolean delante) {
  float pies = y + 48;
  if (s == ESC_SALON) {
    for (float[] p : pupitres) if (delante == (pies < p[1] + 30)) pupitre(p[0], p[1]);
  } else if (s == ESC_CAFETERIA) {
    for (float[] m : mesasCafe) if (delante == (pies < m[1] + 24)) mesaCafe(m[0], m[1]);
  }
}

Interactivo npcTere, npcRocio;   // estan detras de un mostrador: se dibujan con el fondo

void ambienteLugar(Lugar L) {
  if (L.clima == 1) {
    for (int i = 0; i < 2; i++) agregarParticula(new Particula(random(-60, width), random(-20, 0), 2.5, random(10, 13), 55, 1.1, color(170, 190, 255), 1));
    if (random(1) < 0.1) agregarParticula(new Particula(random(width), random(200, height), 0, 0, 36, random(8, 16), color(190, 210, 255), 7));
  } else if (L.clima == 2) {
    if (random(1) < 0.08) {
      color[] cs = {neonRosa, neonCian, neonAmarillo, neonVerde, color(255)};
      Particula p = new Particula(random(width), -10, random(-0.5, 0.5), random(0.6, 1.2), 500, 8, cs[int(random(cs.length))], 3);
      p.giro = random(-0.06, 0.06);
      agregarParticula(p);
    }
  } else if (L.clima == 3) {
    if (random(1) < 0.08) agregarParticula(new Particula(random(width), random(L.yMin, height), random(-0.2, 0.2), random(-0.3, -0.05), random(120, 240), random(2, 3.5), color(255, 240, 200), 6));
  } else if (L.clima == 4) {
    if (frameCount % 6 == 0) agregarParticula(new Particula(560 + random(-6, 6), 110, random(-0.2, 0.2), -0.7, 80, 18, color(230), 5));
    for (int i = 0; i < 1; i++) agregarParticula(new Particula(random(-60, width), random(-20, 0), 2.5, random(10, 13), 55, 1.1, color(170, 190, 255), 1));
  }
}

// ------------------------------------- REGISTRO DE TODOS LOS LUGARES -------------------------------------
float[][] pupitres = {{160, 268}, {330, 268}, {500, 268}, {160, 378}, {330, 378}, {500, 378}};
float[][] mesasCafe = {{620, 395}, {200, 445}};

Interactivo objeto(float ix, float iy, String nombre, String[] frases) {
  Interactivo it = new Interactivo(ix, iy, nombre, 1);
  it.frases = frases;
  return it;
}

Charla charla(String quien, String[] lineas, String[] ops, float[][] ef, String[] resp, String desp) {
  return new Charla(quien, lineas).con(ops, ef, resp, desp);
}

void registrarLugares() {
  lugares.clear();

  // ---------------- 45 PARQUE y 46 CENTRO (ya existian) ----------------
  Lugar parque = new Lugar(ESC_PARQUE, "Parque Central");
  parque.inter = interParque;
  parque.obs = obsParque;
  parque.puerta(2, 1, "Mapa", 0, 800);
  parque.clima = 3;
  lugares.put(ESC_PARQUE, parque);

  Lugar centro = new Lugar(ESC_CENTRO, "Centro NOVA");
  centro.inter = interCentro;
  centro.obs = obsCentro;
  centro.puerta(2, 1, "Mapa", 0, 800);
  centro.interior = true;
  lugares.put(ESC_CENTRO, centro);

  // ---------------- 52 AVENIDA CENTRAL ----------------
  Lugar av = new Lugar(ESC_AVENIDA, "Avenida Central");
  av.puerta(0, ESC_PASEO, "Paseo de Campaña", 260, 540).puerta(2, 1, "Mapa", 260, 540);
  av.obs = new float[][] {{150, 92, 100, 176}, {150, 334, 100, 166}, {550, 92, 100, 176}, {550, 334, 100, 166}};
  av.clima = 3;
  av.agregar(persona(95, 240, "Tono", #DC3C3C, #141414, charla("Tono (repartidor)", new String[] {
    "Que hubo! Soy Tono, reparto domicilios por toda Nova. Uno escucha de todo en la calle.",
    "Me acaban de decir en un semaforo que mañana cierran la Avenida Central PARA SIEMPRE por las elecciones.",
    "Ya se lo iba a contar a los 200 repartidores del grupo. Lo mando o que?"
  }, new String[] {"Mandalo, mejor prevenir", "Revisemos la cuenta oficial de Transito Nova"},
    new float[][] {{10, -8, -6}, {-3, 10, 6}},
    new String[] {"Tono: Listo... uy, ahora nadie quiere hacer domicilios mañana y los restaurantes estan perdiendo pedidos.",
    "Tono: Mira: solo la cierran el domingo de 6 a 2 por la votacion. Menos mal no mande eso!"},
    "Tono: Si necesitas un domicilio, ya sabes. Rapidito y verificado!")));
  av.agregar(persona(440, 430, "Señora Carmen", #A05AC8, #8C8C8C, charla("Señora Carmen", new String[] {
    "Voy a la protesta de la Alcaldia! Hice esta pancarta: 'CLEMENCIA COMPRA VOTOS'.",
    "Lo vi en un video. Bueno, eran 9 segundos, pero se veia clarito que le daban plata.",
    "Me ayudas a cargarla? Entre mas gente la vea, mejor."
  }, new String[] {"Ayudarla a cargar la pancarta", "Mostrarle que el video completo dura 4 minutos"},
    new float[][] {{12, -10, -8}, {-4, 12, 10}},
    new String[] {"Carmen: Gracias! ...Mira cuanta gente toma fotos. Aunque, oye... y si no era verdad?",
    "Carmen: En el video completo le estaban devolviendo un prestamo? Ay, Dios... voy a cambiar el cartel: 'QUEREMOS PRUEBAS'."},
    "Carmen: Nos vemos en la Alcaldia. Con pruebas, siempre!")));
  av.agregar(persona(705, 210, "Lucia", #3C64B4, #5A3214, new Charla("Lucia (Nova Noticias)", new String[] {
    "Hola, soy Lucia, reportera de Nova Noticias. Estoy grabando como se mueven los rumores en la calle.",
    "Algo que aprendi en la universidad: un buen periodista confirma con al menos dos fuentes independientes.",
    "Y si no puede confirmar, lo dice. 'No esta confirmado' tambien es informacion.",
    "Por cierto, esta noche hay concurso en el estudio de Nova Noticias. Pasate por el mapa!"
  })));
  av.agregar(maquina(705, 440, "Cabina: Telefono Roto", ESC_TELROTO));
  av.agregar(objeto(330, 215, "Carrito de helados", new String[] {
    "El carrito de helados tiene sabores raros: 'Mango Verificado', 'Fresa sin Fuente' y 'Chicle Viral'.",
    "El heladero te guiña el ojo: 'El de Mango Verificado nunca falla'.",
    "Un letrero dice: 'Hoy 2x1 si me cuentas un dato con fuente'."}));
  lugares.put(ESC_AVENIDA, av);

  // ---------------- 53 PASEO DE CAMPANA ----------------
  Lugar pa = new Lugar(ESC_PASEO, "Paseo de Campaña");
  pa.puerta(0, 24, "Alcaldia", 340, 460).puerta(2, ESC_AVENIDA, "Avenida", 340, 460);
  pa.yMin = 110;
  pa.obs = new float[][] {{50, 150, 170, 50}, {50, 320, 170, 50}, {580, 150, 170, 50}, {580, 320, 170, 50}};
  pa.clima = 2;
  pa.agregar(persona(270, 235, "Bruno", #3C78C8, #141414, charla("Bruno (campaña de Patroclo)", new String[] {
    "Hola, joven! Bruno, de la campaña de Patroclo. Tienes Conecta? Claro que si, todo el mundo tiene!",
    "Mira estos memes: Gonzalo 'prohibiendo carros', Clemencia 'robando'. Ninguno es real, pero son chistosos, no?",
    "Te pagamos 20 mil por cada meme que compartas hoy. Es plata facil."
  }, new String[] {"Aceptar y compartir los memes", "Rechazarlo y preguntarle por las propuestas reales"},
    new float[][] {{18, -15, -12}, {-5, 10, 8}},
    new String[] {"Bruno: Eso! Ya eres tendencia... aunque tus amigos te estan preguntando si de verdad crees eso.",
    "Bruno: Las propuestas? Eh... buena pregunta. Tenemos un plan de transporte... creo. Dejame buscar el folleto."},
    "Bruno: Vota Patroclo! O... bueno, vota informado.")));
  pa.agregar(persona(530, 235, "Pili", #46A064, #DCA032, charla("Pili (campaña de Gonzalo)", new String[] {
    "Hola! Soy Pili, voluntaria de Gonzalo. Seguro ya viste el meme de que quiere prohibir los carros.",
    "La propuesta real es una ciclorruta de 12 kilometros y mas buses. Esta aqui, en este folleto de 4 paginas.",
    "Casi nadie lo lee: comparten el meme y ya. Tu que haces?"
  }, new String[] {"Juzgar por el meme, da igual", "Leer la propuesta completa"},
    new float[][] {{6, -8, -6}, {0, 10, 6}},
    new String[] {"Pili: Ok... es triste, pero asi se ganan y se pierden elecciones en Nova.",
    "Pili: Gracias! No tienes que votar por el, solo queriamos que decidieras con informacion real."},
    "Pili: Lee las propuestas de TODOS los candidatos. Eso es lo justo.")));
  pa.agregar(persona(300, 140, "Guardia Ortiz", #283C50, #141414, new Charla("Guardia Ortiz", new String[] {
    "Alto ahi... ah, no, tranquilo, solo estoy de turno. Soy el guardia Ortiz.",
    "Adentro de la Alcaldia hay una protesta enorme. Todo empezo por un video que nadie ha verificado.",
    "Sigue derecho por la alfombra y habla con el empleado de la entrada. Y no empujes a nadie, por favor."
  })));
  pa.agregar(persona(270, 450, "Tomas", #FFB43C, #3C2814, charla("Tomas (y su dron Pixel)", new String[] {
    "Mira mi dron! Grabe toda la protesta desde arriba. Hay una parte donde alguien empuja a un policia.",
    "Si corto solo esos 5 segundos, parece que los manifestantes atacaron primero. Seria super viral!",
    "Pero en el video completo se ve que fue un tropezon. Cual subo?"
  }, new String[] {"Subir solo los 5 segundos", "Subir el video completo con fecha y lugar"},
    new float[][] {{16, -12, -12}, {4, 10, 10}},
    new String[] {"Tomas: Wow, 50 mil vistas... pero ahora todos se estan insultando en los comentarios. Creo que la embarre.",
    "Tomas: Menos vistas, pero un periodista me escribio para usarlo como prueba. Mi dron es famoso!"},
    "Tomas: Mi dron se llama Pixel. Saluda, Pixel!")));
  pa.agregar(maquina(690, 450, "Kiosko: Foto Trucada", ESC_FOTO));
  pa.agregar(objeto(110, 450, "Muro de carteles", new String[] {
    "El muro esta lleno de carteles encima de carteles. Alguien escribio con marcador: 'Y las propuestas?'",
    "Un cartel de Ramirez tiene encima un sticker que dice FAKE. Debajo, otro que dice 'el sticker es fake'.",
    "Hay un cartel pequeño de la Registraduria: 'Consulta tu mesa de votacion en el sitio oficial'."}));
  lugares.put(ESC_PASEO, pa);

  // ---------------- 54 MERCADO DEL BARRIO ----------------
  Lugar me = new Lugar(ESC_MERCADO, "Barrio  -  Mercado");
  me.puerta(3, 18, "Plaza", 150, 470).puerta(1, ESC_CANCHA, "Cancha", 360, 480).puerta(0, ESC_CALLEJON, "Callejon", 345, 455);
  me.yMin = 150;
  me.obs = new float[][] {{115, 245, 170, 40}, {515, 245, 170, 40}};
  me.clima = 1;
  me.agregar(persona(200, 335, "Don Pacho", #C8643C, #CCCCCC, charla("Don Pacho (frutas)", new String[] {
    "Lleve, lleve! Mangos, piñas, aguacates... Ay, joven, que susto tengo!",
    "Me llego un audio diciendo que la fruta que viene del sur esta envenenada. Ya nadie me compra.",
    "Mi primo dice que mande otro audio diciendo que la fruta envenenada es la de MI competencia. Usted que dice?"
  }, new String[] {"Mandar el audio contra la competencia", "Pedirle a Salud Nova un comunicado oficial"},
    new float[][] {{14, -12, -10}, {-4, 12, 10}},
    new String[] {"Pacho: Ya lo mande... y ahora nadie compra NINGUNA fruta en todo el mercado. Hasta yo perdi.",
    "Pacho: Salud Nova dijo que todo es falso y hasta vinieron a comprarme mangos! Hoy vendi el doble."},
    "Pacho: Pruebe este mango, cortesia de la casa! Verificado y dulcecito.")));
  me.agregar(persona(600, 335, "Yuli", #9650FF, #141414, charla("Yuli (arreglo celulares)", new String[] {
    "Hola, soy Yuli. Arreglo celulares... y los limpio de enlaces raros.",
    "Hoy media Nova recibio esto: 'GANASTE UN CELULAR GRATIS, entra aqui y pon tu contraseña de Conecta'.",
    "Mira, a ti tambien te llego. Que haces?"
  }, new String[] {"Abrir el enlace, un celular gratis!", "Reportar el enlace y avisar al barrio"},
    new float[][] {{5, -12, -6}, {2, 10, 10}},
    new String[] {"Yuli: Ay no... te robaron la cuenta y ahora esta mandando el mismo enlace a todos tus contactos.",
    "Yuli: Asi se hace! Nadie regala celulares. Si te piden contraseñas, es una trampa."},
    "Yuli: Activa la verificacion en dos pasos. Me lo vas a agradecer!")));
  me.agregar(objeto(420, 455, "Gato del mercado", new String[] {
    "Un gato atigrado duerme sobre una caja de mangos. Ni se inmuta.",
    "El gato te mira, bosteza y sigue durmiendo. Es el ser mas tranquilo de Nova.",
    "Miau. (El gato no tiene opiniones politicas. Que envidia.)"}));
  me.agregar(maquina(700, 185, "Ciber Nova: Teclado Veloz", ESC_TECLADO));
  lugares.put(ESC_MERCADO, me);

  // ---------------- 55 CANCHA ----------------
  Lugar ca = new Lugar(ESC_CANCHA, "Barrio  -  Cancha");
  ca.puerta(3, ESC_MERCADO, "Mercado", 380, 480);
  ca.yMin = 118;
  ca.obs = new float[][] {{8, 210, 44, 140}, {748, 210, 44, 140}, {610, 178, 80, 26}};
  ca.agregar(persona(230, 210, "Entrenador Rafa", #E6E6E6, #141414, charla("Entrenador Rafa", new String[] {
    "Eso, muchachos, a calentar! Ah, hola. Soy Rafa, el entrenador del torneo del barrio.",
    "Esta mañana alguien dijo que el torneo se cancelaba porque iban a tumbar la cancha. Casi no viene nadie!",
    "Ahora dicen en un audio que va a llover acido. Cancelo por si acaso?"
  }, new String[] {"Cancelar por si acaso", "Revisar el pronostico oficial y confirmar con la Junta"},
    new float[][] {{6, -6, -12}, {0, 8, 12}},
    new String[] {"Rafa: Cancelado... los niños se fueron tristes a sus casas. Y no cayo ni una gota.",
    "Rafa: Cielo despejado y la Junta confirmo! Que empiece el torneo!"},
    "Rafa: Si quieres practicar, ese balon del centro es para cobrar penales.")));
  ca.agregar(persona(600, 430, "Valentina", #FF3CC8, #3C2814, new Charla("Valentina (capitana)", new String[] {
    "Soy Valentina, la capitana de Las Estrellas del Barrio.",
    "La semana pasada inventaron que haciamos trampa. Lo desmentimos con el video completo del partido.",
    "Lo mejor: el equipo rival nos pidio perdon. Ahora somos amigas!"
  })));
  ca.agregar(maquina(400, 318, "Balon: Penales", ESC_PENALES));
  ca.agregar(maquina(650, 222, "Pantalla: Salto con la Mano", ESC_SALTO));
  lugares.put(ESC_CANCHA, ca);

  // ---------------- 56 CALLEJON DE LOS MURALES ----------------
  Lugar cj = new Lugar(ESC_CALLEJON, "Barrio  -  Callejon de los murales");
  cj.puerta(2, ESC_MERCADO, "Mercado", 280, 520);
  cj.yMin = 100;
  cj.obs = new float[][] {{0, 0, 232, 500}, {568, 0, 232, 500}};
  cj.clima = 4;
  cj.agregar(persona(300, 270, "Maya", #3CB48C, #DC3C78, charla("Maya (grafitera)", new String[] {
    "Shhh... estoy terminando este mural. Soy Maya, grafitera. Legal, eh? La Junta me dio permiso.",
    "Un tipo me ofrecio plata para pintar aqui 'RAMIREZ LADRON' en letras gigantes. Sin pruebas, claro.",
    "Me falta el mensaje del centro del mural. Que pinto?"
  }, new String[] {"Pintar 'RAMIREZ LADRON'", "Pintar 'LA VERDAD NO SE COMPARTE, SE VERIFICA'"},
    new float[][] {{16, -14, -12}, {4, 10, 12}},
    new String[] {"Maya: Quedo gigante... ya hay gente tomandole fotos. Y a Ramirez nadie lo ha acusado de nada.",
    "Maya: Me encanta! Los niños del barrio ya se estan tomando selfies con el mural."},
    "Maya: El arte tambien informa. Vuelve cuando quieras.")));
  cj.agregar(persona(510, 190, "El Filtrador", #282832, #141414, charla("El Filtrador", new String[] {
    "Psst... tu. Si, tu. Me dicen 'El Filtrador'. Tengo una USB con 'documentos secretos' de la Alcaldia.",
    "No te puedo decir de donde salieron. Tampoco si son reales. Pero son bombasticos!",
    "Te la regalo. Publicalos y seras famoso. Trato?"
  }, new String[] {"Publicar los documentos ya", "Llevarlos a Nova Noticias para que los verifiquen"},
    new float[][] {{20, -16, -10}, {2, 12, 10}},
    new String[] {"(Horas despues se descubre que eran documentos falsos hechos con IA. Tu nombre esta en todas partes.)",
    "(Lucia, de Nova Noticias, los revisa: dos son falsos y uno es real pero viejo. Publican la historia con contexto. Buen trabajo!)"},
    "...El Filtrador ya no esta. Solo queda una sombra y olor a cafe.")));
  cj.agregar(objeto(520, 430, "Mural", new String[] {
    "El mural muestra un celular gigante con una lupa. Abajo dice: 'Antes de compartir, mira quien lo dijo'.",
    "En una esquina del mural hay pintado un pato. El mismo pato del Parque Central?",
    "Alguien firmo el mural: 'Nova somos todos'."}));
  lugares.put(ESC_CALLEJON, cj);

  // ---------------- 57 PASILLO DEL COLEGIO ----------------
  Lugar ps = new Lugar(ESC_PASILLO, "Colegio  -  Pasillo principal");
  ps.puerta(0, ESC_CAFETERIA, "Cafeteria", 350, 450).puerta(3, ESC_SALON, "Salon 10B", 250, 360)
    .puerta(1, ESC_BIBLIOTECA, "Biblioteca", 250, 360).puerta(2, 17, "Calle 4", 300, 500);
  ps.yMin = 160;
  ps.interior = true;
  ps.clima = 3;
  ps.agregar(persona(270, 240, "Dani", #5A78A0, #3C2814, charla("Dani", new String[] {
    "...Hola. Soy Dani. Supongo que ya sabes quien soy. 'El del casillero'.",
    "Era una maqueta de geografia. Un volcan. Me tomaron la foto sin permiso y ahora me dicen 'el espia de la constructora'.",
    "No quiero volver al colegio. Tu tambien te reiste de la foto?"
  }, new String[] {"Decirle que si, que era muy chistosa", "Ayudarle a reportar la foto y contar la verdad"},
    new float[][] {{6, -10, -12}, {2, 12, 14}},
    new String[] {"Dani: ...Ya. Gracias por la sinceridad, supongo. (Dani se va caminando con la cabeza abajo.)",
    "Dani: En serio? Gracias... Con el reporte, Conecta bajo la foto. Y la coordinadora va a hablar en la asamblea."},
    "Dani: Si quieres ver el volcan, esta en mi casillero. Hasta hace erupcion con bicarbonato!")));
  ps.agregar(persona(570, 420, "Coordinadora Gladys", #8C3C50, #646464, new Charla("Coordinadora Gladys", new String[] {
    "Buenos dias. Soy Gladys, la coordinadora. No deberias estar en clase? Bueno, no importa.",
    "Esta semana ha sido un caos: fotos sin permiso, cadenas falsas, hasta un video de 'gusanos en la cafeteria'.",
    "Vamos a hacer una asamblea sobre redes sociales. Pasa por el 10B, la biblioteca y la cafeteria: todos tienen algo que contar."
  })));
  ps.agregar(objeto(190, 192, "Casillero de Dani", new String[] {
    "El casillero de Dani tiene una maqueta de un volcan de plastilina. Dice: 'Geografia 10B'. Nada de planos secretos.",
    "Hay una nota pegada: 'Dani, eres lo maximo. No les hagas caso. - Camila'.",
    "El volcan tiene un boton que dice 'NO TOCAR'. Mejor no tocarlo."}));
  ps.agregar(objeto(640, 192, "Cartelera", new String[] {
    "Cartelera: 'Asamblea sobre redes sociales - viernes 10 a.m.'",
    "Cartelera: 'Se busca cargador de celular azul. Recompensa: mi eterna gratitud'.",
    "Cartelera: 'Club de Periodismo Escolar: aprende a verificar noticias! Martes y jueves'."}));
  lugares.put(ESC_PASILLO, ps);

  // ---------------- 58 SALON 10B ----------------
  Lugar sa = new Lugar(ESC_SALON, "Colegio  -  Salon 10B");
  sa.puerta(1, ESC_PASILLO, "Pasillo", 250, 360);
  sa.yMin = 140;
  sa.interior = true;
  sa.obs = new float[][] {{115, 268, 90, 26}, {285, 268, 90, 26}, {455, 268, 90, 26}, {115, 378, 90, 26}, {285, 378, 90, 26}, {455, 378, 90, 26}, {600, 150, 150, 34}};
  sa.agregar(persona(400, 185, "Profe Hernan", #505A78, #CCCCCC, charla("Profe Hernan (Etica)", new String[] {
    "Bienvenido a Etica. Hoy el tema es: 'Somos responsables de lo que compartimos?'",
    "Mateo dice que no, que si el no invento el rumor, no es su culpa. Camila dice que cada reenvio cuenta.",
    "Quiero tu opinion antes de terminar la clase. Quien tiene razon?"
  }, new String[] {"Mateo: el culpable es solo quien lo inventa", "Camila: cada persona que lo comparte es responsable"},
    new float[][] {{4, -6, -6}, {0, 10, 10}},
    new String[] {"Profe: Interesante... pero piensa: un rumor que nadie reenvia se muere solito. De tarea: pensarlo.",
    "Profe: Exacto. Sin reenvios, un rumor no llega a ningun lado. Punto extra para ti!"},
    "Profe: Recuerden: libertad de expresion no es libertad de inventar.")));
  sa.agregar(persona(690, 440, "Vale", #DC6E8C, #8C5A3C, charla("Vale", new String[] {
    "Ay, hola... Soy Vale. Fui yo la que le tomo la foto a Dani. No pense que fuera a pasar todo esto.",
    "Mi primo la reenvio y ahora hay mil versiones. Me siento fatal.",
    "Mejor me quedo callada y espero a que se olvide?"
  }, new String[] {"Quedarse callada, ya pasara", "Borrar la foto, pedirle perdon a Dani y aclarar"},
    new float[][] {{4, -8, -10}, {0, 12, 12}},
    new String[] {"Vale: Ok... (Una semana despues la foto sigue circulando. Dani ya no viene al colegio.)",
    "Vale: Tienes razon. Ya le escribi a Dani... y me perdono! La aclaracion ya tiene 300 likes."},
    "Vale: Gracias por no juzgarme. Aprendi la leccion.")));
  sa.agregar(maquina(230, 168, "Tablero: Telefono Roto", ESC_TELROTO));
  lugares.put(ESC_SALON, sa);

  // ---------------- 59 BIBLIOTECA ----------------
  Lugar bi = new Lugar(ESC_BIBLIOTECA, "Colegio  -  Biblioteca");
  bi.puerta(3, ESC_PASILLO, "Pasillo", 250, 360);
  bi.yMin = 145;
  bi.interior = true;
  bi.clima = 3;
  bi.obs = new float[][] {{220, 300, 180, 40}, {500, 165, 200, 40}, {620, 390, 110, 30}};
  bi.agregar(npcRocio = persona(600, 168, "Bibliotecaria Rocio", #B48C50, #3C2814, new Charla("Bibliotecaria Rocio", new String[] {
    "Bienvenido a la biblioteca. Soy Rocio. Aqui hablamos bajito... y verificamos fuerte.",
    "Sabias que puedes saber si una foto es vieja? Se llama busqueda inversa de imagenes.",
    "Subes la foto y te muestra donde aparecio antes. La foto del 'incendio en el colegio' era de otro pais, de hace 5 años.",
    "El computador del fondo tiene un juego para entrenar el ojo con fotos trucadas. Pruebalo!"
  })));
  bi.agregar(persona(170, 430, "Sebas", #3C96C8, #141414, charla("Sebas", new String[] {
    "Hola... soy Sebas. Tengo que entregar un trabajo sobre las elecciones en una hora.",
    "Encontre un blog sin autor que dice cosas super escandalosas de los candidatos. Copiarlo seria rapidisimo.",
    "Lo copio o busco fuentes de verdad?"
  }, new String[] {"Copiar el blog, no hay tiempo", "Ayudarle a buscar fuentes oficiales y medios serios"},
    new float[][] {{6, -8, -6}, {0, 10, 8}},
    new String[] {"Sebas: Entregado... (Al dia siguiente le devuelven el trabajo con un 1.0: 'Fuente no confiable'.)",
    "Sebas: Lo terminamos! Con datos de la Registraduria y de dos periodicos. Gracias!"},
    "Sebas: Ahora siempre reviso quien escribio lo que leo.")));
  bi.agregar(maquina(675, 382, "Computador: Foto Trucada", ESC_FOTO));
  bi.agregar(objeto(150, 168, "Estante de libros", new String[] {
    "Un libro se llama 'Como no caer en bulos, edicion para tias'. Parece muy pedido.",
    "Estante de Historia: rumores famosos que cambiaron el mundo. Da un poco de miedo.",
    "Un libro de cocina tiene un separador que dice: 'Verifica tambien tus recetas'."}));
  lugares.put(ESC_BIBLIOTECA, bi);

  // ---------------- 60 CAFETERIA ----------------
  Lugar cf = new Lugar(ESC_CAFETERIA, "Colegio  -  Cafeteria");
  cf.puerta(2, ESC_PASILLO, "Pasillo", 330, 470);
  cf.yMin = 135;
  cf.interior = true;
  cf.obs = new float[][] {{250, 130, 300, 46}, {560, 395, 120, 26}, {140, 445, 120, 26}};
  cf.agregar(npcTere = persona(400, 150, "Doña Tere", #F0F0F0, #8C8C8C, charla("Doña Tere (cafeteria)", new String[] {
    "Siguiente! Ah, hola mijo. Que te sirvo? Hoy hay arroz con pollo... que, por cierto, NO tiene gusanos.",
    "Alguien subio un video diciendo que habia gusanos en la comida. Era un video de otra ciudad, de hace años!",
    "Los estudiantes ya no quieren almorzar. Me ayudas a que la gente sepa la verdad?"
  }, new String[] {"Mejor no meterse", "Buscar el video original y compartir la aclaracion"},
    new float[][] {{0, -4, -8}, {4, 10, 12}},
    new String[] {"Tere: Bueno, mijo... (La cafeteria sigue vacia y se bota mucha comida.)",
    "Tere: Bendito seas! Ya se lleno la fila. Toma, un postre gratis."},
    "Tere: Come bien, que pensar gasta energia!")));
  cf.agregar(persona(200, 390, "Camilo", #DCA032, #141414, charla("Camilo", new String[] {
    "Bro, no comas eso. Vi un video de gusanos en la comida de la cafeteria. Asqueroso!",
    "Bueno, el video no muestra el colegio... ni la cafeteria... pero lo compartieron 2.000 personas.",
    "Voy a crear un grupo para boicotear la cafeteria. Te unes?"
  }, new String[] {"Unirme al boicot", "Preguntarle si el video es realmente de aqui"},
    new float[][] {{12, -10, -10}, {-2, 8, 8}},
    new String[] {"Camilo: Ya somos 300! ...Espera, por que Doña Tere esta llorando?",
    "Camilo: Ehh... ahora que lo dices, esas bandejas son azules y aqui son verdes. Ups."},
    "Camilo: Ok, ok, el arroz con pollo esta bueno. No le digas a nadie que dije eso.")));
  cf.agregar(persona(620, 375, "Lu y Caro", #FF8CB4, #E6C878, new Charla("Lu y Caro", new String[] {
    "Lu: Supiste que el profe Hernan es un robot? Caro: Lo vi en Conecta!",
    "Lu: Bueno, era una cuenta de memes. Caro: Pero tenia muchos likes. Lu: ...Eso no lo hace verdad, cierto?",
    "Caro: Ok, ya. Desde hoy solo chismes con fuente. Lu: Pacto de chismosas responsables!"
  })));
  cf.agregar(objeto(220, 172, "Menu del dia", new String[] {
    "Menu del dia: arroz con pollo, jugo de mora y postre. Sin gusanos (verificado por Salud Nova).",
    "En el tablero alguien escribio: 'Viernes: lasaña gratis'. Debajo, la cocinera escribio: 'FALSO'.",
    "Precio especial para quien traiga su propio vaso. Bien por el planeta!"}));
  lugares.put(ESC_CAFETERIA, cf);

  npcTere.oculto = true;
  npcRocio.oculto = true;
  for (Lugar L : lugares.values()) ordenarPorProfundidad(L.inter);
}

// ------------------------------------- AYUDANTES DE DIBUJO -------------------------------------
void pisoBaldosas(float y0, float tam, color a, color b) {
  noStroke();
  for (float yy = y0; yy < height; yy += tam) {
    for (float xx = 0; xx < width; xx += tam) {
      fill(((int) (xx / tam + yy / tam)) % 2 == 0 ? a : b);
      rect(xx, yy, tam, tam);
    }
  }
}

void edificiosCiudad(float x0, float x1, float base, float sem) {
  float cx = x0;
  int k = 0;
  noStroke();
  while (cx < x1) {
    float w = min(x1 - cx, 60 + hsh(sem + k * 3.3) * 50);
    float h = 50 + hsh(sem + k * 7.1) * 50;
    fill(lerpColor(color(50, 30, 80), color(80, 50, 100), hsh(sem + k)));
    rect(cx, base - h, w - 4, h);
    for (float vy = base - h + 8; vy < base - 10; vy += 12) {
      for (float vx = cx + 6; vx < cx + w - 12; vx += 12) {
        if (hsh(sem + vx * 0.3 + vy * 0.7) > 0.55) {
          fill(hsh(vx + vy) > 0.5 ? color(255, 210, 140, 220) : color(0, 240, 255, 170));
          rect(vx, vy, 5, 6);
        }
      }
    }
    if (hsh(sem + k * 9) > 0.5) {
      boolean on = hsh(k + floor(frameCount / 7.0)) > 0.07;
      fill(k % 2 == 0 ? neonRosa : neonCian, on ? 255 : 70);
      rect(cx + 8, base - 22, w - 24, 8, 3);
    }
    cx += w;
    k++;
  }
}

void autoVertical(float ax, float ay, color c, int dir) {
  noStroke();
  fill(255, 255, 200, 50);
  if (dir > 0) triangle(ax - 10, ay + 22, ax + 10, ay + 22, ax, ay + 70);
  else triangle(ax - 10, ay - 22, ax + 10, ay - 22, ax, ay - 70);
  fill(0, 80);
  rect(ax - 15, ay - 23, 32, 50, 7);
  fill(c);
  rect(ax - 16, ay - 25, 32, 50, 7);
  fill(30, 40, 60);
  rect(ax - 12, ay + (dir > 0 ? 6 : -18), 24, 12, 3);
  fill(255, 255, 220);
  ellipse(ax - 9, ay + dir * 24, 6, 4);
  ellipse(ax + 9, ay + dir * 24, 6, 4);
  fill(255, 50, 50);
  ellipse(ax - 9, ay - dir * 24, 5, 3);
  ellipse(ax + 9, ay - dir * 24, 5, 3);
}

void toldo(float tx, float ty, float tw, color c) {
  noStroke();
  int n = int(tw / 20);
  for (int i = 0; i < n; i++) {
    fill(i % 2 == 0 ? c : color(245));
    rect(tx + i * 20, ty, 20, 22);
    arc(tx + i * 20 + 10, ty + 22, 20, 14, 0, PI);
  }
}

void cajaFrutas(float cx, float cy, color fruta) {
  noStroke();
  fill(150, 100, 60);
  rect(cx - 18, cy - 10, 36, 18, 2);
  fill(fruta);
  for (int i = 0; i < 5; i++) ellipse(cx - 12 + i * 6, cy - 12 + (i % 2) * 3, 9, 9);
}

void gatito(float cx, float cy) {
  noStroke();
  fill(0, 60);
  ellipse(cx, cy + 6, 34, 8);
  fill(200, 130, 60);
  ellipse(cx, cy, 30, 16);
  ellipse(cx + 14, cy - 6, 14, 13);
  triangle(cx + 9, cy - 10, cx + 12, cy - 18, cx + 15, cy - 11);
  triangle(cx + 15, cy - 11, cx + 19, cy - 18, cx + 21, cy - 9);
  stroke(200, 130, 60);
  strokeWeight(4);
  noFill();
  float c = sin(frameCount * 0.08) * 8;
  bezier(cx - 14, cy, cx - 24, cy - 4, cx - 22, cy - 16 + c, cx - 28, cy - 20 + c);
  noStroke();
  fill(30);
  rect(cx + 11, cy - 7, 3, 1.5);
  rect(cx + 16, cy - 7, 3, 1.5);
}

void pupitre(float cx, float cy) {
  noStroke();
  fill(120, 80, 50);
  rect(cx - 45, cy, 90, 18, 3);
  fill(150, 105, 70);
  rect(cx - 45, cy, 90, 5, 3);
  fill(70, 50, 30);
  rect(cx - 40, cy + 18, 5, 12);
  rect(cx + 35, cy + 18, 5, 12);
  fill(240);
  rect(cx - 20, cy + 2, 16, 3);
}

void mostrador(float mx, float my, float mw) {
  noStroke();
  fill(0, 60);
  rect(mx + 4, my + 46, mw, 6);
  fill(150, 110, 80);
  rect(mx, my + 14, mw, 34, 4);
  fill(190, 150, 110);
  rect(mx - 4, my + 8, mw + 8, 10, 4);
}

void mesaCafe(float cx, float cy) {
  noStroke();
  fill(0, 60);
  ellipse(cx, cy + 30, 120, 14);
  fill(220, 220, 230);
  rect(cx - 60, cy, 120, 24, 6);
  fill(240, 240, 250);
  rect(cx - 60, cy, 120, 6, 6);
  fill(80, 160, 90);
  rect(cx - 40, cy + 6, 22, 8, 3);
  fill(220, 120, 60);
  rect(cx + 10, cy + 6, 22, 8, 3);
}

void estanteLibros(float ex, float ey, float ew, float eh, float sem) {
  noStroke();
  fill(90, 60, 40);
  rect(ex, ey, ew, eh, 3);
  for (float yy = ey + 6; yy < ey + eh - 10; yy += 28) {
    fill(60, 40, 26);
    rect(ex + 4, yy + 22, ew - 8, 4);
    float xx = ex + 6;
    int k = 0;
    while (xx < ex + ew - 12) {
      float w = 6 + hsh(sem + yy + k) * 7;
      fill(paletaRopa[int(hsh(sem + k * 1.7 + yy) * paletaRopa.length) % paletaRopa.length]);
      rect(xx, yy + 4 + hsh(k + yy) * 4, w, 18 - hsh(k + yy) * 4);
      xx += w + 1;
      k++;
    }
  }
}

void puertaLateral(float px, float py, boolean izquierda, String t) {
  noStroke();
  fill(70, 50, 40);
  rect(izquierda ? 0 : width - 18, py, 18, 110);
  fill(izquierda ? color(255, 220, 120) : color(255, 220, 120));
  ellipse(izquierda ? 14 : width - 14, py + 58, 5, 5);
}

// ------------------------------------- FONDO: 52 AVENIDA CENTRAL -------------------------------------
float[][] autosAv = {{175, 0, 2.6, 0}, {225, 300, -2.2, 1}, {575, 150, 2.4, 2}, {625, 420, -2.8, 3}};
color[] coloresAutos = {#DC3C3C, #3C78DC, #F0C83C, #E6E6E6};

void fondoAvenida() {
  degradado(0, 0, width, 92, color(30, 14, 60), color(120, 56, 120));
  edificiosCiudad(0, 260, 92, 52);
  edificiosCiudad(540, 800, 92, 77);
  noStroke();
  fill(70, 50, 100);
  quad(260, 92, 540, 92, 500, 40, 300, 40);
  // aceras con tiendas
  fill(92, 86, 110);
  rect(0, 92, 150, 408);
  rect(650, 92, 150, 408);
  for (int i = 0; i < 4; i++) {
    fill(paletaCasas[i % paletaCasas.length]);
    rect(0, 120 + i * 95, 24, 80);
    rect(776, 120 + i * 95, 24, 80);
    fill(255, 210, 130, 200);
    rect(4, 135 + i * 95, 14, 22);
    rect(782, 135 + i * 95, 14, 22);
  }
  // calles
  fill(36, 34, 46);
  rect(150, 92, 100, 408);
  rect(550, 92, 100, 408);
  fill(230, 200, 80);
  for (float yy = 100; yy < height; yy += 50) {
    rect(198, yy, 4, 26);
    rect(598, yy, 4, 26);
  }
  // boulevard
  fill(122, 110, 132);
  rect(250, 92, 300, 408);
  stroke(108, 96, 118);
  strokeWeight(1);
  for (float yy = 92; yy < height; yy += 26) line(250, yy, 550, yy);
  for (float xx = 250; xx < 550; xx += 50) line(xx, 92, xx, height);
  noStroke();
  // paso peatonal
  fill(240, 240, 240, 220);
  for (float yy = 274; yy < 330; yy += 12) {
    rect(152, yy, 96, 7);
    rect(552, yy, 96, 7);
  }
  // arboles, postes y bancas
  arbolito(272, 140, 18, 1);
  arbolito(528, 140, 18, 2);
  arbolito(272, 470, 18, 3);
  arbolito(528, 470, 18, 4);
  poste(140, 250, 0);
  poste(660, 250, 1);
  banca(400, 140);
  // moto de Tono
  fill(30);
  ellipse(48, 232, 18, 18);
  ellipse(88, 232, 18, 18);
  fill(220, 60, 60);
  rect(48, 210, 40, 16, 6);
  fill(60);
  rect(44, 200, 8, 14);
  fill(230, 200, 80);
  rect(70, 196, 22, 18, 3);
  // carrito de helados
  fill(0, 60);
  ellipse(330, 218, 70, 12);
  fill(240, 240, 250);
  rect(300, 176, 60, 38, 6);
  fill(255, 140, 180);
  rect(300, 176, 60, 10, 6);
  fill(80);
  ellipse(310, 216, 10, 10);
  ellipse(350, 216, 10, 10);
  stroke(120);
  strokeWeight(2);
  line(330, 176, 330, 150);
  noStroke();
  for (int i = 0; i < 4; i++) {
    fill(i % 2 == 0 ? neonRosa : neonAmarillo);
    arc(330, 150, 56, 30, PI + i * QUARTER_PI, PI + (i + 1) * QUARTER_PI);
  }
  // cabina telefonica
  fill(0, 60);
  ellipse(705, 446, 50, 10);
  fill(200, 40, 50);
  rect(683, 360, 44, 82, 6);
  fill(150, 220, 255, 160);
  rect(689, 372, 32, 50, 3);
  fill(255);
  textFont(fuenteUI);
  textSize(8);
  textAlign(CENTER, CENTER);
  text("TELEFONO", 705, 366);
  // autos que paran si estas en el paso peatonal
  boolean enPaso = (y + 40 > 262 && y + 32 < 336);
  for (int i = 0; i < autosAv.length; i++) {
    float[] a = autosAv[i];
    int dir = a[2] > 0 ? 1 : -1;
    float frente = a[1] + dir * 26;
    boolean frena = enPaso && ((dir > 0 && frente > 250 && frente < 270) || (dir < 0 && frente < 345 && frente > 325));
    if (!frena && !pausaAbierta && !telefonoAbierto) a[1] += a[2];
    if (a[1] > height + 40) a[1] = 60;
    if (a[1] < 60) a[1] = height + 40;
    autoVertical(a[0], a[1], coloresAutos[int(a[3])], dir);
  }
}

// ------------------------------------- FONDO: 53 PASEO DE CAMPANA -------------------------------------
void fondoPaseo() {
  degradado(0, 0, width, 110, color(40, 20, 70), color(120, 60, 110));
  noStroke();
  // la alcaldia al fondo
  fill(200, 190, 215);
  rect(250, 20, 300, 90);
  fill(170, 160, 195);
  triangle(240, 22, 400, -10, 560, 22);
  for (int i = 0; i < 6; i++) {
    fill(230, 225, 240);
    rect(272 + i * 46, 40, 10, 60);
  }
  fill(90, 64, 52);
  rect(375, 66, 50, 44, 25, 25, 0, 0);
  fill(30, 25, 50);
  rect(320, 24, 160, 14, 3);
  fill(255, 220, 120);
  textFont(fuenteUI);
  textSize(9);
  textAlign(CENTER, CENTER);
  text("ALCALDIA DE NOVA", 400, 30);
  // piso
  fill(112, 102, 122);
  rect(0, 110, width, 390);
  stroke(98, 88, 108);
  strokeWeight(1);
  for (int xx = 0; xx < width; xx += 40) line(xx, 110, xx, height);
  for (int yy = 110; yy < height; yy += 40) line(0, yy, width, yy);
  noStroke();
  fill(150, 40, 60);
  rect(350, 110, 100, 390);
  fill(220, 180, 80);
  rect(350, 110, 3, 390);
  rect(447, 110, 3, 390);
  // banderines
  for (int k = 0; k < 2; k++) {
    float by = 120 + k * 170;
    stroke(80);
    strokeWeight(1);
    line(0, by, width, by + 10);
    noStroke();
    for (int i = 0; i < 20; i++) {
      float bx = i * 42 + 10;
      float sy = by + i * 0.5 + sin(frameCount * 0.1 + i) * 1.5;
      fill(paletaFlores[(i + k) % paletaFlores.length]);
      triangle(bx, sy, bx + 18, sy, bx + 9, sy + 18);
    }
  }
  // carpas de los candidatos
  carpa(50, 130, #3C78C8, "PATROCLO");
  carpa(50, 300, #DC6E8C, "CLEMENCIA");
  carpa(580, 130, #46A064, "GONZALO");
  carpa(580, 300, #DCA032, "RAMIREZ");
  // muro de carteles
  fill(90, 84, 100);
  rect(50, 395, 120, 56, 4);
  for (int i = 0; i < 7; i++) {
    pushMatrix();
    translate(62 + (i % 4) * 28, 405 + (i / 4) * 22);
    rotate(hsh(i * 3.3) * 0.4 - 0.2);
    fill(paletaRopa[i % paletaRopa.length]);
    rect(0, 0, 24, 18, 2);
    popMatrix();
  }
  // kiosko de fotos
  fill(0, 60);
  ellipse(690, 456, 70, 12);
  fill(40, 30, 70);
  rect(660, 380, 60, 72, 6);
  fill(neonAmarillo, 200);
  rect(668, 392, 44, 30, 3);
  fill(30);
  ellipse(690, 407, 16, 16);
  fill(neonAmarillo);
  textFont(fuenteUI);
  textSize(9);
  textAlign(CENTER, CENTER);
  text("FOTO", 690, 436);
  // el dron de Tomas
  float dx = 290 + sin(frameCount * 0.03) * 40, dy = 370 + cos(frameCount * 0.05) * 10;
  fill(60);
  rect(dx - 12, dy - 3, 24, 6, 3);
  stroke(60);
  strokeWeight(2);
  line(dx - 16, dy - 6, dx - 8, dy);
  line(dx + 16, dy - 6, dx + 8, dy);
  noStroke();
  fill(200, 200, 220, 120);
  ellipse(dx - 16, dy - 6, 16, 4);
  ellipse(dx + 16, dy - 6, 16, 4);
  fill(frameCount % 20 < 10 ? neonRojo : neonVerde);
  ellipse(dx, dy, 4, 4);
}

void carpa(float cx, float cy, color c, String t) {
  noStroke();
  fill(0, 60);
  rect(cx + 4, cy + 72, 170, 8, 4);
  fill(c);
  quad(cx - 6, cy + 24, cx + 176, cy + 24, cx + 160, cy, cx + 10, cy);
  for (int i = 0; i < 9; i++) {
    fill(i % 2 == 0 ? c : color(245));
    arc(cx + 10 + i * 19, cy + 24, 19, 14, 0, PI);
  }
  fill(70, 60, 80);
  rect(cx + 8, cy + 24, 5, 46);
  rect(cx + 157, cy + 24, 5, 46);
  fill(240);
  rect(cx + 20, cy + 42, 130, 28, 3);
  fill(c);
  textFont(fuenteUI);
  textSize(12);
  textAlign(CENTER, CENTER);
  text(t, cx + 85, cy + 55);
}

// ------------------------------------- FONDO: 54 MERCADO -------------------------------------
void fondoMercado() {
  degradado(0, 0, width, 60, color(14, 8, 34), color(58, 28, 84));
  noStroke();
  // tiendas de arriba (con un callejon en la mitad)
  for (int i = 0; i < 6; i++) {
    float tx = i * 135 - 10;
    if (tx > 300 && tx < 460) continue;
    fill(paletaCasas[i % paletaCasas.length]);
    rect(tx, 40, 125, 110);
    fill(255, 214, 130, 220);
    rect(tx + 14, 60, 34, 26, 3);
    rect(tx + 76, 60, 34, 26, 3);
    toldo(tx, 100, 120, i % 2 == 0 ? color(220, 60, 60) : color(60, 140, 200));
    fill(50, 30, 30);
    rect(tx + 48, 122, 28, 28);
  }
  fill(20, 14, 30);
  rect(345, 40, 110, 110);
  fill(60, 50, 80);
  rect(345, 140, 110, 10);
  fill(neonCian);
  textFont(fuenteUI);
  textSize(10);
  textAlign(CENTER, CENTER);
  // letrero del ciber
  boolean on = hsh(floor(frameCount / 6.0)) > 0.06;
  fill(10, 8, 26);
  rect(650, 82, 110, 16, 4);
  fill(on ? neonVerde : color(40, 80, 50));
  text("CIBER NOVA", 705, 89);
  fill(30, 30, 50);
  rect(670, 128, 60, 22, 3);
  fill(neonVerde, 180);
  rect(676, 131, 48, 15, 2);
  // piso empedrado
  fill(84, 78, 96);
  rect(0, 150, width, 350);
  for (int i = 0; i < 260; i++) {
    fill(hsh(i * 2.1) > 0.5 ? color(96, 90, 108) : color(74, 68, 86));
    ellipse(hsh(i * 1.3) * width, 155 + hsh(i * 3.7) * 345, 16, 10);
  }
  // guirnalda
  for (int i = 0; i <= 20; i++) {
    float t = i / 20.0;
    float lx = t * width, ly = 170 + sin(t * PI) * 30;
    boolean onL = hsh(i + floor(frameCount / 12.0)) > 0.2;
    fill(paletaFlores[i % paletaFlores.length], onL ? 255 : 80);
    ellipse(lx, ly, 7, 7);
  }
  // puesto de frutas y puesto de celulares
  puesto(115, 205, color(60, 160, 80), "FRUTAS DON PACHO");
  cajaFrutas(150, 238, color(255, 180, 40));
  cajaFrutas(200, 238, color(230, 60, 60));
  cajaFrutas(250, 238, color(120, 200, 60));
  puesto(515, 205, color(150, 80, 255), "YULI REPARA");
  for (int i = 0; i < 4; i++) {
    fill(30);
    rect(540 + i * 32, 226, 18, 28, 3);
    fill(i % 2 == 0 ? neonCian : neonRosa, 180);
    rect(542 + i * 32, 229, 14, 20, 2);
  }
  // cajas y el gato
  fill(150, 100, 60);
  rect(380, 440, 44, 26, 2);
  rect(440, 446, 30, 20, 2);
  gatito(410, 438);
  poste(40, 150, 0);
  poste(760, 150, 1);
}

void puesto(float px, float py, color c, String t) {
  noStroke();
  fill(0, 60);
  rect(px + 4, py + 82, 170, 8, 4);
  toldo(px - 4, py - 8, 180, c);
  fill(130, 90, 55);
  rect(px, py + 40, 170, 40, 3);
  fill(160, 115, 75);
  rect(px - 3, py + 36, 176, 8, 3);
  fill(70, 50, 35);
  rect(px + 4, py + 14, 5, 26);
  rect(px + 161, py + 14, 5, 26);
  fill(240);
  rect(px + 20, py + 56, 130, 16, 3);
  fill(c);
  textFont(fuenteUI);
  textSize(10);
  textAlign(CENTER, CENTER);
  text(t, px + 85, py + 63);
}

// ------------------------------------- FONDO: 55 CANCHA -------------------------------------
void fondoCancha() {
  degradado(0, 0, width, 60, color(60, 120, 200), color(150, 200, 240));
  noStroke();
  // graderias con publico
  fill(110, 110, 130);
  rect(0, 40, width, 78);
  for (int r = 0; r < 3; r++) {
    fill(130 - r * 10, 130 - r * 10, 150 - r * 10);
    rect(0, 46 + r * 24, width, 6);
    for (int i = 0; i < 26; i++) {
      float ax = 14 + i * 31 + r * 10;
      float salto = abs(sin(frameCount * 0.1 + i + r)) * 4;
      fill(paletaRopa[(i + r) % paletaRopa.length]);
      rect(ax - 7, 52 + r * 24 - salto, 14, 14, 4);
      fill(tonosPiel[(i + r) % tonosPiel.length]);
      ellipse(ax, 47 + r * 24 - salto, 11, 11);
    }
  }
  // reja
  stroke(170, 170, 190, 160);
  strokeWeight(1);
  for (int xx = 0; xx < width; xx += 14) line(xx, 112, xx + 14, 126);
  noStroke();
  // cancha
  for (int i = 0; i < 8; i++) {
    fill(i % 2 == 0 ? color(60, 140, 70) : color(52, 126, 62));
    rect(0, 118 + i * 48, width, 48);
  }
  noFill();
  stroke(240, 240, 240, 200);
  strokeWeight(3);
  rect(30, 140, 740, 340);
  line(400, 140, 400, 480);
  ellipse(400, 310, 110, 110);
  rect(30, 230, 70, 160);
  rect(700, 230, 70, 160);
  noStroke();
  // arcos
  fill(240);
  rect(8, 210, 6, 140);
  rect(786, 210, 6, 140);
  stroke(240, 240, 240, 120);
  strokeWeight(1);
  for (float yy = 210; yy < 350; yy += 10) {
    line(14, yy, 50, yy);
    line(750, yy, 786, yy);
  }
  noStroke();
  // niños jugando
  for (int i = 0; i < 4; i++) {
    float t = frameCount * 0.012 + i * 1.6;
    float nx = 400 + cos(t) * (220 - i * 20), ny = 300 + sin(t * 1.3) * 110;
    if (dist(nx, ny, x + 50, y + 40) < 50) continue;
    pushMatrix();
    translate(nx, ny + 20);
    scale(0.8);
    dibujarNPC(0, 0, paletaRopa[(i * 2) % paletaRopa.length], #2A1E14, i * 2.3, false, "");
    popMatrix();
  }
  // pantalla gigante del minijuego de saltar con la mano
  fill(0, 70);
  rect(612, 200, 80, 8);
  fill(60, 60, 80);
  rect(620, 150, 6, 52);
  rect(678, 150, 6, 52);
  fill(20, 18, 40);
  rect(600, 120, 104, 66, 6);
  fill(80, 180, 255, 200);
  rect(606, 126, 92, 54, 3);
  float saltoP = abs(sin(frameCount * 0.08)) * 16;
  fill(255, 214, 170);
  rect(626, 156 - saltoP, 10, 14, 2);
  fill(neonRojo);
  rect(656, 164, 12, 12, 2);
  fill(70, 56, 96);
  rect(606, 174, 92, 6);
  // el balon de los penales
  float bb = abs(sin(frameCount * 0.08)) * 4;
  fill(0, 70);
  ellipse(400, 316, 20, 6);
  fill(250);
  ellipse(400, 306 - bb, 18, 18);
  fill(30);
  ellipse(400, 306 - bb, 6, 6);
  ellipse(394, 301 - bb, 4, 4);
  ellipse(406, 311 - bb, 4, 4);
  // la puerta de la reja (salida)
  fill(170, 170, 190);
  rect(0, 380, 8, 100);
}

// ------------------------------------- FONDO: 56 CALLEJON -------------------------------------
void fondoCallejon() {
  background(24, 18, 34);
  noStroke();
  fill(40, 34, 52);
  rect(232, 0, 336, height);
  for (int i = 0; i < 6; i++) {
    fill(30, 26, 40);
    ellipse(300 + hsh(i) * 200, 160 + hsh(i * 3) * 300, 60 + hsh(i * 7) * 40, 14);
  }
  // paredes de ladrillo
  for (int lado = 0; lado < 2; lado++) {
    float wx = lado == 0 ? 0 : 568;
    fill(110, 60, 56);
    rect(wx, 0, 232, height);
    stroke(80, 44, 40);
    strokeWeight(1);
    for (float yy = 0; yy < height; yy += 16) {
      line(wx, yy, wx + 232, yy);
      for (float xx = wx + ((yy / 16) % 2) * 16; xx < wx + 232; xx += 32) line(xx, yy, xx, yy + 16);
    }
    noStroke();
  }
  // murales
  fill(neonRosa, 200);
  ellipse(120, 160, 150, 150);
  fill(neonCian, 200);
  triangle(40, 330, 210, 280, 160, 440);
  fill(neonAmarillo);
  textFont(fuente);
  textSize(28);
  textAlign(CENTER, CENTER);
  text("NOVA", 120, 160);
  fill(neonVerde, 210);
  rect(590, 330, 190, 120, 20);
  fill(30);
  ellipse(660, 380, 50, 50);
  stroke(30);
  strokeWeight(8);
  line(678, 398, 705, 425);
  noStroke();
  fill(255);
  textFont(fuenteUI);
  textSize(11);
  text("MIRA QUIEN LO DIJO", 685, 440);
  fill(neonMorado, 200);
  rect(600, 80, 170, 80, 10);
  fill(255);
  textSize(13);
  text("LA VERDAD\nSE VERIFICA", 685, 120);
  // luces colgantes
  for (int i = 0; i <= 10; i++) {
    float t = i / 10.0;
    float lx = 232 + t * 336, ly = 60 + sin(t * PI) * 26;
    fill(255, 220, 140, 60);
    ellipse(lx, ly, 18, 18);
    fill(255, 230, 160);
    ellipse(lx, ly, 6, 6);
  }
  // contenedor y escalera de incendios
  contenedor(285, 470, color(60, 70, 90));
  fill(30);
  for (int i = 0; i < 4; i++) rect(568, 150 + i * 30, 30, 4);
  rect(594, 140, 4, 120);
  // spray de Maya
  if (frameCount % 3 == 0) agregarParticula(new Particula(248, 232 + random(-6, 6), random(-1.5, -0.5), random(-0.5, 0.5), 25, 4, paletaFlores[int(random(4))], 0));
  // ojos de gato en la oscuridad
  if ((frameCount / 90) % 3 != 0) {
    fill(255, 255, 120);
    ellipse(540, 60, 5, 3);
    ellipse(549, 60, 5, 3);
  }
}

// ------------------------------------- FONDO: 57 PASILLO -------------------------------------
void fondoPasillo() {
  pisoBaldosas(160, 40, color(200, 196, 210), color(170, 166, 184));
  noStroke();
  fill(120, 140, 170);
  rect(0, 0, width, 160);
  fill(90, 110, 140);
  rect(0, 150, width, 10);
  // casilleros
  for (int i = 0; i < 9; i++) {
    float lx = 20 + i * 34;
    if (i == 5) fill(220, 120, 60);
    else fill(70, 90, 150);
    rect(lx, 40, 30, 110, 2);
    fill(30, 40, 70);
    for (int k = 0; k < 3; k++) rect(lx + 6, 52 + k * 6, 18, 3);
    fill(200);
    rect(lx + 22, 96, 4, 10);
  }
  fill(neonAmarillo);
  ellipse(197, 70, 12, 12);
  // puerta de la cafeteria
  fill(110, 80, 60);
  rect(350, 50, 100, 110, 4);
  fill(150, 200, 230, 150);
  rect(360, 62, 36, 40, 3);
  rect(404, 62, 36, 40, 3);
  fill(30, 25, 50);
  rect(355, 20, 90, 22, 4);
  fill(255, 220, 120);
  textFont(fuenteUI);
  textSize(11);
  textAlign(CENTER, CENTER);
  text("CAFETERIA", 400, 30);
  // vitrina de trofeos
  fill(80, 60, 50);
  rect(480, 60, 100, 90, 4);
  fill(180, 220, 240, 120);
  rect(486, 66, 88, 78, 3);
  for (int i = 0; i < 3; i++) {
    fill(neonAmarillo);
    arc(505 + i * 25, 100, 16, 18, 0, PI);
    rect(503 + i * 25, 108, 4, 10);
    rect(498 + i * 25, 118, 14, 4);
  }
  // cartelera
  fill(150, 110, 70);
  rect(600, 50, 170, 100, 4);
  fill(200, 170, 120);
  rect(606, 56, 158, 88, 3);
  for (int i = 0; i < 5; i++) {
    fill(paletaFlores[i % 4]);
    pushMatrix();
    translate(620 + (i % 3) * 50, 70 + (i / 3) * 40);
    rotate(hsh(i) * 0.3 - 0.15);
    rect(0, 0, 40, 30);
    popMatrix();
  }
  // lamparas del techo
  for (int i = 0; i < 4; i++) {
    fill(255, 250, 220, 25);
    ellipse(100 + i * 200, 300, 220, 120);
  }
  puertaLateral(0, 250, true, "SALON 10B");
  puertaLateral(width, 250, false, "BIBLIOTECA");
  fill(110, 80, 60);
  rect(300, 488, 200, 12);
}

// ------------------------------------- FONDO: 58 SALON 10B -------------------------------------
void fondoSalon() {
  noStroke();
  fill(160, 120, 80);
  rect(0, 140, width, 360);
  stroke(140, 100, 66);
  strokeWeight(1);
  for (float yy = 140; yy < height; yy += 24) line(0, yy, width, yy);
  noStroke();
  fill(220, 210, 180);
  rect(0, 0, width, 140);
  fill(200, 190, 160);
  rect(0, 130, width, 10);
  // tablero
  fill(60, 60, 70);
  rect(110, 20, 420, 106, 4);
  fill(30, 70, 50);
  rect(118, 28, 404, 90);
  fill(240);
  textFont(fuenteUI);
  textSize(14);
  textAlign(LEFT, TOP);
  text("ETICA - 10B", 132, 36);
  textSize(12);
  text("Somos responsables de lo\nque compartimos?", 132, 58);
  fill(neonAmarillo);
  textSize(11);
  text("Hoy: TELEFONO ROTO", 360, 96);
  // ventanas
  for (int i = 0; i < 2; i++) {
    fill(90, 160, 220);
    rect(600 + i * 95, 26, 80, 70, 3);
    fill(255, 255, 255, 60);
    rect(604 + i * 95, 30, 30, 62);
    stroke(255);
    strokeWeight(3);
    line(640 + i * 95, 26, 640 + i * 95, 96);
    noStroke();
  }
  // escritorio del profe
  fill(100, 70, 45);
  rect(600, 150, 150, 34, 3);
  fill(240);
  rect(620, 140, 30, 12);
  fill(neonRojo);
  ellipse(700, 146, 14, 14);
  // estudiantes sentados (los pupitres se dibujan por delante)
  for (int i = 0; i < pupitres.length; i++) {
    if (i == 2) continue;
    dibujarNPC(pupitres[i][0], pupitres[i][1] + 10, paletaRopa[(i * 3) % paletaRopa.length], i % 2 == 0 ? #2A1E14 : #8C5A3C, i * 1.9, false, "");
  }
  puertaLateral(width, 250, false, "PASILLO");
}

// ------------------------------------- FONDO: 59 BIBLIOTECA -------------------------------------
void fondoBiblioteca() {
  noStroke();
  fill(130, 40, 50);
  rect(0, 145, width, 355);
  fill(150, 50, 60);
  for (int i = 0; i < 20; i++) rect(0, 160 + i * 18, width, 2);
  fill(180, 160, 130);
  rect(0, 0, width, 145);
  estanteLibros(10, 10, 280, 132, 59);
  estanteLibros(300, 10, 180, 132, 61);
  // ventana redonda
  fill(90, 160, 220);
  ellipse(560, 70, 90, 90);
  stroke(255);
  strokeWeight(3);
  line(515, 70, 605, 70);
  line(560, 25, 560, 115);
  noStroke();
  estanteLibros(640, 10, 150, 132, 67);
  // mesa de lectura con lamparas
  fill(0, 60);
  rect(224, 336, 180, 10, 4);
  fill(110, 75, 50);
  rect(220, 300, 180, 38, 4);
  for (int i = 0; i < 2; i++) {
    fill(255, 240, 180, 40);
    ellipse(260 + i * 100, 300, 80, 40);
    fill(60, 120, 80);
    arc(260 + i * 100, 288, 26, 20, PI, TWO_PI);
    fill(80);
    rect(258 + i * 100, 288, 4, 12);
  }
  fill(240);
  rect(300, 306, 30, 20);
  dibujarNPC(npcRocio.ix, npcRocio.iy, npcRocio.ropa, npcRocio.pelo, npcRocio.fase, false, npcRocio.nombre);
  mostrador(500, 165, 200);
  // computador
  fill(0, 60);
  rect(624, 418, 110, 8, 4);
  fill(100, 70, 50);
  rect(620, 390, 110, 30, 3);
  fill(30, 30, 40);
  rect(645, 344, 60, 44, 4);
  fill(neonAmarillo, 180);
  rect(649, 348, 52, 34, 2);
  fill(30);
  rect(667, 386, 16, 6);
  // plantas
  for (int i = 0; i < 2; i++) {
    float px = i == 0 ? 40 : 470;
    fill(160, 90, 60);
    rect(px - 12, 450, 24, 26, 4);
    fill(60, 140, 80);
    ellipse(px, 440, 40, 30);
    ellipse(px - 10, 430, 24, 22);
  }
  puertaLateral(0, 250, true, "PASILLO");
}

// ------------------------------------- FONDO: 60 CAFETERIA -------------------------------------
void fondoCafeteria() {
  pisoBaldosas(135, 34, color(230, 230, 220), color(200, 210, 200));
  noStroke();
  fill(240, 200, 120);
  rect(0, 0, width, 135);
  fill(210, 170, 100);
  rect(0, 126, width, 9);
  // ventanas al patio
  for (int i = 0; i < 3; i++) {
    fill(110, 190, 240);
    rect(560 + i * 76, 20, 64, 80, 4);
    fill(60, 150, 80);
    rect(560 + i * 76, 80, 64, 20);
    fill(255, 255, 255, 70);
    rect(564 + i * 76, 24, 20, 72);
  }
  // tablero del menu
  fill(40, 40, 50);
  rect(140, 20, 160, 100, 4);
  fill(240);
  textFont(fuenteUI);
  textSize(12);
  textAlign(LEFT, TOP);
  text("MENU DEL DIA", 152, 28);
  textSize(10);
  text("Arroz con pollo\nJugo de mora\nPostre", 152, 50);
  fill(neonVerde);
  text("SIN GUSANOS (verificado)", 152, 98);
  // bandejas de comida sobre el mostrador
  for (int i = 0; i < 5; i++) {
    fill(80, 160, 90);
    rect(268 + i * 56, 124, 46, 14, 3);
    fill(paletaFlores[i % 4]);
    ellipse(282 + i * 56, 128, 10, 8);
    fill(255, 230, 160);
    ellipse(300 + i * 56, 129, 12, 8);
  }
  dibujarNPC(npcTere.ix, npcTere.iy, npcTere.ropa, npcTere.pelo, npcTere.fase, !npcTere.hablado, npcTere.nombre);
  mostrador(250, 130, 300);
  // estudiantes almorzando (las mesas van por delante)
  for (int i = 1; i < mesasCafe.length; i++) {
    dibujarNPC(mesasCafe[i][0] - 36, mesasCafe[i][1] + 8, paletaRopa[(i * 5) % paletaRopa.length], #2A1E14, i * 3.1, false, "");
  }
  fill(110, 80, 60);
  rect(330, 488, 140, 12);
}
