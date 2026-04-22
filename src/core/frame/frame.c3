module video_dedupe::core::frame;

// 8x8 for fast hashing, 16x16 for better discrimination
const int NORMALIZED_WIDTH = 8;
const int NORMALIZED_HEIGHT = 8;
const int PIXEL_BUFFER_SIZE = NORMALIZED_WIDTH * NORMALIZED_HEIGHT; // 64 bytes

struct Frame
{
	double timestamp;
	int width;
	int height;
	char[PIXEL_BUFFER_SIZE] pixels;
}
