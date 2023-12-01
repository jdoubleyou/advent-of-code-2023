const std = @import("std");

pub const Error = error{
    UnknownArgumentGiven,
    InvalidPuzzleNumber,
    UnableToFormat,
};

const PuzFn = *const fn (std.mem.Allocator, std.fs.File) anyerror![]const u8;

fn noOp(allocator: std.mem.Allocator, in: std.fs.File) anyerror![]const u8 {
    _ = in;
    _ = allocator;
    return "";
}

fn get(comptime container: anytype) PuzFn {
    if (@hasDecl(container, "puzzle")) {
        return @field(container, "puzzle");
    } else return noOp;
}

const puzzles = [25]PuzFn{
    get(@import("puzzles/day01.zig")),
    get(@import("puzzles/day02.zig")),
    get(@import("puzzles/day03.zig")),
    get(@import("puzzles/day04.zig")),
    get(@import("puzzles/day05.zig")),
    get(@import("puzzles/day06.zig")),
    get(@import("puzzles/day07.zig")),
    get(@import("puzzles/day08.zig")),
    get(@import("puzzles/day09.zig")),
    get(@import("puzzles/day10.zig")),
    get(@import("puzzles/day11.zig")),
    get(@import("puzzles/day12.zig")),
    get(@import("puzzles/day13.zig")),
    get(@import("puzzles/day14.zig")),
    get(@import("puzzles/day15.zig")),
    get(@import("puzzles/day16.zig")),
    get(@import("puzzles/day17.zig")),
    get(@import("puzzles/day18.zig")),
    get(@import("puzzles/day19.zig")),
    get(@import("puzzles/day20.zig")),
    get(@import("puzzles/day21.zig")),
    get(@import("puzzles/day22.zig")),
    get(@import("puzzles/day23.zig")),
    get(@import("puzzles/day24.zig")),
    get(@import("puzzles/day25.zig")),
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();

    const args: [][]u8 = try std.process.argsAlloc(arena.allocator());
    var puzzle: ?usize = null;
    switch (args.len) {
        1 => {},
        2 => {
            const p: usize = try std.fmt.parseInt(usize, args[1], 10);
            if (p < 1 or p > 25) {
                return error.InvalidPuzzleNumber;
            }
            puzzle = p - 1;
        },
        else => return error.UnknownArgumentGiven,
    }

    if (puzzle) |p| {
        try run_puzzle(arena.allocator(), puzzles[p], p + 1);
    } else {
        for (puzzles, 0..) |p, i| {
            try run_puzzle(arena.allocator(), p, i + 1);
        }
    }
}

fn run_puzzle(allocator: std.mem.Allocator, puzzle_fn: PuzFn, day: usize) !void {
    const num = try std.fmt.allocPrint(allocator, "{d:0>2}", .{day});
    defer allocator.free(num);

    const writer = std.io.getStdOut().writer();
    try writer.print("\nAttempting to run puzzle day{s}", .{num});

    var dir = try std.fs.cwd().openIterableDir("data", .{});
    defer dir.close();

    var iter = dir.iterate();
    var found_files: u32 = 0;
    while (try iter.next()) |e| {
        switch (e.kind) {
            .file => {
                const has_num: bool = std.mem.startsWith(u8, e.name, num);
                const is_in_file = std.mem.endsWith(u8, e.name, ".in");
                if (has_num and is_in_file) {
                    try writer.print("\n--> found file: {s}", .{e.name});
                    const in_file = try dir.dir.openFile(e.name, .{});
                    defer in_file.close();

                    const out_file_name = try allocator.alloc(u8, e.name.len);
                    _ = std.mem.replace(u8, e.name, "in", "ou", out_file_name);
                    defer allocator.free(out_file_name);

                    try writer.print("\n----> creating file: {s}", .{out_file_name});
                    const out_file = try dir.dir.createFile(out_file_name, .{});
                    defer out_file.close();

                    try out_file.writeAll(try puzzle_fn(allocator, in_file));
                    found_files += 1;
                }
            },
            else => {},
        }
    }

    if (found_files == 0) {
        try writer.print("\n--> no files found", .{});
    }
}

test {
    _ = @import("puzzles/day01.zig");
    _ = @import("puzzles/day02.zig");
    _ = @import("puzzles/day03.zig");
    _ = @import("puzzles/day04.zig");
    _ = @import("puzzles/day05.zig");
    _ = @import("puzzles/day06.zig");
    _ = @import("puzzles/day07.zig");
    _ = @import("puzzles/day08.zig");
    _ = @import("puzzles/day09.zig");
    _ = @import("puzzles/day10.zig");
    _ = @import("puzzles/day11.zig");
    _ = @import("puzzles/day12.zig");
    _ = @import("puzzles/day13.zig");
    _ = @import("puzzles/day14.zig");
    _ = @import("puzzles/day15.zig");
    _ = @import("puzzles/day16.zig");
    _ = @import("puzzles/day17.zig");
    _ = @import("puzzles/day18.zig");
    _ = @import("puzzles/day19.zig");
    _ = @import("puzzles/day20.zig");
    _ = @import("puzzles/day21.zig");
    _ = @import("puzzles/day22.zig");
    _ = @import("puzzles/day23.zig");
    _ = @import("puzzles/day24.zig");
    _ = @import("puzzles/day25.zig");
}
