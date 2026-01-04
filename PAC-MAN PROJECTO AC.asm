; ====================================
; PROJECTO PAC-MAN
;GRUPO: 7
;MEMBROS:
;DIONISIO DIOGO ALBANO
;MARCOS PAULO NSANDA
;FABIO ANTUNES
;DARIO CAVALEIRO
; ====================================

; CONSTANTES DO SISTEMA
BASE_ECRA       EQU 8000H
TAM_ECRA        EQU 0080H
TOPO_PILHA      EQU 7FFEH
BYTES_POR_LINHA EQU 4
BITS_POR_BYTE   EQU 8

DISPLAYS        EQU 0A000H
TECLADO_SAIDA   EQU 0C000H
TECLADO_ENTRADA EQU 0E000H

LINHA_1         EQU 0001H
LINHA_2         EQU 0002H
LINHA_3         EQU 0004H
LINHA_4         EQU 0008H

MASCARA_TECLADO EQU 000FH

; ====================================
; DADOS DO PROGRAMA
; ====================================
PLACE 1000H

; máscaras para bits dentro do byte (bit7..bit0)
tabela_mascaras:
    WORD 0080H
    WORD 0040H
    WORD 0020H
    WORD 0010H
    WORD 0008H
    WORD 0004H
    WORD 0002H
    WORD 0001H

; tabelas do Pac-Man (3x3) - 1 = pixel aceso, 0 = apagado
tabela_pacman_direita:
    WORD 1
    WORD 1
    WORD 1
    WORD 1
    WORD 0
    WORD 0
    WORD 1
    WORD 1
    WORD 1

tabela_pacman_esquerda:
    WORD 1
    WORD 1
    WORD 1
    WORD 0
    WORD 0
    WORD 1
    WORD 1
    WORD 1
    WORD 1

tabela_pacman_cima:
    WORD 1
    WORD 0
    WORD 1
    WORD 1
    WORD 0
    WORD 1
    WORD 1
    WORD 1
    WORD 1

tabela_pacman_baixo:
    WORD 1
    WORD 1
    WORD 1
    WORD 1
    WORD 0
    WORD 1
    WORD 1
    WORD 0
    WORD 1

; tabela do objeto (3x3)
tabela_objeto:
    WORD 0
    WORD 1
    WORD 0
    WORD 1
    WORD 1
    WORD 1
    WORD 0
    WORD 1
    WORD 0

; tabela do fantasma 
; 1 0 1
; 0 1 0
; 1 0 1
tabela_fantasma:
    WORD 1
    WORD 0
    WORD 1
    WORD 0
    WORD 1
    WORD 0
    WORD 1
    WORD 0
    WORD 1

; Variáveis do teclado e pacman
tecla_lida:
    WORD 0
tecla_anterior:
    WORD 0   ; mantida mas não usada para bloquear movimento
pixel_linha:
    WORD 5
pixel_coluna:
    WORD 5
pacman_direcao:
    WORD 0

; Variáveis para fantasmas
; Estado: 0 = inactivo, 1 = na_caixa, 2 = saindo, 3 = activo
fant0_estado:    WORD 0
fant0_linha:     WORD 0
fant0_coluna:    WORD 0
fant0_atraso:    WORD 0

fant1_estado:    WORD 0
fant1_linha:     WORD 0
fant1_coluna:    WORD 0
fant1_atraso:    WORD 0

fant2_estado:    WORD 0
fant2_linha:     WORD 0
fant2_coluna:    WORD 0
fant2_atraso:    WORD 0

fant3_estado:    WORD 0
fant3_linha:     WORD 0
fant3_coluna:    WORD 0
fant3_atraso:    WORD 0

; Gerador simples (contador incrementado no ciclo principal)
gerador:      WORD 1

; Pilha
pilha:
    TABLE 100H
topo_pilha_real:

; ====================================
; INICIO DO PROGRAMA
; ====================================
PLACE 0000H

inicio:
    MOV SP, topo_pilha_real

    ; Inicializar variáveis de teclado (garante valores conhecidos)
    MOV R1, tecla_lida
    MOV R2, 0
    MOV [R1], R2
    MOV R1, tecla_anterior
    MOV [R1], R2

    ; Inicializar gerador (valor inicial)
    MOV R1, gerador
    MOV R2, 1
    MOV [R1], R2

    CALL limpar_ecra

    CALL desenhar_bordas
    CALL desenhar_caixa_central
    CALL desenhar_objetos_cantos

    ; Inicializar dados dos fantasmas (atrasos e estados)
    CALL inicializar_fantasmas

    JMP ciclo_principal

; ============================================
; ROTINAS DE CENARIO
; ====================================================

desenhar_bordas:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    MOV R1, 0
    MOV R3, 0
    MOV R4, 32
loop_borda_superior:
    MOV R2, R3
    CALL acender_pixel
    ADD R3, 1
    CMP R3, R4
    JNE loop_borda_superior

    MOV R1, 31
    MOV R3, 0
loop_borda_inferior:
    MOV R2, R3
    CALL acender_pixel
    ADD R3, 1
    CMP R3, R4
    JNE loop_borda_inferior

    MOV R2, 0
    MOV R3, 1
    MOV R4, 31
loop_borda_esquerda:
    MOV R1, R3
    CALL acender_pixel
    ADD R3, 1
    CMP R3, R4
    JNE loop_borda_esquerda

    MOV R2, 31
    MOV R3, 1
loop_borda_direita:
    MOV R1, R3
    CALL acender_pixel
    ADD R3, 1
    CMP R3, R4
    JNE loop_borda_direita

    POP R4
    POP R3
    POP R2
    POP R1
    RET

desenhar_caixa_central:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    ; LINHA SUPERIOR (14) - ABERTA (fantasmas saem por aqui)
    ; LINHA INFERIOR (18) - completa
    MOV R1, 18
    MOV R3, 14
    MOV R4, 19
loop_caixa_base:
    MOV R2, R3
    CALL acender_pixel
    ADD R3, 1
    CMP R3, R4
    JNE loop_caixa_base

    ; LADO ESQUERDO (coluna 14, linhas 14-17)
    MOV R2, 14
    MOV R3, 14
    MOV R4, 18
loop_caixa_esq:
    MOV R1, R3
    CALL acender_pixel
    ADD R3, 1
    CMP R3, R4
    JNE loop_caixa_esq

    ; LADO DIREITO (coluna 18, linhas 14-17)
    MOV R2, 18
    MOV R3, 14
    MOV R4, 18
loop_caixa_dir:
    MOV R1, R3
    CALL acender_pixel
    ADD R3, 1
    CMP R3, R4
    JNE loop_caixa_dir

    POP R4
    POP R3
    POP R2
    POP R1
    RET

desenhar_objetos_cantos:
    PUSH R1
    PUSH R2

    MOV R1, 2
    MOV R2, 2
    CALL desenhar_objeto

    MOV R1, 2
    MOV R2, 27
    CALL desenhar_objeto

    MOV R1, 27
    MOV R2, 2
    CALL desenhar_objeto

    MOV R1, 27
    MOV R2, 27
    CALL desenhar_objeto

    POP R2
    POP R1
    RET

desenhar_objeto:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7

    MOV R7, R1
    MOV R6, R2
    MOV R5, 0

loop_linha_obj:
    CMP R5, 3
    JEQ fim_desenhar_obj

    MOV R4, 0

loop_coluna_obj:
    CMP R4, 3
    JEQ proxima_linha_obj

    MOV R3, R5
    ADD R3, R3
    ADD R3, R5
    ADD R3, R4
    SHL R3, 1

    PUSH R1
    MOV R1, tabela_objeto
    ADD R1, R3
    MOV R3, [R1]
    POP R1

    CMP R3, 1
    JNZ nao_acender_obj

    MOV R1, R7
    ADD R1, R5
    MOV R2, R6
    ADD R2, R4
    CALL acender_pixel

nao_acender_obj:
    ADD R4, 1
    JMP loop_coluna_obj

proxima_linha_obj:
    ADD R5, 1
    JMP loop_linha_obj

fim_desenhar_obj:
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; =================================
; ROTINA: pode_mover
; Verifica se o Pac-Man pode mover para uma posição (3x3) sem colidir
pode_mover:
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    ; Verificar limites externos
    CMP R1, 1
    JLT movimento_invalido

    MOV R3, 28
    CMP R1, R3
    JGT movimento_invalido

    CMP R2, 1
    JLT movimento_invalido

    MOV R3, 28
    CMP R2, R3
    JGT movimento_invalido

    ; Limites do Pac-Man (3x3)
    MOV R3, R1
    ADD R3, 2          ; linha_fim = R1+2
    MOV R4, R2
    ADD R4, 2          ; coluna_fim = R2+2

    ; Verificar colisão com a caixa central (14..18)
    MOV R5, 14
    CMP R4, R5
    JLT movimento_valido    ; coluna_fim < 14

    MOV R5, 18
    CMP R2, R5
    JGT movimento_valido    ; coluna_inicio > 18

    MOV R5, 14
    CMP R3, R5
    JLT movimento_valido    ; linha_fim < 14

    MOV R5, 18
    CMP R1, R5
    JGT movimento_valido    ; linha_inicio > 18

    ; Se chegou aqui, há colisão com a caixa
    JMP movimento_invalido

movimento_valido:
    MOV R0, 1
    JMP fim_pode_mover

movimento_invalido:
    MOV R0, 0

fim_pode_mover:
    POP R6
    POP R5
    POP R4
    POP R3
    RET

; ====================================
; DESENHAR / APAGAR PAC-MAN
; ====================================

desenhar_pacman:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R7, R1
    MOV R6, R2

    MOV R8, pacman_direcao
    MOV R8, [R8]

    CMP R8, 0
    JNZ testa_esq_des
    MOV R8, tabela_pacman_direita
    JMP iniciar_desenho_pac

testa_esq_des:
    CMP R8, 1
    JNZ testa_cima_des
    MOV R8, tabela_pacman_esquerda
    JMP iniciar_desenho_pac

testa_cima_des:
    CMP R8, 2
    JNZ usa_baixo_des
    MOV R8, tabela_pacman_cima
    JMP iniciar_desenho_pac

usa_baixo_des:
    MOV R8, tabela_pacman_baixo

iniciar_desenho_pac:
    MOV R5, 0

loop_linha_pacman:
    CMP R5, 3
    JEQ fim_desenhar_pacman

    MOV R4, 0

loop_coluna_pacman:
    CMP R4, 3
    JEQ proxima_linha_pacman

    MOV R3, R5
    ADD R3, R3
    ADD R3, R5
    ADD R3, R4
    SHL R3, 1

    PUSH R1
    MOV R1, R8
    ADD R1, R3
    MOV R3, [R1]
    POP R1

    CMP R3, 1
    JNZ nao_acender_pacman

    MOV R1, R7
    ADD R1, R5
    MOV R2, R6
    ADD R2, R4
    CALL acender_pixel

nao_acender_pacman:
    ADD R4, 1
    JMP loop_coluna_pacman

proxima_linha_pacman:
    ADD R5, 1
    JMP loop_linha_pacman

fim_desenhar_pacman:
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

apagar_pacman:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8

    MOV R7, R1
    MOV R6, R2

    MOV R8, pacman_direcao
    MOV R8, [R8]

    CMP R8, 0
    JNZ testa_esq_apg
    MOV R8, tabela_pacman_direita
    JMP iniciar_apagar_pac

testa_esq_apg:
    CMP R8, 1
    JNZ testa_cima_apg
    MOV R8, tabela_pacman_esquerda
    JMP iniciar_apagar_pac

testa_cima_apg:
    CMP R8, 2
    JNZ usa_baixo_apg
    MOV R8, tabela_pacman_cima
    JMP iniciar_apagar_pac

usa_baixo_apg:
    MOV R8, tabela_pacman_baixo

iniciar_apagar_pac:
    MOV R5, 0

loop_linha_apagar:
    CMP R5, 3
    JEQ fim_apagar_pacman

    MOV R4, 0

loop_coluna_apagar:
    CMP R4, 3
    JEQ proxima_linha_apagar

    MOV R3, R5
    ADD R3, R3
    ADD R3, R5
    ADD R3, R4
    SHL R3, 1

    PUSH R1
    MOV R1, R8
    ADD R1, R3
    MOV R3, [R1]
    POP R1

    CMP R3, 1
    JNZ nao_apagar_pacman

    MOV R1, R7
    ADD R1, R5
    MOV R2, R6
    ADD R2, R4
    CALL apagar_pixel

nao_apagar_pacman:
    ADD R4, 1
    JMP loop_coluna_apagar

proxima_linha_apagar:
    ADD R5, 1
    JMP loop_linha_apagar

fim_apagar_pacman:
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; ====================================
; CICLO PRINCIPAL
; ====================================

ciclo_principal:
    CALL ler_teclado

    ; Ler tecla actual de memória para R4 (consistência)
    MOV R5, tecla_lida
    MOV R4, [R5]

    
    CMP R4, 0
    JEQ apenas_desenhar

    ; Apagar Pac-Man na posição atual antes de tentar mover
    MOV R5, pixel_linha
    MOV R1, [R5]
    MOV R5, pixel_coluna
    MOV R2, [R5]
    CALL apagar_pacman

    ; Verificar cada tecla e mover se possível
    MOV R5, 0011H
    CMP R4, R5
    JNZ testa_tecla4
    ; Tecla CIMA
    MOV R5, pixel_linha
    MOV R1, [R5]
    SUB R1, 1              ; tenta mover para cima (uma vez)
    MOV R5, pixel_coluna
    MOV R2, [R5]
    CALL pode_mover        ; verifica se pode
    CMP R0, 0
    JEQ apenas_desenhar    ; não pode, ignora movimento
    ; Pode mover! Atualizar posição e direção
    MOV R5, pacman_direcao
    MOV R6, 2
    MOV [R5], R6
    MOV R5, pixel_linha
    MOV [R5], R1
    JMP apos_movimento

testa_tecla4:
    MOV R5, 0021H
    CMP R4, R5
    JNZ testa_tecla6
    ; Tecla ESQUERDA
    MOV R5, pixel_linha
    MOV R1, [R5]
    MOV R5, pixel_coluna
    MOV R2, [R5]
    SUB R2, 1
    CALL pode_mover
    CMP R0, 0
    JEQ apenas_desenhar
    MOV R5, pacman_direcao
    MOV R6, 1
    MOV [R5], R6
    MOV R5, pixel_coluna
    MOV R2, [R5]
    SUB R2, 1
    MOV [R5], R2
    JMP apos_movimento

testa_tecla6:
    MOV R5, 0024H
    CMP R4, R5
    JNZ testa_tecla9
    ; Tecla DIREITA
    MOV R5, pixel_linha
    MOV R1, [R5]
    MOV R5, pixel_coluna
    MOV R2, [R5]
    ADD R2, 1
    CALL pode_mover
    CMP R0, 0
    JEQ apenas_desenhar
    MOV R5, pacman_direcao
    MOV R6, 0
    MOV [R5], R6
    MOV R5, pixel_coluna
    MOV R2, [R5]
    ADD R2, 1
    MOV [R5], R2
    JMP apos_movimento

testa_tecla9:
    MOV R5, 0044H
    CMP R4, R5
    JNZ apenas_desenhar
    ; Tecla BAIXO
    MOV R5, pixel_linha
    MOV R1, [R5]
    ADD R1, 1
    MOV R5, pixel_coluna
    MOV R2, [R5]
    CALL pode_mover
    CMP R0, 0
    JEQ apenas_desenhar
    MOV R5, pacman_direcao
    MOV R6, 3
    MOV [R5], R6
    MOV R5, pixel_linha
    MOV R1, [R5]
    ADD R1, 1
    MOV [R5], R1

apos_movimento:
    ; depois de mover, continuamos para desenhar e processar fantasmas
    ; (não voltamos a apagar o pacman)

apenas_desenhar:
    ; Processar nascimentos dos fantasmas (decrementa atrasos e cria fantasma quando chega a 0)
    CALL processar_nascimentos

    ; Desenhar Pac-Man (na nova posição)
    MOV R5, pixel_linha
    MOV R1, [R5]
    MOV R5, pixel_coluna
    MOV R2, [R5]
    CALL desenhar_pacman

    ; Desenhar todos os fantasmas activos (3x3 em X)
    CALL desenhar_todos_fantasmas

    ; Incrementar gerador (aumenta aleatoriedade ao longo do tempo)
    MOV R1, gerador
    MOV R2, [R1]
    ADD R2, 1
    MOV [R1], R2

    JMP ciclo_principal

; ====================================
; ROTINAS DE TECLADO
; ====================================

ler_teclado:
    PUSH R1
    PUSH R2
    PUSH R3

    MOV R1, LINHA_1
    CALL testar_linha
    CMP R3, 0
    JNZ tecla_encontrada_linha1

    MOV R1, LINHA_2
    CALL testar_linha
    CMP R3, 0
    JNZ tecla_encontrada_linha2

    MOV R1, LINHA_3
    CALL testar_linha
    CMP R3, 0
    JNZ tecla_encontrada_linha3

    MOV R1, LINHA_4
    CALL testar_linha
    CMP R3, 0
    JNZ tecla_encontrada_linha4

    MOV R4, 0
    JMP fim_ler_teclado

tecla_encontrada_linha1:
    MOV R4, LINHA_1
    SHL R4, 4
    OR R4, R3
    JMP guardar_tecla

tecla_encontrada_linha2:
    MOV R4, LINHA_2
    SHL R4, 4
    OR R4, R3
    JMP guardar_tecla

tecla_encontrada_linha3:
    MOV R4, LINHA_3
    SHL R4, 4
    OR R4, R3
    JMP guardar_tecla

tecla_encontrada_linha4:
    MOV R4, LINHA_4
    SHL R4, 4
    OR R4, R3

guardar_tecla:
    PUSH R5
    MOV R5, tecla_lida
    MOV [R5], R4
    POP R5

fim_ler_teclado:
    POP R3
    POP R2
    POP R1
    RET

testar_linha:
    PUSH R2

    MOV R2, TECLADO_SAIDA
    MOVB [R2], R1

    MOV R2, TECLADO_ENTRADA
    MOVB R3, [R2]

    MOV R2, MASCARA_TECLADO
    AND R3, R2

    POP R2
    RET

; ====================================
; ROTINAS DO PIXELSCREEN
; ====================================

limpar_ecra:
    PUSH R1
    PUSH R2
    PUSH R3

    MOV R1, BASE_ECRA
    MOV R2, TAM_ECRA
    MOV R3, 0

limpar_loop:
    MOVB [R1], R3
    ADD R1, 1
    SUB R2, 1
    JNZ limpar_loop

    POP R3
    POP R2
    POP R1
    RET

calcular_endereco_e_mascara:
    PUSH R5
    PUSH R6

    MOV R3, BASE_ECRA

    ; R1 = linha, R2 = coluna (entradas)
    MOV R5, R1
    SHL R5, 2
    ADD R3, R5

    MOV R5, R2
    SHR R5, 3
    ADD R3, R5

    MOV R5, R2
    MOV R6, 0007H
    AND R5, R6

    SHL R5, 1
    MOV R6, tabela_mascaras
    ADD R6, R5
    MOV R4, [R6]

    MOV R6, 00FFH
    AND R4, R6

    POP R6
    POP R5
    RET

acender_pixel:
    PUSH R3
    PUSH R4
    PUSH R5

    CALL calcular_endereco_e_mascara

    MOVB R5, [R3]
    OR R5, R4
    MOVB [R3], R5

    POP R5
    POP R4
    POP R3
    RET

apagar_pixel:
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6

    CALL calcular_endereco_e_mascara

    MOVB R5, [R3]
    MOV R6, R4
    NOT R6
    AND R5, R6
    MOVB [R3], R5

    POP R6
    POP R5
    POP R4
    POP R3
    RET

; ====================================
; ROTINAS DE FANTASMAS 
; ==============================

; inicializar_fantasmas:
; - coloca todos os fantasmas em estado 0 (inactivo)
; - define um atraso inicial baseado no gerador (pequeno atraso)
inicializar_fantasmas:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4        ; registo para máscara

    ; ler gerador
    MOV R1, gerador
    MOV R2, [R1]

    ; preparar máscara 0003H em R4 
    MOV R4, 0003H

    ; fant0_atraso = (gerador & 3) + 1
    MOV R3, R2
    AND R3, R4
    ADD R3, 1
    MOV R1, fant0_atraso
    MOV [R1], R3

    ; fant1_atraso = (gerador >> 1 & 3) + 1
    MOV R3, R2
    SHR R3, 1
    AND R3, R4
    ADD R3, 1
    MOV R1, fant1_atraso
    MOV [R1], R3

    ; fant2_atraso = (gerador >> 2 & 3) + 1
    MOV R3, R2
    SHR R3, 2
    AND R3, R4
    ADD R3, 1
    MOV R1, fant2_atraso
    MOV [R1], R3

    ; fant3_atraso = ((gerador + 3) & 3) + 1
    MOV R3, R2
    ADD R3, 3
    AND R3, R4
    ADD R3, 1
    MOV R1, fant3_atraso
    MOV [R1], R3

    ; Colocar todos os estados em 0 (inactivo)
    MOV R1, fant0_estado
    MOV R2, 0
    MOV [R1], R2
    MOV R1, fant1_estado
    MOV [R1], R2
    MOV R1, fant2_estado
    MOV [R1], R2
    MOV R1, fant3_estado
    MOV [R1], R2

    POP R4
    POP R3
    POP R2
    POP R1
    RET

; processar_nascimentos:
; - decrementa cada atraso (se >0)
; - quando chega a 0, coloca o fantasma "na_caixa" e desenha o sprite 3x3 em X
processar_nascimentos:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    ; --- Fantasma 0 ---
    MOV R1, fant0_atraso
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_f0
    SUB R2, 1
    MOV [R1], R2
    CMP R2, 0
    JNZ skip_f0
    ; chegou a 0 -> nascer na caixa
    MOV R1, fant0_estado
    MOV R2, 1
    MOV [R1], R2
    ; posição inicial (canto superior esquerdo do sprite) - escolhemos (15,15)
    MOV R1, fant0_linha
    MOV R2, 15
    MOV [R1], R2
    MOV R1, fant0_coluna
    MOV R2, 15
    MOV [R1], R2
    ; desenhar sprite 3x3 em X
    MOV R1, 15
    MOV R2, 15
    CALL desenhar_fantasma

skip_f0:

    ; --- Fantasma 1 ---
    MOV R1, fant1_atraso
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_f1
    SUB R2, 1
    MOV [R1], R2
    CMP R2, 0
    JNZ skip_f1
    MOV R1, fant1_estado
    MOV R2, 1
    MOV [R1], R2
    MOV R1, fant1_linha
    MOV R2, 15
    MOV [R1], R2
    MOV R1, fant1_coluna
    MOV R2, 16    ; ligeira variação
    MOV [R1], R2
    MOV R1, 15
    MOV R2, 16
    CALL desenhar_fantasma

skip_f1:

    ; --- Fantasma 2 ---
    MOV R1, fant2_atraso
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_f2
    SUB R2, 1
    MOV [R1], R2
    CMP R2, 0
    JNZ skip_f2
    MOV R1, fant2_estado
    MOV R2, 1
    MOV [R1], R2
    MOV R1, fant2_linha
    MOV R2, 16
    MOV [R1], R2
    MOV R1, fant2_coluna
    MOV R2, 15
    MOV [R1], R2
    MOV R1, 16
    MOV R2, 15
    CALL desenhar_fantasma

skip_f2:

    ; --- Fantasma 3 ---
    MOV R1, fant3_atraso
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_f3
    SUB R2, 1
    MOV [R1], R2
    CMP R2, 0
    JNZ skip_f3
    MOV R1, fant3_estado
    MOV R2, 1
    MOV [R1], R2
    MOV R1, fant3_linha
    MOV R2, 16
    MOV [R1], R2
    MOV R1, fant3_coluna
    MOV R2, 16
    MOV [R1], R2
    MOV R1, 16
    MOV R2, 16
    CALL desenhar_fantasma

skip_f3:

    POP R4
    POP R3
    POP R2
    POP R1
    RET

; desenhar_fantasma:
; - entrada: R1 = linha (canto superior esquerdo), R2 = coluna
; - usa tabela_fantasma (3x3) e chama acender_pixel para cada 1
desenhar_fantasma:
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7

    ; R1 = linha, R2 = coluna (entradas)
    MOV R5, R1    ; base linha
    MOV R6, R2    ; base coluna

    MOV R3, 0     ; linha relativa 0..2
linha_loop_fant:
    CMP R3, 3
    JEQ fim_desenhar_fant
    MOV R4, 0     ; coluna relativa 0..2
coluna_loop_fant:
    CMP R4, 3
    JEQ proxima_linha_fant

    ; índice na tabela = (R3*3 + R4) ; cada entry ocupa WORD, e tabela usa offset em bytes (SHL 1)
    MOV R7, R3
    ADD R7, R7
    ADD R7, R3     ; R7 = R3*3
    ADD R7, R4     ; R7 = R3*3 + R4
    SHL R7, 1      ; multiplicar por 2 (WORD)

    PUSH R1
    MOV R1, tabela_fantasma
    ADD R1, R7
    MOV R7, [R1]
    POP R1

    CMP R7, 1
    JNZ nao_acender_fant

    ; calcular posição absoluta do pixel
    MOV R1, R5
    ADD R1, R3
    MOV R2, R6
    ADD R2, R4
    CALL acender_pixel

nao_acender_fant:
    ADD R4, 1
    JMP coluna_loop_fant

proxima_linha_fant:
    ADD R3, 1
    JMP linha_loop_fant

fim_desenhar_fant:
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    RET

; desenhar_todos_fantasmas:
; - desenha todos os fantasmas cujo estado >= 1 (na_caixa ou activo)
desenhar_todos_fantasmas:
    PUSH R1
    PUSH R2

    ; fant0
    MOV R1, fant0_estado
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_draw0
    MOV R1, fant0_linha
    MOV R2, [R1]
    MOV R1, fant0_coluna
    MOV R3, [R1]
    ; chamar desenhar_fantasma com R1=linha, R2=coluna
    PUSH R3
    PUSH R2
    MOV R1, R2
    MOV R2, R3
    CALL desenhar_fantasma
    POP R2
    POP R3

skip_draw0:

    ; fant1
    MOV R1, fant1_estado
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_draw1
    MOV R1, fant1_linha
    MOV R2, [R1]
    MOV R1, fant1_coluna
    MOV R3, [R1]
    PUSH R3
    PUSH R2
    MOV R1, R2
    MOV R2, R3
    CALL desenhar_fantasma
    POP R2
    POP R3

skip_draw1:

    ; fant2
    MOV R1, fant2_estado
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_draw2
    MOV R1, fant2_linha
    MOV R2, [R1]
    MOV R1, fant2_coluna
    MOV R3, [R1]
    PUSH R3
    PUSH R2
    MOV R1, R2
    MOV R2, R3
    CALL desenhar_fantasma
    POP R2
    POP R3

skip_draw2:

    ; fant3
    MOV R1, fant3_estado
    MOV R2, [R1]
    CMP R2, 0
    JEQ skip_draw3
    MOV R1, fant3_linha
    MOV R2, [R1]
    MOV R1, fant3_coluna
    MOV R3, [R1]
    PUSH R3
    PUSH R2
    MOV R1, R2
    MOV R2, R3
    CALL desenhar_fantasma
    POP R2
    POP R3

skip_draw3:

    POP R2
    POP R1
    RET

