module video_dedupe::core::decode;
import video_dedupe::core::frame;

faultdef DECODER_INIT_FAILED, FILE_OPEN_FAILED, FRAME_DECODE_FAILED, NO_VIDEO_STREAM;

struct VideoDecoder
{
	Allocator allocator;
	AVFormatContext* fmt_ctx;
	AVCodecContext* codec_ctx;
	SwsContext* sws_ctx;
	AVPacket* pkt;
	AVFrame* frame;
	Frame current_frame;
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
fn VideoDecoder*? open(Allocator allocator, String path)
{
	// open_input -> find_video_stream -> open_decoder -> packet_alloc -> frame_alloc
	VideoDecoder* vd = alloc::malloc(allocator, VideoDecoder.sizeof);
	defer catch alloc::free(allocator, vd);

	AVFormatContext*? maybe_fmt = open_input(path);
	if (catch excuse = maybe_fmt) return FILE_OPEN_FAILED~;
	AVFormatContext* fmt_ctx = maybe_fmt;
	defer catch close_input(&fmt_ctx);

	int? maybe_stream = find_video_stream(fmt_ctx);
	if (catch excuse = maybe_stream) return NO_VIDEO_STREAM~;
	int stream_index = maybe_stream;

	AVCodecContext*? maybe_codec = open_decoder(fmt_ctx, stream_index);
	if (catch excuse = maybe_codec) return DECODER_INIT_FAILED~;
	AVCodecContext* codec_ctx = maybe_codec;
	defer catch close_decoder(&codec_ctx);

	AVPacket*? maybe_pkt = packet_alloc();
	if (catch excuse = maybe_pkt) return DECODER_INIT_FAILED~;
	AVPacket* pkt = maybe_pkt;
	defer catch packet_free(&pkt);

	AVFrame*? maybe_frame = frame_alloc();
	if (catch excuse = maybe_frame) return DECODER_INIT_FAILED~;
	AVFrame* frame = maybe_frame;
	defer catch frame_free(&frame);

	vd.allocator = allocator;
	vd.fmt_ctx = fmt_ctx;
	vd.codec_ctx = codec_ctx;
	vd.sws_ctx = null;
	vd.pkt = pkt;
	vd.frame = frame;
	vd.video_stream_index = stream_index;
	vd.eof = false;
	vd.flushed = false;

	return vd;
}

<*
 Frees the resources. The function cannot fail.
*>
fn void VideoDecoder.close(VideoDecoder* this)
{
	swscontext_free(this.sws_ctx);
	frame_free(&this.frame);
	packet_free(&this.pkt);
	close_decoder(&this.codec_ctx);
	close_input(&this.fmt_ctx);
	alloc::free(this.allocator, this);
}

<*
 Retrieves the next frame.
 NOTE:
 - The returned frame is reused internally.
 - Calling next_frame again invalidates the previous frame.
 - Do NOT store the pointer long-term.
 @return "Decoded frame."
 @return ? STREAM_END : "Reached EOF."
 @return ? FRAME_DECODE_FAILED : "Unable to decode the frame."
*>
fn Frame*? VideoDecoder.get_frame(VideoDecoder* this)
{
	frame_unref(this.frame);

	AVFrame*? maybe_frame = next_frame(
		this.fmt_ctx,
		this.codec_ctx,
		this.pkt,
		this.frame,
		this.video_stream_index,
		&this.eof,
		&this.flushed
	);

	if (catch excuse = maybe_frame)
	{
		if (excuse == STREAM_END) return STREAM_END~;
		if (excuse == DECODE_FAILED) return FRAME_DECODE_FAILED~;
		return FRAME_DECODE_FAILED~;
	}

	AVFrame* frame = maybe_frame;

	if (!this.sws_ctx)
	{
		this.sws_ctx = sws_getContext(
			this.frame.width,
			this.frame.height,
			frame.format,
			frame::NORMALIZED_WIDTH,
			frame::NORMALIZED_HEIGHT,
			decode::AV_PIX_FMT_GRAY8,
			decode::SWS_BILINEAR,
			null,
			null,
			null
		);
		if (!this.sws_ctx) return FRAME_DECODE_FAILED~;
	}

	char*[1] dst_data = { &this.current_frame.pixels[0] };
	int[1] dst_stride = { frame::NORMALIZED_WIDTH };
	sws_scale(
		this.sws_ctx,
		&frame.data[0],
		&frame.linesize[0],
		0,
		frame.height,
		&dst_data[0],
		&dst_stride[0]
	);

	// AVFrame -> Frame
	AVRational tb = this.fmt_ctx.streams[this.video_stream_index].time_base;
	this.current_frame.timestamp = (double)this.frame.pts
		* ((double)tb.num / (double)tb.den);
	this.current_frame.width = frame::NORMALIZED_WIDTH;
	this.current_frame.height = frame::NORMALIZED_HEIGHT;

	return &this.current_frame;
}
