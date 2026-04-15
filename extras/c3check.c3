module c3;
import std::io;

struct AVCodecParameters
{
	int codec_type;
	int codec_id;
}
struct AVStream
{
	void* av_class;
	int index;
	int id;
	AVCodecParameters* codecpar;
	void* priv_data;
	AVRational time_base;
}
struct AVRational
{
	int num;
	int den;
}
struct AVFrame
{
	char[136] _padding;
	long pts;
}

fn int main(String[] args)
{
	AVStream strm;
	uint codecpar = $offsetof ( strm.codecpar );
	uint time_base = $offsetof ( strm.time_base );
	io::printfn("size of AVStream: %d", $sizeof (AVStream));
	io::printfn("offset for codecpar: %d", codecpar);
	io::printfn("offset for time_base: %d", time_base);
	io::printn();
	AVFrame frm;
	uint pts = $offsetof ( frm.pts );
	io::printfn("size of AVFrame: %d", AVFrame.sizeof);
	io::printfn("offset for pts: %d", pts);
	return 0;
}
