const std = @import("std");
const memoryMappedRegisters = @import("memory_mapped_registers.zig");

pub fn memoryWrite(memory: []u16, address: u16, value: u16) void {
    memory[address] = value;
}

pub fn memoryRead(memory: []u16, address: u16) !u16{

    if(address == memoryMappedRegisters.MemoryRegisters.MR_KBSR){
        if(true){
            if ((keyboardRead())) {
                memory[memoryMappedRegisters.MemoryRegisters.MR_KBSR] = 1 << 15;
                memory[memoryMappedRegisters.MR_KBDR] = @as(u16, std.io.getStdIn().reader().readByte() catch 0);
            } else {
                memory[memoryMappedRegisters.MemoryRegisters.MR_KBSR] = 0;
            }
        }
    }
    return memory[address];
}

fn keyboardRead() !u16 {
    var stdin = std.os.getStdIn().reader();
    var buffer: [1]u8 = undefined;

    // Read a single byte
    const bytesRead = try stdin.readAll(&buffer);
    if (bytesRead == 0) {
        return 0; // No input received
    }

    const symb = buffer[0];

    // Check for control keys (example: Escape or Ctrl+C)
    if (symb == 27) { // ASCII for Escape
        std.debug.print("Pressed escaping\n", .{});
        std.os.exit(-2);
    } else if (symb == 3) { // ASCII for Ctrl+C (0x03)
        std.debug.print("Pressed Ctrl+C\n", .{});
        std.os.exit(-2);
    }

    return @as(u16, symb);
}