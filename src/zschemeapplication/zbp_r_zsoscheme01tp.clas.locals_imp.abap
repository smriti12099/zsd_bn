CLASS lhc_zsoscheme DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zsoscheme
        RESULT result,

      createSOSchemeData FOR MODIFY
        IMPORTING keys FOR ACTION zsoscheme~createSOSchemeData RESULT result,
      get_instance_features FOR INSTANCE FEATURES
            IMPORTING keys REQUEST requested_features FOR zsoscheme RESULT result.

          METHODS deleteSOSchemeData FOR MODIFY
            IMPORTING keys FOR ACTION zsoscheme~deleteSOSchemeData RESULT result.

ENDCLASS.

CLASS lhc_zsoscheme IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD createSOSchemeData.
    CONSTANTS mycid TYPE abp_behv_cid VALUE 'My%CID_soschemecalc' ##NO_TEXT.

    DATA salesorder TYPE char13.
    DATA plantcode TYPE char05.
    DATA customergroup TYPE char03.
    DATA schemecode TYPE char13.
    DATA schemegroupcode TYPE char05.
    DATA schemecheckcode TYPE char72.
    DATA itembatch TYPE char13.
    DATA schemeqty  TYPE int1.
    DATA freeqty TYPE int1.
    DATA freeqtycalc TYPE p DECIMALS 2.
    DATA minimumqty TYPE int1.

    DATA orderqty TYPE int2.
    DATA companycode TYPE char05.
    DATA productdesc TYPE char72.

    DATA create_soscheme TYPE STRUCTURE FOR CREATE ZR_zsoscheme01TP.
    DATA create_soschemetab TYPE TABLE FOR CREATE ZR_zsoscheme01TP.

    DATA create_soschemeline TYPE STRUCTURE FOR CREATE ZR_soschlines.
    DATA create_soschemelinetab TYPE TABLE FOR CREATE ZR_soschlines.

    DATA insertTag TYPE int1.
    DATA supplytag TYPE int1.


    LOOP AT keys INTO DATA(ls_key).
      insertTag = 0.
      TRY.
          salesorder = ls_key-%param-salesorder .
          salesorder = |{ salesorder  WIDTH = 10 ALIGN = RIGHT  PAD = '0' }|.

          IF salesorder = ''.
            APPEND VALUE #( %cid = ls_key-%cid ) TO failed-zsoscheme.
            APPEND VALUE #( %cid = ls_key-%cid
                            %msg = new_message_with_text(
                                     severity = if_abap_behv_message=>severity-error
                                     text     = 'Sales Order No. cannot be blank.' )
                          ) TO reported-zsoscheme.
            RETURN.
          ENDIF.
      ENDTRY.

      DATA sodate TYPE d.
      DATA distributionchannel TYPE C LENGTH 2.
      DATA division TYPE C LENGTH 2.
      DATA customerpricegroup TYPE C LENGTH 2.


      SELECT FROM I_SalesOrder AS soi
          FIELDS soi~DistributionChannel, soi~OrganizationDivision, soi~SalesOrderDate, soi~CustomerPriceGroup
          WHERE soi~SalesOrder = @salesorder
          INTO TABLE @DATA(so).
      LOOP AT so INTO DATA(waso).
        sodate = waso-salesorderdate.
        distributionchannel = waso-DistributionChannel.
        division = waso-OrganizationDivision.
        customerpricegroup = waso-CustomerPriceGroup.
*        IF waso-DistributionChannel <> 'GT' OR waso-OrganizationDivision <> 'B2'.
*          APPEND VALUE #( %cid = ls_key-%cid
*                          %msg = new_message_with_text(
*                                   severity = if_abap_behv_message=>severity-error
*                                   text     = 'Sales Order No. must be of GT and B2 category.' )
*                        ) TO reported-zsoscheme.
*          RETURN.
*        ENDIF.
      ENDLOOP.

      customergroup = ''.
*      SELECT SINGLE FROM I_SalesOrder AS soi
*"        join I_Customer as cus on soi~SoldToParty = cus~Customer
*      JOIN I_CustomerSalesArea AS cus ON soi~SoldToParty = cus~Customer
*          FIELDS cus~SalesDistrict
*          WHERE soi~SalesOrder = @salesorder "AND cus~DistributionChannel = 'GT' AND cus~Division = 'B2'
*          INTO @DATA(customergroup2).
*      customergroup = customergroup2.


      plantcode = ''.
      SELECT SINGLE FROM I_SalesOrderItem AS soi
          FIELDS soi~Plant
          WHERE soi~SalesOrder = @salesorder
          INTO @DATA(plantcode2).
      plantcode = plantcode2.

      SELECT SINGLE FROM ztable_plant AS pl
          FIELDS pl~comp_code
          WHERE pl~plant_code = @plantcode
          INTO @DATA(companycode2).
      companycode = companycode2.

      SELECT FROM zscheme AS sch
      JOIN zschemelines AS schline ON sch~bukrs = schline~bukrs AND sch~schemecode = schline~schemecode
      JOIN I_ProductStdVH as prod ON schline~productcode = prod~ProductExternalID
      FIELDS sch~schemecode, sch~freeqty, sch~schemeqty, sch~minimumqty, schline~schemegroupcode, prod~Product
      WHERE sch~bukrs = @companycode AND sch~plantcode = @plantcode AND sch~validfrom <= @sodate AND sch~validto >= @sodate
      AND sch~customerpricegroup = @customerpricegroup AND sch~distributionchannel = @distributionchannel AND sch~division = @division
      ORDER BY sch~schemecode, schline~schemegroupcode
         INTO TABLE @DATA(ltlines).

      schemecode = ''.
      schemegroupcode = ''.
      schemecheckcode = ''.
      itembatch = ''.
      orderqty = 0.
      schemeqty = 0.
      freeqty = 0.
      minimumqty = 0.
      LOOP AT ltlines INTO DATA(walines).
        IF schemecode <> walines-schemecode OR schemegroupcode <> walines-schemegroupcode.
          IF orderqty <> 0 AND orderqty >= minimumqty.
            insertTag = 1.
            freeqtycalc = orderqty / schemeqty.
            freeqty = floor( freeqtycalc ).
            "insert so scheme & lines
            create_soscheme = VALUE #( %cid      = ls_key-%cid
                            Bukrs = companycode
                            Salesorder = salesorder
                            Schemecode = schemecode
                            Schemegroupcode = schemegroupcode
                            Schemecheckcode = schemecheckcode
                            Orderqty = orderqty
                            Freeqty = freeqty
                            Appliedqty = 0
                            ).
            APPEND create_soscheme TO create_soschemetab.

            MODIFY ENTITIES OF ZR_zsoscheme01TP IN LOCAL MODE
            ENTITY zsoscheme
            CREATE FIELDS ( bukrs salesorder schemecode schemegroupcode schemecheckcode orderqty freeqty appliedqty )
                  WITH create_soschemetab
            MAPPED   mapped
            FAILED   failed
            REPORTED reported.

            SELECT FROM zschemelines AS schline
            JOIN I_ProductStdVH as prod on schline~productcode = prod~ProductExternalID
                FIELDS schline~schemecode, schline~schemegroupcode, prod~Product, schline~defaultfree
            WHERE schline~bukrs = @companycode AND schline~schemecode = @schemecode AND schline~schemegroupcode = @schemegroupcode
            ORDER BY schline~productcode
                INTO TABLE @DATA(ltschlines).

            LOOP AT ltschlines INTO DATA(waschlines).
              productdesc = ''.
              SELECT FROM I_ProductDescription AS pd
                  FIELDS pd~Product, pd~ProductDescription
                  WHERE pd~Product = @waschlines-product AND pd~LanguageISOCode = 'EN'
                  INTO TABLE @DATA(Itlines).
              DATA: ls_Itlines LIKE LINE OF Itlines.

              READ TABLE Itlines WITH KEY Product = waschlines-product
                          INTO ls_Itlines.
              IF sy-subrc = 0.
                productdesc = ls_Itlines-ProductDescription.
              ENDIF.

              itembatch = ''.
              SELECT SINGLE FROM I_SalesOrderItem AS sl
                FIELDS sl~Batch
                WHERE sl~SalesOrder = @salesorder
                    AND sl~Product = @waschlines-Product
                    INTO @itembatch.

              create_soschemeline = VALUE #( %cid      = ls_key-%cid
                              Bukrs = companycode
                              Salesorder = salesorder
                              Schemecode = schemecode
                              Schemegroupcode = schemegroupcode
                              Schemecheckcode = schemecheckcode
                              Productcode = waschlines-Product
                              Productdesc = productdesc
                              Defaultfree = waschlines-defaultfree
                              Freeqty = 0
                              Batch = itembatch
                              ).
              APPEND create_soschemeline TO create_soschemelinetab.

              MODIFY ENTITIES OF ZR_soschlines
              ENTITY ZR_soschlines
              CREATE FIELDS ( bukrs salesorder schemecode schemegroupcode schemecheckcode  Productcode Productdesc Defaultfree freeqty Batch )
                    WITH create_soschemelinetab.

              CLEAR : create_soschemeline.
              CLEAR : create_soschemelinetab.
            ENDLOOP.

            CLEAR : create_soscheme.
            CLEAR : create_soschemetab.

          ENDIF.

          schemecode = walines-schemecode.
          schemegroupcode = walines-schemegroupcode.
          schemecheckcode = |{ walines-schemecode }| & |-| & |{ walines-schemegroupcode }|.
          schemeqty = walines-schemeqty.
          freeqty = walines-freeqty.
          minimumqty = walines-minimumqty.
          orderqty = 0.
        ENDIF.

        SELECT FROM I_SalesOrderItem AS sl
        FIELDS SUM( sl~OrderQuantity )
        WHERE sl~SalesOrder = @salesorder
            AND sl~Product = @walines-Product
            INTO @DATA(soqty).

        IF sy-subrc = 0.
          orderqty = orderqty + soqty.
        ENDIF.
      ENDLOOP.
      IF orderqty <> 0 AND orderqty >= minimumqty.
        "insert so scheme & lines
        inserttag = 1.
        freeqtycalc = orderqty / schemeqty.
        freeqty = floor( freeqtycalc ).
        create_soscheme = VALUE #( %cid      = ls_key-%cid
                        Bukrs = companycode
                        Salesorder = salesorder
                        Schemecode = schemecode
                        Schemegroupcode = schemegroupcode
                        Schemecheckcode = schemecheckcode
                        Orderqty = orderqty
                        Freeqty = freeqty
                        Appliedqty = 0
                        ).
        APPEND create_soscheme TO create_soschemetab.

        MODIFY ENTITIES OF ZR_zsoscheme01TP IN LOCAL MODE
        ENTITY zsoscheme
        CREATE FIELDS ( bukrs salesorder schemecode schemegroupcode schemecheckcode orderqty freeqty appliedqty )
              WITH create_soschemetab
        MAPPED   mapped
        FAILED   failed
        REPORTED reported.

        SELECT FROM zschemelines AS schline
        JOIN I_ProductStdVH as prod on schline~productcode = prod~ProductExternalID
            FIELDS schline~schemecode, schline~schemegroupcode, prod~Product, schline~defaultfree
        WHERE schline~bukrs = @companycode AND schline~schemecode = @schemecode AND schline~schemegroupcode = @schemegroupcode
        ORDER BY schline~productcode
            INTO TABLE @DATA(ltschlines2).

        LOOP AT ltschlines2 INTO DATA(waschlines2).
          productdesc = ''.
          SELECT FROM I_ProductDescription AS pd
              FIELDS pd~Product, pd~ProductDescription
              WHERE pd~Product = @waschlines2-Product AND pd~LanguageISOCode = 'EN'
              INTO TABLE @DATA(Itlines2).
          DATA: ls_Itlines2 LIKE LINE OF Itlines2.

          READ TABLE Itlines2 WITH KEY Product = waschlines2-Product
                      INTO ls_Itlines2.
          IF sy-subrc = 0.
            productdesc = ls_Itlines2-ProductDescription.
          ENDIF.

          itembatch = ''.
          SELECT SINGLE FROM I_SalesOrderItem AS sl
            FIELDS sl~Batch
            WHERE sl~SalesOrder = @salesorder
                AND sl~Product = @waschlines2-Product
                INTO @itembatch.

          create_soschemeline = VALUE #( %cid      = ls_key-%cid
                          Bukrs = companycode
                          Salesorder = salesorder
                          Schemecode = schemecode
                          Schemegroupcode = schemegroupcode
                          Schemecheckcode = schemecheckcode
                          Productcode = waschlines2-Product
                          Defaultfree = waschlines2-defaultfree
                          Productdesc = productdesc
                          Freeqty = 0
                          Batch = itembatch
                          ).
          APPEND create_soschemeline TO create_soschemelinetab.

          MODIFY ENTITIES OF ZR_soschlines
          ENTITY ZR_soschlines
          CREATE FIELDS ( bukrs salesorder schemecode schemegroupcode schemecheckcode Productcode Productdesc Defaultfree freeqty Batch )
                WITH create_soschemelinetab.

          CLEAR : create_soschemeline.
          CLEAR : create_soschemelinetab.
        ENDLOOP.


      ENDIF.
      IF inserttag = 0.
        create_soscheme = VALUE #( %cid      = ls_key-%cid
                        Bukrs = companycode
                        Salesorder = salesorder
                        Schemecode = 'NA'
                        Schemegroupcode = 'NA'
                        Schemecheckcode = 'NA'
                        Orderqty = 0
                        Freeqty = 0
                        Appliedqty = 0
                        ).
        APPEND create_soscheme TO create_soschemetab.

        MODIFY ENTITIES OF ZR_zsoscheme01TP IN LOCAL MODE
        ENTITY zsoscheme
        CREATE FIELDS ( bukrs salesorder schemecode schemegroupcode schemecheckcode orderqty freeqty appliedqty )
              WITH create_soschemetab
        MAPPED   mapped
        FAILED   failed
        REPORTED reported.

      ENDIF.


      APPEND VALUE #( %cid = ls_key-%cid
                      %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text     = 'Success.' )
                      ) TO reported-zsoscheme.
      RETURN.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD deleteSOSchemeData.
    DATA: it_header_d TYPE TABLE FOR DELETE ZR_zsoscheme01TP.
    DATA: it_lines_d TYPE TABLE FOR DELETE ZR_soschlines.


    READ ENTITIES OF ZR_zsoscheme01TP IN LOCAL MODE
      ENTITY zsoscheme
      FIELDS ( Bukrs Salesorder Schemecode Schemegroupcode ) with CORRESPONDING #( keys )
      RESULT DATA(soschemedata)
      FAILED failed.

    LOOP AT soschemedata INTO DATA(soscheme).
      IF soscheme-Salesorder <> ''.
        SELECT FROM zsoscheme
          FIELDS Bukrs, salesorder, schemecode, schemegroupcode
          WHERE salesorder = @soscheme-Salesorder
          INTO TABLE @DATA(ltsoschemedelete).
        LOOP AT ltsoschemedelete INTO DATA(walines).
            it_header_d = value #( ( Bukrs = walines-bukrs
                                    Salesorder = walines-salesorder
                                    Schemecode = walines-schemecode
                                    Schemegroupcode = walines-schemegroupcode
                                    ) ).

            SELECT FROM zsoschemelines
              FIELDS Bukrs, salesorder, schemecode, schemegroupcode, productcode
              WHERE salesorder = @soscheme-Salesorder
              INTO TABLE @DATA(ltsoschlinedelete).
            LOOP AT ltsoschlinedelete INTO DATA(wasolines).
                it_lines_d = value #( ( Bukrs = walines-bukrs
                                                Salesorder = walines-salesorder
                                                Schemecode = walines-schemecode
                                                Schemegroupcode = walines-schemegroupcode
                                                Productcode = wasolines-productcode
                                                ) ).

              MODIFY ENTITIES OF ZR_soschlines "IN LOCAL MODE
                ENTITY ZR_soschlines
                DELETE FROM it_lines_d.
"                FAILED failed
"                REPORTED reported.

            ENDLOOP.

          MODIFY ENTITIES OF ZR_zsoscheme01TP IN LOCAL MODE
            ENTITY zsoscheme
            DELETE FROM it_header_d
            FAILED failed
            REPORTED reported.

        ENDLOOP.

        APPEND VALUE #( %tky = soscheme-%tky
                    %msg = new_message_with_text(
                      severity = if_abap_behv_message=>severity-success
                      text = 'Scheme Data Deleted.' )
                      ) to reported-zsoscheme.

*        COMMIT ENTITIES
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
