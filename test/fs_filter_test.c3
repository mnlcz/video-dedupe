module video_dedupe::tests::fs;

import video_dedupe::fs;
import std::core::test;
import std::io::path;

// --- filtering ---

fn void test_fs_filter_nonvideo() @test
{
	Path p = { .path_string = "image.png", };
	test::@check(!fs::is_video_file(p), "%s is a video file", p.path_string);
}

fn void test_fs_filter_video() @test
{
	Path p = { .path_string = "movie.mp4", };
	test::@check(fs::is_video_file(p), "%s is not a video file", p.path_string);
}

fn void test_fs_filter_uppercase_video_ext() @test
{
	Path p = { .path_string = "clip.MKV", };
	test::@check(fs::is_video_file(p), "%s is not a video file", p.path_string);
}

fn void test_fs_filter_no_ext() @test
{
	Path p = { .path_string = "no_extension", };
	test::@check(!fs::is_video_file(p), "%s is a video file", p.path_string);
}

fn void test_fs_filter_multi_ext() @test
{
	Path p = { .path_string = "weird.mp4.txt", };
	test::@check(!fs::is_video_file(p), "%s is a video file", p.path_string);
}
