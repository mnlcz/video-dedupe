module video_dedupe::tests::fs;

import video_dedupe::fs;
import std::core::test;
import std::io::file;
import std::io::path;

fn Path make_temp_dir(Allocator alloc) @local
{
	Path tmp = path::temp_directory(alloc)!!;
	Path vdd_temp = tmp.append(alloc, "/video_dedupe")!!;
	if (path::exists(vdd_temp)) return vdd_temp;

	path::mkdir(vdd_temp)!!;
	return vdd_temp;
}

fn void make_temp_files(Path p, String[] files) @local
{
	foreach (file : files)
	{
		Path n = p.tappend(file)!!;
		File f = file::open_path(n, "w")!!;
		defer f.close()!!;
	}
}

fn void clean_temp_files(Path p) @local
{
	PathList pl = path::ls(tmem, p)!!;

	foreach (f : pl)
	{
		String tmp = p.path_string.tconcat(string::tformat("/%s", f));
		file::delete(tmp)!!;
	}
}

// --- integration tests: scan + filter ---

fn void test_fs_integration_scan_filter_no_videos() @test => @pool()
{
	Path tmp = make_temp_dir(tmem);
	make_temp_files(tmp, { "hello.txt", "image.png" });
	defer clean_temp_files(tmp);

	PathList pl = fs::tlist_dir(tmp);
	int count = 0;

	foreach (p : pl)
	{
		if (fs::is_video_file(p)) count++;
	}

	test::eq(0, count);
}

fn void test_fs_integration_scan_filter_videos() @test => @pool()
{
	Path tmp = make_temp_dir(tmem);
	make_temp_files(tmp, { "hello.txt", "image.png", "clip.MKV", "movie.mp4" });
	defer clean_temp_files(tmp);

	PathList pl = fs::tlist_dir(tmp);
	int count = 0;

	foreach (p : pl)
	{
		if (fs::is_video_file(p)) count++;
	}

	test::eq(2, count);
}
