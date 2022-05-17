FROM ubuntu:latest as build_env

RUN apt-get update 
RUN apt -y --no-install-recommends --no-install-suggests install \
build-essential \
git \
autopoint \
intltool \
imagemagick \
graphicsmagick \
libmagickcore-dev \
pstoedit \
libpstoedit-dev \
libtool \
cargo

RUN apt clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
apt autoremove -y

RUN /bin/sh -c cd /tmp && \
git clone https://github.com/RazrFalcon/svgcleaner.git && \
cd svgcleaner && \
cargo install --path . --root /usr/local && \
cd .. && \
rm svgcleaner -Rf

RUN /bin/sh -c cd /tmp && \
git clone --depth 1 https://github.com/autotrace/autotrace.git && \
cd autotrace && \
./autogen.sh && \
LD_LIBRARY_PATH=/usr/local/lib \
./configure --prefix=/usr/local && \
make && \
make install && \
cd .. && \
rm autotrace -Rf

RUN /bin/sh -c cd /tmp && \
git clone https://github.com/tomkwok/svgasm && \
cd svgasm/ && \
make && \
cp svgasm /usr/local/bin && \
cd .. && \
rm svgasm -Rf

RUN apt remove build-essential cargo libmagickcore-dev libpstoedit-dev libtool -y
RUN apt autoremove -y



FROM ubuntu:latest

RUN apt-get update 
RUN apt -y --no-install-recommends --no-install-suggests install \
autopoint \
imagemagick \
graphicsmagick \
pstoedit 

COPY --from=build_env /usr/local /usr/local
COPY --from=build_env /usr/local/lib /usr/local/lib

RUN mkdir /data
VOLUME ["/data"]

ENV LD_LIBRARY_PATH=/usr/local/lib