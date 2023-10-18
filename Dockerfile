# Mesa3D Software Drivers
#
# VERSION ${MESA_VERSION}

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Build arguments.
ARG VCS_REF
ARG BUILD_DATE
ARG MESA_DEMOS="false"
ARG MESA_VERSION="23.2.1"

# Labels / Metadata.
# LABEL maintainer="James Brink, brink.james@gmail.com" \
#       decription="Mesa3D Software Drivers" \
#       version="${MESA_VERSION}" \
#       org.label-schema.name="Mesa3D-Software-Drivers" \
#       org.label-schema.build-date=$BUILD_DATE \
#       org.label-schema.vcs-ref=$VCS_REF \
#       org.label-schema.vcs-url="https://github.com/jamesbrink/docker-gource" \
#       org.label-schema.schema-version="1.0.0-rc1"

# Enable source code repositories.
RUN sed -i 's/# deb-src/deb-src/g' /etc/apt/sources.list

# Install all needed deps and compile the mesa llvmpipe driver from source.
RUN set -xe
RUN apt-get update -y && apt-get install -y build-essential git python3-dev python3-pip
RUN	apt-get build-dep -y mesa
RUN apt-get install -y wget
RUN	pip install mako
RUN pip install --user meson
RUN mkdir -p /var/tmp/build; \
    cd /var/tmp/build; \
    wget "https://mesa.freedesktop.org/archive/mesa-${MESA_VERSION}.tar.xz"; \
    tar xfv mesa-${MESA_VERSION}.tar.xz; \
    rm mesa-${MESA_VERSION}.tar.xz; \
    cd mesa-${MESA_VERSION}; \
    # ./configure --enable-glx=gallium-xlib --with-gallium-drivers=swrast,swr --disable-dri --disable-gbm --disable-egl --enable-gallium-osmesa --prefix=/usr/local; \
	# meson setup build64 --libdir lib64 --prefix $HOME/mesa -Dgallium-drivers=swrast -Dvulkan-drivers=swrast -Dbuildtype=release; \
    # make; \
    # make install; \
    # cd .. ; \
	meson setup builddir/ -Dprefix="/usr/local" -Dgallium-drivers=swrast -Dvulkan-drivers=swrast; \
	meson install -C builddir/; \
    rm -rf mesa-${MESA_VERSION};
    # if [ "${MESA_DEMOS}" == "true" ]; then \
    #     apk add --no-cache --virtual .mesa-demos-runtime-deps glu glew \
    #     && apk add --no-cache --virtual .mesa-demos-build-deps glew-dev freeglut-dev \
    #     && wget "ftp://ftp.freedesktop.org/pub/mesa/demos/mesa-demos-8.4.0.tar.gz" \
    #     && tar xfv mesa-demos-8.4.0.tar.gz \
    #     && rm mesa-demos-8.4.0.tar.gz \
    #     && cd mesa-demos-8.4.0 \
    #     && ./configure --prefix=/usr/local \
    #     && make \
    #     && make install \
    #     && cd .. \
    #     && rm -rf mesa-demos-8.4.0 \
    #     && apk del .mesa-demos-build-deps; \
    # fi; \
    # apk del .build-deps;

RUN apt-get install freeglut3-dev mesa-utils libgl1-mesa-glx -y

# Copy our entrypoint into the container.
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh

# Setup our environment variables.
ENV XVFB_WHD="1920x1080x24"\
    DISPLAY=":99" \
    LIBGL_ALWAYS_SOFTWARE="1" \
    GALLIUM_DRIVER="llvmpipe" \
    LP_NO_RAST="false" \
    LP_DEBUG="" \
    LP_PERF="" \
    LP_NUM_THREADS=""

# Set the default command.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
