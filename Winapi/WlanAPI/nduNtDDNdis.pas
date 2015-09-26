unit nduNtDDNdis;

interface

uses
	nduCType;

type
	Pndu_NDIS_OBJECT_HEADER = ^Tndu_NDIS_OBJECT_HEADER;
  Tndu_NDIS_OBJECT_HEADER = packed record
  	aType: uchar;
    Revision: uchar;
    Size: ushort;
  end;

implementation

end.
