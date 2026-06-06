**free
/if NOT defined(QUSLMBR)
/define QUSLMBR

//  List Database File Members (QUSLMBR) API
dcl-pr QUSLMBR extpgm('QUSLMBR');
  i_qUsrSpc  char(20) const;
  i_format   char(8) const;
  i_qFile    char(20) const;
  i_mbr      char(10) const;
  i_ovrPrc   char(1) const;
  io_errCode char(65535) options(*nopass: *varsize);
end-pr;

//  Input Parameter Section
dcl-ds QUSLMBR_inpParm_t qualified based(pDummy);
  qUsrSpc likeds(qObj_t);
  format  char(8);
  qFile   likeds(qObj_t);
  mbr     char(10);
  ovrOrc  char(1);
end-ds;

//  Header Section
dcl-ds QUSLMBR_header_t qualified based(pDummy);
  qFileUsed  likeds(qObj_t);
  fileAttr   char(10);
  text       char(50);
  numMbr     int(10);
  isSrcFile  ind;
  reserved_1 char(3);
  textCcsid  uns(10);
end-ds;

//  MBRL0100 List Data Section
dcl-ds mbrl0100_t qualified based(pDummy);
  mbr char(10);
end-ds;

//  MBRL0200 List Data Section
dcl-ds mbrl0200_t qualified based(pDummy);
  mbr       char(10);
  srcType   char(10);
  crtDatTim char(13);
  chgDatTim char(13);
  text      char(50);
  textCcsid uns(10);
end-ds;

/endif
