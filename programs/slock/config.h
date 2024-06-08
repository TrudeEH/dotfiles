/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nogroup";

static const char *colorname[NUMCOLS] = {
	[BG] =     "#282828",   /* background */
	[INIT] =   "#ebdbb2",   /* after initialization */
	[INPUT] =  "#8ec07c",   /* during input */
	[FAILED] = "#fb4934",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* size of square in px */
static const int squaresize = 50;

/* time in seconds before the monitor shuts down */
static const int monitortime = 5;
