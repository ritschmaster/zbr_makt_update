*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

MODULE 0101_user_command INPUT.
  PERFORM 0101_user_command USING g_0101_okcode
                                  gobj_0101_alv
                                  gt_0101_data_alv.
ENDMODULE.
