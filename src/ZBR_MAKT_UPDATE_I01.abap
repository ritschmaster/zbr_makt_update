*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

MODULE 0100_user_command INPUT.
  PERFORM 0100_user_command USING g_0100_okcode
                                  gobj_0100_alv
                                  gt_0100_data_alv.
ENDMODULE.
