//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"",	"sb-network",				10,			0},
	{"",	"sb-battery",				20,			0},
	{"",	"sb-volume",				0,			10},
	{"",	"sb-cpu",				5,			0},
	{"",	"sb-memory",				10,			0},
	{" ",	"date '+%d/%m/%y (%a) %I:%M%p'",	60,			0},
};

//sets delimiter between status commands. NULL character ('\0') means no delimiter.
static char delim[] = " | ";
static unsigned int delimLen = 5;

