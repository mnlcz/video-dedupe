module video_dedupe::core::decode;

faultdef OPEN_FAILED, STREAM_INFO_FAILED;

const int AVMEDIA_TYPE_VIDEO = 0;
const int AVMEDIA_TYPE_AUDIO = 1;

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
