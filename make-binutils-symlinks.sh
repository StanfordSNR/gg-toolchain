#!/bin/sh -xe

ln -sf /usr/bin/x86_64-linux-gnu-strip inst/bin/x86_64-linux-musl-strip
ln -sf /usr/bin/x86_64-linux-gnu-ranlib inst/bin/x86_64-linux-musl-ranlib
ln -sf /usr/bin/x86_64-linux-gnu-nm inst/bin/x86_64-linux-musl-nm
ln -sf /usr/bin/x86_64-linux-gnu-ld inst/bin/x86_64-linux-musl-ld
ln -sf /usr/bin/x86_64-linux-gnu-as inst/bin/x86_64-linux-musl-as
ln -sf /usr/bin/x86_64-linux-gnu-ar inst/bin/x86_64-linux-musl-ar
