# Projeto Pac-Man — Arquitectura de Computadores

Este repositório contém o projeto prático da disciplina de **Arquitectura de Computadores**, cujo objetivo é a implementação do jogo **Pac-Man** em Assembly, utilizando o **PixelScreen**, integração com teclado, controlo de movimentos e verificação de colisões.

O projeto foi desenvolvido em grupo, conforme as especificações fornecidas pelo docente.

---

## Estrutura do Repositório

O repositório contém os seguintes ficheiros:

- **pacman.asm**  
  Código-fonte principal do projeto, escrito em Assembly.  
  Implementa:
  - Desenho e apagamento de pixels
  - Desenho dos objetos do jogo (Pac-Man, paredes, etc.)
  - Movimento do Pac-Man
  - Verificação de colisões
  - Integração com o teclado

- **pacman.cmod**  
  Circuito digital utilizado no projeto, compatível com o simulador adotado na disciplina.

- **pacman.xlsx**  
  Modelo da tela (PixelScreen), contendo o mapeamento lógico dos pixels utilizados no jogo.

- **README.md**  
  Documento de descrição do projeto (este ficheiro).

---

## Funcionalidades Implementadas

- Representação gráfica do jogo utilizando PixelScreen  
- Desenho e remoção dinâmica do Pac-Man  
- Controlo de movimentos através do teclado  
- Verificação de limites do ecrã  
- Deteção de colisões com obstáculos  
- Organização do código em rotinas bem definidas  

---

## Organização do Código

O código Assembly está organizado em rotinas, entre as quais:

- Inicialização do sistema  
- Rotinas de desenho e apagamento de pixels  
- Rotinas de desenho e apagamento do Pac-Man  
- Rotina de verificação de movimento (`pode_mover`)  
- Rotinas de leitura do teclado  
- Ciclo principal do jogo  

Essa organização facilita a leitura, manutenção e explicação do projeto durante a defesa.

---

## Tecnologias Utilizadas

- Linguagem: **Assembly**
- Simulador com suporte a **PixelScreen**
- Circuito digital (`.cmod`)
- Planilha de apoio para modelação da tela (`.xlsx`)
- GitHub para controlo de versões

---

## Docente

O docente da disciplina foi convidado como colaborador no repositório GitHub:

- **Username GitHub:** `joaojdacosta`

---

## Informações Importantes

- **Disciplina:** Arquitectura de Computadores  
- **Tipo de trabalho:** Projeto prático em grupo  
- **Prazo de entrega:** 04/01/2026 até às 23h  
- **Defesa do projeto:** 05/01/2026, a partir das 10h  

---

## Observações Finais

Este projeto foi desenvolvido com foco na correta aplicação dos conceitos estudados na disciplina, incluindo:

- Endereçamento de memória
- Manipulação de registos
- Estruturação de programas em Assembly
- Interação entre software e hardware simulado

---
