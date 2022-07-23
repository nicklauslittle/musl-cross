ARG TARGET=x86_64-linux-musl
# aarch64[_be]-linux-musl
# arm[eb]-linux-musleabi[hf]
# i*86-linux-musl
# microblaze[el]-linux-musl
# mips-linux-musl
# mips[el]-linux-musl[sf]
# mips64[el]-linux-musl[n32][sf]
# powerpc-linux-musl[sf]
# powerpc64[le]-linux-musl
# riscv64-linux-musl
# s390x-linux-musl
# sh*[eb]-linux-musl[fdpic][sf]
# x86_64-linux-musl[x32]
ARG GCC_VER=11.3.0
# 11.3.0
# 10.3.0
# 9.4.0
# 9.2.0
# 8.5.0
# 7.5.0
# 6.5.0
# 5.3.0
# 4.2.1

# Build using Alpine image
FROM alpine AS build
RUN apk add make g++ git patch xz

RUN git clone https://github.com/richfelker/musl-cross-make.git
RUN mv musl-cross-make/patches/gcc-11.2.0 musl-cross-make/patches/gcc-11.3.0
RUN echo "cf86a48278f9a6f4b03d4390550577b20353b4e9  gcc-11.3.0.tar.xz" > musl-cross-make/hashes/gcc-11.3.0.tar.xz.sha1
RUN make -C musl-cross-make TARGET=${TARGET} GCC_VER=${GCC_VER} COMMON_CONFIG='CC="gcc -static --static" CXX="g++ -static --static" CFLAGS="-g0 -O3 -fPIC" CXXFLAGS="-g0 -O3 -fPIC" LDFLAGS="-s" --disable-shared --enable-static' install

# Copy toolchain into scratch image
FROM scratch AS deploy
COPY --from=build /musl-cross-make/output/ /

ENTRYPOINT ["/bin/${TARGET}-g++"]
CMD ["--help"]
