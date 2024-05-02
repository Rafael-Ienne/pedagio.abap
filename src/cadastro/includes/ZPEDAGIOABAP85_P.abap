*&---------------------------------------------------------------------*
*& Include          ZPEDAGIOABAP85_P
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  "Verificação para que o campo de categoria seja obrigatoriamente preenchido
  IF p_catv IS INITIAL.
    MESSAGE 'Preencha a categoria de veículo corretamente' TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    "Instanciação do objeto comprovante com os seus respectivos parâmetros
    go_comprovante = NEW zclpedagioabap85(
      id_nome_operador     = p_operno
      id_placa             = p_placa
      id_forma_pagamento   = p_forpag
      id_categoria_veiculo = p_catv
    ).

    IF go_comprovante->get_valor( ) IS NOT INITIAL.
      go_comprovante->gravar_cobranca( ).
    ELSE.
      MESSAGE 'Categoria não encontrada' TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.

  ENDIF.