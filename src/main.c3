module video_dedupe;

import std::io;
import std::os;
import video_dedupe::cli::args;

fn int main(String[] args)
{
	Path? maybe_path = args::parse_args(mem, args);
	defer (void)maybe_path.free();

	if (catch flt = maybe_path)
	{
		switch (flt)
		{
			case args::MISSING_ARGUMENTS:
				io::eprintfn("Error: Expected at least 1 argument.");
			case args::UNKNOWN_ARGUMENT:
				io::eprintfn("Error: Expected only 1 argument.");
			case args::INVALID_ARGUMENT:
				io::eprintfn("Error: %s doesn't look like a path.", args[1]);
			case args::INVALID_PATH:
				io::eprintfn("Error: path %s doesn't exist.", args[1]);
			default:
				io::eprintfn("Error: Failed to parse arguments: %s", flt);
		}

		args::print_usage(args[0]);
		os::exit(1);
	}

	Path path = maybe_path;

	// Small test
	@pool()
	{
		PathList pl = path::ls(tmem, path)!!;

		foreach (p : pl)
		{
			io::printn(p.path_string);
		}
	};

	return 0;
}
