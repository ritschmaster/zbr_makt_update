*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

CLASS zcl_0101_alv_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          it_0101_alv_data_ref TYPE REF TO zbr_makt_update_t_bapiret2,

      get_0101_alv_data_ref
        RETURNING
          VALUE(robj_0101_alv_data_ref) TYPE REF TO zbr_makt_update_t_bapiret2,

      handle_hotspot_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
          e_row
          e_column
          es_row_no.

  PRIVATE SECTION.
    DATA:
        t_0101_alv_data_ref TYPE REF TO zbr_makt_update_t_bapiret2.
ENDCLASS.

CLASS zcl_0101_alv_event_receiver IMPLEMENTATION.
  METHOD constructor.
    t_0101_alv_data_ref = it_0101_alv_data_ref.
  ENDMETHOD.

  METHOD get_0101_alv_data_ref.
    robj_0101_alv_data_ref = t_0101_alv_data_ref.
  ENDMETHOD.

  METHOD handle_hotspot_click.
    DATA(lobj_0101_alv_data_ref) = get_0101_alv_data_ref( ).
    PERFORM 0101_handle_hotspot_click USING e_row
                                            e_column
                                            lobj_0101_alv_data_ref.
  ENDMETHOD.
ENDCLASS.