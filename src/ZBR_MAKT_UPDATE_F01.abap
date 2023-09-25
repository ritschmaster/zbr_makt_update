*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

FORM main USING irt_matnr TYPE zbr_makt_update_rt_matnr.
  "============================================================================
  " Get the affected materials.
  DATA: lt_data TYPE zbr_makt_update_t_data.
  PERFORM select_data USING    irt_matnr
                      CHANGING lt_data.

  "============================================================================
  " Call the screen
  PERFORM call_screen_0100 USING lt_data.
ENDFORM.

FORM select_data USING    irt_matnr TYPE zbr_makt_update_rt_matnr
                 CHANGING et_data  TYPE zbr_makt_update_t_data.
  CLEAR et_data.

  SELECT makt~matnr makt~spras makt~maktx
    INTO TABLE et_data
    FROM mara
    INNER JOIN makt ON makt~matnr = mara~matnr
    WHERE mara~matnr IN irt_matnr.
ENDFORM.

* This subroutine will set the maximum available views in a BAPIE1MATHEADER
* entry. It utilizes the possible material views according to the
* customizing of the material type to be used.
*
* The parameter I_PSTAT defines the views to be used. The BAPIE1MATHEADER
* entry is not validated.
*
* The parameter CS_HEADATA is a true CHANGING parameter. Other attribues
* than the VIEW fields are not updated.
FORM set_bapie1matheader_max_views USING    i_pstat     LIKE t134-pstat
                                   CHANGING cs_headdata TYPE bapie1matheader.
  IF i_pstat CS 'K'.
    cs_headdata-basic_view = abap_true.
  ELSE.
    cs_headdata-basic_view = abap_false.
  ENDIF.

  IF i_pstat CS 'V'.
    cs_headdata-sales_view = abap_true.
  ELSE.
    cs_headdata-sales_view = abap_false.
  ENDIF.

  IF i_pstat CS 'E'.
    cs_headdata-purchase_view = abap_true.
  ELSE.
    cs_headdata-purchase_view = abap_false.
  ENDIF.

  IF i_pstat CS 'D'.
    cs_headdata-mrp_view = abap_true.
  ELSE.
    cs_headdata-mrp_view = abap_false.
  ENDIF.

  IF i_pstat CS 'P'.
    cs_headdata-forecast_view = abap_true.
  ELSE.
    cs_headdata-forecast_view = abap_false.
  ENDIF.

  IF i_pstat CS 'A'.
    cs_headdata-work_sched_view = abap_true.
  ELSE.
    cs_headdata-work_sched_view = abap_false.
  ENDIF.

  IF i_pstat CS 'F'.
    cs_headdata-prt_view = abap_true.
  ELSE.
    cs_headdata-prt_view = abap_false.
  ENDIF.

  IF i_pstat CS 'L'.
    cs_headdata-storage_view = abap_true.
  ELSE.
    cs_headdata-storage_view = abap_false.
  ENDIF.

  IF i_pstat CS 'S'.
    cs_headdata-warehouse_view = abap_true.
  ELSE.
    cs_headdata-warehouse_view = abap_false.
  ENDIF.

  IF i_pstat CS 'Q'.
    cs_headdata-quality_view = abap_true.
  ELSE.
    cs_headdata-quality_view = abap_false.
  ENDIF.

  IF i_pstat CS 'B'.
    cs_headdata-account_view = abap_true.
  ELSE.
    cs_headdata-account_view = abap_false.
  ENDIF.

  IF i_pstat CS 'G'.
    cs_headdata-cost_view = abap_true.
  ELSE.
    cs_headdata-cost_view = abap_false.
  ENDIF.
ENDFORM.

* Updates the materials described by IT_DATA. If any error occurs, then the
* changes are rolled back. In any case a protocol on what has happened is
* presented to the user.
*
* If the parameter I_TEST is ABAP_TRUE, then any changes will be rolled back.
* Otherwise a commit is performed if the changes could be applied successfully.
FORM update_materials USING    it_data   TYPE zbr_makt_update_t_data
                               i_test    TYPE flag
                      changing et_return type bapiret2_t.
  "============================================================================
  " Transform IT_DATA to be consumable by the BAPI
  DATA:
    lt_headdata            TYPE TABLE OF bapie1matheader,
    lt_clientdata          TYPE TABLE OF bapie1mara,
    lt_clientdatax         TYPE TABLE OF bapie1marax,
    lt_materialdescription TYPE TABLE OF bapie1makt.

    clear et_return.

  LOOP AT it_data ASSIGNING FIELD-SYMBOL(<is_data>)
    GROUP BY <is_data>-matnr ASCENDING
    ASSIGNING FIELD-SYMBOL(<is_data_matnr_group>).
    "==========================================================================
    " Add a new line to LT_HEADDATA
    APPEND INITIAL LINE TO lt_headdata ASSIGNING FIELD-SYMBOL(<ls_headdata>).

    "==========================================================================
    " Setup easy values for the new LT_HEADDATA entry
    <ls_headdata>-function = 'INS'.
    <ls_headdata>-material = <is_data_matnr_group>.

    "==========================================================================
    " Setup the sophisticated values for the new LT_HEADDATA entry
    DATA: lf_pstat LIKE t134-pstat.
    SELECT SINGLE mara~mbrsh, mara~mtart, t134~pstat
      INTO ( @<ls_headdata>-ind_sector, @<ls_headdata>-matl_type, @lf_pstat )
      FROM mara
        INNER JOIN t134 ON t134~mtart = mara~mtart
      WHERE mara~matnr = @<is_data_matnr_group>.
    PERFORM set_bapie1matheader_max_views USING lf_pstat
                                          CHANGING <ls_headdata>.

    "==========================================================================
    " Add a new line to LT_CLIENTDATA and set it up
    APPEND INITIAL LINE TO lt_clientdata ASSIGNING FIELD-SYMBOL(<ls_clientdata>).
    <ls_clientdata> = VALUE #(
      function = 'INS'
      material = <is_data_matnr_group>
    ).

    "==========================================================================
    " Add a new line to LT_CLIENTDATAX and set it up
    APPEND INITIAL LINE TO lt_clientdatax ASSIGNING FIELD-SYMBOL(<ls_clientdatax>).
    <ls_clientdatax> = VALUE #(
      function = 'INS'
      material = <is_data_matnr_group>
    ).

    "==========================================================================
    " Add a new line to the material descriptions for each language and set it
    " up
    LOOP AT GROUP <is_data_matnr_group> ASSIGNING FIELD-SYMBOL(<is_data_matnr>).
      APPEND INITIAL LINE TO lt_materialdescription ASSIGNING FIELD-SYMBOL(<ls_materialdescription>).
      <ls_materialdescription> = VALUE #(
        function  = 'INS'
        material  = <is_data_matnr>-matnr
        langu     = <is_data_matnr>-spras
        matl_desc = <is_data_matnr>-maktx
      ).
    ENDLOOP.
  ENDLOOP.

  "============================================================================
  " Save the materials
  CALL FUNCTION 'BAPI_MATERIAL_SAVEREPLICA'
    EXPORTING
      noappllog           = abap_false
      nochangedoc         = abap_false
      testrun             = i_test
      inpfldcheck         = abap_false
    TABLES
      headdata            = lt_headdata[]
      clientdata          = lt_clientdata[]
      clientdatax         = lt_clientdatax[]
      materialdescription = lt_materialdescription
      returnmessages      = et_return[].

  "============================================================================
  " Rollback and exit out on error
  LOOP AT et_return TRANSPORTING NO FIELDS
    WHERE type CA 'AEX'.
    "==========================================================================
    " Rollback the changes
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    "==========================================================================
    " Exit out
    RETURN.
  ENDLOOP.

  "============================================================================
  " Updating materials ended successfully

  IF i_test = abap_true.
    "==========================================================================
    " Rollback the changes by the test run
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    "==========================================================================
    " Commit the changes
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ENDIF.
ENDFORM.