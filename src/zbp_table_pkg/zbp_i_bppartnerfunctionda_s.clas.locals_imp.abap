CLASS LHC_RAP_TDAT_CTS DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      GET
        RETURNING
          VALUE(RESULT) TYPE REF TO IF_MBC_CP_RAP_TDAT_CTS.

ENDCLASS.

CLASS LHC_RAP_TDAT_CTS IMPLEMENTATION.
  METHOD GET.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = 'ZBPPARTNERFUNCTIONDA'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'BpPartnerFunctionDa' table = 'ZDT_BP_PARTNER' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_BPPARTNERFUNCTIONDA_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR BpPartnerFunctioAll
        RESULT result,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR BpPartnerFunctioAll
        RESULT result.
ENDCLASS.

CLASS LHC_ZI_BPPARTNERFUNCTIONDA_S IMPLEMENTATION.
  METHOD GET_INSTANCE_FEATURES.
    DATA: edit_flag            TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result = VALUE #( FOR key in keys (
               %TKY = key-%TKY
               %ACTION-edit = edit_flag
               %ASSOC-_BpPartnerFunctionDa = edit_flag ) ).
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_BPPARTNERFUNCTIONDA' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%UPDATE      = is_authorized.
    result-%ACTION-Edit = is_authorized.
  ENDMETHOD.
ENDCLASS.
CLASS LSC_ZI_BPPARTNERFUNCTIONDA_S DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_SAVER.
  PROTECTED SECTION.
    METHODS:
      SAVE_MODIFIED REDEFINITION.
ENDCLASS.

CLASS LSC_ZI_BPPARTNERFUNCTIONDA_S IMPLEMENTATION.
  METHOD SAVE_MODIFIED ##NEEDED.
  ENDMETHOD.
ENDCLASS.
CLASS LHC_ZI_BPPARTNERFUNCTIONDA DEFINITION FINAL INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_FEATURES FOR GLOBAL FEATURES
        IMPORTING
          REQUEST REQUESTED_FEATURES FOR BpPartnerFunctionDa
        RESULT result,
      COPYBPPARTNERFUNCTIONDA FOR MODIFY
        IMPORTING
          KEYS FOR ACTION BpPartnerFunctionDa~CopyBpPartnerFunctionDa,
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR BpPartnerFunctionDa
        RESULT result,
      GET_INSTANCE_FEATURES FOR INSTANCE FEATURES
        IMPORTING
          KEYS REQUEST requested_features FOR BpPartnerFunctionDa
        RESULT result.
ENDCLASS.

CLASS LHC_ZI_BPPARTNERFUNCTIONDA IMPLEMENTATION.
  METHOD GET_GLOBAL_FEATURES.
    DATA edit_flag TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%UPDATE = edit_flag.
    result-%DELETE = edit_flag.
  ENDMETHOD.
  METHOD COPYBPPARTNERFUNCTIONDA.
    DATA new_BpPartnerFunctionDa TYPE TABLE FOR CREATE ZI_BpPartnerFunctionDa_S\_BpPartnerFunctionDa.

    IF lines( keys ) > 1.
      INSERT mbc_cp_api=>message( )->get_select_only_one_entry( ) INTO TABLE reported-%other.
      failed-BpPartnerFunctionDa = VALUE #( FOR fkey IN keys ( %TKY = fkey-%TKY ) ).
      RETURN.
    ENDIF.

    READ ENTITIES OF ZI_BpPartnerFunctionDa_S IN LOCAL MODE
      ENTITY BpPartnerFunctionDa
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(ref_BpPartnerFunctionDa)
        FAILED DATA(read_failed).

    IF ref_BpPartnerFunctionDa IS NOT INITIAL.
      ASSIGN ref_BpPartnerFunctionDa[ 1 ] TO FIELD-SYMBOL(<ref_BpPartnerFunctionDa>).
      DATA(key) = keys[ KEY draft %TKY = <ref_BpPartnerFunctionDa>-%TKY ].
      DATA(key_cid) = key-%CID.
      APPEND VALUE #(
        %TKY-SingletonID = 1
        %IS_DRAFT = <ref_BpPartnerFunctionDa>-%IS_DRAFT
        %TARGET = VALUE #( (
          %CID = key_cid
          %IS_DRAFT = <ref_BpPartnerFunctionDa>-%IS_DRAFT
          %DATA = CORRESPONDING #( <ref_BpPartnerFunctionDa> EXCEPT
          SingletonID
          CreatedBy
          CreatedAt
          LocalLastChangedBy
          LocalLastChangedAt
          LastChangedAt
        ) ) )
      ) TO new_BpPartnerFunctionDa ASSIGNING FIELD-SYMBOL(<new_BpPartnerFunctionDa>).
      <new_BpPartnerFunctionDa>-%TARGET[ 1 ]-Customer = to_upper( key-%PARAM-Customer ).
      <new_BpPartnerFunctionDa>-%TARGET[ 1 ]-SalesOrg = to_upper( key-%PARAM-SalesOrg ).
      <new_BpPartnerFunctionDa>-%TARGET[ 1 ]-DistChannel = to_upper( key-%PARAM-DistChannel ).
      <new_BpPartnerFunctionDa>-%TARGET[ 1 ]-Division = to_upper( key-%PARAM-Division ).

      MODIFY ENTITIES OF ZI_BpPartnerFunctionDa_S IN LOCAL MODE
        ENTITY BpPartnerFunctioAll CREATE BY \_BpPartnerFunctionDa
        FIELDS (
                 Customer
                 SalesOrg
                 DistChannel
                 Division
                 PartnerFunction
                 Bpcustomernumber
               ) WITH new_BpPartnerFunctionDa
        MAPPED DATA(mapped_create)
        FAILED failed
        REPORTED reported.

      mapped-BpPartnerFunctionDa = mapped_create-BpPartnerFunctionDa.
    ENDIF.

    INSERT LINES OF read_failed-BpPartnerFunctionDa INTO TABLE failed-BpPartnerFunctionDa.

    IF failed-BpPartnerFunctionDa IS INITIAL.
      reported-BpPartnerFunctionDa = VALUE #( FOR created IN mapped-BpPartnerFunctionDa (
                                                 %CID = created-%CID
                                                 %ACTION-CopyBpPartnerFunctionDa = if_abap_behv=>mk-on
                                                 %MSG = mbc_cp_api=>message( )->get_item_copied( )
                                                 %PATH-BpPartnerFunctioAll-%IS_DRAFT = created-%IS_DRAFT
                                                 %PATH-BpPartnerFunctioAll-SingletonID = 1 ) ).
    ENDIF.
  ENDMETHOD.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_BPPARTNERFUNCTIONDA' ID 'ACTVT' FIELD '02'.
    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                  ELSE if_abap_behv=>auth-unauthorized ).
    result-%ACTION-CopyBpPartnerFunctionDa = is_authorized.
  ENDMETHOD.
  METHOD GET_INSTANCE_FEATURES.
    result = VALUE #( FOR row IN keys ( %TKY = row-%TKY
                                        %ACTION-CopyBpPartnerFunctionDa = COND #( WHEN row-%IS_DRAFT = if_abap_behv=>mk-off THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
    ) ).
  ENDMETHOD.
ENDCLASS.
