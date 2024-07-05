CC = cc

CFLAGS = -Wall -Wextra 
TARGET = main.o

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) main.c -o $(TARGET) -lncurses -lmenu

clean:
	rm -f $(TARGET)

