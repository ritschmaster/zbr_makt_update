*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

CONSTANTS:
  gc_0101_cc_alv      TYPE char10 VALUE 'CC_ALV',
  gc_0101_tabname_alv TYPE tabname VALUE 'ZBR_MAKT_UPDATE_S_BAPIRET2',
  gc_0101_back        TYPE syucomm VALUE 'BACK',
  gc_0101_exit        TYPE syucomm VALUE 'EXIT',
  gc_0101_cancel      TYPE syucomm VALUE 'CANCEL'.

DATA:
  gt_0101_data_alv TYPE zbr_makt_update_t_bapiret2,
  g_0101_okcode    TYPE sy-ucomm,
  g_0101_inited    TYPE flag,
  gobj_0101_cc_alv TYPE REF TO cl_gui_custom_container,
  gobj_0101_alv    TYPE REF TO cl_gui_alv_grid.
