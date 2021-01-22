unit nduWlanAPI;

interface

uses
  nduCType, nduL2cmn, nduWlanTypes, nduWinDot11, nduWinNT, Windows, nduEapTypes;

const
	NDU_WLAN_API_VERSION 						= 1;
  NDU_WLAN_MAX_NAME_LENGTH 				= NDU_L2_PROFILE_MAX_NAME_LENGTH;

  //Profil Flags
  NDU_WLAN_PROFILE_GROUP_POLICY		= $00000001;
  NDU_WLAN_PROFILE_USER						= $00000002;

  WLAN_SET_EAPHOST_DATA_ALL_USERS = $00000001;

  WLAN_MAX_PHY_TYPE_NUMBER	= 8;

type
	Pndu_WLAN_PROFILE_INFO = ^Tndu_WLAN_PROFILE_INFO;
	Tndu_WLAN_PROFILE_INFO = record
  	strProfileName: array[0..NDU_WLAN_MAX_NAME_LENGTH - 1] of wchar;
    dwFlags: DWORD;
  end;

  Pndu_DOT11_NETWORK = ^Tndu_DOT11_NETWORK;
  Tndu_DOT11_NETWORK = record
  	dot11Ssid: Tndu_DOT11_SSID;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
  end;

const
	NDU_DOT11_PSD_IE_MAX_DATA_SIZE 			= 220;		// 255 - 6 - 2 - FORMAT ID
  NDU_DOT11_PSD_IE_MAX_ENTRY_NUMBER		= 10; 		// 10 enties at most

type
	Pndu_WLAN_RAW_DATA = ^Tndu_WLAN_RAW_DATA;
	Tndu_WLAN_RAW_DATA = record
  	dwDataSize: DWORD;
    DataBlob: array[0..0] of Byte;
  end;

  Pndu_WLAN_RAW_DATA_LIST = ^Tndu_WLAN_RAW_DATA_LIST;
  PPndu_WLAN_RAW_DATA_LIST = ^Pndu_WLAN_RAW_DATA_LIST;
  Tndu_WLAN_RAW_DATA_LIST = record
  	dwTotalSize: DWORD;
    dwNumberOfItems: DWORD;
    case Integer of
    	0: (dwDataOffset: DWORD);
      1: (dwDataSize: DWORD);
  end;

  {$MINENUMSIZE 4}
  Pndu_WLAN_CONNECTION_MODE = ^Tndu_WLAN_CONNECTION_MODE;
  Tndu_WLAN_CONNECTION_MODE = (
  	wlan_connection_mode_profile = 0,
    wlan_connection_mode_temporary_profile,
    wlan_connection_mode_discovery_secure,
    wlan_connection_mode_discovery_unsecure,
    wlan_connection_mode_auto,
    wlan_connection_mode_invalid);

  Tndu_WLAN_REASON_CODE = DWORD;
  Pndu_WLAN_REASON_CODE = ^Tndu_WLAN_REASON_CODE;

const
	NDU_WLAN_REASON_CODE_SUCCESS 						= NDU_L2_REASON_CODE_SUCCESS;
  NDU_WLAN_REASON_CODE_UNKNOWN						= NDU_L2_REASON_CODE_UNKNOWN;

  NDU_WLAN_REASON_CODE_RANGE_SIZE					= NDU_L2_REASON_CODE_GROUP_SIZE;
  NDU_WLAN_REASON_CODE_BASE								= NDU_L2_REASON_CODE_DOT11_AC_BASE;

  NDU_WLAN_REASON_CODE_AC_BASE						= NDU_L2_REASON_CODE_DOT11_AC_BASE;

  NDU_WLAN_REASON_CODE_AC_CONNECT_BASE		=
  	(NDU_WLAN_REASON_CODE_AC_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE div 2);

  NDU_WLAN_REASON_CODE_AC_END							=
  	(NDU_WLAN_REASON_CODE_AC_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE - 1);


  NDU_WLAN_REASON_CODE_PROFILE_BASE				= NDU_L2_REASON_CODE_PROFILE_BASE;

  NDU_WLAN_REASON_CODE_PROFILE_CONNECT_BASE =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE div 2);

  NDU_WLAN_REASON_CODE_PROFILE_END				=
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE - 1);

  // range for MSM
	//
  NDU_WLAN_REASON_CODE_MSM_BASE 					= NDU_L2_REASON_CODE_DOT11_MSM_BASE;

  NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE 	=
  	(NDU_WLAN_REASON_CODE_MSM_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE div 2);

  NDU_WLAN_REASON_CODE_MSM_END						=
  	(NDU_WLAN_REASON_CODE_MSM_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE - 1);

  // range for MSMSEC
	//
  NDU_WLAN_REASON_CODE_MSMSEC_BASE				=
  	NDU_L2_REASON_CODE_DOT11_SECURITY_BASE;

  NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE div 2);

  NDU_WLAN_REASON_CODE_MSMSEC_END					=
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + NDU_WLAN_REASON_CODE_RANGE_SIZE - 1);

  // AC network incompatible reason codes
	//
  NDU_WLAN_REASON_CODE_NETWORK_NOT_COMPATIBLE =
  	(NDU_WLAN_REASON_CODE_AC_BASE + 1);
  NDU_WLAN_REASON_CODE_PROFILE_NOT_COMPATIBLE =
  	(NDU_WLAN_REASON_CODE_AC_BASE + 2);

  // AC connect reason code
	//
  NDU_WLAN_REASON_CODE_NO_AUTO_CONNECTION	=
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 1);
  NDU_WLAN_REASON_CODE_NOT_VISIBLE =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 2);
  NDU_WLAN_REASON_CODE_GP_DENIED =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 3);
  NDU_WLAN_REASON_CODE_USER_DENIED =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 4);
  NDU_WLAN_REASON_CODE_BSS_TYPE_NOT_ALLOWED =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 5);
  NDU_WLAN_REASON_CODE_IN_FAILED_LIST =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 6);
  NDU_WLAN_REASON_CODE_IN_BLOCKED_LIST =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 7);
  NDU_WLAN_REASON_CODE_SSID_LIST_TOO_LONG =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 8);
  NDU_WLAN_REASON_CODE_CONNECT_CALL_FAIL =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 9);
  NDU_WLAN_REASON_CODE_SCAN_CALL_FAIL =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 10);
  NDU_WLAN_REASON_CODE_NETWORK_NOT_AVAILABLE =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 11);
  NDU_WLAN_REASON_CODE_PROFILE_CHANGED_OR_DELETED =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 12);
  NDU_WLAN_REASON_CODE_KEY_MISMATCH =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 13);
  NDU_WLAN_REASON_CODE_USER_NOT_RESPOND =
  	(NDU_WLAN_REASON_CODE_AC_CONNECT_BASE + 14);

  // Profile validation errors
	//
  NDU_WLAN_REASON_CODE_INVALID_PROFILE_SCHEMA =
    (NDU_WLAN_REASON_CODE_PROFILE_BASE + 1);
  NDU_WLAN_REASON_CODE_PROFILE_MISSING =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 2);
  NDU_WLAN_REASON_CODE_INVALID_PROFILE_NAME =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 3);
  NDU_WLAN_REASON_CODE_INVALID_PROFILE_TYPE =
    (NDU_WLAN_REASON_CODE_PROFILE_BASE + 4);
  NDU_WLAN_REASON_CODE_INVALID_PHY_TYPE =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 5);
  NDU_WLAN_REASON_CODE_MSM_SECURITY_MISSING =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 6);
  NDU_WLAN_REASON_CODE_IHV_SECURITY_NOT_SUPPORTED =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 7);
  NDU_WLAN_REASON_CODE_IHV_OUI_MISMATCH =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 8);
  NDU_WLAN_REASON_CODE_IHV_OUI_MISSING =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 9);
  NDU_WLAN_REASON_CODE_IHV_SETTINGS_MISSING =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 10);
  NDU_WLAN_REASON_CODE_CONFLICT_SECURITY =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 11);
  NDU_WLAN_REASON_CODE_SECURITY_MISSING =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 12);
  NDU_WLAN_REASON_CODE_INVALID_BSS_TYPE =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 13);
  NDU_WLAN_REASON_CODE_INVALID_ADHOC_CONNECTION_MODE =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 14);
  NDU_WLAN_REASON_CODE_NON_BROADCAST_SET_FOR_ADHOC =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 15);
  NDU_WLAN_REASON_CODE_AUTO_SWITCH_SET_FOR_ADHOC =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 16);
  NDU_WLAN_REASON_CODE_AUTO_SWITCH_SET_FOR_MANUAL_CONNECTION =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 17);
  NDU_WLAN_REASON_CODE_IHV_SECURITY_ONEX_MISSING =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 18);
  NDU_WLAN_REASON_CODE_PROFILE_SSID_INVALID =
  	(NDU_WLAN_REASON_CODE_PROFILE_BASE + 19);

  // MSM network incompatible reasons
	//
  NDU_WLAN_REASON_CODE_UNSUPPORTED_SECURITY_SET_BY_OS =
  	(NDU_WLAN_REASON_CODE_MSM_BASE + 1);
  NDU_WLAN_REASON_CODE_UNSUPPORTED_SECURITY_SET =
  	(NDU_WLAN_REASON_CODE_MSM_BASE + 2);
  NDU_WLAN_REASON_CODE_BSS_TYPE_UNMATCH =
  	(NDU_WLAN_REASON_CODE_MSM_BASE + 3);
  NDU_WLAN_REASON_CODE_PHY_TYPE_UNMATCH =
  	(NDU_WLAN_REASON_CODE_MSM_BASE + 4);
  NDU_WLAN_REASON_CODE_DATARATE_UNMATCH =
  	(NDU_WLAN_REASON_CODE_MSM_BASE + 5);

  // MSM connection failure reasons, to be defined
	// failure reason codes
	//
  NDU_WLAN_REASON_CODE_USER_CANCELLED =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 1);
  NDU_WLAN_REASON_CODE_ASSOCIATION_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 2);
  NDU_WLAN_REASON_CODE_ASSOCIATION_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 3);
  NDU_WLAN_REASON_CODE_PRE_SECURITY_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 4);
  NDU_WLAN_REASON_CODE_START_SECURITY_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 5);
  NDU_WLAN_REASON_CODE_SECURITY_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 6);
  NDU_WLAN_REASON_CODE_SECURITY_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 7);
  NDU_WLAN_REASON_CODE_ROAMING_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 8);
  NDU_WLAN_REASON_CODE_ROAMING_SECURITY_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 9);
  NDU_WLAN_REASON_CODE_ADHOC_SECURITY_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 10);
  NDU_WLAN_REASON_CODE_DRIVER_DISCONNECTED =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 11);
  NDU_WLAN_REASON_CODE_DRIVER_OPERATION_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 12);
  NDU_WLAN_REASON_CODE_IHV_NOT_AVAILABLE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 13);
  NDU_WLAN_REASON_CODE_IHV_NOT_RESPONDING =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 14);
  NDU_WLAN_REASON_CODE_DISCONNECT_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 15);
  NDU_WLAN_REASON_CODE_INTERNAL_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 16);
  NDU_WLAN_REASON_CODE_UI_REQUEST_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSM_CONNECT_BASE + 17);

  // MSMSEC reason codes
	//
  NDU_WLAN_REASON_CODE_MSMSEC_MIN = NDU_WLAN_REASON_CODE_MSMSEC_BASE;
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_KEY_INDEX =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 1);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_PSK_PRESENT =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 2);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_KEY_LENGTH =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 3);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_PSK_LENGTH =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 4);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_NO_AUTH_CIPHER_SPECIFIED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 5);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_TOO_MANY_AUTH_CIPHER_SPECIFIED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 6);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_DUPLICATE_AUTH_CIPHER =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 7);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_RAWDATA_INVALID =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 8);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_AUTH_CIPHER =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 9);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_ONEX_DISABLED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 10);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_ONEX_ENABLED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 11);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_PMKCACHE_MODE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 12);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_PMKCACHE_SIZE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 13);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_PMKCACHE_TTL =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 14);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_PREAUTH_MODE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 15);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_PREAUTH_THROTTLE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 16);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_PREAUTH_ONLY_ENABLED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 17);
  NDU_WLAN_REASON_CODE_MSMSEC_CAPABILITY_NETWORK =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 18);
  NDU_WLAN_REASON_CODE_MSMSEC_CAPABILITY_NIC =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 19);
  NDU_WLAN_REASON_CODE_MSMSEC_CAPABILITY_PROFILE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 20);
  NDU_WLAN_REASON_CODE_MSMSEC_CAPABILITY_DISCOVERY =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 21);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_PASSPHRASE_CHAR =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 22);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_KEYMATERIAL_CHAR =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 23);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_WRONG_KEYTYPE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 24);
  NDU_WLAN_REASON_CODE_MSMSEC_MIXED_CELL =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 25);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_AUTH_TIMERS_INVALID =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 26);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_INVALID_GKEY_INTV =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 27);
  NDU_WLAN_REASON_CODE_MSMSEC_TRANSITION_NETWORK =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 28);
  NDU_WLAN_REASON_CODE_MSMSEC_PROFILE_KEY_UNMAPPED_CHAR =
  	(NDU_WLAN_REASON_CODE_MSMSEC_BASE + 29);


  NDU_WLAN_REASON_CODE_MSMSEC_UI_REQUEST_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 1);
  NDU_WLAN_REASON_CODE_MSMSEC_AUTH_START_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 2);
  NDU_WLAN_REASON_CODE_MSMSEC_AUTH_SUCCESS_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 3);
  NDU_WLAN_REASON_CODE_MSMSEC_KEY_START_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 4);
  NDU_WLAN_REASON_CODE_MSMSEC_KEY_SUCCESS_TIMEOUT =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 5);
  NDU_WLAN_REASON_CODE_MSMSEC_M3_MISSING_KEY_DATA =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 6);
  NDU_WLAN_REASON_CODE_MSMSEC_M3_MISSING_IE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 7);
  NDU_WLAN_REASON_CODE_MSMSEC_M3_MISSING_GRP_KEY =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 8);
  NDU_WLAN_REASON_CODE_MSMSEC_PR_IE_MATCHING =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 9);
  NDU_WLAN_REASON_CODE_MSMSEC_SEC_IE_MATCHING =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 10);
  NDU_WLAN_REASON_CODE_MSMSEC_NO_PAIRWISE_KEY =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 11);
  NDU_WLAN_REASON_CODE_MSMSEC_G1_MISSING_KEY_DATA =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 12);
  NDU_WLAN_REASON_CODE_MSMSEC_G1_MISSING_GRP_KEY =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 13);
  NDU_WLAN_REASON_CODE_MSMSEC_PEER_INDICATED_INSECURE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 14);
  NDU_WLAN_REASON_CODE_MSMSEC_NO_AUTHENTICATOR =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 15);
  NDU_WLAN_REASON_CODE_MSMSEC_NIC_FAILURE =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 16);
  NDU_WLAN_REASON_CODE_MSMSEC_CANCELLED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 17);
  NDU_WLAN_REASON_CODE_MSMSEC_KEY_FORMAT =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 18);
  NDU_WLAN_REASON_CODE_MSMSEC_DOWNGRADE_DETECTED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 19);
  NDU_WLAN_REASON_CODE_MSMSEC_PSK_MISMATCH_SUSPECTED =
  	(NDU_WLAN_REASON_CODE_MSMSEC_CONNECT_BASE + 20);

  NDU_WLAN_REASON_CODE_MSMSEC_MAX =	NDU_WLAN_REASON_CODE_MSMSEC_END;

type
	Tndu_WLAN_SIGNAL_QUALITY = ulong;
  Pndu_WLAN_SIGNAL_QUALITY = ^Tndu_WLAN_SIGNAL_QUALITY;

const
  NDU_WLAN_AVAILABLE_NETWORK_CONNECTED 		= $00000001;
  NDU_WLAN_AVAILABLE_NETWORK_HAS_PROFILE 	= $00000002;

  NDU_WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_ADHOC_PROFILES 	= $00000001;
  NDU_WLAN_AVAILABLE_NETWORK_INCLUDE_ALL_MANUAL_HIDDEN_PROFILES	= $00000002;

type
	Pndu_WLAN_RATE_SET = ^Tndu_WLAN_RATE_SET;
  Tndu_WLAN_RATE_SET = record
  	uRateSetLength: ulong;
    usRateSet: array[0..NDU_DOT11_RATE_SET_MAX_LENGTH - 1] of ushort;
  end;

	Pndu_WLAN_AVAILABLE_NETWORK = ^Tndu_WLAN_AVAILABLE_NETWORK;
  {
	Tndu_WLAN_AVAILABLE_NETWORK = record
    strProfileName: array[0..NDU_WLAN_MAX_NAME_LENGTH - 1] of wchar;
    dot11Ssid: Tndu_DOT11_SSID;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
    uNumberOfBssids: ulong;
    bNetworkConnectable: Bool;
    wlanNotConnectableReason: Tndu_WLAN_REASON_CODE;
    uDot11PhyType: ulong;
    wlanSignalQuality: Tndu_WLAN_SIGNAL_QUALITY;
    dot11RateSet: Tndu_DOT11_RATE_SET;
    bSecurityEnabled: Bool;
    dot11DefaultAuthAlgorithm: Tndu_DOT11_AUTH_ALGORITHM;
    dot11DefaultCipherAlgorithm: Tndu_DOT11_CIPHER_ALGORITHM;
    dwFlags: DWORD;
    dwReserved: DWORD;
  end;}

  Tndu_WLAN_AVAILABLE_NETWORK = record
    strProfileName: array[0..NDU_WLAN_MAX_NAME_LENGTH - 1] of wchar;
    dot11Ssid: Tndu_DOT11_SSID;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
    uNumberOfBssids: ulong;
    bNetworkConnectable: Bool;
    wlanNotConnectableReason: Tndu_WLAN_REASON_CODE;
    uNumberOfPhyTypes: ulong;
    dot11PhyTypes: array[0..WLAN_MAX_PHY_TYPE_NUMBER -1] of Tndu_DOT11_PHY_TYPE;
    bMorePhyTypes: Bool;
    wlanSignalQuality: Tndu_WLAN_SIGNAL_QUALITY;
    bSecurityEnabled: Bool;
    dot11DefaultAuthAlgorithm: Tndu_DOT11_AUTH_ALGORITHM;
    dot11DefaultCipherAlgorithm: Tndu_DOT11_CIPHER_ALGORITHM;
    dwFlags: DWORD;
    dwReserved: DWORD;
  end;

  Pndu_WLAN_BSS_ENTRY = ^Tndu_WLAN_BSS_ENTRY;
  Tndu_WLAN_BSS_ENTRY = record
    dot11Ssid: Tndu_DOT11_SSID;
    uPhyId: ulong;
    dot11Bssid: Tndu_DOT11_MAC_ADDRESS;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
    dot11BssPhyType: Tndu_DOT11_PHY_TYPE;
    lRssi: long;
    uLinkQuality: ulong;
    bInRegDomain: Boolean;
    usBeaconPeriod: ushort;
    ullTimestamp: ulonglong;
    ullHostTimestamp: ulonglong;
    usCapabilityInformation: ushort;
    ulChCenterFrequency: ulong;
    wlanRateSet: Tndu_WLAN_RATE_SET;
    ulIeOffset: ulong;
    ulIeSize: ulong;
  end;

  Pndu_WLAN_BSS_LIST = ^Tndu_WLAN_BSS_LIST;
  PPndu_WLAN_BSS_LIST	= ^Pndu_WLAN_BSS_LIST;
  Tndu_WLAN_BSS_LIST = record
    dwTotalSize: DWORD;
    dwNumberOfItems: DWORD;
    wlanBssEntries: array[0..0] of Tndu_WLAN_BSS_ENTRY;
  end;

  {$MINENUMSIZE 4}
  Pndu_WLAN_INTERFACE_STATE = ^Tndu_WLAN_INTERFACE_STATE;
  Tndu_WLAN_INTERFACE_STATE = (
  	wlan_interface_state_not_ready = 0,
    wlan_interface_state_connected,
    wlan_interface_state_ad_hoc_network_formed,
    wlan_interface_state_disconnecting,
    wlan_interface_state_disconnected,
    wlan_interface_state_associating,
    wlan_interface_state_discovering,
    wlan_interface_state_authenticating);

  Pndu_WLAN_INTERFACE_INFO = ^Tndu_WLAN_INTERFACE_INFO;
  Tndu_WLAN_INTERFACE_INFO = record
  	InterfaceGuid: TGUID;
    strInterfaceDescription: array[0..NDU_WLAN_MAX_NAME_LENGTH - 1] of wchar;
    isState: Tndu_WLAN_INTERFACE_STATE;
  end;

  Pndu_WLAN_ASSOCIATION_ATTRIBUTES = ^Tndu_WLAN_ASSOCIATION_ATTRIBUTES;
  Tndu_WLAN_ASSOCIATION_ATTRIBUTES = record
    dot11Ssid: Tndu_DOT11_SSID;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
    dot11Bssid: Tndu_DOT11_MAC_ADDRESS;
    dot11PhyType: Tndu_DOT11_PHY_TYPE;
    uDot11PhyIndex: ulong;
    wlanSignalQuality: Tndu_WLAN_SIGNAL_QUALITY;
    ulRxRate: ulong;
    ulTxRate: ulong;
  end;

  Pndu_WLAN_SECURITY_ATTRIBUTES = ^Tndu_WLAN_SECURITY_ATTRIBUTES;
  Tndu_WLAN_SECURITY_ATTRIBUTES = record
  	bSecurityEnabled: Bool;
    bOneXEnabled: Bool;
    dot11AuthAlgorithm: Tndu_DOT11_AUTH_ALGORITHM;
    dot11CipherAlgorithm: Tndu_DOT11_CIPHER_ALGORITHM;
  end;


  Pndu_WLAN_CONNECTION_ATTRIBUTES = ^Tndu_WLAN_CONNECTION_ATTRIBUTES;
  Tndu_WLAN_CONNECTION_ATTRIBUTES =  record
  	isState: Tndu_WLAN_INTERFACE_STATE;
    wlanConnectionMode: Tndu_WLAN_CONNECTION_MODE;
    strProfileName: array[0..NDU_WLAN_MAX_NAME_LENGTH - 1] of wchar;
    wlanAssociationAttributes: Tndu_WLAN_ASSOCIATION_ATTRIBUTES;
    wlanSecurityAttributes: Tndu_WLAN_SECURITY_ATTRIBUTES;
  end;

  {$MINENUMSIZE 4}
  Pndu_DOT11_RADIO_STATE = ^Tndu_DOT11_RADIO_STATE;
  Tndu_DOT11_RADIO_STATE = (
  	dot11_radio_state_unknown = 0,
    dot11_radio_state_on,
    dot11_radio_state_off);

const
	// the maximum number of PHYs supported by a NIC
	NDU_WLAN_MAX_PHY_INDEX = 63;

type
	Pndu_WLAN_PHY_RADIO_STATE = ^Tndu_WLAN_PHY_RADIO_STATE;
	Tndu_WLAN_PHY_RADIO_STATE = record
    dwPhyIndex: DWORD;
    dot11SoftwareRadioState: Tndu_DOT11_RADIO_STATE;
    dot11HardwareRadioState: Tndu_DOT11_RADIO_STATE;
  end;

  Pndu_WLAN_RADIO_STATE = ^Tndu_WLAN_RADIO_STATE;
  Tndu_WLAN_RADIO_STATE = record
  	dwNumberOfPhys: DWORD;
    PhyRadioState: array[0..NDU_WLAN_MAX_PHY_INDEX - 1] of Tndu_WLAN_PHY_RADIO_STATE;
  end;

  {$MINENUMSIZE 4}
  Pndu_WLAN_INTERFACE_TYPE = ^Tndu_WLAN_INTERFACE_TYPE;
  Tndu_WLAN_INTERFACE_TYPE = (
  	wlan_interface_type_emulated_802_11 = 0,
    wlan_interface_type_native_802_11,
    wlan_interface_type_invalid);

  Pndu_WLAN_INTERFACE_CAPABILITY = ^Tndu_WLAN_INTERFACE_CAPABILITY;
  PPndu_WLAN_INTERFACE_CAPABILITY = ^Pndu_WLAN_INTERFACE_CAPABILITY;
  Tndu_WLAN_INTERFACE_CAPABILITY = record
  	interfaceType: Tndu_WLAN_INTERFACE_TYPE;
    bDot11DSupported: Bool;
    dwMaxDesiredSsidListSize: DWORD;
    dwMaxDesiredBssidListSize: DWORD;
    dwNumberOfSupportedPhys: DWORD;
    dot11PhyTypes: array[0..NDU_WLAN_MAX_PHY_INDEX - 1] of Tndu_DOT11_PHY_TYPE;
  end;

  Pndu_WLAN_AUTH_CIPHER_PAIR_LIST = ^Tndu_WLAN_AUTH_CIPHER_PAIR_LIST;
  Tndu_WLAN_AUTH_CIPHER_PAIR_LIST = record
  	pAuthCipherPairList: array[0..0] of Tndu_DOT11_AUTH_CIPHER_PAIR;
  end;

  Pndu_WLAN_COUNTRY_OR_REGION_STRING_LIST = ^Tndu_WLAN_COUNTRY_OR_REGION_STRING_LIST;
  Tndu_WLAN_COUNTRY_OR_REGION_STRING_LIST = record
  	pCountryOrRegionStringList: array[0..0] of Tndu_DOT11_COUNTRY_OR_REGION_STRING;
  end;

  Pndu_WLAN_PROFILE_INFO_LIST = ^Tndu_WLAN_PROFILE_INFO_LIST;
  PPndu_WLAN_PROFILE_INFO_LIST = ^Pndu_WLAN_PROFILE_INFO_LIST;
  Tndu_WLAN_PROFILE_INFO_LIST = record
  	dwNumberOfItems: DWORD;
    dwIndex: DWORD;
    ProfileInfo: array[0..0] of Tndu_WLAN_PROFILE_INFO;
  end;

  Pndu_WLAN_AVAILABLE_NETWORK_LIST = ^Tndu_WLAN_AVAILABLE_NETWORK_LIST;
  PPndu_WLAN_AVAILABLE_NETWORK_LIST = ^Pndu_WLAN_AVAILABLE_NETWORK_LIST;
  Tndu_WLAN_AVAILABLE_NETWORK_LIST = record
  	dwNumberOfItems: DWORD;
    dwIndex: DWORD;
    Network: array[0..0] of Tndu_WLAN_AVAILABLE_NETWORK;
  end;

  Pndu_WLAN_INTERFACE_INFO_LIST = ^Tndu_WLAN_INTERFACE_INFO_LIST;
  PPndu_WLAN_INTERFACE_INFO_LIST = ^Pndu_WLAN_INTERFACE_INFO_LIST;
  Tndu_WLAN_INTERFACE_INFO_LIST = record
  	dwNumberOfItems: DWORD;
    dwIndex: DWORD;
    InterfaceInfo: array[0..0] of Tndu_WLAN_INTERFACE_INFO;
  end;

  Pndu_DOT11_NETWORK_LIST = ^Tndu_DOT11_NETWORK_LIST;
  PPndu_DOT11_NETWORK_LIST = ^Pndu_DOT11_NETWORK_LIST;
  Tndu_DOT11_NETWORK_LIST = record
  	dwNumberOfItems: DWORD;
    dwIndex: DWORD;
    Network: array[0..0] of Tndu_DOT11_NETWORK;
  end;

  {$MINENUMSIZE 4}
  Pndu_WLAN_POWER_SETTING = ^Tndu_WLAN_POWER_SETTING;
  Tndu_WLAN_POWER_SETTING = (
  	wlan_power_setting_no_saving = 0,
    wlan_power_setting_low_saving,
    wlan_power_setting_medium_saving,
    wlan_power_setting_maximum_saving,
    wlan_power_setting_invalid);

const
	NDU_WLAN_CONNECTION_HIDDEN_NETWORK 		= $00000001;
  NDU_WLAN_CONNECTION_ADHOC_JOIN_ONLY 	= $00000002;

type
	Pndu_WLAN_CONNECTION_PARAMETERS = ^Tndu_WLAN_CONNECTION_PARAMETERS;
	Tndu_WLAN_CONNECTION_PARAMETERS = record
  	wlanConnectionMode: Tndu_WLAN_CONNECTION_MODE;
    strProfile: LPCTSTR;
    pDot11Ssid: Pndu_DOT11_SSID;
    pDesiredBssidList: Pndu_DOT11_BSSID_LIST;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
    dwFlags: DWORD;
  end;

  Pndu_WLAN_MSM_NOTIFICATION_DATA = ^Tndu_WLAN_MSM_NOTIFICATION_DATA;
  Tndu_WLAN_MSM_NOTIFICATION_DATA = record
  	wlanConnectionMode: Tndu_WLAN_CONNECTION_MODE;
    strProfileName: array[0..NDU_WLAN_MAX_NAME_LENGTH - 1] of wchar;
    dot11Ssid: Tndu_DOT11_SSID;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
    dot11MacAddr: Tndu_DOT11_MAC_ADDRESS;
    bSecurityEnabled: Bool;
    bFirstPeer: Bool;
    bLastPeer: Bool;
    wlanReasonCode: Tndu_WLAN_REASON_CODE;
  end;

  Pndu_WLAN_CONNECTION_NOTIFICATION_DATA = ^Tndu_WLAN_CONNECTION_NOTIFICATION_DATA;
  Tndu_WLAN_CONNECTION_NOTIFICATION_DATA = record
  	wlanConnectionMode: Tndu_WLAN_CONNECTION_MODE;
    strProfileName: array[0..NDU_WLAN_MAX_NAME_LENGTH - 1] of wchar;
    dot11Ssid: Tndu_DOT11_SSID;
    dot11BssType: Tndu_DOT11_BSS_TYPE;
    bSecurityEnabled: Bool;
    wlanReasonCode: Tndu_WLAN_REASON_CODE;
    strProfileXml: array[0..0] of wchar;
  end;

const
	NDU_WLAN_NOTIFICATION_SOURCE_NONE = NDU_L2_NOTIFICATION_SOURCE_NONE;
  NDU_WLAN_NOTIFICATION_SOURCE_ALL 	= NDU_L2_NOTIFICATION_SOURCE_ALL;

  NDU_WLAN_NOTIFICATION_SOURCE_ACM	= NDU_L2_NOTIFICATION_SOURCE_WLAN_ACM;
  NDU_WLAN_NOTIFICATION_SOURCE_MSM	= NDU_L2_NOTIFICATION_SOURCE_WLAN_MSM;
  NDU_WLAN_NOTIFICATION_SOURCE_SECURITY	= NDU_L2_NOTIFICATION_SOURCE_WLAN_SECURITY;
  NDU_WLAN_NOTIFICATION_SOURCE_IHV	= NDU_L2_NOTIFICATION_SOURCE_WLAN_IHV;

type
	{$MINENUMSIZE 4}
	Pndu_WLAN_NOTIFICATION_ACM = ^Tndu_WLAN_NOTIFICATION_ACM;
	Tndu_WLAN_NOTIFICATION_ACM = (
  	wlan_notification_acm_start = NDU_L2_NOTIFICATION_CODE_PUBLIC_BEGIN,
    wlan_notification_acm_autoconf_enabled,
    wlan_notification_acm_autoconf_disabled,
    wlan_notification_acm_background_scan_enabled,
    wlan_notification_acm_background_scan_disabled,
    wlan_notification_acm_bss_type_change,
    wlan_notification_acm_power_setting_change,
    wlan_notification_acm_scan_complete,
    wlan_notification_acm_scan_fail,
    wlan_notification_acm_connection_start,
    wlan_notification_acm_connection_complete,
    wlan_notification_acm_connection_attempt_fail,
    wlan_notification_acm_filter_list_change,
    wlan_notification_acm_interface_arrival,
    wlan_notification_acm_interface_removal,
    wlan_notification_acm_profile_change,
    wlan_notification_acm_profile_name_change,
    wlan_notification_acm_profiles_exhausted,
    wlan_notification_acm_network_not_available,
    wlan_notification_acm_network_available,
    wlan_notification_acm_disconnecting,
    wlan_notification_acm_disconnected,
    wlan_notification_acm_end);

  {$MINENUMSIZE 4}
  Pndu_WLAN_NOTIFICATION_MSM = ^Tndu_WLAN_NOTIFICATION_MSM;
  Tndu_WLAN_NOTIFICATION_MSM = (
  	wlan_notification_msm_start = NDU_L2_NOTIFICATION_CODE_PUBLIC_BEGIN,
    wlan_notification_msm_associating,
    wlan_notification_msm_associated,
    wlan_notification_msm_authenticating,
    wlan_notification_msm_connected,
    wlan_notification_msm_roaming_start,
    wlan_notification_msm_roaming_end,
    wlan_notification_msm_radio_state_change,
    wlan_notification_msm_signal_quality_change,
    wlan_notification_msm_disassociating,
    wlan_notification_msm_disconnected,
    wlan_notification_msm_peer_join,
    wlan_notification_msm_peer_leave,
    wlan_notification_msm_end);

  {$MINENUMSIZE 4}
  Pndu_WLAN_NOTIFICATION_SECURITY = ^Tndu_WLAN_NOTIFICATION_SECURITY;
  Tndu_WLAN_NOTIFICATION_SECURITY = (
  	wlan_notification_security_start = NDU_L2_NOTIFICATION_CODE_PUBLIC_BEGIN,
    wlan_notification_security_end);

  Tndu_WLAN_NOTIFICATION_DATA = Tndu_L2_NOTIFICATION_DATA;
  Pndu_WLAN_NOTIFICATION_DATA = ^Tndu_WLAN_NOTIFICATION_DATA;

  Tndu_WLAN_NOTIFICATION_CALLBACK	= PVOID;
  Pndu_WLAN_NOTIFICATION_CALLBACK	= PVOID;

  {$MINENUMSIZE 4}
  Pndu_WLAN_OPCODE_VALUE_TYPE = ^Tndu_WLAN_OPCODE_VALUE_TYPE;
  Tndu_WLAN_OPCODE_VALUE_TYPE = (
  	wlan_opcode_value_type_query_only = 0,
    wlan_opcode_value_type_set_by_group_policy,
    wlan_opcode_value_type_set_by_user,
    wlan_opcode_value_type_invalid);

  {$MINENUMSIZE 4}
  Pndu_WLAN_INTF_OPCODE = ^Tndu_WLAN_INTF_OPCODE;
  Tndu_WLAN_INTF_OPCODE = (
  	wlan_intf_opcode_autoconf_start = $000000000,
    wlan_intf_opcode_autoconf_enabled,
    wlan_intf_opcode_background_scan_enabled,
    wlan_intf_opcode_media_streaming_mode,
    wlan_intf_opcode_radio_state,
    wlan_intf_opcode_bss_type,
    wlan_intf_opcode_interface_state,
    wlan_intf_opcode_current_connection,
    wlan_intf_opcode_channel_number,
    wlan_intf_opcode_supported_infrastructure_auth_cipher_pairs,
    wlan_intf_opcode_supported_adhoc_auth_cipher_pairs,
    wlan_intf_opcode_supported_country_or_region_string_list,
    wlan_intf_opcode_autoconf_end = $0fffffff,
    wlan_intf_opcode_msm_start = $10000100,
    wlan_intf_opcode_statistics,
    wlan_intf_opcode_rssi,
    wlan_intf_opcode_msm_end = $1fffffff,
    wlan_intf_opcode_security_start = $20010000,
    wlan_intf_opcode_security_end = $2fffffff,
    wlan_intf_opcode_ihv_start = $30000000,
    wlan_intf_opcode_ihv_end = $3fffffff);

  {$MINENUMSIZE 4}
  Pndu_WLAN_AUTOCONF_OPCODE = ^Tndu_WLAN_AUTOCONF_OPCODE;
  Tndu_WLAN_AUTOCONF_OPCODE = (
  	wlan_autoconf_opcode_start = 0,
    wlan_autoconf_opcode_show_denied_networks,
    wlan_autoconf_opcode_power_setting,
    wlan_autoconf_opcode_connect_with_all_user_profile_only,
    wlan_autoconf_opcode_end);

  {$MINENUMSIZE 4}
  Pndu_WLAN_IHV_CONTROL_TYPE = ^Tndu_WLAN_IHV_CONTROL_TYPE;
  Tndu_WLAN_IHV_CONTROL_TYPE = (
  	wlan_ihv_control_type_service,
    wlan_ihv_control_type_driver);

  {$MINENUMSIZE 4}
  Pndu_WLAN_FILTER_LIST_TYPE = ^Tndu_WLAN_FILTER_LIST_TYPE;
  Tndu_WLAN_FILTER_LIST_TYPE = (
  	wlan_filter_list_type_gp_permit,
    wlan_filter_list_type_gp_deny,
    wlan_filter_list_type_user_permit,
    wlan_filter_list_type_user_deny);

  Pndu_WLAN_PHY_FRAME_STATISTICS = ^Tndu_WLAN_PHY_FRAME_STATISTICS;
  Tndu_WLAN_PHY_FRAME_STATISTICS = record
  	ullTransmittedFrameCount: ulonglong;
    ullMulticastTransmittedFrameCount: ulonglong;
    ullFailedCount: ulonglong;
    ullRetryCount: ulonglong;
    ullMultipleRetryCount: ulonglong;
    ullMaxTXLifetimeExceededCount: ulonglong;
    ullTransmittedFragmentCount: ulonglong;
    ullRTSSuccessCount: ulonglong;
    ullRTSFailureCount: ulonglong;
    ullACKFailureCount: ulonglong;
    ullReceivedFrameCount: ulonglong;
    ullMulticastReceivedFrameCount: ulonglong;
    ullPromiscuousReceivedFrameCount: ulonglong;
    ullMaxRXLifetimeExceededCount: ulonglong;
    ullFrameDuplicateCount: ulonglong;
    ullReceivedFragmentCount: ulonglong;
    ullPromiscuousReceivedFragmentCount: ulonglong;
    ullFCSErrorCount: ulonglong;
  end;

  Pndu_WLAN_MAC_FRAME_STATISTICS = ^Tndu_WLAN_MAC_FRAME_STATISTICS;
  Tndu_WLAN_MAC_FRAME_STATISTICS = record
  	ullTransmittedFrameCount: ulonglong;
    ullReceivedFrameCount: ulonglong;
    ullWEPExcludedCount: ulonglong;
    ullTKIPLocalMICFailures: ulonglong;
    ullTKIPReplays: ulonglong;
    ullTKIPICVErrorCount: ulonglong;
    ullCCMPReplays: ulonglong;
    ullCCMPDecryptErrors: ulonglong;
    ullWEPUndecryptableCount: ulonglong;
    ullWEPICVErrorCount: ulonglong;
    ullDecryptSuccessCount: ulonglong;
    ullDecryptFailureCount: ulonglong;
  end;

  Pndu_WLAN_STATISTICS = ^Tndu_WLAN_STATISTICS;
  Tndu_WLAN_STATISTICS = record
  	ullFourWayHandshakeFailures: ulonglong;
    ullTKIPCounterMeasuresInvoked: ulonglong;
    ullReserved: ulonglong;
    MacUcastCounters: Tndu_WLAN_MAC_FRAME_STATISTICS;
    MacMcastCounters: Tndu_WLAN_MAC_FRAME_STATISTICS;
    dwNumberOfPhys: DWORD;
    PhyCounters: array[0..0] of Tndu_WLAN_PHY_FRAME_STATISTICS;
  end;

const
  NDU_WLAN_READ_ACCESS = (NDU_STANDARD_RIGHTS_READ or  NDU_FILE_READ_DATA);
  NDU_WLAN_EXECUTE_ACCESS = (NDU_WLAN_READ_ACCESS or
  	NDU_STANDARD_RIGHTS_EXECUTE or NDU_FILE_EXECUTE);
  NDU_WLAN_WRITE_ACCESS = (NDU_WLAN_READ_ACCESS or NDU_WLAN_EXECUTE_ACCESS or
  	NDU_STANDARD_RIGHTS_WRITE or NDU_FILE_WRITE_DATA or NDU_DELETE or
    NDU_WRITE_DAC);

type
	{$MINENUMSIZE 4}
	Pndu_WLAN_SECURABLE_OBJECT = ^Tndu_WLAN_SECURABLE_OBJECT;
  Tndu_WLAN_SECURABLE_OBJECT = (
  	wlan_secure_permit_list = 0,
    wlan_secure_deny_list,
    wlan_secure_ac_enabled,
    wlan_secure_bc_scan_enabled,
    wlan_secure_bss_type,
    wlan_secure_show_denied,
    wlan_secure_interface_properties,
    wlan_secure_ihv_control,
    wlan_secure_all_user_profiles_order,
    wlan_secure_sso,
    wlan_secure_add_new_all_user_profiles,
    wlan_secure_add_new_per_user_profiles,
    wlan_secure_manual_connect_single_user,
    wlan_secure_manual_connect_multi_user,
    wlan_secure_media_streaming_mode_enabled,
    NDU_WLAN_SECURABLE_OBJECT_COUNT);

const
	wlan_api_dll = 'wlanapi.dll';

	function WlanOpenHandle(dwClientVersion: DWORD; pReserved: PVOID;
  	pdwNegotiatedVersion: PWord; phClientHandle: PHandle): DWORD; stdcall;

  function WlanCloseHandle(hClientHandle: Handle;
  	pReserved: PVOID): DWORD; stdcall;

	function WlanEnumInterfaces(hClientHandle: Handle;
  	pReserved: PVOID; ppInterfaceList: PPndu_WLAN_INTERFACE_INFO_LIST
    ): DWORD; stdcall;

  function WlanSetAutoConfigParameter(hClientHandle: Handle;
  	OpCode: Tndu_WLAN_AUTOCONF_OPCODE; dwDataSize: DWORD;
    const pData: PVOID; pReserved: PVOID): DWORD; stdcall;

  function WlanQueryAutoConfigParameter(hClientHandle: Handle;
  	OpCode: Tndu_WLAN_AUTOCONF_OPCODE; pReserved: PVOID;
    pdwDataSize: PDWORD; ppData: PPVOID;
    pWlanOpcodeValueType: Pndu_WLAN_OPCODE_VALUE_TYPE): DWORD; stdcall;

  function WlanGetInterfaceCapability(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; pReserved: PVOID;
    ppCapability: PPndu_WLAN_INTERFACE_CAPABILITY): DWORD; stdcall;

  function WlanSetInterface(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; OpCode: Tndu_WLAN_INTF_OPCODE;
    dwDataSize: DWORD; const pData: PVOID; pReserved: PVOID): DWORD; stdcall;

  function WlanQueryInterface(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; OpCode: Tndu_WLAN_INTF_OPCODE;
    pReserved: PVOID; pdwDataSize: PDWORD; ppData: PPVOID;
    pWlanOpcodeValueType: Pndu_WLAN_OPCODE_VALUE_TYPE): DWORD; stdcall;

  function WlanIhvControl(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; aType: Tndu_WLAN_IHV_CONTROL_TYPE;
    dwInBufferSize: DWORD; pInBuffer: pvoid; dwOutBufferSize: DWORD;
    pOutBuffer: PVOID): DWORD; stdcall;

  function WlanScan(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; const pDot11Ssid: Pndu_DOT11_SSID;
    const pIeData: Pndu_WLAN_RAW_DATA; pReserved: PVOID): DWORD; stdcall;

	function WlanGetAvailableNetworkList(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; dwFlags: DWORD; pReserved: PVOID;
    var pAvailableNetworkList: Pndu_WLAN_AVAILABLE_NETWORK_LIST): DWORD; stdcall;

  function WlanGetNetworkBssList(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; const pDot11Ssid: Pndu_DOT11_SSID;
    dot11BssType: Tndu_DOT11_BSS_TYPE; bSecurityEnabled: BOOL;
    pReserved: PVOID; ppWlanBssList: PPndu_WLAN_BSS_LIST): DWORD; stdcall;

  function WlanConnect(hClientHandle: Handle; const pInterfaceGuid: PGUID;
  	const pConnectionParameters: Pndu_WLAN_CONNECTION_PARAMETERS;
    pReserved: PVOID): DWORD; stdcall;

  function WlanDisconnect(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; pReserved: PVOID): DWORD; stdcall;

  function WlanRegisterNotification(hClientHandle: Handle;
  	dwNotifSource: DWORD; bIgnoreDuplicate: Bool;
    funcCallback: Tndu_WLAN_NOTIFICATION_CALLBACK;
    pCallbackContext: PVOID; pReserved: PVOID;
    pdwPrevNotifSource: PDWORD): DWORD; stdcall;

  function WlanGetProfile(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    pReserved: PVOID; pstrProfileXml: LPWSTR; pdwFlags: PDWORD;
    pdwGrantedAccess: PDWORD): DWORD; stdcall;

  function WlanSetProfileEapUserData(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    eapType: Tndu_EAP_METHOD_TYPE; dwFlags: DWORD;
    dwEapUserDataSize: DWORD; const pbEapUserData: LPByte;
    pReserved: PVOID): DWORD; stdcall;

  function WlanSetProfileEapXMLUserData(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    eapType: Tndu_EAP_METHOD_TYPE; dwFlags: DWORD;
    strEapXMLUserData: LPCWSTR; pReserved: PVOID): DWORD; stdcall;

  function WlanSetProfile(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; dwFlags: DWORD; strProfileXml: LPCWSTR;
    strAllUserProfileSecurity: LPCWSTR;
    bOverwrite: Bool; pReserved: PVOID;
    pdwReasonCode: PDWORD): DWORD; stdcall;

  function WlanDeleteProfile(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    pReserved: PVOID): DWORD; stdcall;

  function WlanRenameProfile(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strOldProfileName: LPCWSTR;
    strNewProfileName: LPCWSTR; pReserved: PVOID): DWORD; stdcall;

  function WlanGetProfileList(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; pReserved: PVOID;
    ppProfileList: PPndu_WLAN_PROFILE_INFO_LIST): DWORD; stdcall;

  function WlanSetProfileList(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; dwItems: DWORD;
    strProfileNames: LPCWSTR; pReserved: PVOID): DWORD; stdcall;

  function WlanSetProfilePosition(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    dwPosition: DWORD; pReserved: PVOID): DWORD; stdcall;

  function WlanSetProfileCustomUserData(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    dwDataSize: DWORD; const pData: LPByte;
    pReserved: PVOID): DWORD; stdcall;

  function WlanGetProfileCustomUserData(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    pReserved: PVOID; pdwDataSize: PDWORD; ppData: PPByte): DWORD; stdcall;

  function WlanSetFilterList(hClientHandle: Handle;
  	wlanFilterListType: Tndu_WLAN_FILTER_LIST_TYPE;
    const pNetworkList: Pndu_DOT11_NETWORK_LIST;
    pReserved: PVOID): DWORD; stdcall;

  function WlanGetFilterList(hClientHandle: Handle;
  	wlanFilterListType: Tndu_WLAN_FILTER_LIST_TYPE;
    pReserved: PVOID; ppNetworkList: PPndu_DOT11_NETWORK_LIST): DWORD; stdcall;

  function WlanSetPsdIEDataList(hClientHandle: Handle; strFormat: LPCWSTR;
    const pPsdIEDataList: Pndu_WLAN_RAW_DATA_LIST;
    pReserved: pvoid): DWORD; stdcall;

  function WlanSaveTemporaryProfile(hClientHandle: Handle;
  	const pInterfaceGuid: PGUID; strProfileName: LPCWSTR;
    strAllUserProfileSecurity: LPCWSTR; dwFlags: DWORD;
    bOverWrite: Bool; pReserved: PVOID): DWORD; stdcall;

  function WlanExtractPsdIEDataList(hClientHandle: Handle;
  	dwIeDataSize: DWORD; const pRawIeData: PByte;
    strFormat: LPCWSTR; pReserved: PVOID;
    ppPsdIEDataList: PPndu_WLAN_RAW_DATA_LIST): DWORD; stdcall;

	function WlanReasonCodeToString(dwReasonCode: DWORD;
  	dwBufferSize: DWORD; pStringBuffer: PWChar;
    pReserved: PVOID): DWORD; stdcall;

  function WlanAllocateMemory(dwMemorySize: DWORD): pvoid; stdcall;

	function WlanFreeMemory(pMemory: PVOID): PVOID; stdcall;

  function WlanSetSecuritySettings(hClientHandle: Handle;
  	SecurableObject: Tndu_WLAN_SECURABLE_OBJECT;
    strModifiedSDDL: LPCWSTR): DWORD; stdcall;

  function WlanGetSecuritySettings(hClientHandle: Handle;
  	SecurableObject: Tndu_WLAN_SECURABLE_OBJECT;
    pstrCurrentSDDL: PLPWSTR; pdwGrantedAccess: PWORD): DWORD; stdcall;

const
	NDU_WLAN_UI_API_VERSION 					= 1;
  NDU_WLAN_UI_API_INITIAL_VERSION		= 1;

type
	Pndu_WL_DISPLAY_PAGES = ^Tndu_WL_DISPLAY_PAGES;
	Tndu_WL_DISPLAY_PAGES = (
  	WLConnectionPage,
		WLSecurityPage);

  function WlanUIEditProfile(dwClientVersion: DWORD;
  	wstrProfileName: LPCWSTR; pInterfaceGuid: PGUID;
    hWnd: HWND; wlStartPage: Tndu_WL_DISPLAY_PAGES;
    pReserved: PVOID; pWlanReasonCode: Pndu_WLAN_REASON_CODE): DWORD; stdcall;


implementation

	function WlanOpenHandle;								external  wlan_api_dll	name	'WlanOpenHandle';
  function WlanCloseHandle;								external	wlan_api_dll	name	'WlanCloseHandle';
  function WlanEnumInterfaces; 						external	wlan_api_dll	name	'WlanEnumInterfaces';
  function WlanSetAutoConfigParameter;		external	wlan_api_dll	name	'WlanSetAutoConfigParameter';
  function WlanQueryAutoConfigParameter;  external	wlan_api_dll	name	'WlanQueryAutoConfigParameter';
  function WlanGetInterfaceCapability;		external	wlan_api_dll	name	'WlanGetInterfaceCapability';
  function WlanSetInterface;							external	wlan_api_dll	name	'WlanSetInterface';
  function WlanQueryInterface;						external	wlan_api_dll	name	'WlanQueryInterface';
  function WlanIhvControl;								external	wlan_api_dll	name	'WlanIhvControl';
  function WlanScan;											external	wlan_api_dll	name	'WlanScan';
  function WlanGetAvailableNetworkList;		external	wlan_api_dll	name	'WlanGetAvailableNetworkList';
  function WlanGetNetworkBssList;					external	wlan_api_dll	name	'WlanGetNetworkBssList';
  function WlanConnect;										external	wlan_api_dll	name	'WlanConnect';
  function WlanDisconnect;								external	wlan_api_dll	name	'WlanDisconnect';
  function WlanRegisterNotification;			external	wlan_api_dll	name	'WlanRegisterNotification';	
  function WlanGetProfile;								external	wlan_api_dll	name	'WlanGetProfile';
  function WlanSetProfileEapUserData;			external	wlan_api_dll	name	'WlanSetProfileEapUserData';
  function WlanSetProfileEapXMLUserData;	external	wlan_api_dll	name	'WlanSetProfileEapXMLUserData';
  function WlanSetProfile;								external	wlan_api_dll	name	'WlanSetProfile';
  function WlanDeleteProfile;							external	wlan_api_dll	name	'WlanDeleteProfile';
  function WlanRenameProfile;							external	wlan_api_dll	name	'WlanRenameProfile';
  function WlanGetProfileList;						external	wlan_api_dll	name	'WlanGetProfileList';
  function WlanSetProfileList;						external	wlan_api_dll	name	'WlanSetProfileList';
  function WlanSetProfilePosition;				external	wlan_api_dll	name	'WlanSetProfilePosition';
  function WlanSetProfileCustomUserData;	external  wlan_api_dll	name 	'WlanSetProfileCustomUserData';
  function WlanGetProfileCustomUserData;	external	wlan_api_dll	name	'WlanGetProfileCustomUserData';
  function WlanSetFilterList;							external	wlan_api_dll	name	'WlanSetFilterList';
  function WlanGetFilterList;							external	wlan_api_dll	name	'WlanGetFilterList';
  function WlanSetPsdIEDataList;					external	wlan_api_dll	name	'WlanSetPsdIEDataList';
  function WlanSaveTemporaryProfile;			external	wlan_api_dll	name	'WlanSaveTemporaryProfile';
  function WlanExtractPsdIEDataList;			external	wlan_api_dll	name	'WlanExtractPsdIEDataList';
  function WlanReasonCodeToString;				external	wlan_api_dll	name	'WlanReasonCodeToString';
  function WlanAllocateMemory;						external	wlan_api_dll	name	'WlanAllocateMemory';
  function WlanFreeMemory;								external	wlan_api_dll	name	'WlanFreeMemory';
  function WlanSetSecuritySettings;				external	wlan_api_dll	name	'WlanSetSecuritySettings';
  function WlanGetSecuritySettings;				external	wlan_api_dll	name	'WlanGetSecuritySettings';
  function WlanUIEditProfile;							external	wlan_api_dll	name	'WlanUIEditProfile';

end.
