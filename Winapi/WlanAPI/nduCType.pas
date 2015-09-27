{*------------------------------------------------------------------------------
  C Typen Deklaration (Übersetztung der Variabeln von C in Delphi)
	@Author    nitschchedu
  @Version   1 Alpha
  @Todo      C Typen Convertation
-------------------------------------------------------------------------------}

unit nduCType;

interface

uses
	Windows, Classes;

type
	//*** Übersetztung der Variabeln von C in Delphi ***//
  //*** ------------------------------------------ ***//
  //C                 //Delphi        //Komentar
  //*** ------------------------------------------ ***//
	Bool 							= LongBool;  			///C Bool
  Int 							= Integer;				///C Int
  unsigned_short 		= Word;						///C unsigned short
  ushort						= Word;						///C ushort
  short							= Smallint;				///C short
  signed_short			= Smallint;				///C signed short
	UINT							= Cardinal;				///C UINT
  DWORD							= Cardinal;				///C DWORD
  unsigned_long			= Cardinal;				///C unsigned short
  unsigned_long_int	= Cardinal;				///C unsigned short int
  ulong							= Cardinal;				///C ULong
  long							= Longint;				///C Long
  signed_char				= Shortint;				///C signed char
  unsigned_char			= Byte;						///C unsigned char
  uchar							= Byte;						///C UChar
  LPSTR							= PChar;					///C LPSTR
  PSTR							= PChar;					///C PSTR
  //C Void (Gibt es nicht in Delphi) (ist ne procedure)
  //void							= Pointer;
  PVOID							= Pointer;				///C PVoid
  PPVOID						= ^PVOID;					///C ppvoid
  float							= Single;					///C float
  long_double				= Extended;				///C long double
  wchar							= WideChar;				///C WChar
  ulonglong					= TLargeInteger;	///C ulonglong
  LPCTSTR						= PWideChar;			///C LPCTSTR
  Handle						= THandle;				///C Handle
  LPByte						= PByte;					///C LPByte
  PLPCWSTR					= ^LPCWSTR;				///C PLPCWSTR
  PPByte						= ^PByte;					///C PPByte
  unsigned_int			= Cardinal;				///C unsigned int
  Punsigned_int			= ^unsigned_int;	///C unsigned int *
  unsigned					= Cardinal;				///C unsigned
  LPVOID						= Pointer;				///C LPVOID
  ULONG_PTR					= LongWord;				///C ULONG_PTR
  PTSTR 						= LPWSTR;					///C PTSTR
  PPTSTR 						= ^PTSTR;					///C PPTSTR
  int32							= Longint;				///C int32
  //*** ------------------------------------------ ***//
  //*** ------------------------------------------ ***//


  //*** ------------------------------------------ ***//
  //***	crtdefs.h																	 ***//
  Tndu_time32_t 		= long;						///C time32_t aus der crtdefs.h
  Tndu_errno_t 			= Integer;        ///C errno_t aus der crtdefs.h
  Tndu_size_t 			= Int64;          ///C size_t aus der crtdefs.h
  //*** ------------------------------------------ ***//
  //*** ------------------------------------------ ***//




  _SecHandle = record
    dwLower: ULONG_PTR;
    dwUpper: ULONG_PTR;
  end;

  SecHandle = _SecHandle;
	PSecHandle = ^SecHandle;

implementation

end.
