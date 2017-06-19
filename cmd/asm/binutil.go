package main

type bitslice struct {
	value uint32
	size  uint32
}

func concat(slices ...bitslice) (concat uint32, err error) {
	offset := uint32(0)
	for i := len(slices) - 1; i >= 0; i-- {
		bits := slices[i]
		concat, err = emplace(concat, bits.value, offset, offset+bits.size)
		if err != nil {
			return
		}
		offset += bits.size
	}
	return
}

func bitmask(v, from, to uint32) uint32 {
	mask := uint32(1 << from)
	for i := from + 1; i < to; i++ {
		mask |= 1 << i
	}
	return mask & v
}

func getbits(v, from, to uint32) bitslice {
	return bitslice{bitmask(v, from, to) >> from, to - from}
}

func emplace(bits, v, from, to uint32) (uint32, error) {
	shiftv := v << from
	v = bitmask(shiftv, from, to)
	if v != shiftv {
		return bits, ErrValueDontFitImmediate
	}
	return bits | v, nil
}
