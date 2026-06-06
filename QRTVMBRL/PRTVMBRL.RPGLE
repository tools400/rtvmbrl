**free
//===============================================================*
//                                                               *
//  (c) 2000, Thomas Raddatz                                     *
//                                                               *
//  Bereich  : RTVMBRL                                           *
//  Exp.Liste: RTVMBRL_P                                         *
//  Typ      : RPGLE                                             *
//                                                               *
//  erstellt : 24.05.2000                                        *
//                                                               *
//===============================================================*
//                                                               *
//  Kurzdokumentation :                                          *
//                                                               *
//  Prototypen für Serviceprogramm RTVMBRL                       *
//                                                               *
//===============================================================*

//===============================================================*
//  Reference fields
//===============================================================*
dcl-s mbrLst_handle_t pointer based(pDummy);

//===============================================================*
//  Open List Of Database File Members
//===============================================================*

dcl-pr f_opnMbrLst ind opdesc extproc('RTVMBRLR1_f_opnMbrLst');
  i_fileName char(10) value;
  i_fileLib  char(10) value;
  i_mbr      char(10) value;
  i_orderBy  char(10) value;
  o_handle   like(mbrLst_handle_t);
  o_msg      char(32767) options(*nopass: *varsize);
end-pr;

//===============================================================*
//  Close List Of Database File Members
//===============================================================*

dcl-pr f_cloMbrLst ind extproc('RTVMBRLR1_f_cloMbrLst');
  io_handle like(mbrLst_handle_t);
end-pr;

//===============================================================*
//  Get First Member
//===============================================================*

dcl-pr f_getFirstMbr ind opdesc extproc('RTVMBRLR1_f_getFirstMbr');
  i_handle like(mbrLst_handle_t) value;
  o_data   char(32767) options(*varsize);
end-pr;

//===============================================================*
//  Get Next Member
//===============================================================*

dcl-pr f_getNextMbr ind opdesc extproc('RTVMBRLR1_f_getNextMbr');
  i_handle like(mbrLst_handle_t) value;
  o_data   char(32767) options(*varsize);
end-pr;

//===============================================================*
//  Get Number of Members available
//===============================================================*

dcl-pr f_getNumMbrAvl int(10) extproc('RTVMBRLR1_f_getNumMbrAvl');
  i_handle like(mbrLst_handle_t) value;
end-pr;

