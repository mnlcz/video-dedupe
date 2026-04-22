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
	char*[8] data;
	int[8] linesize;
	char[8] _pad1;
	int width;
	int height;
	char[4] _pad2;
	int format;
	char[16] _pad3;
	long pts;
}

fn int main(String[] args)
{
	AVStream strm;
	io::printfn("size of AVStream: %d", $sizeof (AVStream));
	io::printfn("offset for codecpar: %d", $offsetof ( strm.codecpar ));
	io::printfn("offset for time_base: %d", $offsetof ( strm.time_base ));
	io::printn();
	AVFrame frm;
	io::printfn("size of AVFrame: %d", AVFrame.sizeof);
	io::printfn("offset data: %d", $offsetof ( frm.data ));
	io::printfn("offset linesize: %d", $offsetof ( frm.linesize ));
	io::printfn("offset width: %d", $offsetof ( frm.width ));
	io::printfn("offset height: %d", $offsetof ( frm.height ));
	io::printfn("offset format: %d", $offsetof ( frm.format ));
	io::printfn("offset for pts: %d", $offsetof ( frm.pts ));
	return 0;
}
