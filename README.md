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

- [ ] Skeleton: argument parsing. Very early fs integration.
  - [ ] Restrict argument path to directories only. Add an extra validator in `parse_args` and a new fault, something like `NOT_A_DIRECTORY`.
  - [x] Move `args.c3` to a dedicated `cli/` directory.
  - [ ] Consider adding flags, current logic should go in something like `video_dedupe --scan <dirpath>`. But I could also allow `video_dedupe --compare <a> <b>`.
- [-] Decoder + sampler: extract frames at fixed intervals.
