# Ciudad Nova

Un juego hecho en [Processing](https://processing.org) sobre rumores, redes sociales y decisiones.
Faltan 7 días para las elecciones en Ciudad Nova y Conecta, la red social de la ciudad, está llena de bulos.
Explora la ciudad, habla con la gente y decide qué compartes: tus decisiones mueven tu **Viralidad**, tu **Confiabilidad** y tu **Impacto**, y al final te llevan a uno de 4 finales.

## Cómo jugarlo

1. Instala Processing 4.
2. Instala la **Video Library for Processing 4** (en Processing: *Sketch → Importar biblioteca → Gestionar bibliotecas*, busca "Video Library for Processing 4"). Sin ella el juego no compila, porque el minijuego Manotazo usa la cámara.
3. Abre `Lab.pde` (las demás pestañas `.pde` se cargan solas).
4. Presiona ▶ (Run).

## Controles

| Tecla | Acción |
|---|---|
| W A S D / flechas | Caminar |
| SHIFT | Correr |
| E | Hablar / revisar objetos |
| ENTER | Avanzar diálogos |
| Clic | Elegir opciones |
| P o TAB | Abrir el teléfono |
| ESC | Pausa |
| F3 | Modo debug (coordenadas del mouse) |

## Lugares

- **Barrio:** entrada a Nova, plaza, Junta Vecinal, calles, mercado, cancha y callejón de los murales
- **Colegio:** cuatro calles, el Café 404 y, por la puerta de la Calle 4, el pasillo, el salón 10°B, la biblioteca y la cafetería
- **Alcaldía:** se llega caminando por la Avenida Central y el Paseo de Campaña
- **Parque Central**, **Centro NOVA**, **Nova Noticias** (concurso en vivo) y **Plaza de la Votación** (los finales)

## Minijuegos

Verificador Express, Atrapa Bulos, Caza Bots, Rastreo de Fuentes, Teléfono Roto, Penales, Foto Trucada, Teclado Veloz, y dos que se juegan **con la mano frente a la cámara web**:
- **Manotazo:** mueve la mano para sacar los bulos de la pantalla.
- **Salto con la Mano:** levanta la mano para saltar las pilas de bulos.

La cámara busca **solo la mano**: combina el movimiento con el color de piel, ignora la cara y la ropa, y con la tecla **C** aprende tu tono de piel. Sin cámara se juegan con el mouse o el teclado.
Están en la Sala Arcade del menú, en la app Juegos del teléfono y en máquinas repartidas por la ciudad.

## Archivos

| Archivo | Qué tiene |
|---|---|
| `Lab.pde` | El juego original: escenas, diálogos y decisiones |
| `Vida.pde` | Partículas, HUD, transiciones, logros, pausa y hora del día |
| `Menu.pde` | Menú animado, intro, créditos y "Cómo jugar" |
| `Telefono.pde` | El teléfono y sus apps |
| `Escenarios.pde` | Diálogos nuevos, mapa vivo, Nova Noticias, votación y finales |
| `Lugares.pde` | Los lugares por los que se camina y sus personajes |
| `Fondos.pde` | Fondos dibujados con código para las escenas sin imagen |
| `Eventos.pde` | Eventos aleatorios del mapa |
| `Minijuegos.pde`, `Minijuegos2.pde` | La Sala Arcade y los 8 minijuegos |
| `Camara.pde` | La cámara, la detección de la mano y el minijuego Manotazo |
| `Salto.pde` | El minijuego Salto con la Mano |
| `Carga.pde` | Pantallas de carga con tema para cada minijuego y lugar |
| `Responsable.pde` | Uso responsable: la pausa antes de compartir, los rumores que se riegan por el mapa, los mensajes de los afectados, los personajes que recuerdan y tu historial al final |
| `Pixel.pde` | Hace que los fondos y personajes dibujados con código se vean pixel art |
| `data/` | Imágenes, sprites y la fuente |

Los récords y logros se guardan en `datos_nova.txt`, junto a `Lab.pde`. Ese archivo no se sube al repositorio.
