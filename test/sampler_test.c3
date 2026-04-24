module video_dedupe::tests::frame;

import video_dedupe::core::decode;
import video_dedupe::core::frame;
import std::core::test;

// --- sampler ---

fn void test_sampler_interval_count() @test => @pool()
{
	VideoDecoder*? maybe_decoder = decode::open(
		tmem,
		"resources/test_5s_30fps.mp4"
	);
	if (catch maybe_decoder)
	{
		test::@check(false, "Open failed.");
	}
	VideoDecoder* decoder = maybe_decoder!!;
	defer decoder.close();

	Sampler s = frame::sampler_init(tmem, 1.0);
	defer s.destroy();

	if (catch s.process(decoder))
	{
		test::@check(false, "Process failed.");
	}

	Frame[] samples = s.get_samples();
	test::@check(samples.len == 5, "Expected 5 samples.");
}

fn void test_sampler_timestamp_spacing() @test => @pool()
{
	VideoDecoder*? maybe_decoder = decode::open(
		tmem,
		"resources/test_5s_30fps.mp4"
	);
	if (catch maybe_decoder)
	{
		test::@check(false, "Open failed.");
	}
	VideoDecoder* decoder = maybe_decoder!!;
	defer decoder.close();

	double interval = 1.0;
	Sampler s = frame::sampler_init(tmem, interval);
	defer s.destroy();

	if (catch s.process(decoder))
	{
		test::@check(false, "Process failed.");
		return;
	}

	Frame[] samples = s.get_samples();
	for (int i = 1; i < samples.len; i++)
	{
		double diff = samples[i].timestamp - samples[i - 1].timestamp;
		test::@check(diff >= interval, "Samples too close together.");
	}

	for (usz i = 0; i < samples.len; i++)
	{
		bool all_zero = true;
		for (int j = 0; j < frame::PIXEL_BUFFER_SIZE; j++)
		{
			if (samples[i].pixels[j] != 0)
			{
				all_zero = false;
				break;
			}
		}
		test::@check(!all_zero, "Sampled frame has empty pixel buffer.");
	}
}