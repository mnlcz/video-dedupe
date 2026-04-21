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
