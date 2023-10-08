*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

CLASS zcl_0100_alv_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          it_0100_alv_data_ref TYPE REF TO zbr_makt_update_t_data_alv,

      get_0100_alv_data_ref
        RETURNING
          VALUE(robj_0100_alv_data_ref) TYPE REF TO zbr_makt_update_t_data_alv,

      get_length_orig
        RETURNING
          VALUE(r_length_orig) TYPE int4,

      data_changed_finished
        FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING
          e_modified
          et_good_cells.

  PRIVATE SECTION.
    DATA:
      t_0100_alv_data_ref TYPE REF TO zbr_makt_update_t_data_alv,
      length_orig         TYPE int4.
ENDCLASS.

CLASS zcl_0100_alv_event_receiver IMPLEMENTATION.
  METHOD constructor.
    t_0100_alv_data_ref = it_0100_alv_data_ref.
    length_orig = lines( t_0100_alv_data_ref->* ).
  ENDMETHOD.

  METHOD get_0100_alv_data_ref.
    robj_0100_alv_data_ref = t_0100_alv_data_ref.
  ENDMETHOD.

  METHOD get_length_orig.
    r_length_orig = length_orig.
  ENDMETHOD.

  METHOD data_changed_finished.
    "==========================================================================
    " Exit out if nothing has been changed
    CHECK e_modified = abap_true.

    "==========================================================================
    " Delete all lines after the original length
    DATA(lt_0100_alv_data_ref) = get_0100_alv_data_ref( ).
    DATA(lf_i) = lines( lt_0100_alv_data_ref->* ).
    DATA(lf_refresh) = abap_false.
    WHILE lf_i > length_orig.
      DELETE t_0100_alv_data_ref->* INDEX lf_i.

      lf_refresh = abap_true.

      SUBTRACT 1 FROM lf_i.
    ENDWHILE.

    "==========================================================================
    " Refresh the ALV after modifiying it
    IF lf_refresh = abap_true.
      DATA: ls_stable TYPE lvc_s_stbl.
      ls_stable-row = abap_true.
      ls_stable-col = abap_true.
      gobj_0100_alv->refresh_table_display(
        is_stable      = ls_stable
        i_soft_refresh = abap_true
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.