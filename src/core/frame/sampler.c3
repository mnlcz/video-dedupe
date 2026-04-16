module video_dedupe::core::frame;

import std::collections::list;
import video_dedupe::core::decode;

alias ListFrame = List {Frame};

struct Sampler
{
	Allocator allocator;
	double interval;
	double next_sample_time;
	ListFrame samples;
}

<*
 Constructor for Sampler.
 @param interval : `The interval used for selecting frames.`
 @return "Sampler value."
*>
fn Sampler sampler_init(Allocator allocator, double interval)
{
	Sampler s = { .allocator = allocator, .interval = interval, };
	s.samples.init(s.allocator);

	return s;
}

<*
 Pulls frames from the decoder and applies interval filter.
 @param decoder : `Decoder instance that will retrieve the frames.`
 @return ? decode::FRAME_DECODE_FAILED : "The decoder was unable to get a frame."
*>
fn void? Sampler.process(Sampler* this, VideoDecoder* decoder)
{
	while (true)
	{
		Frame*? maybe_frame = decoder.get_frame();

		if (catch excuse = maybe_frame)
		{
			if (excuse == decode::STREAM_END) return; // normal finish
			return decode::FRAME_DECODE_FAILED~;
		}

		Frame* frame = maybe_frame;

		if (frame.timestamp < this.next_sample_time) continue;

		this.samples.push(*frame);
		this.next_sample_time += this.interval;
	}
}

<*
 Samples slice accessor.
*>
fn Frame[] Sampler.get_samples(Sampler* this)
{
	return this.samples.array_view();
}

<*
 Destructor for Sampler.
*>
fn void Sampler.destroy(Sampler* this)
{
	this.samples.free();
}
