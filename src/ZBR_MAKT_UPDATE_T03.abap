*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

CONSTANTS:
  gc_0100_cc_alv          TYPE char10 VALUE 'CC_ALV',
  gc_0100_tabname_alv     TYPE tabname VALUE 'ZBR_MAKT_UPDATE_S_DATA_ALV',
  gc_0100_save            TYPE syucomm VALUE 'SAVE',
  gc_0100_test            TYPE syucomm VALUE 'TEST',
  gc_0100_back            TYPE syucomm VALUE 'BACK',
  gc_0100_exit            TYPE syucomm VALUE 'EXIT',
  gc_0100_cancel          TYPE syucomm VALUE 'CANCEL',
  gc_0100_fieldname_maktx TYPE fieldname VALUE 'MAKTX'.

DATA:
  gt_0100_data_alv TYPE zbr_makt_update_t_data_alv,
  g_0100_okcode    TYPE sy-ucomm,
  g_0100_inited    TYPE flag,
  gobj_0100_cc_alv TYPE REF TO cl_gui_custom_container,
  gobj_0100_alv    TYPE REF TO cl_gui_alv_grid.
