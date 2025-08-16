CLASS LHC_ZSCHEME DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZScheme
        RESULT result,

      validatescheme FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZScheme~validatescheme.


ENDCLASS.

CLASS LHC_ZSCHEME IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD validatescheme.
    READ ENTITIES OF ZR_ZScheme02TP IN LOCAL MODE
      ENTITY ZScheme
      FIELDS ( plantcode Validfrom Validto Freeqty Schemeqty Minimumqty division distributionchannel customerpricegroup )
      WITH CORRESPONDING #( keys )
      RESULT DATA(ltschemes).


    loop at ltschemes INTO DATA(lvscheme).
        IF lvscheme-plantcode IS INITIAL.
            APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_PLANT'
                            %msg  = new_message_with_text(
                                    text = 'Plant code cannot be blank.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-division IS INITIAL.
            APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_DIVISION'
                            %msg  = new_message_with_text(
                                    text = 'Division cannot be blank.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-distributionchannel IS INITIAL.
            APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_DISTCHANNEL'
                            %msg  = new_message_with_text(
                                    text = 'Distribution Channel cannot be blank.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-customerpricegroup IS INITIAL.
            APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_CUSTOMERPG'
                            %msg  = new_message_with_text(
                                    text = 'Price group cannot be blank.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-Validfrom IS INITIAL.
            APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_DATE'
                            %msg  = new_message_with_text(
                                    text = 'Valid from cannot be blank.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-Validto < lvscheme-Validfrom.
            APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_DATE'
                            %msg  = new_message_with_text(
                                    text = 'Invalid Valid from-to dates.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-Schemeqty <= 0.
            APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_QTY'
                            %msg  = new_message_with_text(
                                    text = 'Scheme quantity cannot be zero.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-Freeqty <= 0.
                    APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_QTY'
                            %msg  = new_message_with_text(
                                    text = 'Free quantity cannot be zero.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

        IF lvscheme-Minimumqty <= 0.
                    APPEND VALUE #( %tky = lvscheme-%tky ) TO failed-zscheme.

            APPEND VALUE #( %tky = lvscheme-%tky
                            %state_area = 'VALIDATE_QTY'
                            %msg  = new_message_with_text(
                                    text = 'Minimum quantity cannot be zero.'
                                    severity = if_abap_behv_message=>severity-error )
                            ) TO reported-zscheme.
            RETURN.
        ENDIF.

    endloop.
  ENDMETHOD.

ENDCLASS.
