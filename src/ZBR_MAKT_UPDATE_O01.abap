*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

MODULE 0100_init OUTPUT.
  PERFORM 0100_init CHANGING g_0100_inited
                             gobj_0100_cc_alv
                             gobj_0100_alv
                             gt_0100_data_alv.
ENDMODULE.

MODULE 0100_status OUTPUT.
  PERFORM 0100_status.
ENDMODULE.
