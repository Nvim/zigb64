const std = @import("std");
const b64 = @import("base64.zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const base64 = b64.Base64.init();
    try stdout.print("Char at index 42: {c}\n", .{base64._char_at(42)});
    try stdout.flush();
}
