unit IpHelperApi;

interface

uses
Windows;

const
   ANY_SIZE = 1;
   iphlpapi = 'iphlpapi.dll';
   TCP_TABLE_OWNER_PID_ALL = 5;

   MIB_TCP_STATE:
   array[1..12] of string = ('CLOSED', 'LISTEN', 'SYN-SENT ','SYN-RECEIVED', 'ESTABLISHED', 'FIN-WAIT-1',
                             'FIN-WAIT-2', 'CLOSE-WAIT', 'CLOSING','LAST-ACK', 'TIME-WAIT', 'delete TCB');

type
   TCP_TABLE_CLASS = Integer;

  PMibTcpRowOwnerPid = ^TMibTcpRowOwnerPid;
  TMibTcpRowOwnerPid  = packed record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwOwningPid: DWORD;
    end;


  PMIB_TCPTABLE_OWNER_PID  = ^MIB_TCPTABLE_OWNER_PID;
  MIB_TCPTABLE_OWNER_PID = packed record
   dwNumEntries: DWord;
   table: array [0..ANY_SIZE - 1] OF TMibTcpRowOwnerPid;
  end;

var
   GetExtendedTcpTable:function  (pTcpTable: Pointer; dwSize: PDWORD; bOrder: BOOL; lAf: ULONG; TableClass: TCP_TABLE_CLASS; Reserved: ULONG): DWord; stdcall;


implementation

end.
