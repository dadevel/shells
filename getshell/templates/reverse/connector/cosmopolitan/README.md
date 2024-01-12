# TCP reverse shell with Cosmopolitan Libc

Thanks to the dark magic of [Cosmopolitan](https://github.com/jart/cosmopolitan/) the resulting binary runs natively on Linux, Windows and MacOS.

## Usage

Compile static binary.

~~~ bash
git clone --depth 1 https://github.com/jart/cosmopolitan.git
cp ./shell.c ./cosmopolitan/examples/
cd ./cosmopolitan/
make -j$(nproc) -O MODE=tiny
ls ./o/tiny/examples/shell.com
~~~
