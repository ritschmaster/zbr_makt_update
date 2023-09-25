*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

MODULE 0101_init OUTPUT.
  PERFORM 0101_init CHANGING g_0101_inited
                             gobj_0101_cc_alv
                             gobj_0101_alv
                             gt_0101_data_alv.
ENDMODULE.

MODULE 0101_status OUTPUT.
  PERFORM 0101_status.
ENDMODULE.
