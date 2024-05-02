FUNCTION zencontrartarifa.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(ID_CATEGORIA) TYPE  ZCATVEICULO
*"  EXPORTING
*"     REFERENCE(ED_VALOR) TYPE  ZVALTARIFA
*"  EXCEPTIONS
*"      NAO_ENCONTRADO
*"----------------------------------------------------------------------

  "Selecionando todos os dados da tabela de tarifas ztarpedagio
  SELECT *
  FROM ztarpedagio
  INTO TABLE @DATA(lt_valores).

  "Ordenando os dados para uma busca mais eficiente
  SORT lt_valores BY categoria.

  "Pegando o valor da tarifa com base na categoria do veiculo
  READ TABLE lt_valores
  INTO DATA(ls_valor)
  WITH KEY categoria = id_categoria BINARY SEARCH.

  ed_valor = ls_valor-valor.

ENDFUNCTION.