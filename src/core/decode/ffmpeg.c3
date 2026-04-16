module video_dedupe::core::decode @private;

faultdef ALLOC_FAILED, CODEC_NOT_FOUND, CODEC_OPEN_FAILED, CODEC_PARAMS_FAILED, DECODE_FAILED, OPEN_FAILED, STREAM_INFO_FAILED, STREAM_NOT_FOUND, STREAM_END @public;

const int AVMEDIA_TYPE_VIDEO = 0;
const int AVMEDIA_TYPE_AUDIO = 1;
const int AVERROR_EAGAIN = -11;
const int AVERROR_EOF = -541478725; // ffmpeg specific

<*
 Opens a media source and initializes an `AVFormatContext` for reading.
 @param path : `The path to the media file.`
 @return "A pointer to the context."
 @return ? OPEN_FAILED : "The ffmpeg binding was unable to open the media."
 @return ? STREAM_INFO_FAILED : "The stream information couldn't be read."
*>
fn AVFormatContext*? open_input(String path)
{
	AVFormatContext* ctx = null;

	@pool()
	{
		ZString cpath = path.zstr_tcopy();
		if (avformat_open_input(
			&ctx,
			cpath,
			null,
			null
		) < 0) return OPEN_FAILED~;
		if (!ctx) return OPEN_FAILED~;

		if (avformat_find_stream_info(ctx, null) < 0)
		{
			avformat_close_input(&ctx);
			return STREAM_INFO_FAILED~;
		}
	};

	return ctx;
}

<*
 Closes the opened media source and frees the resources.
 @param ctx : `The context referring to the media to close.`
*>
fn void close_input(AVFormatContext** ctx)
{
	if (!ctx) return;
	avformat_close_input(ctx);
}

<*
 Sends compressed data into the decoder, decodes it and gets frames.
 @param fmt_ctx : `Pointer to the format context.`
 @param codec_ctx : `Pointer to the decoder context.`
 @param pkt : `Pointer to the compressed data.`
 @param frame : `Decoded data container`
 @param video_stream_index : `Index of the stream to decode.`
 @param eof : `Internal state flag. Indicates package availability.`
 @param flushed : `Internal state flag. Indicates if the decoder was flushed.`
 @return "Decoded frame."
 @return ? STREAM_END : "Reached EOF."
 @return ? DECODE_FAILED : "Either the package couldn't be sent or the frame couldn't be received."
*>
fn AVFrame*? next_frame(
	AVFormatContext* fmt_ctx,
	AVCodecContext* codec_ctx,
	AVPacket* pkt,
	AVFrame* frame,
	int video_stream_index,
	bool* eof,
	bool* flushed
)
{
	while (true)
	{
		int ret = avcodec_receive_frame(codec_ctx, frame);
		if (ret == 0) return frame; // Got a frame
		if (ret == AVERROR_EOF) return STREAM_END~; // Decoder fully drained
		if (ret != AVERROR_EAGAIN) return DECODE_FAILED~;

		// --- read packets ---
		if (!*eof)
		{
			ret = av_read_frame(fmt_ctx, pkt);

			if (ret < 0)
			{
				*eof = true;
				continue;
			}

			if (pkt.stream_index != video_stream_index)
			{
				av_packet_unref(pkt);
				continue;
			}

			ret = avcodec_send_packet(codec_ctx, pkt);
			av_packet_unref(pkt);

			// decoder full, continue to retry receive_frame
			if (ret == AVERROR_EAGAIN) continue;

			if (ret < 0) return DECODE_FAILED~;

			continue;
		}

		// --- EOF but not flushed ---
		if (!*flushed)
		{
			ret = avcodec_send_packet(codec_ctx, null);

			if (ret < 0) return DECODE_FAILED~;

			*flushed = true;
			continue;
		}

		return STREAM_END~;
	}
}

<*
 Tries to allocate an empty AVFrame instance.
 @return "A valid pointer to AVFrame, ready to be used."
 @return ? ALLOC_FAILED : "The allocation failed."
*>
fn AVFrame*? frame_alloc()
{
	AVFrame* frame = av_frame_alloc();
	if (frame == null) return ALLOC_FAILED~;
	return frame;
}

<*
 Frees the frame container. The function is safe and cannot fail and should be called at the end of the decoder lifecycle.
 @param frame : `Frame to free.`
*>
fn void frame_free(AVFrame** frame)
{
	av_frame_free(frame);
}

<*
 Clears frame data, releases internal buffers, but keeps the frame container allocated. The function should be called after each decoded frame.
 @param frame : `Frame to clear.`
*>
fn void frame_unref(AVFrame* frame)
{
	av_frame_unref(frame);
}

<*
 Tries to allocate a packet.
 @return "A valid pointer to AVPacket."
 @return ? ALLOC_FAILED : "The allocation failed."
*>
fn AVPacket*? packet_alloc()
{
	AVPacket* pkt = av_packet_alloc();
	if (!pkt) return ALLOC_FAILED~;
	return pkt;
}

<*
 Frees the resources used by the packet. The function is safe and cannot fail.
 @param pkt : `Packet to free.`
*>
fn void packet_free(AVPacket** pkt)
{
	av_packet_free(pkt);
}

<*
 Takes an open container and produces an initialized context.
 @param fmt_ctx : `Pointer to the open container open_input produced.`
 @param video_stream_index : `Video index produced by find_video_stream.`
 @return "AVCodecContext instance ready to receive packets."
 @return ? CODEC_NOT_FOUND : `avcodec_find_decoder failed.`
 @return ? ALLOC_FAILED : `avcodec_alloc_context3 returned null, it was unable to allocate.`
 @return ? CODEC_PARAMS_FAILED : `avcodec_parameters_to_context returnet negative. E.g. the parameters got malformed or are incompatible.`
 @return ? CODEC_OPEN_FAILED : `avcodec_open2 returned negative. E.g. missing hardware support or invalid configuration.`
*>
fn AVCodecContext*? open_decoder(
	AVFormatContext* fmt_ctx,
	int video_stream_index
)
{
	/* avcodec_find_decoder -> avcodec_alloc_context3 -> avcodec_parameters_to_context -> avcodec_open2 */
	AVStream* stream = fmt_ctx.streams[video_stream_index];
	int codec_id = stream.codecpar.codec_id;

	AVCodec* codec = avcodec_find_decoder(codec_id);
	if (!codec) return CODEC_NOT_FOUND~;

	AVCodecContext* codec_ctx = avcodec_alloc_context3(codec);
	if (!codec_ctx) return ALLOC_FAILED~;

	defer catch avcodec_free_context(&codec_ctx);

	int ret = avcodec_parameters_to_context(codec_ctx, stream.codecpar);
	if (ret < 0) return CODEC_PARAMS_FAILED~;

	ret = avcodec_open2(codec_ctx, codec, null);
	if (ret < 0) return CODEC_OPEN_FAILED~;

	return codec_ctx;
}

<*
 Frees the resources associated with a codec context. The function cannot fail.
 @param codec_ctx : `Pointer to the codec context.`
*>
fn void close_decoder(AVCodecContext** codec_ctx)
{
	if (!codec_ctx) return;
	avcodec_free_context(codec_ctx);
}

<*
 Finds which stream index corresponds to video.
 @param fmt_ctx : `The opened media file.`
 @return "Video stream index."
 @return ? STREAM_NOT_FOUND
*>
fn int? find_video_stream(AVFormatContext* fmt_ctx)
{
	int ret = av_find_best_stream(fmt_ctx, AVMEDIA_TYPE_VIDEO, -1, -1, null, 0);
	if (ret < 0) return STREAM_NOT_FOUND~;

	return ret;
}
