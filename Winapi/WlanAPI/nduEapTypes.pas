unit nduEapTypes;

interface

uses
	nduCType, Classes, Windows;

const
	NDU_eapPropCipherSuiteNegotiation 						= $00000001;
  NDU_eapPropMutualAuth													= $00000002;
  NDU_eapPropIntegrity													= $00000004;
  NDU_eapPropReplayProtection										= $00000008;
  NDU_eapPropConfidentiality                 		= $00000010;
  NDU_eapPropKeyDerivation											= $00000020;
  NDU_eapPropKeyStrength64											= $00000040;
  NDU_eapPropKeyStrength128											= $00000080;
  NDU_eapPropKeyStrength256											= $00000100;
  NDU_eapPropKeyStrength512											= $00000200;
  NDU_eapPropKeyStrength1024										= $00000400;
  NDU_eapPropDictionaryAttackResistance					= $00000800;
  NDU_eapPropFastReconnect											= $00001000;
  NDU_eapPropCryptoBinding											= $00002000;
  NDU_eapPropSessionDependence									= $00004000;
  NDU_eapPropFragmentation											= $00008000;
  NDU_eapPropChannelBinding											= $00010000;
  NDU_eapPropNap																= $00020000;
  NDU_eapPropStandalone													= $00040000;
  NDU_eapPropMppeEncryption											= $00080000;
  NDU_eapPropTunnelMethod												= $00100000;
  NDU_eapPropSupportsConfig											= $00200000;
  NDU_eapPropReserved														= $80000000;

  NDU_EAP_VALUENAME_PROPERTIES									= 'Properties';

type
	NDU_EAP_SESSIONID = DWORD;

  Tndu_EAP_TYPE = record
  	atype: Byte;
    dwVendorId: DWORD;
    dwVendorType: DWORD;
  end;

  Tndu_EAP_METHOD_TYPE = record
  	eapType: Tndu_EAP_TYPE;
    dwAuthorId: DWORD;
  end;

  Pndu_EAP_METHOD_INFO = ^Tndu_EAP_METHOD_INFO;
  Tndu_EAP_METHOD_INFO = record
  	eaptype: Tndu_EAP_METHOD_TYPE;
    pwszAuthorName: LPWSTR;
    pwszFriendlyName: LPWSTR;
    eapProperties: DWORD;
    pInnerMethodInfo: Pndu_EAP_METHOD_INFO;
  end;

  Tndu_EAP_METHOD_INFO_ARRAY = record
    dwNumberOfMethods: DWORD;
    pEapMethods: Pndu_EAP_METHOD_INFO;
  end;

  Tndu_EAP_ERROR = record
  	dwWinError: DWORD;
    atype: Tndu_EAP_METHOD_TYPE;
    dwReasonCode: DWORD;
    rootCauseGuid: TGUID;
    repairGuid: TGUID;
    helpLinkGuid: TGUID;

    pRootCauseString: LPWSTR;
    pRepairString: LPWSTR;
  end;

  //....

implementation

end.
