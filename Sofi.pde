// =====================================================================================
//  SOFI.pde -> como se ve Sofi en todo el juego
//  Pelo largo con fleco y una pinza de estrella, pestañas, labios, blusa rosada
//  con la cintura marcada, falda azul con vuelo y botas cortas.
//   - dibujarSofiCuerpo: en los lugares (mismo tamaño que los demas personajes)
//   - sofiU: en las cinematicas y las animaciones de los finales (pixeles grandes)
// =====================================================================================

final color SOFI_PELO = #4A2C1A;
final color SOFI_PELO_BRILLO = #6E4430;
final color SOFI_PIEL = #F1C9A5;
final color SOFI_BLUSA = #E85D75;
final color SOFI_FALDA = #2D3A5A;
final color SOFI_PINZA = #FFC846;

// ------------------------------------- EN LOS LUGARES -------------------------------------
void dibujarSofiCuerpo(float cx, float pies, float fase, boolean marca) {
  if (dibujarPersonaNova("Sofi", cx, pies, fase)) {
    if (marca) marcaSpriteNova(cx, pies, fase);
    return;
  }
  pushStyle();
  float t = frameCount * 0.06 + fase;
  float bob = sin(t) * 1.5;
  float hy = pies - 50 + bob;
  noStroke();
  fill(0, 90);
  ellipse(cx, pies, 34, 10);
  // contorno oscuro (como el resto del pixel art)
  fill(16, 8, 28);
  rect(cx - 9, pies - 16, 18, 18, 2);
  quad(cx - 19, pies - 16 + bob, cx + 19, pies - 16 + bob, cx + 12, pies - 30 + bob, cx - 12, pies - 30 + bob);
  rect(cx - 14, pies - 42 + bob, 28, 16, 8);
  rect(cx - 17, hy - 12, 34, 40, 12);
  ellipse(cx, hy, 30, 30);
  // el pelo largo de atras (cae hasta la mitad de la espalda)
  fill(SOFI_PELO);
  rect(cx - 15, hy - 8, 30, 36, 10);
  // piernas con medias y botas cortas
  fill(48, 44, 70);
  rect(cx - 7, pies - 15, 5, 14, 2);
  rect(cx + 2, pies - 15, 5, 14, 2);
  fill(#5A3518);
  rect(cx - 8, pies - 5, 7, 6, 2);
  rect(cx + 1, pies - 5, 7, 6, 2);
  // falda con vuelo (se mece un poquito al caminar)
  float vuelo = sin(t * 0.9) * 1.5;
  fill(SOFI_FALDA);
  quad(cx - 10, pies - 28 + bob, cx + 10, pies - 28 + bob, cx + 16 + vuelo, pies - 13 + bob, cx - 16 + vuelo, pies - 13 + bob);
  fill(255, 30);
  quad(cx - 3, pies - 28 + bob, cx + 1, pies - 28 + bob, cx + 2 + vuelo, pies - 13 + bob, cx - 5 + vuelo, pies - 13 + bob);
  // brazos
  color manga = color(red(SOFI_BLUSA) * 0.8, green(SOFI_BLUSA) * 0.8, blue(SOFI_BLUSA) * 0.8);
  fill(manga);
  pushMatrix();
  translate(cx - 11, pies - 39 + bob);
  rotate(sin(t * 0.7) * 0.12);
  rect(-3, 0, 5, 17, 3);
  fill(SOFI_PIEL);
  ellipse(-0.5, 18, 5, 5);
  popMatrix();
  fill(manga);
  pushMatrix();
  translate(cx + 11, pies - 39 + bob);
  rotate(-sin(t * 0.7) * 0.12);
  rect(-2, 0, 5, 17, 3);
  fill(SOFI_PIEL);
  ellipse(0.5, 18, 5, 5);
  popMatrix();
  // blusa con la cintura marcada
  fill(SOFI_BLUSA);
  quad(cx - 11, pies - 40 + bob, cx + 11, pies - 40 + bob, cx + 8, pies - 27 + bob, cx - 8, pies - 27 + bob);
  rect(cx - 11, pies - 41 + bob, 22, 6, 4);
  fill(255, 60);
  rect(cx - 9, pies - 39 + bob, 5, 9, 3);
  fill(#B83A55);
  rect(cx - 8, pies - 28 + bob, 16, 2);   // cinturon fino
  // cara
  fill(SOFI_PIEL);
  ellipse(cx, hy, 24, 25);
  // fleco y mechones a los lados de la cara
  fill(SOFI_PELO);
  arc(cx, hy - 3, 28, 24, PI, TWO_PI);
  quad(cx - 12, hy - 4, cx - 4, hy - 4, cx - 9, hy + 2, cx - 13, hy + 1);
  rect(cx - 15, hy - 4, 5, 22, 3);
  rect(cx + 10, hy - 4, 5, 22, 3);
  fill(SOFI_PELO_BRILLO);
  rect(cx - 7, hy - 12, 6, 2, 1);
  // la pinza de estrella
  fill(SOFI_PINZA);
  estrellaChica(cx + 9, hy - 9, 3.6);
  // ojos con pestañas
  boolean parpadea = ((frameCount + int(fase * 100)) % 210) < 7;
  fill(25);
  if (parpadea) {
    rect(cx - 7, hy + 2, 5, 1.5);
    rect(cx + 2, hy + 2, 5, 1.5);
  } else {
    ellipse(cx - 4.5, hy + 2, 3.5, 5);
    ellipse(cx + 4.5, hy + 2, 3.5, 5);
    rect(cx - 7.5, hy - 1, 2, 1.2);   // pestañas
    rect(cx + 5.5, hy - 1, 2, 1.2);
  }
  // mejillas y labios
  fill(255, 120, 120, 110);
  ellipse(cx - 8, hy + 7, 5, 3);
  ellipse(cx + 8, hy + 7, 5, 3);
  fill(#D9506A);
  rect(cx - 2, hy + 8, 4, 1.6, 1);
  if (marca) {
    float b = abs(sin(frameCount * 0.1 + fase)) * 6;
    fill(neonAmarillo);
    ellipse(cx, hy - 32 - b, 20, 20);
    triangle(cx - 4, hy - 24 - b, cx + 4, hy - 24 - b, cx, hy - 18 - b);
    fill(30);
    textFont(fuenteUI);
    textSize(14);
    textAlign(CENTER, CENTER);
    text("!", cx, hy - 33 - b);
  }
  popStyle();
}

void estrellaChica(float x, float y, float r) {
  beginShape();
  for (int k = 0; k < 10; k++) {
    float a = -HALF_PI + k * PI / 5;
    float rr = k % 2 == 0 ? r : r * 0.45;
    vertex(x + cos(a) * rr, y + sin(a) * rr);
  }
  endShape(CLOSE);
}

// ------------------------------------- EN LAS CINEMATICAS (pixeles grandes) -------------------------------------
// mismo alto que personaU (31 pixeles). (x, y) = la esquina de arriba de la cabeza
void sofiU(float x, float y, float u, float a) {
  pushStyle();
  tint(255, 255 * constrain(a, 0, 1));
  boolean dibujado = dibujarSpriteNova("Sofi", x + 6 * u, y + 31 * u, u / 2,
    modoSpriteNova("Sofi"), 0);
  popStyle();
  if (dibujado) return;
  noStroke();
  // pelo largo de atras
  fill(SOFI_PELO, 255 * a);
  rect(x - u, y + 2 * u, 14 * u, 11 * u, u);
  // falda con vuelo
  fill(SOFI_FALDA, 255 * a);
  quad(x, y + 19 * u, x + 12 * u, y + 19 * u, x + 15 * u, y + 25 * u, x - 3 * u, y + 25 * u);
  // piernas y botas
  fill(48, 44, 70, 255 * a);
  rect(x + 2 * u, y + 25 * u, 3 * u, 4 * u);
  rect(x + 7 * u, y + 25 * u, 3 * u, 4 * u);
  fill(#5A3518, 255 * a);
  rect(x + 1 * u, y + 29 * u, 4 * u, 2 * u);
  rect(x + 7 * u, y + 29 * u, 4 * u, 2 * u);
  // blusa con cintura
  fill(SOFI_BLUSA, 255 * a);
  rect(x - u, y + 12 * u, 14 * u, 4 * u);
  rect(x + u, y + 16 * u, 10 * u, 3 * u);
  fill(#B83A55, 255 * a);
  rect(x + u, y + 18 * u, 10 * u, u);
  // cara
  fill(SOFI_PIEL, 255 * a);
  rect(x + u, y + 3 * u, 10 * u, 9 * u);
  // fleco y mechones
  fill(SOFI_PELO, 255 * a);
  rect(x, y, 12 * u, 4 * u);
  rect(x + u, y + 3 * u, 4 * u, 2 * u);
  rect(x - u, y + 2 * u, 2 * u, 14 * u);
  rect(x, y + 16 * u, u, 2 * u);   // las puntas caen sobre la blusa
  rect(x + 11 * u, y + 2 * u, 2 * u, 14 * u);
  rect(x + 11 * u, y + 16 * u, u, 2 * u);
  fill(SOFI_PELO_BRILLO, 255 * a);
  rect(x + 3 * u, y + u, 4 * u, u);
  // pinza de estrella
  fill(SOFI_PINZA, 255 * a);
  rect(x + 9 * u, y + u, 2 * u, 2 * u);
  // ojos con pestañas y labios
  fill(#101018, 255 * a);
  rect(x + 3 * u, y + 6 * u, 2 * u, 2 * u);
  rect(x + 7 * u, y + 6 * u, 2 * u, 2 * u);
  rect(x + 2 * u, y + 5 * u, u, u);
  rect(x + 9 * u, y + 5 * u, u, u);
  fill(255, 140, 150, 160 * a);
  rect(x + 2 * u, y + 9 * u, 2 * u, u);
  rect(x + 8 * u, y + 9 * u, 2 * u, u);
  fill(#D9506A, 255 * a);
  rect(x + 5 * u, y + 10 * u, 2 * u, u);
}
