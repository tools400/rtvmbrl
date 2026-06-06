**free
//=====================================================================*
//  Author  :  Thomas Raddatz                                          *
//  Date    :  24.05.2000                                              *
//  E-mail  :  Thomas.Raddatz@Tools400.de                              *
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
//  06.06.2002  Th.Raddatz    Fixed problem that CEEGSI changed        *
//                            foreign storage becauce of a wrong       *
//                            prototype. (Forgotten FC parameter.)     *
//                                                                     *
//  26.09.2002  Th.Raddatz    Added DEFINE statements to the           *
//                            reference fields to prevent compiler     *
//                            error message RNF3316                    *
//                                                                     *
//  26.09.2002  Th.Raddatz    Changed how the API error message is     *
//                            is assigned to o_msg in routine          *
//                            f_opnMbrLst() to ensure proper value.    *
//                                                                     *
//  03.06.2003  Th.Raddatz    Changed service program to use a pointer *
//                            instead of a data structure as the       *
//                            handle.                                  *
//                            Added reference field for handle.        *
//                                                                     *
//  30.06.2003  Th.Raddatz    Changed definition of errCode parameter  *
//                            to use reference field.                  *
//                                                                     *
//  17.12.2008  Th.Raddatz    Changed program to /FREE and to use      *
//                            BASICS1. Removed external data structures*
//                            from distribution.                       *
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
//       >>PARM<< TGTRLS(V6R1M0);                                      *
//       >>PARM<< OPTION(*EVENTF);                                     *
//     >>END-COMPILE<<                                                 *
//                                                                     *
//     >>EXECUTE<<                                                     *
//                                                                     *
//   >>END-PRE-COMPILER<<                                              *
//=====================================================================*
ctl-opt nomain;
ctl-opt extbinint(*yes) bnddir('QC2LE');
ctl-opt datfmt(*iso) timfmt(*iso) debug(*yes);
/copy QRTVMBRL,COPYRIGHT
//=====================================================================*

//  Exported procedures
/copy QRTVMBRL,PRTVMBRL

//  Imported procedures
/copy QBASICS1,PBASICS1 Tools/400 Runtime Library
/copy QRTVMBRL,QUSLMBR List Database File members(QUSLMBR) API
/copy QRTVMBRL,CLIB Prototypes for C-Library
/copy QRTVMBRL,CEELIB Prototypes for CEE APIs
/copy QRTVMBRL,GENLSTHDR Generic List Header for List APIs

//  Type definitions
dcl-ds handle_t qualified based(pDummy);
  pUsrSpc  pointer;
  numE     int(10);
  reserved char(36);
end-ds;

//  Prototypen für interne Funktionen
dcl-pr f_getEntry ind;
  i_handle like(mbrLst_handle_t) value;
  o_data   char(32767) options(*varsize);
  i_length int(10) value;
end-pr;

dcl-pr f_mblSort ind;
  i_pUsrSpc pointer value;
  i_orderBy char(10) value;
  o_msg     likeds(msg_t);
end-pr;

dcl-pr f_mblSortByName int(10);
  i_pKey     pointer value;
  i_pElement pointer value;
end-pr;

dcl-pr f_mblSortByCrtDate int(10);
  i_pKey     pointer value;
  i_pElement pointer value;
end-pr;

dcl-pr cvtApiTmstmp timestamp;
  i_apiTmstmp char(13) value;
end-pr;

//==================================================================*
//  Open Member List
// -----------------------------------------------------------------
//  Using format:  MBRL0200
//==================================================================*
dcl-proc f_opnMbrLst export;
  dcl-pi *n ind opdesc;
    i_fileName char(10) value;
    i_fileLib  char(10) value;
    i_mbr      char(10) value;
    i_orderBy  char(10) value;
    o_handle   like(mbrLst_handle_t);
    o_msg      char(32767) options(*nopass: *varsize);
  end-pi;

//  Return value
  dcl-s o_isDone ind inz(cFalse);

//  Parameter positions
  dcl-c p_msg 6;

//  Fields for optional parameters
  dcl-ds msg likeds(msg_t) inz;

//  Helper fields
  dcl-s isUsrSpc ind inz;
  dcl-s pUsrSpc pointer inz;
  dcl-ds qUsrSpc likeds(qObj_t) inz;
  dcl-ds qFile likeds(qObj_t) inz;
  dcl-ds errCode likeds(errCode_t) inz;
  dcl-ds strInfMsg likeds(strInf_t) inz;

//  Handle
  dcl-ds handle likeds(handle_t) based(pHandle);
//-------------------------------------------------------------------

dou '1';

   // Produce temporary object name
   qUsrSpc = f_getTmpName();
   if (qUsrSpc.name = '');
      msg = f_newMsg('CPF9898'
                     : 'Temporary object name +
                        could not be produced.'
                     : cMsg_Escape
                     : 'QCPFMSG'
                     : '*LIBL');
      leave;
   endif;

   // Create user space
   if (not f_crtUsrSpc(qUsrSpc.name
                       : qUsrSpc.lib
                       : 'List Database File Members, MBRL0200, ' +
                          i_orderBy
                       : 65536
                       : 'TEMP'
                       : '*USE'
                       : msg));
      leave;
   endif;

   isUsrSpc = cTrue;

   // Retrieve member list
   qFile.name = i_fileName;
   qFile.lib  = i_fileLib;
   errCode = f_newApiErrCode(cTrue);
   QUSLMBR(qUsrSpc: 'MBRL0200': qFile: i_mbr: '0': errCode);

   if (f_isApiError(errCode));
      msg = f_cvtApiErrCodeToMsg(errCode);
      leave;
   endif;

   // Retrieve user space pointer
   pUsrSpc = f_rtvUsrSpcPtr(qUsrSpc.name: qUsrSpc.lib: msg);
   if (msg.ID <> cMSG_ID_OK);
      leave;
   endif;

   // Sort member list in user space
   if (not f_mblSort(pUsrSpc: i_orderBy: msg));
      leave;
   endif;

   // Produce handle
   pHandle = %alloc(%size(handle_t));
   clear handle;
   handle.pUsrSpc   = pUsrSpc;
   handle.numE      = 0;
   handle.reserved  = *ALLx'00';

   o_handle = pHandle;
   o_isDone = cTrue;
enddo;

if (not o_isDone and isUsrSpc);
   f_dltUsrSpc(qUsrSpc.name: qUsrSpc.lib);
   isUsrSpc = cFalse;
endif;

// Return message to caller
if (%parms() >= p_msg);
   CEEGSI(p_msg: strInfMsg.dataType
               : strInfMsg.curlen
               : strInfMsg.maxlen: *omit);
   %subst(o_msg: 1: strInfMsg.curlen) = msg;
endif;

return o_isDone;


end-proc;

//==================================================================*
//  Close Member List
//==================================================================*
dcl-proc f_cloMbrLst export;
  dcl-pi *n ind;
    io_handle like(mbrLst_handle_t);
  end-pi;

//  Return value
  dcl-s o_isDone ind inz(cFalse);

//  Handle
  dcl-ds handle likeds(handle_t) based(io_handle);

//  Generic List Header for List APIs
  dcl-ds genLstHdr likeds(genLstHdr_t) based(pGenLstHdr);

//  Input Parameter Section of QUSLMBR API
  dcl-ds inpSct likeds(QUSLMBR_inpParm_t) based(pInpSct);
//-------------------------------------------------------------------

// Get user space name
pGenLstHdr = handle.pUsrSpc;
pInpSct    = handle.pUsrSpc + genLstHdr.ofsInpSct;

// Delete user space
o_isDone = f_dltUsrSpc(inpSct.qUsrSpc.name: inpSct.qUsrSpc.lib);

// Clear handle data
handle = *ALLx'00';

// Free handle memory
dealloc(N) io_handle;

return o_isDone;


end-proc;

//==================================================================*
//  Get First Member
//==================================================================*
dcl-proc f_getFirstMbr export;
  dcl-pi *n ind opdesc;
    i_handle like(mbrLst_handle_t) value;
    o_data   char(32767) options(*varsize);
  end-pi;

//  Return value
  dcl-s o_isDone ind inz(cFalse);

//  Parameter positions
  dcl-c p_data 2;

//  Handle
  dcl-ds handle likeds(handle_t) based(i_handle);

//  Helper fields
  dcl-ds strInfData likeds(strInf_t) inz;
//-------------------------------------------------------------------

// Get length of o_data
CEEGSI(p_data: strInfData.datatype
             : strInfData.curlen
             : strInfData.maxlen
             : *omit);

// Get first entry
handle.numE = 0;

// Retrieve entry data
o_isDone = f_getEntry(i_handle: o_data: strInfData.curlen);

return o_isDone;


end-proc;

//==================================================================*
//  Get Next Member
//==================================================================*

dcl-proc f_getNextMbr export;
  dcl-pi *n ind opdesc;
    i_handle like(mbrLst_handle_t) value;
    o_data   char(32767) options(*varsize);
  end-pi;

//  Return value
  dcl-s o_isDone ind inz(cFalse);

//  Parameter positions
  dcl-c p_data 2;

//  Helper fields
  dcl-ds strInfData likeds(strInf_t) inz;
//-------------------------------------------------------------------

// Get length of o_data
CEEGSI(p_data: strInfData.datatype
             : strInfData.curlen
             : strInfData.maxlen
             : *omit);

// Retrieve entry data
o_isDone = f_getEntry(i_handle: o_data: strInfData.curlen);

return o_isDone;


end-proc;

//==================================================================*
//  Get Number of Members available
//==================================================================*

dcl-proc f_getNumMbrAvl export;
  dcl-pi *n int(10);
    i_handle like(mbrLst_handle_t) value;
  end-pi;

//  Handle
  dcl-ds handle likeds(handle_t) based(i_handle);

//  Generic List Header for List APIs
  dcl-ds genLstHdr likeds(genLstHdr_t) based(handle.pUsrSpc);
//-------------------------------------------------------------------

return genLstHdr.numE;


end-proc;

//==================================================================*
//  *** private ***
//  Get Entry
//==================================================================*
dcl-proc f_getEntry;
  dcl-pi *n ind;
    i_handle like(mbrLst_handle_t) value;
    o_data   char(32767) options(*varsize);
    i_length int(10) value;
  end-pi;

//  Deklarieren Funktionswert
  dcl-s o_isDone ind inz(cFalse);

//  Handle
  dcl-ds handle likeds(handle_t) based(i_handle);

//  Deklarieren Feld für Eintragsdaten
  dcl-s pDest pointer inz;
  dcl-s pSrc pointer inz;
  dcl-s count int(10) inz;

//  Generic List Header for List APIs
  dcl-ds genLstHdr likeds(genLstHdr_t) based(handle.pUsrSpc);
//-------------------------------------------------------------------

// Return to caller if there are no entries left
if (handle.numE >= genLstHdr.numE);
   o_isDone = cFalse;
   return o_isDone;
endif;

// Copy entry to o_data
pDest = %addr(o_data);
pSrc  = handle.pUsrSpc + genLstHdr.ofsLstSct   +
                         (handle.numE * genLstHdr.sizeE);

if (i_length < genLstHdr.sizeE);
   count = i_length;
else;
   count = genLstHdr.sizeE;
endif;

memCpy(pDest: pSrc: count);

// Increase number of entries returned
handle.numE = handle.numE + 1;

// Return return value
o_isDone = cTrue;

return o_isDone;


end-proc;

//==================================================================*
//  *** private ***
//  Sort User Space
//==================================================================*
dcl-proc f_mblSort;
  dcl-pi *n ind;
    i_pUsrSpc pointer value;
    i_orderBy char(10) value;
    o_msg     likeds(msg_t);
  end-pi;

//  Return value
  dcl-s o_isDone ind inz(cFalse);

//  Helper fields
  dcl-s pCompFunc pointer(*proc) inz;

//  Generic List Header for List APIs
  dcl-ds genLstHdr likeds(genLstHdr_t) based(i_pUsrSpc);
//-------------------------------------------------------------------

// Get address of sort procedure ...
select;

   // ... do not sort
when (i_orderBy = '*NONE');
   pCompFunc = *NULL;
   o_isDone = cTrue;
   o_msg    = f_newMsg(cMSG_ID_OK);

   // ... sortieren nach Name
when (i_orderBy = '*NAME');
   pCompFunc = %paddr('F_MBLSORTBYNAME');
   o_isDone = cTrue;
   o_msg    = f_newMsg(cMSG_ID_OK);

   // ... sortieren nach Erstellungsdatum
when (i_orderBy = '*CRTDATE');
   pCompFunc = %paddr('F_MBLSORTBYCRTDATE');
   o_isDone = cTrue;
   o_msg    = f_newMsg(cMSG_ID_OK);

   // ... unsupported sort value
other;
   pCompFunc = *NULL;
   o_isDone = cFalse;
   o_msg    = f_newMsg('CPF9898'
                : 'Value ' + %trim(i_orderBy) +
                   ' for parameter ''orderBy'' +
                   not supported'
                : cMsg_Escape
                : 'QCPFMSG'
                : '*LIBL');
endsl;

// Sort user space
if (pCompFunc <> *NULL);
   qsort(i_pUsrSpc + genLstHdr.ofsLstSct     // basing pointer
         : genLstHdr.numE                    // number of entries
         : genLstHdr.sizeE                   // length of entry
         : pCompFunc);                       // compare procedure
endif;

return o_isDone;


end-proc;

//==================================================================*
//  *** private ***
//  Member List: Sort By Name
//==================================================================*
dcl-proc f_mblSortByName;
  dcl-pi *n int(10);
    i_pKey     pointer value;
    i_pElement pointer value;
  end-pi;

//  Return value
  dcl-s o_result int(10) inz;

//  KEY entry
  dcl-ds key likeds(mbrl0200_t) based(i_pKey);

//  ELEMENT entry
  dcl-ds element likeds(mbrl0200_t) based(i_pElement);
//-------------------------------------------------------------------

select;
when (key.mbr < element.mbr);
   o_result = -1;
when (key.mbr > element.mbr);
   o_result =  1;
other;
   o_result =  0;
endsl;

return o_result;


end-proc;

//==================================================================*
//  *** private ***
//  Member List: Sort By Creation Date
//==================================================================*
dcl-proc f_mblSortByCrtDate;
  dcl-pi *n int(10);
    i_pKey     pointer value;
    i_pElement pointer value;
  end-pi;

//  Return value
  dcl-s o_result int(10) inz;

//  KEY entry
  dcl-ds key likeds(mbrl0200_t) based(i_pKey);

//  ELEMENT entry
  dcl-ds element likeds(mbrl0200_t) based(i_pElement);
//-------------------------------------------------------------------

select;
when (cvtApiTmstmp(key.crtDatTim) < cvtApiTmstmp(element.crtDatTim));
   o_result = -1;
when (cvtApiTmstmp(key.crtDatTim) > cvtApiTmstmp(element.crtDatTim));
   o_result =  1;
other;
   o_result =  0;
endsl;

return o_result;


end-proc;

//==================================================================*
//  *** private ***
//  Converts a given API timestamp to a RPG timestamp.
//==================================================================*
dcl-proc cvtApiTmstmp;
  dcl-pi *n timestamp;
    i_apiTmstmp char(13) value;
  end-pi;

//  Return value
  dcl-s timestamp timestamp inz;
//-------------------------------------------------------------------

timestamp = %date(%subst(i_apiTmstmp: 1: 7): *cymd0) +
            %time(%subst(i_apiTmstmp: 8: 6): *hms0 );

return timestamp;


end-proc;

