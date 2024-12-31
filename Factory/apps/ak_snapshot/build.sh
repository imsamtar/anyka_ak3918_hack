mkdir -p obj
arm-anykav200-linux-uclibcgnueabi-gcc -fno-strict-aliasing -Os -w -D_GNU_SOURCE -std=c99 -fms-extensions $(pwd) -I$(pwd)/../lib/libplat/include -I -I -c -o obj/convert.o src/convert.c
arm-anykav200-linux-uclibcgnueabi-gcc -fno-strict-aliasing -Os -w -D_GNU_SOURCE -std=c99 -fms-extensions $(pwd) -I$(pwd)/../lib/libplat/include -I -I -c -o obj/main.o src/main.c
