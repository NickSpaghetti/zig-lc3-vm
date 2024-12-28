const std = @import("std");


//swap bits from big endian to little endian and vise versa
pub fn swap16(x: u16) u16 {
    //swap the bit order
    //BE: The most significant byte is stored at the lowest memory address.
    //LE: The least significant byte is stored at the lowest memory address.
    return (x << 8) | (x >> 8);
}

