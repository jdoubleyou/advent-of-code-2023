const std = @import("std");

pub fn readAll(allocator: std.mem.Allocator, file: std.fs.File) std.fs.File.ReadError![]u8 {
    const file_size = try file.getEndPos();
    return try file.readToEndAlloc(allocator, file_size);
}

pub const TestFile = struct {
    allocator: std.mem.Allocator,
    tempDir: std.testing.TmpDir,
    name: []const u8,

    const Self = @This();

    pub fn of(allocator: std.mem.Allocator, name: []const u8, contents: []const u8) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        var tempDir = std.testing.tmpDir(.{});

        const f = try tempDir.dir.createFile(name, .{ .read = true });
        try f.writeAll(contents);
        f.close();

        self.* = .{
            .allocator = allocator,
            .tempDir = tempDir,
            .name = name,
        };
        return self;
    }

    pub fn file(self: *const Self) !std.fs.File {
        return try self.tempDir.dir.openFile(self.name, .{});
    }

    pub fn del(self: *const Self) void {
        var t = self.tempDir; // dumb
        t.cleanup();
        self.allocator.destroy(self);
    }
};
