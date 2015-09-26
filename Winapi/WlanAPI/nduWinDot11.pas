unit nduWinDot11;

interface

uses
	nduCType, nduWlanTypes, nduNtDDNdis;

type
	Tndu_DOT11_MAC_ADDRESS = array[0..5] of uchar;
  Pndu_DOT11_MAC_ADDRESS = ^Tndu_DOT11_MAC_ADDRESS;

  Pndu_DOT11_BSSID_LIST = ^Tndu_DOT11_BSSID_LIST;
  Tndu_DOT11_BSSID_LIST = record
  	//const NDU_DOT11_BSSID_LIST_REVISION_1 = 1;
    Header: Tndu_NDIS_OBJECT_HEADER;
    uNumOfEntries: ulong;
    uTotalNumOfEntries: ulong;
    BSSIDs: array[0..0] of Tndu_DOT11_MAC_ADDRESS;
  end;

  {$MINENUMSIZE 4}
  Pndu_DOT11_PHY_TYPE = ^Tndu_DOT11_PHY_TYPE;
  Tndu_DOT11_PHY_TYPE = (
  	dot11_phy_type_unknown = 0,
    dot11_phy_type_any = dot11_phy_type_unknown,
    dot11_phy_type_fhss = 1,
    dot11_phy_type_dsss = 2,
    dot11_phy_type_irbaseband = 3,
    dot11_phy_type_ofdm = 4,
    dot11_phy_type_hrdsss = 5,
    dot11_phy_type_erp = 6,
    dot11_phy_type_IHV_start = $80000000,
    dot11_phy_type_IHV_end = $ffffffff);

const
	NDU_DOT11_RATE_SET_MAX_LENGTH = 126; // 126 bytes

type
	Pndu_DOT11_RATE_SET = ^Tndu_DOT11_RATE_SET;
	Tndu_DOT11_RATE_SET = record
  	uRateSetLength: ulong;
    ucRateSet: array[0..NDU_DOT11_RATE_SET_MAX_LENGTH - 1] of uchar;
  end;

  Tndu_DOT11_COUNTRY_OR_REGION_STRING = array[0..2] of uchar;
  Pndu_DOT11_COUNTRY_OR_REGION_STRING = ^Tndu_DOT11_COUNTRY_OR_REGION_STRING;

  //.. wird noch weiter gehen

implementation

end.
