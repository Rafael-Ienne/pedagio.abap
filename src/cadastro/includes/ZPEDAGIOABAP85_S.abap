*&---------------------------------------------------------------------*
*& Include          ZPEDAGIOABAP85_S
*&---------------------------------------------------------------------*

TABLES: zcompedagios, sscrfields.

"Variável do tipo zclpedagioabap85, a fim de relizar as operações
"desejadas para os dados do pedágio
DATA: go_comprovante TYPE REF TO zclpedagioabap85.

"Tela de seleção
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS: p_operno TYPE zcompedagios-nome_operador,
              p_catv   TYPE zcompedagios-categoria_veiculo,
              p_forpag TYPE zcompedagios-forma_pagamento,
              p_placa  TYPE zcompedagios-placa.
SELECTION-SCREEN: END OF BLOCK b1.

"Botão para redirecionar para o relatório da tabela zcompedagios
SELECTION-SCREEN FUNCTION KEY 1.

INITIALIZATION.
  p_operno = sy-uname.
  p_forpag = 'DINHEIRO'.
  MOVE 'Relatorio' TO sscrfields-functxt_01.

AT SELECTION-SCREEN.
  "Verificação para redirecionar o usuário para um relatório caso o botão de relatorio seja clicado
  IF sy-ucomm EQ 'FC01'.
    SUBMIT zrelatorioalvpedagio VIA SELECTION-SCREEN.
  ENDIF.