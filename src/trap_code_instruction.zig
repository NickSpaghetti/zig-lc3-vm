const std = @import("std");
const register = @import("registers.zig");
const instruction = @import("instruction.zig");

//PUTS trap code is used to ouptut a null-terminated string
pub fn Puts(memory: []u16, reg: []u16) void {
    var c: [*]u16 = @ptrCast(&memory[reg[register.R_R0]]);
    while(c[0] != 0){
        std.debug.print("{c}", .{@as(u8, @truncate(c[0]))});
        c += 1;
    }
    std.io.getStdOut().writer().flush() catch unreachable;
}

// Get Input Character
pub fn GetC(reg: []u16) void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeByte(@as(u8, @truncate(reg[register.R_R0])));
    try stdout.flush();
}

// Output Character
pub fn Out(reg: []u16) void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeByte(@as(u8, @truncate(reg[register.R_R0])));
    try stdout.flush();
}

//Prompt for Input Character
pub fn In(reg: []u16) void {

    std.debug.print("Enter a character: ", .{});
    const c = std.io.getStdIn().reader().readByte() catch |err| {
    std.debug.print("Error reading input: {}\n", .{err});
    return;
    };
    const stdout = std.io.getStdOut().writer();
    try stdout.writeByte(c);
    try stdout.flush();
    reg[register.R_R0] = c;
    instruction.updateFlags(c, reg);
}

//Output String
pub fn PutSP(memory: []u16, reg: []u16) !void {
    const stdout = std.io.getStdOut().writer();
    var c: [*]u16 = @ptrCast(&memory[reg[register.R_R0]]);

    while (c[0] != 0) {
        const char1 = @as(u8, @truncate(c[0] & 0xFF));
        try stdout.writeByte(char1);

        const char2 = @as(u8, @truncate(c[0] >> 8));
        if (char2 != 0) {
            try stdout.writeByte(char2);
        }

        c += 1;
    }

    try stdout.flush();
}

//Halts the Program
pub fn Halt(isRunning: bool) !bool {
    if(!isRunning){
        std.debug.panic("Some how we got to Halt while the program is not running.", .{});
        return false;
    }
    try std.io.getStdOut().writeAll("HALT\n");
    try std.io.getStdOut().flush();
    return false;

}
