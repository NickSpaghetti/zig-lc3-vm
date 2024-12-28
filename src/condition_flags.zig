pub const ConditionFlags = enum(u16) {
    FL_POS = 1 << 0, // P = 1
    FL_ZRO = 1 << 1, // Z = 2
    FL_NEG = 1 << 2, // N = 4
};