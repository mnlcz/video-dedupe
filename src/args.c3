module video_dedupe::args;

import std::io;
import std::os;

faultdef INVALID_ARGUMENT, INVALID_PATH, MISSING_ARGUMENTS, UNKNOWN_ARGUMENT;

<*
 Validates if the argument is a path.
 @param allocator : `The allocator to use for the Path instantiation.`
 @param s_path : `argv[1], the path in a string format.`
 @return "Path instance with s_path as attribute."
 @return ? INVALID_ARGUMENT : "The argument is not a valid path."
*>
fn Path? validate_arg(Allocator allocator, String s_path)
{
	if (s_path.len == 0) return INVALID_ARGUMENT~;

	@pool()
	{
		// Create mutable copy since `normalize` could segfault
		String tmp = s_path.copy(tmem);

		String? maybe_ok = path::normalize(tmp);

		if (catch flt = maybe_ok) return INVALID_ARGUMENT~;

		String final = maybe_ok.copy(allocator);

		return { .path_string = final, .allocator = allocator };
	};
}

<*
 Prints usage instructions to stderr.
 @param binary_name : `argv[0], used to show the correct name of the program.`
*>
fn void print_usage(String binary_name)
{
	io::eprintfn("Usage: %s <path>", binary_name);
}

<*
 Validates the path in the filesystem.
 @param path : `Path instance corresponding to the argv[1] argument.`
 @return ? INVALID_PATH : "The path doesn't exist."
*>
fn void? validate_path(Path path)
{
	if (!path::exists(path)) return INVALID_PATH~;
}

<*
 Parses the arguments from the command line.
 @param allocator : `The allocator used for building the Path and the validations.`
 @param args : `argv directly from main.`
 @return ? validate_path!
 @return ? validate_arg!
 @return ? MISSING_ARGUMENTS : "Fewer arguments than expected."
 @return ? UNKNOWN_ARGUMENT : "The user provided an argument not expected by the program."
*>
fn Path? parse_args(Allocator allocator, String[] args)
{
	if (args.len < 2) return MISSING_ARGUMENTS~;
	if (args.len > 2) return UNKNOWN_ARGUMENT~;

	String s_path = args[1];
	Path p = validate_arg(allocator, s_path)!;
	validate_path(p)!;

	return p;
}
