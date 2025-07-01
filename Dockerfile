FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    build-essential wget subversion git curl \
    libxml2-dev uuid-dev libsqlite3-dev \
    libjansson-dev libssl-dev libedit-dev \
    libncurses5-dev uuid-dev

WORKDIR /usr/src
RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz && \
    tar xvf asterisk-20-current.tar.gz && \
    rm asterisk-20-current.tar.gz

WORKDIR /usr/src/asterisk-20.*
RUN contrib/scripts/install_prereq install
RUN ./configure --with-pjproject-bundled --with-jansson-bundled

RUN make menuselect.makeopts
RUN menuselect/menuselect --enable res_pjsip_transport --enable res_pjsip_udp --enable res_pjsip_tcp --enable chan_pjsip menuselect.makeopts

RUN make -j$(nproc) && make install && make samples

CMD ["asterisk", "-f", "-U", "root"]
