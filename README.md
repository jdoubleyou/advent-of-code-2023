# Advent Of Code 2023

**Language**: Zig

**Version**: 0.11.0

## Running

To run each puzzle file:

```shell
$ zig build run
```

To run only puzzle files for the given day.

```shell
$ zig build run -- <day>
```

## Testing

To run a single puzzles tests:

```shell
$ zig test --main-pkg-path src src/puzzles/day<day_number>.zig
```

To run all puzzles tests:

```shell
$ zig build test
```
