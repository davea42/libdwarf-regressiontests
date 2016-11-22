/* Define basic data types */
typedef	unsigned char               UINT8;          /*  8 bit */
typedef	signed char                 SINT8;          /*  8 bit signed */
typedef volatile unsigned char      VUINT8;
typedef volatile signed char        VSINT8;

typedef	unsigned short              UINT16;         /* 16 bit */
typedef	signed short                SINT16;         /* 16 bit signed */
typedef volatile unsigned short     VUINT16;
typedef volatile signed short       VSINT16;

typedef	unsigned int                UINT32;         /* 32 bit */
typedef	signed int                  SINT32;         /* 32 bit signed */
typedef volatile unsigned int       VUINT32;
typedef volatile signed int         VSINT32;

/* Define packed structures */
#define PACKED  __packed struct

#define DTC_TABLE_CONF_ROWS 10       ///< Size of the EEPROM error table (number of rows).
#define J1939_NUM_SOURCES 	2

typedef PACKED j1939_DM4_struct {
	UINT8 u8FFLength;          ///< Freeze Frame Length, see 5.7.4.1
	
	UINT32 SPN_low:8; ///< Suspect Parameter Number (SPN) 19 bits, lower 8 bits.
	UINT32 SPN_mid:8; ///< Suspect Parameter Number (SPN) 19 bits, middle 8 bits.
	UINT32 SPN_high:3;  ///< Suspect Parameter Number (SPN) 19 bits, remaining 3 bits.
	UINT32 FMI  :5;  ///< Failure Mode Identifier (FMI) 5 bits	
	UINT32 CM   :1;  ///< SPN Conversion Method (CM) 1 bit
	UINT32 OC   :7;  ///< Occurrence Count (OC) 7 bits
	// required environmental parameters
	UINT8 u8EngineTorqueMode;  ///< SPN 899, engine torque mode
	UINT8 u8Boost;             ///< SPN 102, boost
	UINT8 u8EngineSpeed_lsb;   ///< SPN 190, engine speed (LSB)
	UINT8 u8EngineSpeed_msb;   ///< SPN 190, engine speed (MSB)
	UINT8 u8EnginePrcLoad;     ///< SPN 92, engine % load
	UINT8 u8EngineCoolantTemp; ///< SPN 110, engine coolant temperature
	UINT8 u8VehicleSpeed_lsb;  ///< SPN 84, vehicle speed (LSB)
	UINT8 u8VehicleSpeed_msb;  ///< SPN 84, vehicle speed (MSB)
	// manufacturer specific information to be put here. I'm using them as spacers now.
	UINT8 u8ManSpec1;
	UINT8 u8ManSpec2;
	UINT8 u8ManSpec3;
} tJ1939_DM4_msg;

/** Union for the DM4 message. It allows us to access the DM4 message as a struct when filling it in \ref J1939_DM4_func and as an u8 memory area when sending it */
typedef union j1939_DM4_union
{
	tJ1939_DM4_msg xMsg[DTC_TABLE_CONF_ROWS];
	UINT8 u8data[sizeof(tJ1939_DM4_msg)*DTC_TABLE_CONF_ROWS]; ///< the theoretical max number of bytes is 1785. Always doublecheck. Now it should be 10*32 = 320 bytes.
} tJ1939_DM4;

// (global) memory area of the DM4 message(s)
tJ1939_DM4 xJ1939_DM4[J1939_NUM_SOURCES];

main()
{
	UINT8 i;
	for (i=0; i<J1939_NUM_SOURCES; ++i) {
		xJ1939_DM4[i].xMsg[0].SPN_low = 0xF;
		xJ1939_DM4[i].xMsg[0].SPN_mid = 0xD;
		xJ1939_DM4[i].xMsg[0].SPN_low = 0x2;
	}
}