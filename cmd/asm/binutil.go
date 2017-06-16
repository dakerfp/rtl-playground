package main

func bitmask(v, from, to uint32) uint32 {
	mask := uint32(1 << from)
	for i := from + 1; i <= to; i++ {
		mask |= 1 << i
	}
	return mask & v
}

func emplace(bits, v, from, to uint32) (uint32, error) {
	shiftv := v << from
	v = bitmask(shiftv, from, to)
	if v != shiftv {
		return bits, ErrValueDontFitImmediate
	}
	return bits | v, nil
}
