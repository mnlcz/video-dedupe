module video_dedupe::core::decode;

faultdef DECODER_INIT_FAILED, FILE_OPEN_FAILED, FRAME_DECODE_FAILED, NO_VIDEO_STREAM;

struct VideoDecoder
{
	AVFormatContext* fmt_ctx;
	AVCodecContext* codec_ctx;
	AVPacket* pkt;
	AVFrame* frame;
	int video_stream_index;
	bool eof;
	bool flushed;
}

<*
 Allocates the structure and populates the fields.
 @return "Ready to use decoder."
 @return ? FILE_OPEN_FAILED : "Unable to read the stream."
 @return ? NO_VIDEO_STREAM : "Unable to find video stream."
 @return ? DECODER_INIT_FAILED : "Unable to initialize the decoder."
*>
fn VideoDecoder*? open(String path)
{
	// open_input -> find_video_stream -> open_decoder -> packet_alloc -> frame_alloc
	return null;
}

<*
 Frees the resources. The function cannot fail.
*>
fn void VideoDecoder.close(VideoDecoder* this)
{
	// frame_free -> packer_free -> close_decoder -> close_input
}

<*
 Retrieves the next frame.
 @return "Decoded frame."
 @return ? STREAM_END : "Reached EOF."
 @return ? FRAME_DECODE_FAILED : "Unable to decode the frame."
*>
fn AVFrame*? VideoDecoder.next_frame(VideoDecoder* this)
{
	return null;
}
