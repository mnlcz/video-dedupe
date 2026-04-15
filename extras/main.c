#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/frame.h>
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
  printf("offset time_base: %u\n", offsetof(AVStream, time_base));
  printf("\n");
  printf("size of AVFrame: %u\n", sizeof(AVFrame));
  printf("offset of pts: %u\n", offsetof(AVFrame, pts));
  return 0;
}
