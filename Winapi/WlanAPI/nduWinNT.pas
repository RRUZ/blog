{ Übersetztung aus der WinNT.h
}
unit nduWinNT;

interface

const
	//...
	NDU_DELETE       	= $00010000;
  NDU_READ_CONTROL 	= $00020000;

  NDU_STANDARD_RIGHTS_READ		= (NDU_READ_CONTROL);
  NDU_STANDARD_RIGHTS_WRITE		= (NDU_READ_CONTROL);
  NDU_STANDARD_RIGHTS_EXECUTE	= (NDU_READ_CONTROL);

  //..

  NDU_FILE_READ_DATA					= $0001; // file & pipe
  NDU_FILE_EXECUTE						= $0020;

  //..

  NDU_FILE_WRITE_DATA					= $0002;
  NDU_WRITE_DAC								= $00040000;
  

implementation

end.
