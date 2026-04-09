module video_dedupe::core::decode;

faultdef OPEN_FAILED, STREAM_INFO_FAILED, STREAM_END, DECODE_FAILED;

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

	if (avformat_open_input(&ctx, path, null, null) < 0) return OPEN_FAILED~;

	if (avformat_find_stream_info(ctx, null) < 0)
	{
		avformat_close_input(&ctx);
		return STREAM_INFO_FAILED~;
	}

	return ctx;
}

<*
 Closes the opened media source and frees the resources.
 @param ctx : `The context referring to the media to close.`
*>
fn void close_input(AVFormatContext* ctx)
{
	if (ctx == null) return;
	avformat_close_input(&ctx);
}

<*
 Sends compressed data into the decoder, decodes it and gets frames.
 @param fmt_ctx : `Pointer to the format context.`
 @param codec_ctx : `Pointer to the decoder context.`
 @param pkt : `Pointer to the compressed data.`
 @param frame : `Decoded data container`
 @param video_stream_index : `Index of the stream to decode.`
 @param eof : `Internal state flag. Indicates package availability.`
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
	bool* eof
)
{
	while (true)
	{
		int ret = avcodec_receive_frame(codec_ctx, frame);
		if (ret == 0) return frame;
		if (ret == AVERROR_EOF) return STREAM_END~;
		if (ret != AVERROR_EAGAIN) return DECODE_FAILED~;

		if (*eof)
		{
			// flush decoder
			ret = avcodec_send_packet(codec_ctx, null);
			if (ret < 0) return DECODE_FAILED~;
			continue;
		}

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

		// decoder full
		if (ret == AVERROR_EAGAIN) continue;

		if (ret < 0) return DECODE_FAILED~;
	}
}
