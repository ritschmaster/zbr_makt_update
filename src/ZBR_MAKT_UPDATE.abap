*-----------------------------------------------------------------------------*
* ZBR_MAKT_UPDATE: Update material descriptions
*-----------------------------------------------------------------------------*
*
* Creator: Richard Bäck <richard.baeck@icloud.com>
* Date: 2023-07-04
*
*-----------------------------------------------------------------------------*
*
* Subroutines within this report must be maintained as functions. I.e. values
* that are passed in "CHANGING" parameters INTO the function must be ignored
* and cleared/overwritten.
*
* If a global variable must be used, then the usage must be documented in the
* function header and in the header of the include containing the function.
*
*-----------------------------------------------------------------------------*

REPORT zbr_makt_update.

INCLUDE zbr_makt_update_t01.
INCLUDE zbr_makt_update_t02.
INCLUDE zbr_makt_update_t03.
INCLUDE zbr_makt_update_t04.
INCLUDE zbr_makt_update_s01.
INCLUDE zbr_makt_update_c01.
INCLUDE zbr_makt_update_c02.
INCLUDE zbr_makt_update_f01.
INCLUDE zbr_makt_update_f02.
INCLUDE zbr_makt_update_f03.
INCLUDE zbr_makt_update_o01.
INCLUDE zbr_makt_update_o02.
INCLUDE zbr_makt_update_i01.
INCLUDE zbr_makt_update_i02.

START-OF-SELECTION.
  PERFORM main USING s_matnr[].