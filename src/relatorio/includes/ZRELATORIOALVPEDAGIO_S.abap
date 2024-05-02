*&---------------------------------------------------------------------*
*& Include          ZRELATORIOALVPEDAGIO_S
*&---------------------------------------------------------------------*

TABLES: zcompedagios, sscrfields.
TYPE-POOLS: slis.

"Types para exibir informações adicionais no relatório além dos dados da tabela zcompedagios
TYPES: BEGIN OF ty_comprovante.
         INCLUDE STRUCTURE zcompedagios.
TYPES:   nome_completo       TYPE zzdescricao,
         descricao_categoria TYPE zzdescricao.
TYPES: END OF ty_comprovante.

"Types para processar tabela de usuários no FORM f_inserir_nome_op_e_desc_cat
TYPES: BEGIN OF ty_user,
         bname      TYPE user_addr-bname,
         name_textc TYPE user_addr-name_textc.
TYPES: END OF ty_user.
TYPES: ty_users TYPE STANDARD TABLE OF ty_user.

"Types para processar tabela de categorias no FORM f_inserir_nome_op_e_desc_cat
TYPES: BEGIN OF ty_categoria,
         categoria TYPE zdecategorias-categoria,
         descricao TYPE zdecategorias-descricao.
TYPES: END OF ty_categoria.
TYPES: ty_categorias TYPE STANDARD TABLE OF ty_categoria.

"Tabela interna para armazenar os dados do relatório e outras auxiliares
DATA: gt_registros TYPE STANDARD TABLE OF ty_comprovante,
      gt_aux       TYPE STANDARD TABLE OF zcompedagios,
      gt_aux2      TYPE STANDARD TABLE OF zcompedagios.

*Variáveis básicas para gerar ALV
DATA: lo_grid_100   TYPE REF TO cl_gui_alv_grid,
      lv_okcode_100 TYPE sy-ucomm,
      lt_fieldcat   TYPE lvc_t_fcat,
      ls_layout     TYPE lvc_s_layo,
      ls_variant    TYPE disvariant.

"Tela de seleção
SELECTION-SCREEN: BEGIN OF BLOCK b1.
  SELECT-OPTIONS: s_data FOR zcompedagios-data,
                  s_oper FOR zcompedagios-nome_operador,
                  s_cat  FOR zcompedagios-categoria_veiculo,
                  s_form FOR zcompedagios-forma_pagamento.
SELECTION-SCREEN: END OF BLOCK b1.

"Botão para voltar na tela de cobrança de pedágio
SELECTION-SCREEN FUNCTION KEY 1.

INITIALIZATION.
  MOVE 'Voltar para tela de cobrança' TO sscrfields-functxt_01.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS100'.
  SET TITLEBAR 'TITLE100'.
ENDMODULE.

AT SELECTION-SCREEN.
  "Verificação para redirecionar o usuário para a tela de cobrança caso o botão de relatorio seja clicado
  IF sy-ucomm EQ 'FC01'.
    SUBMIT zpedagioabap85 VIA SELECTION-SCREEN.
  ENDIF.