const std = @import("std");
const reg = @import("registers.zig");
const opCodes = @import("opcodes.zig");
const instruction = @import("instruction.zig");
const memoryManager = @import("memory_manager.zig");


pub fn main() !void {
    const max_memory = (1 << 16);
    const memory:  [max_memory]u16 = undefined;
    _ = memory;
    const register_count = 10;
    var registers: [register_count]u16 = undefined;
    LoadArgs();
    // Since xactly one condition flag should be set at a given time, we set it to Z flag.
    registers[reg.R_COND] = opCodes.FL_ZERO;
    //set the PC to starting position
    // 0x3000 is the default
    const PC = enum(u8) {
      PC_START = 0x3000
    };
    registers[reg.R_PC] = PC.PC_START;
    const isRunning = true;
    while(isRunning){
        const instr: u16 = memoryManager.memoryRead(registers[reg.R_PC]);
        registers[reg.R_PC] += 1;
        const op: opCodes = instr >> 12;
        switch (op) {
            opCodes.ADD => instruction.Add(),
            else => std.debug.panic("Bad optCode: &d", .{op}),
        }
    }

}

pub fn LoadArgs() void {
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
        if (!try readImage(arg)) {
            try std.io.getStdOut().writer().print("failed to load image: {s}\n", .{arg});
            std.process.exit(1);
        }
    }

}

pub fn readImage(filename: []const u8) !bool {
    // Implementation of readImage function goes here
    // Return true if successful, false otherwise
    _ = filename;
    return true;
}