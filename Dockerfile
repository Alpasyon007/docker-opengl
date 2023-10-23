# Mesa3D Software Drivers
#
# VERSION ${MESA_VERSION}

FROM nvidia/cuda:12.2.0-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

# Build arguments.
ARG VCS_REF
ARG BUILD_DATE
ARG MESA_VERSION="21.2.6"

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

# Install all needed dependencies.
RUN set -xe \
    && apt-get update -y \
    && apt-get install -y build-essential git python3-dev python3-pip wget libdrm-dev pkg-config \
                       llvm-dev libwayland-dev wayland-protocols libwayland-egl-backend-dev \
                       libx11-dev libxext-dev libxfixes-dev libxcb-glx0-dev libxcb-shm0-dev \
                       libx11-xcb-dev libxcb-dri2-0-dev libxcb-dri3-dev libxcb-present-dev \
                       libxshmfence-dev libxxf86vm-dev libxrandr-dev ninja-build bison flex \
                       freeglut3-dev

RUN	pip install mako meson

# Get Mesa3D source code.
RUN mkdir -p /var/tmp/build; \
    cd /var/tmp/build; \
    wget "https://mesa.freedesktop.org/archive/mesa-${MESA_VERSION}.tar.xz"; \
    tar xfv mesa-${MESA_VERSION}.tar.xz; \
    rm mesa-${MESA_VERSION}.tar.xz;

RUN cd /var/tmp/build; \
    wget "https://archive.mesa3d.org/demos/8.5.0/mesa-demos-8.5.0.tar.gz"; \
    tar xfv mesa-demos-8.5.0.tar.gz; \
    rm mesa-demos-8.5.0.tar.gz;

# Build Mesa3D.
RUN meson setup /var/tmp/build/mesa-${MESA_VERSION} /usr/local \
                                                         -Dglx=gallium-xlib \
                                                         -Dgallium-drivers=swrast \
                                                         -Dplatforms=x11 \
                                                         -Ddri3=false \
                                                         -Ddri-drivers="" \
                                                         -Dvulkan-drivers="" \
                                                         -Dbuildtype=release \
                                                         -Doptimization=3 \
                                                         -Dprefix=/usr/local

RUN meson install -C /usr/local;

RUN	meson setup /var/tmp/build/mesa-demos-8.5.0 /var/tmp/build/mesa-demos-8.5.0/builddir -Dprefix=/var/tmp/build/mesa-demos-8.5.0/builddir;
RUN meson install -C /var/tmp/build/mesa-demos-8.5.0/builddir;