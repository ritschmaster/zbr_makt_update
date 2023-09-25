*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

FORM call_screen_0100 USING it_data TYPE zbr_makt_update_t_data.
  PERFORM 0100_normal_to_alv USING    it_data
                             CHANGING gt_0100_data_alv.

  SORT gt_0100_data_alv BY matnr ASCENDING
                           spras ASCENDING.

  CALL SCREEN 0100.
ENDFORM.

* The parameter C_INITED defines if the Dynpro 0100 has been initialized. It
* is a true CHANGING parameter.
*
* The parameter CCL_CONTAINER is a true CHANGING parameter.
*
* The parameter CC_ALV is a true CHANGING parameter.
*
* The parameter CT_DATA_ALV is a true CHANGING parameter.
FORM 0100_init CHANGING c_inited    TYPE flag
                        cobj_cc_alv TYPE REF TO cl_gui_custom_container
                        cobj_alv    TYPE REF TO cl_gui_alv_grid
                        ct_data_alv TYPE zbr_makt_update_t_data_alv.
  "============================================================================
  " Exit out if the Dynpro has already been initialized
  IF c_inited = abap_true.
    RETURN.
  ENDIF.

  "============================================================================
  " Setup the custom control if the user is running the report in foreground
  IF cl_gui_alv_grid=>offline( ) IS INITIAL.
    IF cobj_cc_alv IS NOT INITIAL.
      cobj_cc_alv->free( ).
    ENDIF.

    CREATE OBJECT cobj_cc_alv
      EXPORTING
        container_name              = gc_0100_cc_alv
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
  ENDIF.

  "============================================================================
  " Create the actual ALV object
  CREATE OBJECT cobj_alv
    EXPORTING
      i_parent = cobj_cc_alv.

  "============================================================================
  " Setup the parameter LS_VARIANT for COBJ_ALV->SET_TABLE_FOR_FIRST_DISPLAY
  DATA: ls_variant TYPE disvariant.
  ls_variant-report = sy-repid.

  "============================================================================
  " Setup the parameter LS_LAYOUT for COBJ_ALV->SET_TABLE_FOR_FIRST_DISPLAY
  DATA: ls_layout TYPE lvc_s_layo.
  ls_layout-cwidth_opt = abap_true.
  ls_layout-sel_mode   = 'D'.
  ls_layout-cwidth_opt = 'A'.

  "============================================================================
  " Setup the parameter IT_TOOLBAR_EXCLUDING for
  " COBJ_ALV->SET_TABLE_FOR_FIRST_DISPLAY
  DATA: lt_toolbar_excluding TYPE ui_functions.
  APPEND cl_gui_alv_grid=>mc_mb_sum TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_mb_view TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_graph TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_info TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_check TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_refresh TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO lt_toolbar_excluding.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row TO lt_toolbar_excluding.

  "============================================================================
  " Setup the parameter IT_FIELDCATALOG for
  " COBJ_ALV->SET_TABLE_FOR_FIRST_DISPLAY
  DATA: lt_fieldcatalog TYPE lvc_t_fcat.
  PERFORM 0100_fieldcatalog CHANGING lt_fieldcatalog.

  "============================================================================
  " Setup the parameter IT_SORT for COBJ_ALV->SET_TABLE_FOR_FIRST_DISPLAY
  DATA: lt_sort TYPE lvc_t_sort.

  "============================================================================
  " Setup the actual ALV object GOBJ_ALV
  CALL METHOD cobj_alv->set_table_for_first_display
    EXPORTING
      is_variant           = ls_variant
      is_layout            = ls_layout
      i_save               = abap_true
      it_toolbar_excluding = lt_toolbar_excluding
    CHANGING
      it_fieldcatalog      = lt_fieldcatalog
      it_sort              = lt_sort
      it_outtab            = ct_data_alv.

  "============================================================================
  " Set the Dynpro to be initialized
  c_inited = abap_true.
ENDFORM.

FORM 0100_status.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.
ENDFORM.

FORM 0100_user_command USING i_okcode    TYPE syucomm
                             iobj_alv    TYPE REF TO cl_gui_alv_grid
                             it_data_alv TYPE zbr_makt_update_t_data_alv.
  iobj_alv->check_changed_data( ).

  CASE i_okcode.
    WHEN gc_0100_save.
      "========================================================================
      " Transform the ALV data to norma data
      DATA: lt_data_save TYPE zbr_makt_update_t_data.
      PERFORM 0100_alv_to_normal USING    it_data_alv
                                 CHANGING lt_data_save.

      "========================================================================
      " Update the materials with the test option
      DATA: lt_return_save TYPE bapiret2_t.
      PERFORM update_materials USING    lt_data_save
                                        abap_false
                               CHANGING lt_return_save.

      "========================================================================
      "
      PERFORM 0100_reset CHANGING g_0100_inited
                                  gobj_0100_cc_alv
                                  gobj_0100_alv.

      "========================================================================
      " Show the messages
      PERFORM call_screen_0101 USING lt_return_save.

    WHEN gc_0100_test.
      "========================================================================
      " Transform the ALV data to norma data
      DATA: lt_data_test TYPE zbr_makt_update_t_data.
      PERFORM 0100_alv_to_normal USING    it_data_alv
                                 CHANGING lt_data_test.

      "========================================================================
      " Update the materials with the test option
      DATA: lt_return_test TYPE bapiret2_t.
      PERFORM update_materials USING    lt_data_test
                                        abap_true
                               CHANGING lt_return_test.

      "========================================================================
      "
      PERFORM 0100_reset CHANGING g_0100_inited
                                  gobj_0100_cc_alv
                                  gobj_0100_alv.

      "========================================================================
      " Show the messages
      PERFORM call_screen_0101 USING lt_return_test.

    WHEN gc_0100_back
      OR gc_0100_exit
      OR gc_0100_cancel.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDFORM.

FORM 0100_fieldcatalog CHANGING et_fieldcatalog TYPE lvc_t_fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_0100_tabname_alv
      i_buffer_active        = abap_true
    CHANGING
      ct_fieldcat            = et_fieldcatalog
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT et_fieldcatalog ASSIGNING FIELD-SYMBOL(<es_fieldcatalog>).
    CASE <es_fieldcatalog>-fieldname.
      WHEN gc_0100_fieldname_maktx.
        <es_fieldcatalog>-edit = abap_true.

      WHEN OTHERS.
        <es_fieldcatalog>-edit = abap_false.

    ENDCASE.
  ENDLOOP.
ENDFORM.

FORM 0100_normal_to_alv USING    it_data     TYPE zbr_makt_update_t_data
                        CHANGING et_data_alv TYPE zbr_makt_update_t_data_alv.
  MOVE-CORRESPONDING it_data TO et_data_alv.
ENDFORM.

FORM 0100_alv_to_normal USING    it_data_alv TYPE zbr_makt_update_t_data_alv
                        CHANGING et_data     TYPE zbr_makt_update_t_data.
  MOVE-CORRESPONDING it_data_alv TO et_data.
ENDFORM.

* The parameter C_INITED defines if the Dynpro 0100 has been initialized. It
* is a true CHANGING parameter.
*
* The parameter CCL_CONTAINER is a true CHANGING parameter.
*
* The parameter CC_ALV is a true CHANGING parameter.
FORM 0100_reset CHANGING c_inited    TYPE flag
                         gobj_cc_alv TYPE REF TO cl_gui_custom_container
                         gobj_alv    TYPE REF TO cl_gui_alv_grid.
  "============================================================================
  " Exit out if the Dynpro has not already been initialized
  IF c_inited = abap_false.
    RETURN.
  ENDIF.

  "============================================================================
  " Free the the old ALV object to ensure that any other Dynpro using the
  " same name for the custom control works as expected
  gobj_alv->free( ).

  "============================================================================
  " The Dynpro can now be re-initialized
  c_inited = abap_false.
ENDFORM.