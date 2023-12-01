const std = @import("std");
const utils = @import("../utils.zig");

pub fn puzzle(allocator: std.mem.Allocator, in: std.fs.File) ![]const u8 {
    var bytes = [5]u8{ 0, 0, 0, 0, 0 };
    _ = try in.read(&bytes);
    return try std.fmt.allocPrint(allocator, "we read in: {s}", .{bytes});
}

test "puzzle 1" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();

    const expected =
        \\ Some file contents.
        \\ Some more contents.
        \\ Woot. Woot.
    ;
    const t = try utils.TestFile.of(
        arena.allocator(),
        "some_file.in",
        expected,
    );
    defer t.del();

    const input = try t.file();
    defer input.close();

    const actual = try puzzle(arena.allocator(), input);
    try std.testing.expectEqualStrings("we read in:  Some", actual);
}
