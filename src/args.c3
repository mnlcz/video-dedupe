module video_dedupe::args;

import libc;
import std::io;
import std::os;

faultdef INVALID_ARGUMENT, INVALID_PATH, MISSING_ARGUMENTS, UNKNOWN_ARGUMENT;

// -------------------------- C ABI -------------------------------
// POSIX regex_t is an opaque struct — size varies by platform
// on Linux x64 it's 40 bytes. I over-allocate for portability
struct RegexT
{
	char[128] __opaque;
}

// match result — start and end offsets of each capture group
struct Regmatch
{
	isz rm_so; // start offset
	isz rm_eo; // end offset
}

const int REG_EXTENDED = 1; // use ERE syntax (like egrep)
extern fn int regcomp(RegexT* preg, ZString pattern, int cflags);
extern fn int regexec(
	RegexT* preg,
	ZString string,
	usz nmatch,
	Regmatch* pmatch,
	int eflags
);
extern fn void regfree(RegexT* preg);
// ----------------------------------------------------------------

<*
 Validates if the argument is a path.
 @param allocator : `The allocator to use for the Path instantiation.`
 @param s_path : `argv[1], the path in a string format.`
 @return "Path instance with s_path as attribute."
 @return ? INVALID_ARGUMENT : "The argument is not a valid path."
*>
fn Path? validate_arg(Allocator allocator, String s_path)
{
	RegexT re;
	int err = regcomp(&re, `^/[^/]+(/[^/]+)*$`, REG_EXTENDED);
	if (err != 0)
	{
		io::eprintfn("Failed to compile regex");
		std::os::exit(1);
	}
	defer regfree(&re);

	@pool()
	{
		ZString cstr_path = s_path.zstr_tcopy();

		int result = regexec(&re, cstr_path, 0, null, 0);
		if (result != 0) return INVALID_ARGUMENT~;

		String matched = cstr_path.str_view().copy(allocator);
		return { .path_string = matched, .allocator = allocator };
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
