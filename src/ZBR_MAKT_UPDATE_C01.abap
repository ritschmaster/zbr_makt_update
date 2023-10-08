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
    DATA(lf_length_orig) = get_length_orig( ).
    DATA(lt_0100_alv_data_ref) = get_0100_alv_data_ref( ).

    PERFORM 0100_handle_data_changed_fin USING    e_modified
                                                  lf_length_orig
                                         CHANGING lt_0100_alv_data_ref.

  ENDMETHOD.
ENDCLASS.