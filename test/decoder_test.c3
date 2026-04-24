module video_dedupe::tests::decode;

import video_dedupe::core::decode;
import video_dedupe::core::frame;
import std::core::test;

// --- open video ---

fn void test_open_invalid_video() @test => @pool()
{
	test::@error(decode::open(tmem, "nothing.mp4"), decode::FILE_OPEN_FAILED);
}

fn void test_open_no_video_file() @test => @pool()
{
	test::@error(
		decode::open(tmem, "resources/test_audio.mp3"),
		decode::NO_VIDEO_STREAM
	);
}

fn void test_open_video() @test => @pool()
{
	VideoDecoder*? maybe_decoder = decode::open(
		tmem,
		"resources/arg_fra_goal.webm"
	);
	if (catch maybe_decoder)
	{
		test::@check(false, "VideoDecoder open failed.");
		return;
	}
	VideoDecoder* decoder = maybe_decoder;
	defer decoder.close();
	test::@check(decoder != null, "VideoDecoder is null.");
}

// --- get_frame ---

fn void test_get_frame_returns_valid_frame() @test => @pool()
{
	VideoDecoder*? maybe_decoder = decode::open(
		tmem,
		"resources/arg_fra_goal.webm"
	);
	if (catch maybe_decoder)
	{
		test::@check(false, "Open failed.");
	}
	VideoDecoder* decoder = maybe_decoder!!;
	defer decoder.close();

	Frame*? maybe_frame = decoder.get_frame();
	if (catch maybe_frame)
	{
		test::@check(false, "get_frame failed on first call.");
		return;
	}
	Frame* frame = maybe_frame;
	test::@check(frame.timestamp >= 0.0, "First frame timestamp is negative.");
	test::@check(frame.width == frame::NORMALIZED_WIDTH, "Wrong width.");
	test::@check(frame.height == frame::NORMALIZED_HEIGHT, "Wrong height.");

	bool all_zero = true;
	for (int i = 0; i < frame::PIXEL_BUFFER_SIZE; i++)
	{
		if (frame.pixels[i] != 0)
		{
			all_zero = false;
			break;
		}
	}
	test::@check(!all_zero, "Pixel buffer is all zeros.");
}

fn void test_get_frame_monotonic_timestamps() @test => @pool()
{
	VideoDecoder*? maybe_decoder = decode::open(
		tmem,
		"resources/arg_fra_goal.webm"
	);
	if (catch maybe_decoder)
	{
		test::@check(false, "Open failed.");
	}
	VideoDecoder* decoder = maybe_decoder!!;
	defer decoder.close();

	double prev_timestamp = -1.0;
	int frame_count = 0;
	bool reached_end = false;

	while (true)
	{
		Frame*? maybe_frame = decoder.get_frame();
		if (catch excuse = maybe_frame)
		{
			if (excuse == decode::STREAM_END)
			{
				reached_end = true;
				break;
			}
			test::@check(false, "Unexpected decode error.");
			return;
		}
		Frame* frame = maybe_frame;
		test::@check(
			frame.timestamp >= prev_timestamp,
			"Timestamp went backwards."
		);
		prev_timestamp = frame.timestamp;
		frame_count++;
	}

	test::@check(reached_end, "Stream never ended.");
	test::@check(frame_count > 0, "No frames were decoded.");
}