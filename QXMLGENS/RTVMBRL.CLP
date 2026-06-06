/* -------------------------------------------------------------------------- */
/* RTVMBRL    - SCRIPT MEMBER                                                 */
/* Use commands  xmlgenINC (generate text for install pgm)                    */
/*               xmlgenMBR (to define source members                          */
/*               xmlgenCMD (execute qcmdexc at run time                       */
/* Put &TOLIB where you want user selected lib at run time.                   */
   DCL &TOLIB *CHAR 10
/* -------------------------------------------------------------------------- */
/* >>PRE-COMPILER<<                                                           */
/*   >>CRTCMD<<  XMLGEN  XMLSCRIPT(&SM) SCRIPTSRCF(&SL/&SF);                  */
/*   >>IMPORTANT<<                                                            */
/*     >>PARM<<  SRCTOFILE(&LI/QXML);                                         */
/*     >>PARM<<  XMLMBR(*SCRIPT);                                             */
/*     >>PARM<<  ENCODING('ISO-8859-1');                                      */
/*     >>PARM<<  AUTHOR('Thomas Raddatz');                                    */
/*   >>END-IMPORTANT<<                                                        */
/*   >>EXECUTE<<                                                              */
/* >>END-PRE-COMPILER<<                                                       */
/* -------------------------------------------------------------------------- */
             XMLGENINC  XINCLUDE(*YES)

             XMLGENVRS XSRCFILE(QRTVMBRL) XSRCLIB(RTVMBRLD) XSRCMBR(COPYRIGHT)

             XMLGENCND  XMSG('Create sample programs? (YES, NO)') +
                          XVALUES(YES NO) XVAR(&CRTTSTPGM)

             XMLGENSET  XVAR(&SRCFILE) XVALUE(QRTVMBRL)

/* ---------------------------------- */
/*  Deploy source member              */
/* ---------------------------------- */
             XMLGENMBR  XMBR(A_INSTALL ) XMBRATR(CLLE  ) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(CEELIB    ) XMBRATR(RPGLE) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(CLIB      ) XMBRATR(RPGLE) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(COPYRIGHT ) XMBRATR(CLLE  ) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*FILE  ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(GENLSTHDR ) XMBRATR(RPGLE) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(PRTVMBRL  ) XMBRATR(RPGLE) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(QUSLMBR   ) XMBRATR(RPGLE) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(RTVMBRL   ) XMBRATR(BND  ) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(RTVMBRL_T ) XMBRATR(RPGLE) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

             XMLGENMBR  XMBR(RTVMBRLR1 ) XMBRATR(RPGLE) +
                          XFROMSRCF(QRTVMBRL  ) XFROMSRCL(RTVMBRLD) +
                          XTOSRCF(QRTVMBRL  ) XOBJTYPE(*PGM   ) +
                          XGENCRT(*NO ) XPARAM(*BLANK)

/* ---------------------------------- */
/*  Create objects                    */
/* ---------------------------------- */
             XMLGENCMD  XCMD(CRTBNDCL PGM(&TOLIB/A_INSTALL) +
                          SRCFILE(&TOLIB/QRTVMBRL) SRCMBR(*PGM) +
                          DFTACTGRP(*NO) ACTGRP(*NEW) +
                          DBGVIEW(*LIST)) XDLTSPLF(A_INSTALL)

             XMLGENCMD  XCMD(CALL PGM(&TOLIB/A_INSTALL) +
                             PARM('&TGTRLS' '&SRCFILE' '&TOLIB' '&CRTTSTPGM'))
             XMLGENCMD  XCMD(DLTPGM PGM(&TOLIB/A_INSTALL))

