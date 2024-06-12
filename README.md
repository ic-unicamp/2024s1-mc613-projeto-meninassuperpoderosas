# Projeto final de MC613 - 2024s1

Grupo: Meninas Superpoderosas

- 246914 - Ana Carolina de Almeida Cardoso
- 252873 - Maria Beatriz G. T. M. Moreira
- 260637 - Pedro Brasil Barroso

## Descrição

Campo minado com as regras usuais.

### Controles
* **SW[0]**: Revela a posição selecionada quando é flipado (tanto para cima quanto para baixo);
* **SW[1]**: Posiciona uma bandeira na posição selecionada quando é flipado;
* **SW[8]**: Modo debug (revela todo o campo);
* **SW[9]**: Reset;
* **KEY[3..0]**: Movimentação, em ordem: cima, baixo, esquerda, direita.

### Displays de 7 segmentos
* Os dois displays mais à esquerda mostram o número de minas restantes (= total - bandeiras);
* Os três displays mais à direita mostram o tempo de jogo em segundos (máx. 999).

### Tamanho do campo
* Determinado pelo wire "multiplicador" no top1. Deve ser uma potência de 2.
