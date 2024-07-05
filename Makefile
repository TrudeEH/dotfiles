CC = cc

CFLAGS = -Wall -Wextra 
TARGET = install

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) main.c -o $(TARGET) -lncurses -lmenu

clean:
	rm -f $(TARGET)

