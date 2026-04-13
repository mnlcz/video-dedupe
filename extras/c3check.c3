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
}

fn int main(String[] args)
{
	AVStream strm;
	uint codecpar = $offsetof ( strm.codecpar );
	io::printfn("size of AVStream: %d", $sizeof (AVStream));
	io::printfn("offset for codecpar: %d", codecpar);
	return 0;
}
