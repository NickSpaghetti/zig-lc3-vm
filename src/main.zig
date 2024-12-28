const std = @import("std");
const reg = @import("registers.zig");
const opCodes = @import("opcodes.zig");
const conditionFlags = @import("condition_flags.zig");
const trapCodes = @import("trap_codes.zig");
const instruction = @import("instruction.zig");
const trapCodeInstruction = @import("trap_code_instruction.zig");
const memoryManager = @import("memory_manager.zig");
const programLoader = @import("program_loader.zig");


pub fn main() !void {
    const MaxMemory = (1 << 16);
    const memory:  *[MaxMemory]u16 = undefined;
    const RegisterCount = 10;
    var registers: [RegisterCount]u16 = undefined;
    try programLoader.LoadArgs(memory);
    // Since xactly one condition flag should be set at a given time, we set it to Z flag.
    registers[@intFromEnum(reg.Registers.R_COND)] = @intFromEnum(conditionFlags.ConditionFlags.FL_ZRO);
    //set the PC to starting position
    // 0x3000 is the default
    const PC = enum(u16) {
      PC_START = 0x3000
    };
    registers[@intFromEnum(reg.Registers.R_PC)] = @intFromEnum(PC.PC_START);
    const isRunning = true;
    while(isRunning){
        const instr: u16 = memoryManager.memoryRead(memory,registers[@intFromEnum(reg.Registers.R_PC)]);
        registers[@intFromEnum(reg.Registers.R_PC)] += 1;
        const op: opCodes = instr >> 12;
        switch (op) {
            opCodes.OpCodes.ADD => instruction.Add(instr, registers),
            opCodes.OpCodes.AND => instruction.And(instr, registers),
            opCodes.OpCodes.NOT => instruction.Not(instr, registers),
            opCodes.OpCodes.BR => instruction.Branch(instr, registers),
            opCodes.OpCodes.JMP => instruction.Jump(instr, registers),
            opCodes.OpCodes.JSR => instruction.JumpToRegister(instr, registers),
            opCodes.OpCodes.LD => instruction.Load(instr, registers),
            opCodes.OpCodes.LDI => instruction.LoadIndirect(instr, registers),
            opCodes.OpCodes.LDR => instruction.LoadRegister(instr, registers),
            opCodes.OpCodes.LEA => instruction.LoadEffectiveAddress(instr, registers),
            opCodes.OpCodes.ST => instruction.Store(instr, registers),
            opCodes.OpCodes.STI => instruction.StoreIndirect(instr, registers),
            opCodes.OpCodes.STR => instruction.StoreRegister(instr, registers),
            opCodes.OpCodes.TRP => {
                registers[@intFromEnum(reg.Registers.R_R7)] = registers[@intFromEnum(reg.Registers.R_PC)];
                switch (instr & 0xFF) {
                    trapCodes.TrapCodes.TRAP_GETC => trapCodeInstruction.GetC(registers),
                    trapCodes.TrapCodes.TRAP_OUT => trapCodeInstruction.Out(registers),
                    trapCodes.TrapCodes.TRAP_PUTS => trapCodeInstruction.Puts(memory, registers),
                    trapCodes.TrapCodes.TRAP_IN => trapCodeInstruction.In(registers),
                    trapCodes.TrapCodes.TRAP_PUTSP => trapCodeInstruction.PutSPPuts(memory, registers),
                    trapCodes.TrapCodes.TRAP_HALT => {
                        isRunning = trapCodeInstruction.Halt(isRunning);
                    }
                }
            },
            opCodes.RES or opCodes.RTI => {},
            else => std.debug.panic("Bad optCode: &d", .{op}),
        }
    }

}