*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

FORM call_screen_0101 USING it_data TYPE bapiret2_t.
  "============================================================================
  " We do not sort GT_0101_DATA_ALV since IT_DATA might have the messages in
  " chronological order.
  CLEAR gt_0101_data_alv.
  LOOP AT it_data ASSIGNING FIELD-SYMBOL(<is_data>).
    "==========================================================================
    " Add a new line an populate it within this iteration
    APPEND INITIAL LINE TO gt_0101_data_alv ASSIGNING FIELD-SYMBOL(<ls_0101_data_alv>).

    "==========================================================================
    " Determine all attributes of the include of BAPIRET2
    MOVE-CORRESPONDING <is_data> TO <ls_0101_data_alv>.

    "==========================================================================
    " Determine the attribute STATUS
    CASE <ls_0101_data_alv>-type.
      WHEN 'S' OR 'I' OR ''.
        <ls_0101_data_alv>-status = icon_green_light.

      WHEN 'W'.
        <ls_0101_data_alv>-status = icon_yellow_light.

      WHEN OTHERS.
        <ls_0101_data_alv>-status = icon_red_light.
    ENDCASE.

    "==========================================================================
    " Determine the attribute LT_AVAILABLE
    DATA: lf_object TYPE dokhl-object.
    CLEAR lf_object.
    CONCATENATE <ls_0101_data_alv>-id
      <ls_0101_data_alv>-number
      INTO lf_object.

    DATA: lt_tline TYPE TABLE OF tline.
    CLEAR lt_tline.
    CALL FUNCTION 'DOCU_GET_FOR_F1HELP'
      EXPORTING
        id       = 'NA'
        langu    = sy-langu
        object   = lf_object
      TABLES
        line     = lt_tline
      EXCEPTIONS
        ret_code = 1
        OTHERS   = 2.
    IF sy-subrc = 0.
      <ls_0101_data_alv>-lt_available = icon_system_help.
    ENDIF.
  ENDLOOP.

  "===========================================================================
  " Show the screen to the user
  CALL SCREEN 0101.
ENDFORM.

* The parameter C_INITED defines if the Dynpro 0101 has been initialized. It
* is a true CHANGING parameter.
*
* The parameter CCL_CONTAINER is a true CHANGING parameter.
*
* The parameter CC_ALV is a true CHANGING parameter.
*
* The parameter CT_DATA_ALV is a true CHANGING parameter.
FORM 0101_init CHANGING c_inited    TYPE flag
                        cobj_cc_alv TYPE REF TO cl_gui_custom_container
                        cobj_alv    TYPE REF TO cl_gui_alv_grid
                        ct_data_alv TYPE zbr_makt_update_t_bapiret2.
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
        container_name              = gc_0101_cc_alv
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
  " Disable any input of the table
  cobj_alv->set_ready_for_input( 0 ).

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
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_0101_tabname_alv
      i_buffer_active        = abap_true
    CHANGING
      ct_fieldcat            = lt_fieldcatalog
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  "============================================================================
  " Setup the parameter IT_SORT for COBJ_ALV->SET_TABLE_FOR_FIRST_DISPLAY
  DATA: lt_sort TYPE lvc_t_sort.

  "============================================================================
  " Setup the handlers of COBJ_ALV
  DATA: ct_data_alv_ref TYPE REF TO zbr_makt_update_t_bapiret2.
  GET REFERENCE OF ct_data_alv INTO ct_data_alv_ref.

  DATA: lobj_event_receiver TYPE REF TO zcl_0101_alv_event_receiver.
  lobj_event_receiver = NEW zcl_0101_alv_event_receiver(
     it_0101_alv_data_ref = ct_data_alv_ref
  ).

  SET HANDLER lobj_event_receiver->handle_hotspot_click FOR cobj_alv.

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

FORM 0101_status.
  SET PF-STATUS '0101'.
  SET TITLEBAR '0101'.
ENDFORM.

FORM 0101_user_command USING i_okcode    TYPE syucomm
                             iobj_alv    TYPE REF TO cl_gui_alv_grid
                             it_data_alv TYPE zbr_makt_update_t_bapiret2.
  CASE i_okcode.
    WHEN gc_0100_back
      OR gc_0100_exit
      OR gc_0100_cancel.
      PERFORM 0101_reset CHANGING g_0101_inited
                                  gobj_0101_cc_alv
                                  gobj_0101_alv.
      LEAVE TO SCREEN 0.

  ENDCASE.
ENDFORM.

FORM 0101_handle_hotspot_click USING i_row      TYPE lvc_s_row
                                     i_column   TYPE lvc_s_col
                                     it_data_alv TYPE REF TO zbr_makt_update_t_bapiret2.
  "============================================================================
  " Get the row the user clicked into <IS_DATA_ALV>
  FIELD-SYMBOLS: <it_data_alv> TYPE zbr_makt_update_t_bapiret2.
  ASSIGN it_data_alv->* TO <it_data_alv>.
  READ TABLE <it_data_alv> ASSIGNING FIELD-SYMBOL(<is_data_alv>) INDEX i_row-index.

  "============================================================================
  " Exit out if the index could not be assigned
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  "============================================================================
  " Get the key of the message
  DATA: lf_dokname TYPE string.
  CONCATENATE <is_data_alv>-id <is_data_alv>-number INTO lf_dokname.

  "============================================================================
  " Show the longtext of the message
  DATA: lt_link TYPE TABLE OF tline.
  CALL FUNCTION 'HELP_OBJECT_SHOW'
    EXPORTING
      dokclass         = 'NA'
      doklangu         = sy-langu
      dokname          = lf_dokname
      msg_var_1        = <is_data_alv>-message_v1
      msg_var_2        = <is_data_alv>-message_v2
      msg_var_3        = <is_data_alv>-message_v3
      msg_var_4        = <is_data_alv>-message_v4
    TABLES
      links            = lt_link
    EXCEPTIONS
      object_not_found = 1
      sapscript_error  = 2
      OTHERS           = 3.
ENDFORM.

* The parameter C_INITED defines if the Dynpro 0101 has been initialized. It
* is a true CHANGING parameter.
*
* The parameter CCL_CONTAINER is a true CHANGING parameter.
*
* The parameter CC_ALV is a true CHANGING parameter.
FORM 0101_reset CHANGING c_inited    TYPE flag
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