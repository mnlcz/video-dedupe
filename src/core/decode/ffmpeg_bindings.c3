module video_dedupe::core::decode;

// ---- avutil types ----
alias AVRational = void; // numerator/denominator fraction, used for timestamps
alias AVDictionary = void;
alias AVFrame = void; // a decoded frame

// avformat types
struct AVStream
{
	void* av_class;
	int index;
	int id;
	AVCodecParameters* codecpar;
}
struct AVFormatContext
{
	void* av_class;
	void* iformat;
	void* oformat;
	void* priv_data;
	void* pb;
	int ctx_flags;
	uint nb_streams;
	AVStream** streams;
}
struct AVPacket
{
	void* buf;
	long pts;
	long dts;
	char* data;
	int size;
	int stream_index;
}

// avcodec types
alias AVCodec = void;
alias AVCodecContext = void; // decoder state for one stream
struct AVCodecParameters
{
	int codec_type;
	int codec_id;
}

// avformat functions
extern fn int avformat_open_input(
	AVFormatContext** ps,
	char* url,
	void* fmt,
	void* options
);
extern fn int avformat_find_stream_info(AVFormatContext* ic, void* options);
extern fn void avformat_close_input(AVFormatContext** s);
extern fn int av_find_best_stream(
	AVFormatContext* ic,
	int type,
	int wanted,
	int related,
	AVCodec** decoder_ret,
	int flags
);
extern fn int av_read_frame(AVFormatContext* s, AVPacket* pkt);

// avcodec functions
extern fn AVCodecContext* avcodec_alloc_context3(AVCodec* codec);
extern fn void avcodec_free_context(AVCodecContext** avctx);
extern fn int avcodec_parameters_to_context(
	AVCodecContext* codec,
	AVCodecParameters* par
);
extern fn AVCodec* avcodec_find_decoder(int id);
extern fn int avcodec_open2(
	AVCodecContext* avctx,
	AVCodec* codec,
	void* options
);
extern fn int avcodec_send_packet(AVCodecContext* avctx, AVPacket* avpkt);
extern fn int avcodec_receive_frame(AVCodecContext* avctx, AVFrame* frame);

// avutil frame/packet funcs
extern fn AVPacket* av_packet_alloc();
extern fn void av_packet_free(AVPacket** pkt);
extern fn void av_packet_unref(AVPacket* pkt);
extern fn AVFrame* av_frame_alloc();
extern fn void av_frame_free(AVFrame** frame);
extern fn void av_frame_unref(AVFrame* frame);
