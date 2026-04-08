module video_dedupe::tests::args;

import video_dedupe::cli::args;
import std::core::test;
import std::io;

// --- invalid argument formats ---

fn void test_parse_args_no_args() @test
{
	test::@error(args::parse_args(mem, { "" }), args::MISSING_ARGUMENTS);
}

fn void test_parse_args_too_many_args() @test
{
	test::@error(
		args::parse_args(mem, { "", "", "", "", "" }),
		args::UNKNOWN_ARGUMENT
	);
}

fn void test_parse_args_bad_str() @test
{
	test::@error(
		args::parse_args(mem, { "", "/../../.." }),
		args::INVALID_ARGUMENT
	);
}

fn void test_parse_args_empty_str() @test
{
	test::@error(args::parse_args(mem, { "", "" }), args::INVALID_ARGUMENT);
}

fn void test_parse_args_nonexistent_path() @test
{
	@pool()
	{
		Path? p = args::parse_args(tmem, { "", "/hello" });
		test::@error(p, args::INVALID_PATH);
	};
}

fn void test_parse_args_nonexistent_subdirectory_path() @test
{
	@pool()
	{
		Path? p = args::parse_args(tmem, { "", "/usr/hello" });
		test::@error(p, args::INVALID_PATH);
	};
}

// --- valid paths ---

fn void test_parse_args_home_directory() @test
{
	@pool()
	{
		String str = "/home";
		Allocator al = tmem;
		Path p1 = args::parse_args(al, { "", str })!!;
		Path p2 = { .path_string = str, .allocator = al, };
		test::eq(p1, p2);
	};
}

fn void test_parse_args_home_directory_slash_end() @test
{
	@pool()
	{
		Allocator al = tmem;
		Path p1 = args::parse_args(
			al,
			{ "", "/home/" }
		)!!; // trailing / gets removed by `normalize`
		Path p2 = { .path_string = "/home", .allocator = al, };
		test::eq(p1, p2);
	};
}

fn void test_parse_args_dotdot_resolution() @test
{
	@pool()
	{
		Allocator al = tmem;
		Path p1 = args::parse_args(al, { "", "/usr/local/bin/../../../" })!!;
		Path p2 = { .path_string = "/", .allocator = al, };
		test::eq(p1, p2);
	};
}

fn void test_parse_args_dot_resolution() @test
{
	@pool()
	{
		Allocator al = tmem;
		Path p1 = args::parse_args(al, { "", "/home/././././././" })!!;
		Path p2 = { .path_string = "/home", .allocator = al, };
		test::eq(p1, p2);
	};
}

fn void test_parse_args_mixed_resolution() @test
{
	@pool()
	{
		Allocator al = tmem;
		Path p1 = args::parse_args(al, { "", "/home/././././././.." })!!;
		Path p2 = { .path_string = "/", .allocator = al, };
		test::eq(p1, p2);
	};
}
