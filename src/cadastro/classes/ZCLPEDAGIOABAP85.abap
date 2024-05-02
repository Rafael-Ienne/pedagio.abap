class ZCLPEDAGIOABAP85 definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      value(ID_NOME_OPERADOR) type XUBNAME
      value(ID_PLACA) type ZZPLACA
      value(ID_FORMA_PAGAMENTO) type ZZFORMAPAGAMENTO
      value(ID_CATEGORIA_VEICULO) type ZCATVEICULO .
  methods GRAVAR_COBRANCA .
  methods GET_VALOR
    returning
      value(RD_VALOR) type ZVALTARIFA .
  methods GET_DATA
    returning
      value(RD_DATA) type ERSDA .
  methods GET_RECIBO
    returning
      value(RD_RECIBO) type ZZRECIBO .
  methods GET_NOME_OPERADOR
    returning
      value(RD_NOME_OPERADOR) type XUBNAME .
  methods GET_CATEGORIA_VEICULO
    returning
      value(RD_CATEGORIA_VEICULO) type ZCATVEICULO .
  methods GET_FORMA_PAGAMENTO
    returning
      value(RD_FORMA_PAGAMENTO) type ZZFORMAPAGAMENTO .
  methods GET_PLACA
    returning
      value(RD_PLACA) type ZZPLACA .
  methods GET_HORA
    returning
      value(RD_HORA) type CREATED_AT_TIME .
  PROTECTED SECTION.
private section.

  data DATA type ERSDA .
  data HORA type CREATED_AT_TIME .
  data RECIBO type ZZRECIBO .
  data NOME_OPERADOR type XUBNAME .
  data CATEGORIA_VEICULO type ZCATVEICULO .
  data VALOR type ZVALTARIFA .
  data FORMA_PAGAMENTO type ZZFORMAPAGAMENTO .
  data PLACA type ZZPLACA .

  methods ENCONTRAR_TARIFA
    importing
      !ID_CATEGORIA_VEICULO type ZCATVEICULO
    exporting
      !ED_VALOR type ZVALTARIFA .
  methods GERAR_VALOR_RECIBO
    returning
      value(RD_RECIBO) type ZZRECIBO .
  methods EXIBIR_COMPROVANTE .
ENDCLASS.



CLASS ZCLPEDAGIOABAP85 IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GRAVAR_COBRANCA
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD gravar_cobranca.

    DATA: ls_comprovante TYPE zcompedagios.

    ls_comprovante-data = me->data.
    ls_comprovante-forma_pagamento = me->forma_pagamento.
    ls_comprovante-hora = me->hora.
    ls_comprovante-nome_operador = me->nome_operador.
    ls_comprovante-placa = me->placa.
    ls_comprovante-recibo = me->recibo.
    ls_comprovante-categoria_veiculo = me->categoria_veiculo.
    ls_comprovante-valor = me->valor.

    INSERT zcompedagios FROM ls_comprovante.

    IF sy-subrc IS INITIAL.
      MESSAGE 'Comprovante gravado com sucesso' TYPE 'S'.
      me->exibir_comprovante( ).
    ELSE.
      MESSAGE 'Erro ao se gravar comprovante' TYPE 'E'.
    ENDIF.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_NOME_OPERADOR               TYPE        XUBNAME
* | [--->] ID_PLACA                       TYPE        ZZPLACA
* | [--->] ID_FORMA_PAGAMENTO             TYPE        ZZFORMAPAGAMENTO
* | [--->] ID_CATEGORIA_VEICULO           TYPE        ZCATVEICULO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD constructor.

    me->encontrar_tarifa(
      EXPORTING
        id_categoria_veiculo = id_categoria_veiculo
       IMPORTING
         ed_valor             = me->valor
    ).

    me->categoria_veiculo = id_categoria_veiculo.
    me->data = sy-datum.
    me->forma_pagamento = id_forma_pagamento.
    me->hora = sy-uzeit.
    me->nome_operador = id_nome_operador.
    me->placa = id_placa.
    me->recibo = me->gerar_valor_recibo( ).

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLPEDAGIOABAP85->EXIBIR_COMPROVANTE
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD exibir_comprovante.

    WRITE: 'DOC. FISCAL EQUIVALENTE IB171-17 Art.2',
          / 'AUTOPISTA LITORAL SUL',
          / '09.313.969/0001-97',
          / 'SÃO PAULO', 'KM365',
          / me->data, me->hora,'Recibo:',me->recibo,
          / 'Operador:', me->nome_operador, 'Categoria:', me->categoria_veiculo,
          / 'Valor pago:', me->valor, 'F. Pagto.:', me->forma_pagamento,
          / 'PLACA:', me->placa.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLPEDAGIOABAP85->ENCONTRAR_TARIFA
* +-------------------------------------------------------------------------------------------------+
* | [--->] ID_CATEGORIA_VEICULO           TYPE        ZCATVEICULO
* | [<---] ED_VALOR                       TYPE        ZVALTARIFA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD encontrar_tarifa.

    CALL FUNCTION 'ZENCONTRARTARIFA'
      EXPORTING
        id_categoria   = id_categoria_veiculo
      IMPORTING
        ed_valor       = ed_valor.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Private Method ZCLPEDAGIOABAP85->GERAR_VALOR_RECIBO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_RECIBO                      TYPE        ZZRECIBO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD gerar_valor_recibo.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr = '01'
        object      = 'ZINTERVALO'
      IMPORTING
        number      = rd_recibo.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_CATEGORIA_VEICULO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_CATEGORIA_VEICULO           TYPE        ZCATVEICULO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_CATEGORIA_VEICULO.
    rd_categoria_veiculo = me->categoria_veiculo.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_DATA
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_DATA                        TYPE        ERSDA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_DATA.
    rd_data = me->data.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_FORMA_PAGAMENTO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_FORMA_PAGAMENTO             TYPE        ZZFORMAPAGAMENTO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_FORMA_PAGAMENTO.
    rd_forma_pagamento = me->forma_pagamento.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_HORA
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_HORA                        TYPE        CREATED_AT_TIME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_HORA.
    rd_hora = me->hora.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_NOME_OPERADOR
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_NOME_OPERADOR               TYPE        XUBNAME
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_NOME_OPERADOR.
    rd_nome_operador = me->nome_operador.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_PLACA
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_PLACA                       TYPE        ZZPLACA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_PLACA.
    rd_placa = me->placa.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_RECIBO
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_RECIBO                      TYPE        ZZRECIBO
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_RECIBO.
    rd_recibo = me->recibo.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCLPEDAGIOABAP85->GET_VALOR
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RD_VALOR                       TYPE        ZVALTARIFA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_VALOR.
    rd_valor = me->valor.
  endmethod.
ENDCLASS.
