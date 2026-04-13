#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <stddef.h>
#include <stdio.h>

int main() {
  printf("size of AVFormatContext:   %u\n", sizeof(AVFormatContext));
  printf("offset nb_streams: %u\n", offsetof(AVFormatContext, nb_streams));
  printf("offset streams: %u\n", offsetof(AVFormatContext, streams));
  printf("\n");
  printf("size of AVPacket:   %u\n", sizeof(AVPacket));
  printf("\n");
  printf("size of AVStream:   %u\n", sizeof(AVStream));
  printf("offset codecpar: %u\n", offsetof(AVStream, codecpar));
  return 0;
}
