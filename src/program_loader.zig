const std = @import("std");
const utils = @import("utils.zig");

pub fn readImageFile(file: std.fs.File, memory: []u16) !void {
    // Read the origin
    var origin: u16 = undefined;
    _ = try file.reader().readInt(u16, std.builtin.Endian.big);
    origin = std.mem.bigToNative(u16, origin);

    //Calculate maximum read size
    const maxRead = 0 - origin;
    var p = memory[origin..];

    //Read the content of the file
    const bytesRead = try file.reader().readAll(std.mem.sliceAsBytes(p[0..maxRead]));
    const wordsRead = bytesRead / 2;

    //swap to little endian
    var i: usize = 0;
    while (i < wordsRead) : (i += 1) {
        p[i] = utils.swap16(p[i]);
    }
}

fn readImage(image_path: []const u8, memory: []u16) !bool {
    const file = std.fs.cwd().openFile(image_path, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return false;
    };
    defer file.close();

    try readImageFile(file,memory);
    return true;
}

pub fn LoadArgs(memory: []u16) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try std.io.getStdOut().writer().print("lc3 [image-file1] ...\n", .{});
        std.process.exit(2);
    }

    for (args[1..]) |arg| {
        if (!try readImage(arg,memory)) {
            try std.io.getStdOut().writer().print("failed to load image: {s}\n", .{arg});
            std.process.exit(1);
        }
    }

}
