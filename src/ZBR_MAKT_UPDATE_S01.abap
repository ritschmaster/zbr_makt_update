*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* For more information see the report ZBR_MAKT_UPDATE.
*
*-----------------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-bl1.

  SELECT-OPTIONS: s_matnr FOR gs_mara-matnr MODIF ID bl1.

SELECTION-SCREEN END OF BLOCK bl1.
