# TCP reverse shell for multiple platforms with Cosmopolitan

Thanks to the dark magic of [cosmopolitan](https://github.com/jart/cosmopolitan/) the resulting binary can run on Linux, Windows and MacOS.

## Usage

Compile static binary.

~~~ bash
git clone --depth 1 https://github.com/jart/cosmopolitan.git
cp ./reverse/connector/cosmopolitan.c ./cosmopolitan/examples/shell.c
cd ./cosmopolitan/
make -j$(nproc) -O MODE=tiny
ls ./o/tiny/examples/shell.com
~~~
