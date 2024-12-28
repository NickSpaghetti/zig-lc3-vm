const std = @import("std");
const registers = @import("registers.zig");
const conditionFlags = @import("condition_flags.zig");
const memoryManager = @import("memory_manager.zig");

pub fn signExtended(x: u16, bitCount: i32) u16 {
    if (((x >> bitCount - 1 )) & 1) {
        x |= (0xFFFF << bitCount);
    }
    return x;
}

pub fn updateFlags(r: u16, reg: *[]u16) void {
    if (reg[r] == 0) {
        reg[@intFromEnum(registers.Register.R_COND)] = @intFromEnum(conditionFlags.ConditionFlags.FL_ZRO);
    }
    else if (reg[r] >> 15) { //a 1 in the left most bit indicates negative number
        reg[@intFromEnum(registers.Register.R_COND)] = @intFromEnum(conditionFlags.ConditionFlags.FL_NEG);
    }
    else {
            reg[@intFromEnum(registers.Register.R_COND)] = @intFromEnum(conditionFlags.ConditionFlags.FL_POS);
        }
}

pub fn Add(instr: u16, reg: *[]u16) void {
    // destination register (DR)
    // shift right 9 then apply the and operator against the last 3 signifigant bits
    const r0 = (instr >> 9) & 0x7;
    // first operand (SR1)
    // shift right 6 then apply the and operator against the last 3 signifigant bits.
    const r1 = (instr >> 6) & 0x7;
    //are we doing addition without having to store it in sr2 register.
    const immediateFlag = (instr >> 5) & 0x1;

    if(immediateFlag == 1) {
        const immediateValueFiveBits = signExtended(instr & 0x1F, 5);
        reg[r0] = reg[r1] + immediateValueFiveBits;
    }
    else {
        //apply logical and against instr and take the last 3 signifgiant bits
        const r2 = instr & 0x7;
        reg[r0] = reg[r1] + reg[r2];
    }
    updateFlags(r0, reg);

}


// LDI is used to load a vlaue from a location in memory to a register.
pub fn LoadIndirect(instr: u16, reg: *[]u16) void {
    // destination register (DR)
    // shift right 9 then apply the and operator against the last 3 signifigant bits
    const r0 = (instr >> 9) & 0x7;
    // add pc_offset to the current PC, look at that memory location to get the final address
    const pc_offset = signExtended(instr & 0xFF,9);
    //Calculate the effect_address by suming vaue at  reg[registers.Register.R_PC] + pc_offset
    //the second call to memoryRead gets the value exists at that effective memory address and be loaded into DR.
    reg[r0] = memoryManager.memoryRead(memoryManager.memoryRead(reg[@intFromEnum(registers.Register.Register.R_PC)]) + pc_offset);
    updateFlags(r0, reg);
}

//bitwise AND
pub fn And(instr: u16, reg: *[]u16) void {
    // destination register (DR)
    // shift right 9 then apply the and operator against the last 3 signifigant bits
    const r0 = (instr >> 9) & 0x7;
    // first operand (SR1)
    // shift right 6 then apply the and operator against the last 3 signifigant bits.
    const r1 = (instr >> 6) & 0x7;
    //are we doing addition without having to store it in sr2 register.
    const immediateFlag = (instr >> 5) & 0x1;

    if(immediateFlag == 1) {
        const immediateValueFiveBits = signExtended(instr & 0x1F, 5);
        reg[r0] = reg[r1] & immediateValueFiveBits;
    }
    else {
        //apply logical and against instr and take the last 3 signifgiant bits
        const r2 = instr & 0x7;
        reg[r0] = reg[r1] & reg[r2];
    }
    updateFlags(r0, reg);
}

//Bitwise not
pub fn Not(instr: u16, reg: *[]u16) void {
    // destination register (DR)
    // shift right 9 then apply the and operator against the last 3 signifigant bits
    const r0 = (instr >> 9) & 0x7;
    // first operand (SR)
    // shift right 6 then apply the and operator against the last 3 signifigant bits.
    const r1 = (instr >> 6) & 0x7;

    // apply bitwise not to r1
    reg[r0] = ~r1;
    updateFlags(r0, reg);
}

// Conditinal Branch
pub fn Branch(instr: u16, reg: *[]u16) void {
    const pc_offset = signExtended(instr & 0xFF,9);
    const conditionalFlag = (instr >> 9) & 0x7;

    if(conditionalFlag == 1 & reg[registers.Register.Register.R_COND]) {
       reg[@intFromEnum(registers.Register.Register.R_PC)] += pc_offset;
    }
}

// Jump will jump to the location specified by the contents of the base register
pub fn Jump(instr: u16, reg: *[]u16) void {
    const r1 = (instr >> 6) & 0x7;
   reg[@intFromEnum(registers.Register.Register.R_PC)] = reg[r1];
}

pub fn JumpToRegister(instr: u16, reg: *[]u16) void {
    const longFlag = (instr >> 11) & 1;
    //load PC into R7
    reg[registers.Register.Register.R_R7] =reg[@intFromEnum(registers.Register.Register.R_PC)];
    if(longFlag == 1) {
        const longPcOffset = signExtended(instr & 0x7FF, 11);
        //JSR
       reg[@intFromEnum(registers.Register.Register.R_PC)] = longPcOffset;
    }
    else {
        const r1 = (instr >> 6) & 0x7;
        //JSRR
       reg[@intFromEnum(registers.Register.Register.R_PC)] = reg[r1];
    }
}

//LD
pub fn Load(instr: u16, reg: *[]u16) void {
    const r0 = (instr >> 9) & 0x7;
    const pc_offset = signExtended(instr & 0xFF,9);
    reg[r0] = memoryManager.memoryRead(reg[@intFromEnum(registers.Register.Register.R_PC)] + pc_offset);
    updateFlags(r0, reg);
}

//LDR
pub fn LoadRegister(instr: u16, reg: *[]u16) void {
    const r0 = (instr >> 9) & 0x7;
    const r1 = (instr >> 6) & 0x7;
    const offset = signExtended(instr & 0x3F,6);
    reg[r0] = memoryManager.memoryRead(reg[r1] + offset);
    updateFlags(r0, reg);
}

//LEA
pub fn LoadEffectiveAddress(instr: u16, reg: []u16) void {
    const r0 = (instr >> 9) & 0x7;
    const pc_offset = signExtended(instr & 0x1FF,9);
    reg[r0] =reg[@intFromEnum(registers.Register.Register.R_PC)] + pc_offset;
    updateFlags(r0, reg);
}

//ST
pub fn Store(instr: u16, reg: []u16) void {
    const r0 = (instr >> 9) & 0x7;
    const pc_offset = signExtended(instr & 0x1FF,9);
    memoryManager.memoryWrite(reg[registers.Register.Register.R_PC] + pc_offset, reg[r0]);
}

//STI
pub fn StoreIndirect(instr: u16, reg: []u16) void {
    const r0 = (instr >> 9) & 0x7;
    const pc_offset = signExtended(instr & 0x1FF,9);
    memoryManager.memoryWrite(memoryManager.memoryRead(reg[registers.Register.Register.R_PC] + pc_offset), reg[r0]);
}

//STR
pub fn StoreRegister(instr: u16, reg: []u16) void {
    const r0 = (instr >> 9) & 0x7;
    const r1 = (instr >> 6) & 0x7;
    const offset = signExtended(instr & 0x3F,6);
    memoryManager.memoryWrite(reg[r1] + offset, reg[r0]);
}




