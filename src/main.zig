const std = @import("std");

pub fn main() !void {
    const max_memory = (1 << 16);
    var memory:  [max_memory]u16 = undefined;
    const register_count = 10;
    var registers: [register_count]u16 = undefined;

}