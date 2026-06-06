**free
//=====================================================================*
//  Author  :  Thomas Raddatz                                          *
//  Date    :  24.05.2000                                              *
//  E-mail  :  thomas.raddatz@tools400.de                              *
//  Homepage:  www.tools400.de                                         *
//=====================================================================*
//                                                                     *
//  This software is free software, you can redistribute it and/or     *
//  modify it under the terms of the GNU General Public License (GPL)  *
//  as published by the Free Software Foundation.                      *
//                                                                     *
//  See GNU General Public License for details.                        *
//          http://www.opensource.org                                  *
//          http://www.opensource.org/licenses/gpl-license.html        *
//                                                                     *
//=====================================================================*
//  History:                                                           *
//                                                                     *
//  Datum       Name          Änderung                                 *
//  ----------  ------------  ---------------------------------------  *
//  26.09.2002  Th.Raddatz    Added reference field msg_t.             *
//                                                                     *
//  26.09.2002  Th.Raddatz    Added msg parameter to the f_opnMbrLst() *
//                            procedure call to get error message      *
//                            back to caller.                          *
//                                                                     *
//  17.12.2008  Th.Raddatz    Changed program to work with RTVMBRL 1.4.*
//                                                                     *
//=====================================================================*
//   >>PRE-COMPILER<<                                                  *
//                                                                     *
//     >>CRTCMD<<  CRTRPGMOD    MODULE(&LI/&OB) +                      *
//                              SRCFILE(&SL/&SF) +                     *
//                              SRCMBR(&SM);                           *
//                                                                     *
//     >>COMPILE<<                                                     *
//       >>PARM<< TRUNCNBR(*NO);                                       *
//       >>PARM<< DBGVIEW(*LIST);                                      *
//     >>END-COMPILE<<                                                 *
//                                                                     *
//     >>EXECUTE<<                                                     *
//                                                                     *
//     >>CMD<<     CRTPGM       PGM(&LI/&OB) +                         *
//                              MODULE(*PGM) +                         *
//                              BNDSRVPGM(&LI/RTVMBRL) +               *
//                              ACTGRP(*NEW) +                         *
//                              DETAIL(*BASIC);                        *
//                                                                     *
//   >>END-PRE-COMPILER<<                                              *
//=====================================================================*
ctl-opt extbinint(*yes);
ctl-opt datfmt(*iso) timfmt(*iso) debug(*yes);
//=====================================================================*

/copy QBASICS1,PBASICS1 Tools/400 Runtime Library
/copy QRTVMBRL,PRTVMBRL Retrieve Member List Service Program
/copy QRTVMBRL,QUSLMBR List Database File members(QUSLMBR) API

//  *ENTRY Parameterliste
dcl-pr RTVKEYL_T extpgm('RTVKEYL_T');
  gi_file_1 char(10) const;
  gi_file_2 char(10) const;
end-pr;

//  Prototypen für interne Funktionen
dcl-pr p_main;
  i_file_1 char(10) const;
  i_file_2 char(10) const;
end-pr;

//*******************************************************************
//  Hauptsteuerleiste des RPG
//*******************************************************************
dcl-pi RTVKEYL_T;
  gi_file_1 char(10) const;
  gi_file_2 char(10) const;
end-pi;

p_main(gi_file_1: gi_file_2);

*inlr = *on;

//==================================================================*
//  Main Prozedur
//  (so hat man auch in der "Hauptsteuerleiste" lokale Variablen)
//==================================================================*

dcl-proc p_main export;
  dcl-pi *n;
    i_file_1 char(10) const;
    i_file_2 char(10) const;
  end-pi;

//  Lokale Arbeitsfelder
  dcl-s isDone1 ind inz;
  dcl-s isDone2 ind inz;

  dcl-s handle1 like(mbrLst_handle_t) inz;
  dcl-s handle2 like(mbrLst_handle_t) inz;

  dcl-s data like(data_1) inz;

  dcl-ds data_1 likeds(mbrl0200_t) inz;
  dcl-ds data_2 likeds(mbrl0200_t) inz;

  dcl-ds screen_msg;
    blank1 char(3) inz;
    col1   char(10) inz;
    blank2 char(4) inz;
    col2   char(10) inz;
  end-ds;

  dcl-s ok char(1) inz;
  dcl-s msg like(msg_t) inz;

//-------------------------------------------------------------------

//  Ausgeben Überschrift
Clear screen_msg;
Dsply screen_msg;
Clear screen_msg;
col1 = 'n. Name:';
col2 = 'n. Datum:';
Dsply screen_msg;
Clear screen_msg;
col1 = *ALL'-';
col2 = *ALL'-';
Dsply screen_msg;

//  Öffnen der 1. Liste
isDone1 = f_opnMbrLst(i_file_1    :
                     '*LIBL'     :
                     '*ALL'      :
                     '*NAME'     :
                     handle1     :
                     msg         );

//  Öffnen der 2. Liste
isDone2 = f_opnMbrLst(i_file_2    :
                     '*LIBL'     :
                     '*ALL'      :
                     '*CRTDATE'  :
                     handle2     :
                     msg         );

//  Lesen 1. Eintrag der 1. Liste
isDone1 = f_getFirstMbr(handle1 :
                       data    );
If isDone1;
   data_1  = data;
Else;
   Clear data_1;
Endif;

//  Lesen 1. Eintrag der 2. Liste
isDone2 = f_getFirstMbr(handle2 :
                       data    );
If isDone2;
   data_2  = data;
Else;
   Clear data_2;
Endif;


Dow isDOne1 or isDone2;

   //  Anzeigen gelesene Einträge
   Reset screen_msg;
   col1 = data_1.mbr;
   col2 = data_2.mbr;
   Dsply screen_msg;

   //  Lesen weitere Einträge Liste 1
   isDone1 = f_getNextMbr(handle1  :
                        data      );
   If isDone1;
      data_1  = data;
   Else;
      Clear data_1;
   Endif;

   //  Lesen weitere Einträge Liste 2
   isDone2 = f_getNextMbr(handle2  :
                        data      );
   If isDone2;
      data_2  = data;
   Else;
      Clear data_2;
   Endif;
Enddo;

//  Anzeigen "Ende" Nachricht
Clear screen_msg;
col1 =
  %trim(%editc(f_getNumMbrAvl(handle1):'Z'));
col2 =
  %trim(%editc(f_getNumMbrAvl(handle2):'Z'));
Dsply screen_msg ok;

//  Schließen 1. Liste
isDone1 = f_cloMbrLst(handle1    );

//  Schließen 2. Liste
isDone2 = f_cloMbrLst(handle2    );

Return;

end-proc;

//==================================================================*

