module video_dedupe::fs;

import std::os;
import std::io::path;

const String[*] VIDEO_EXTENSIONS = {
	"mp4",
	"mkv",
	"mov",
	"webm",
	"avi",
	"wmv",
	"flv",
	"mpg",
	"mpeg",
	"m4v",
	"ts",
	"m2ts"
};

<*
 Checks if the provided file corresponds to a video.
 @param p : "Path of the file to check."
 @return `true if it is a video, otherwise false.`
*>
fn bool is_video_file(Path p)
{
	String? maybe_ext = p.extension();
	if (catch maybe_ext) return false;

	@pool()
	{
		String ext = maybe_ext.copy(tmem);
		ext.convert_to_lower();

		foreach (vext : VIDEO_EXTENSIONS)
		{
			if (ext == vext) return true;
		}
	};

	return false;
}
