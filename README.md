# video_dedupe

WIP.

## TODO

- [ ] Skeleton: argument parsing. Very early fs integration.
  - [ ] Restrict argument path to directories only. Add an extra validator in `parse_args` and a new fault, something like `NOT_A_DIRECTORY`.
  - [ ] Move `args.c3` to a dedicated `cli/` directory.
  - [ ] Consider adding flags, current logic should go in something like `video_dedupe --scan <dirpath>`. But I could also allow `video_dedupe --compare <a> <b>`..
- [-] Decoder + sampler: extract frames at fixed intervals.
