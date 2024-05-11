#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <termios.h>

struct termios orig, now;
char stat[32];
int s_quit = 0, 
    s_save = 0, 
    s_insert = 0,
    s_line = 1,
    s_col = 1,
    s_scroll = 0,
    s_hscroll = 0;

char** buf;
int lines;

int setraw() {
  setvbuf(stdout, NULL, _IONBF, 0);
  tcgetattr(0, &orig);
  now = orig;
  now.c_lflag &= ~(ISIG|ICANON|ECHO);
  now.c_cc[VMIN] = 1;
  now.c_cc[VTIME] = 2;
  tcsetattr(0, TCSANOW, &now);
}

int resetraw() {
  tcsetattr(0, TCSANOW, &orig);
}

void scroll(int l) {
}

void hscroll(int c) {
}

int mvmt(char c) {
  switch (c) {
    case 'w': scroll(-1); break;
    case 'W': scroll(-5); break;
    case 's': scroll(1); break;
    case 'S': scroll(5); break;
    case 'a': hscroll(-1); break;
    case 'A': hscroll(-5); break;
    case 'd': hscroll(1); break;
    case 'D': hscroll(5); break;
    case 'j': break;
    case 'l': break;
    case 'i': break;
    case 'k': break;
    case 'q': break;
    case 'Q': break;
    case 'e': break;
    case 'r': break;
    case 'c': break;
    case 'C': break;
    case 'x': break;
    case 'X': break;
    case 'v': break;
    case 'V': break;
    case 'z': break;
    case 'Z': break;
    case 't': break;
    case 'T': break;
  }
}

int insert(char c) {
}

int getinput() {
  setraw();
  int c = getchar();
  resetraw();
  if (c < 30)
    mvmt(c+96);
  else if (s_insert)
    insert(c);
  else
    mvmt(c);
}

int draw() {
}

int into_array(void* arr, int arrlen, void* item, int index) {
  for (int i = arrlen; i >= index; i--) {
    arr[arrlen+1] = arr[arrlen];
  }
  arr[index] = item;
  arrlen++;
}

char* add_line() {
  lines++;
}

int main(int argc) {
  if (argc > 1) {
  }

  while (true) {
    draw();
    getinput();
  }
}
