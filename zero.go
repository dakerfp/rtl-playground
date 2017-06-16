package main

import (
	"io"
)

type ZeroPad struct {
	w     io.WriteCloser
	nleft int
}

func (z *ZeroPad) Fill() (err error) {
	var i, n int
	for i = 0; i < z.nleft; i += n {
		n, err = z.w.Write([]byte{0})
		if err != nil {
			return
		}
	}
	// ZeroPad should be invalid after this
	z.nleft -= i
	return
}

func (z *ZeroPad) Write(b []byte) (int, error) {
	n, err := z.w.Write(b)
	z.nleft -= n
	return n, err
}

func (z *ZeroPad) Close() error {
	err := z.Fill()
	if err != nil {
		return err
	}
	return z.w.Close()
}
