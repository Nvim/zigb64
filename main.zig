const std = @import("std");
const b64 = @import("base64.zig");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    var mem: [1024]u8 = undefined;
    var heapAlloc = std.heap.FixedBufferAllocator.init(&mem);
    const alloc = heapAlloc.allocator();

    const base64 = b64.Base64.init();
    const ret: []u8 = try base64.encode(alloc, "Testing");
    try stdout.print("Testing => {s}\n", .{ret});
    try stdout.flush();
}
