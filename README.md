# video_dedupe

WIP.

## Goals

Have a way to, given a directory, check (and maybe handle) video duplicates. Eventually, the tool should be capable of checking:

- Videos that are equal but with different naming.
- Videos that are the same content but in different encoding/format/quality.
- Maybe videos that are sections of another video (like clips).

Maybe also:

- Remove duplicates.
  - Allow the user to view the videos before deleting one.
    - Idea: generate symlinks (maybe in `tmp`) for the duplicates and open the file explorer? Detect which symlink the user
      deletes.

## TODO

- [x] Skeleton: argument parsing. Very early fs integration.
  - [ ] Restrict argument path to directories only. Add an extra validator in `parse_args` and a new fault, something like `NOT_A_DIRECTORY`.
  - [x] Move `args.c3` to a dedicated `cli/` directory.
  - [ ] Consider adding flags, current logic should go in something like `video_dedupe --scan <dirpath>`. But I could also allow `video_dedupe --compare <a> <b>`.
  - [ ] Make `is_video_file` ignore directories.
- [ ] Decoder + sampler: extract frames at fixed intervals.
  - [x] Bindings for ffmpeg. (`src/core/decode/ffmpeg_bindings.c3`).
    - [x] external functions.
    - [x] partial structs.
  - [x] Easy wrapper over bindings. (`src/core/decode/ffmpeg.c3`).
    - [x] `av_read_frame`.
    - [x] `av_frame_alloc`.
    - [x] `av_frame_free`.
    - [x] `av_find_best_stream`.
    - [x] `av_find_decoder`.
    - [x] `avcodec_alloc_context3`.
    - [x] `avcodec_parameters_to_context`.
    - [x] `avcodec_open2`.
    - [x] `avcodec_free_context`.
  - [x] Decoder api. (`src/core/decode/decoder.c3`).
  - [x] Sampler
    - [x] `AVFrame` partial.
    - [x] `Frame` struct.
      - [x] Extend `AVStream` to expose `time_base`.
      - [x] Binding for `AVRational`.
      - [x] Implement `Frame`.
      - [x] Update `get_frame`.
    - [x] Sample logic on `Frame`.
  - [x] Maybe make wrappers and bindings `@private`, making `decoder.c3` the only visible api.
  - [ ] Tests.
