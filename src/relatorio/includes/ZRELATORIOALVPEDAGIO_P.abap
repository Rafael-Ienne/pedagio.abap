*&---------------------------------------------------------------------*
*& Include          ZRELATORIOALVPEDAGIO_S
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM f_select_dados.

  IF gt_registros[] IS NOT INITIAL.
    "Caso a tabela não esteja vazia, serão mostrados os dados em um ALV
    CALL SCREEN 100.
  ELSE.
    MESSAGE 'Não foram encontrados registros' TYPE 'I' DISPLAY LIKE 'E'.
  ENDIF.

*&---------------------------------------------------------------------*
*& Module MBUILD_GRID OUTPUT
*&---------------------------------------------------------------------*
MODULE mbuild_grid OUTPUT.
  "Ajusta o tamanho do ALV
  ls_layout-cwidth_opt = 'X'.
  "ALV zebrado ou não
  ls_layout-zebra = 'X'.

  PERFORM build_grid.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Form para construir o grid e gerar o ALV
*&---------------------------------------------------------------------*
FORM build_grid .

  PERFORM f_build_fieldcat USING:

          'DATA' 'DATA' 'zcompedagios' 'Data' CHANGING lt_fieldcat[],
          'HORA' 'HORA' 'zcompedagios' 'Hora' CHANGING lt_fieldcat[],
          'RECIBO' 'RECIBO' 'zcompedagios' 'Recibo' CHANGING lt_fieldcat[],
          'NOME_OPERADOR' 'NOME_OPERADOR' 'zcompedagios' 'Operador' CHANGING lt_fieldcat[],
          'CATEGORIA_VEICULO' 'CATEGORIA_VEICULO' 'zcompedagios' 'Categoria veiculo' CHANGING lt_fieldcat[],
          'VALOR' 'VALOR' 'zcompedagios' 'Valor' CHANGING lt_fieldcat[],
          'FORMA_PAGAMENTO' 'FORMA_PAGAMENTO' 'zcompedagios' 'Forma de pagamento' CHANGING lt_fieldcat[],
          'PLACA' 'PLACA' 'zcompedagios' 'Placa' CHANGING lt_fieldcat[],
          'NOME_COMPLETO' 'NOME_COMPLETO' 'ty_comprovante' 'Nome completo operador' CHANGING lt_fieldcat[],
          'DESCRICAO_CATEGORIA' 'DESCRICAO_CATEGORIA' 'ty_comprovante' 'Descrição categoria' CHANGING lt_fieldcat[].

  IF lo_grid_100 IS INITIAL.

    lo_grid_100   = NEW cl_gui_alv_grid( i_parent = cl_gui_custom_container=>default_screen ).

    "Permite que mais de uma linha seja selecionada(para fins visuais)
    lo_grid_100->set_ready_for_input( 1 ).

    lo_grid_100->set_table_for_first_display(
      EXPORTING

        is_variant                    =    ls_variant
        is_layout                     =    ls_layout

      CHANGING
        it_fieldcatalog               =     lt_fieldcat[]
        it_outtab                     =     gt_registros[]
      ) .

    "Titulo do ALV
    lo_grid_100->set_gridtitle( 'Tabela de cobranças de pedágio' ).

  ELSE.
    "Refresh dos dados para não construir o objeto novamente
    lo_grid_100->refresh_table_display( ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form para preencher a tabela t_fieldcat e estabelecer os campos que
*& serão mostrados no ALV
*&---------------------------------------------------------------------*
FORM f_build_fieldcat USING VALUE(p_fieldname)  TYPE c
                            VALUE(p_field)      TYPE c
                            VALUE(p_table)      TYPE c
                            VALUE(p_coltext)    TYPE c
                            CHANGING t_fieldcat TYPE lvc_t_fcat.
  DATA: ls_fieldcat LIKE LINE OF t_fieldcat[].

  "Nome do campo dado na tabela interna
  ls_fieldcat-fieldname = p_fieldname.
  "Nome do campo na tabela transparente
  ls_fieldcat-ref_field = p_field.
  "Tabela transparente
  ls_fieldcat-ref_table = p_table.
  "Descrição que daremos para o campo no ALV.
  ls_fieldcat-coltext   = p_coltext.

  APPEND ls_fieldcat TO t_fieldcat[].

ENDFORM.

*&---------------------------------------------------------------------*
*& Form para selecionar os ddos da tabela principal zcompedagios e
*& performar a função f_select_user_addr.
*&---------------------------------------------------------------------*
FORM f_select_dados.

  FREE: gt_aux[], gt_aux2[], gt_registros[].

  SELECT * FROM zcompedagios INTO TABLE @DATA(t_comprovantes)
  WHERE data              IN @s_data AND
        nome_operador     IN @s_oper AND
        categoria_veiculo IN @s_cat  AND
        forma_pagamento   IN @s_form.

  MOVE-CORRESPONDING t_comprovantes TO gt_registros.
  MOVE-CORRESPONDING t_comprovantes TO gt_aux.
  MOVE-CORRESPONDING t_comprovantes TO gt_aux2.

  IF t_comprovantes[] IS NOT INITIAL.
    PERFORM f_select_user_addr.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form para selecionar os dados na tabela transparente user_addr com base
*& em todas as entradas da tabela interna gt_aux. Nesse processo, compara-se
*& o campo bname da tabela user_addr com o campo nome_operador
*& da tabela gt_aux. Ao final, é performada a função
*& f_select_zdecategorias, passando a tabela gt_users como parâmetro,
*& que será útil ao performar a função f_inserir_nome_op_e_desc_cat.
*&---------------------------------------------------------------------*
FORM f_select_user_addr.

  SORT gt_aux BY nome_operador.

  DELETE ADJACENT DUPLICATES FROM gt_aux COMPARING nome_operador.

  SELECT bname, name_textc
  FROM user_addr
  INTO TABLE @DATA(gt_users)
  FOR ALL ENTRIES IN @gt_aux
  WHERE bname = @gt_aux-nome_operador.

  PERFORM f_select_zdecategorias USING gt_users.

ENDFORM.

*&--------------------------------------------------------------------------------------*
*& Form para selecionar os dados na tabela transparente zdecategorias com base em todas
*& as entradas da tabela interna gt_aux2. Nesse processo, compara-se o campo categoria
*& da tabela zdecategorias com o campo categoria_veiculo da tabela gt_aux2. Ao final,
*& é performada a função f_inserir_nome_op_e_desc_cat, passando a tabela p_users
*& e gt_categorias como parâmetros
*&---------------------------------------------------------------------------------------*
FORM f_select_zdecategorias USING VALUE(pt_users) TYPE ty_users.

  SORT gt_aux2 BY categoria_veiculo.

  DELETE ADJACENT DUPLICATES FROM gt_aux2 COMPARING categoria_veiculo.

  SELECT categoria, descricao
  FROM zdecategorias
  INTO TABLE @DATA(gt_categorias)
  FOR ALL ENTRIES IN @gt_aux2
  WHERE categoria = @gt_aux2-categoria_veiculo.

  PERFORM f_inserir_nome_op_e_desc_cat USING pt_users
                                             gt_categorias.

ENDFORM.

*&-----------------------------------------------------------------------------*
*& Form para inserir os dados nome_completo(do operador) e descricao_categoria
*& na tabela final gt_registros, que será usada para mostrar o ALV
*&-----------------------------------------------------------------------------*
FORM f_inserir_nome_op_e_desc_cat USING VALUE(pt_users) TYPE ty_users
                                        VALUE(pt_categorias) TYPE ty_categorias.

  LOOP AT gt_registros ASSIGNING FIELD-SYMBOL(<fs_registro>).

    READ TABLE pt_users
    INTO DATA(ls_user)
    WITH KEY bname = <fs_registro>-nome_operador.
    "Inserindo o nome completo do operador na tabela gt_registros
    IF sy-subrc IS INITIAL.
      <fs_registro>-nome_completo = ls_user-name_textc.
    ENDIF.

    READ TABLE pt_categorias
    INTO DATA(ls_categoria)
    WITH KEY categoria = <fs_registro>-categoria_veiculo.
    "Inserindo a descrição da categoria na tabela gt_registros
    IF sy-subrc IS INITIAL.
      <fs_registro>-descricao_categoria = ls_categoria-descricao.
    ENDIF.

  ENDLOOP.

ENDFORM.

MODULE user_command_0100 INPUT.
  lv_okcode_100 = sy-ucomm.
  IF lv_okcode_100 EQ 'BACK' OR lv_okcode_100 EQ 'CANCEL' OR lv_okcode_100 EQ 'EXIT'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDMODULE.