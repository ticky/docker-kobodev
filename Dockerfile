FROM debian:stretch

LABEL maintainer="Jessica Stokes <hello@jessicastokes.net>"

ENV TOOLCHAIN_VERSION 237f149333468e989a21bfe8bbfa72cc985b0951

ENV KOBO /kobo
ENV KOBOLABS $KOBO/KoboLabs

ENV DEBIAN_FRONTEND noninteractive

# System component update, install and cleanup
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        build-essential \
        gettext \
        autoconf \
        libtool \
        libglib2.0-dev \
        libc6:i386 \
        curl \
        unzip \
    && echo "dash dash/sh boolean false" | debconf-set-selections \
    && dpkg-reconfigure --frontend=noninteractive dash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Kobo toolchain image download, extract and configure
RUN echo "Changing directory to $KOBOLABS..." \
    && mkdir -p "$KOBOLABS" \
    && cd "$KOBOLABS" \
    && echo "Downloading toolchain..." \
    && curl -o "$KOBOLABS/toolchain.zip" \
        "https://github.com/kobolabs/Kobo-Reader/archive/$TOOLCHAIN_VERSION.zip" \
    && echo "Extracting toolchain..." \
    && unzip "$KOBOLABS/toolchain.zip" \
        -d "$KOBOLABS" \
    && mv "$KOBOLABS/Kobo-Reader-$TOOLCHAIN_VERSION"/* "$KOBOLABS" \
    && echo "Creating build directories..." \
    && mkdir -p "$KOBO/fs" "$KOBO/tmp" \
    && echo "Installing compiler..." \
    && "$KOBOLABS/toolchain/gcc-codesourcery-2010q1-202.bin" -i silent \
    && cd /root/CodeSourcery/Sourcery_G++_Lite/bin \
    && for f in arm-none-linux-gnueabi-* ; do ln -s $f arm-linux-${f:23}; done \
    && rm -rf \
        "$KOBOLABS/toolchain.zip" \
        "$KOBOLABS/Kobo-Reader-$TOOLCHAIN_VERSION" \
        "$KOBOLABS/toolchain/gcc-codesourcery-2010q1-202.bin" \
        "$KOBOLABS/.git"

ENV PATH=/root/CodeSourcery/Sourcery_G++_Lite/bin:$PATH

# Patches
RUN sed -ibak \
        -e 's/$MAKE install/$MAKE install_sw/' \
        "$KOBOLABS/build/scripts/openssl.sh" \
    && sed -ibak \
        -e "s/\.\/autogen\.sh/sed -ibak 's\/\^AM_C_PROTOTYPES\/\/' makefiles\/configure\.in\n\.\/autogen\.sh/" \
        "$KOBOLABS/build/scripts/libmng.sh" \
    && sed -ibak \
        -e 's/4.6.2/4.8.0/' \
        -e 's/-qt-gif//' \
        "$KOBOLABS/build/scripts/qt.sh"

# Build script config
RUN echo "Configuring build scripts..." \
    && echo "DEVICEROOT=$KOBOLABS/fs" \
        >> "$KOBOLABS/build/build-config-user.sh" \
    && echo "QT_EXTRA_ARGS=--prefix=$KOBO/qt" \
        >> "$KOBOLABS/build/build-config-user.sh"

# Toolchain build
RUN cd $KOBO/tmp \
    && echo "Building toolchain..." \
    && $KOBOLABS/build/build-all.sh

WORKDIR /src
CMD ["/bin/bash"]
