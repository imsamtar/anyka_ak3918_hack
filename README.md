# Cross Compile

- Ubuntu 16.04 live USB (so I don't destroy my distro)
- connect to internet for install
- `dpkg --add-architecture i386`
- `sudo apt update`
- `sudo apt install git libc6:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386`
<!-- - `git clone https://github.com/helloworld-spec/qiwen.git` -->
- `wget https://github.com/helloworld-spec/qiwen/raw/refs/heads/main/anycloud39ev300/SDK/tools/anyka_uclibc_gcc.tar.bz2`
- `sudo tar -Pxvf anyka_uclibc_gcc.tar.bz2` (this will set up the compiler in /opt/)
- `echo "export PATH=\"$PATH:/opt/arm-anykav200-crosstool/usr/bin\"" > ~/.bashrc`
