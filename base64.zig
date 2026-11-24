const std = @import("std");

// 3 raw bytes => 4 encoded bytes
fn _calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        return 4;
    }

    const n_groups: usize = try std.math.divCeil(usize, input.len, 3);
    return n_groups * 4;
}

// 4 encoded bytes => 3 decoded bytes
fn _calc_decode_length(input: []const u8) !usize {
    if (input.len < 4) {
        return 3;
    }

    const n_groups: usize = try std.math.divCeil(usize, input.len, 4);
    var ret: usize = n_groups * 3;

    // ignore '=' sign
    var i: usize = input.len - 1;
    while (i > 0) : (i -= 1) {
        if (input[i] == '=') {
            ret -= 1;
        } else {
            break;
        }
    }

    return ret;
}

pub const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";

        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    pub fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        const n_out = try _calc_encode_length(input);
        var out = try allocator.alloc(u8, n_out);
        var buf = [3]u8{ 0, 0, 0 };

        var count: u8 = 0;
        var iout: u64 = 0;

        for (input) |c| {
            buf[count] = c;
            count += 1;

            if (count == 3) {
                // flush buf & append new char to output
                const mask1: u64 = (buf[0] & 0b00000011) << 4;
                const mask2: u64 = (buf[1] & 0b00001111) << 2;

                out[iout] = self._char_at(buf[0] >> 2);
                out[iout + 1] = self._char_at(mask1 + (buf[1] >> 4));
                out[iout + 2] = self._char_at(mask2 + (buf[2] >> 6));
                out[iout + 3] = self._char_at(buf[2] & 0b00111111);

                iout += 4;
                count = 0;
            }
        }

        // 1 remaining sinlge byte: pad with =
        if (count == 1) {
            out[iout] = self._char_at(buf[0] >> 2);
            out[iout + 1] = (buf[0] & 0b00000011) << 4;
            out[iout + 2] = '=';
            out[iout + 3] = '=';
        }

        if (count == 2) {
            const mask1: u64 = (buf[0] & 0b00000011) << 4;

            out[iout] = self._char_at(buf[0] >> 2);
            out[iout + 1] = self._char_at(mask1 + (buf[1] >> 4));
            out[iout + 2] = self._char_at((buf[1] & 0b00001111) << 2);
            out[iout + 3] = '=';
        }

        return out;
    }

    fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
};
