FROM julia:1.11-bookworm

# Set working directory
WORKDIR /app

# Copy all project files
COPY main.jl ./
COPY styles.jl ./
COPY utils.jl ./
COPY audio.mp3 ./
COPY ./langs ./langs
COPY ./assets ./assets

# Update & install required system packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xpra \
    python3 \
    python3-pip \
    curl \
    bash \
    ffmpeg \
    ca-certificates \
    fontconfig \
    libfreetype6 \
    libass9 \
    libbz2-1.0 \
    libjpeg62-turbo \
    libpng16-16 \
    alsa-utils \
    pulseaudio \
 && rm -rf /var/lib/apt/lists/* 

# Install gTTS for Python
RUN pip install --no-cache-dir --break-system-packages gTTS 
RUN pip install --no-cache-dir --break-system-packages pillow

RUN apt-get update && apt-get install -y \
    build-essential cmake g++ \
    libstdc++6 libatomic1 \
    git curl wget \
    && rm -rf /var/lib/apt/lists/* 

RUN apt-get update && apt-get install -y \
    g++ gcc make cmake \
    libstdc++-12-dev libunwind-dev libffi-dev libatomic1 \
    libssl-dev wget git curl \
 && rm -rf /var/lib/apt/lists/* 


# Install Julia via Juliaup (cached properly)
# RUN curl -fsSL https://install.julialang.org | bash -s -- -y \
#  && export PATH="/root/.juliaup/bin:$PATH" \
#  && juliaup default release 
#
# # Preinstall Julia packages to avoid recompile each run
# ENV PATH="/root/.juliaup/bin:$PATH"
ENV JULIA_CXXWRAP_FORCE_BUILD=1
RUN julia -e 'using Pkg; \
    Pkg.add(PackageSpec(name="CxxWrap", version="0.14.2")); \
    Pkg.add.(["TickTock", "DataStructures", "FFplay_jll"]); \
    Pkg.add(url="https://github.com/clemapfel/mousetrap_jll"); \
    Pkg.add(url="https://github.com/clemapfel/mousetrap.jl"); \
    Pkg.build("CxxWrap"); \
    Pkg.build("Mousetrap")' 

ENV PYTHON=/usr/bin/python3
RUN apt-get update && apt-get install -y python3-dev
RUN julia -e 'using Pkg; Pkg.add("PyCall")' 

EXPOSE 10000
ENV DISPLAY=:10

RUN apt-get update && apt-get install -y \
  libjs-jquery \
  libjs-jquery-ui \
  gnome-backgrounds || true \
  mate-backgrounds || true 
RUN apt-get install -y xpra dbus
RUN apt-get install dbus-x11
# RUN apt-get install -y wget && wget https://xpra.org/lts/jammy/main/binary-arm64/xpra-html5-5.6-r14-1.deb && apt-get -y install ./xpra-html5-5.6-r14-1.deb && rm -f xpra-html5-5.6-r14-1.deb 

# Add non-root user
# ARG UID=10001
# RUN useradd -m -u "${UID}" -s /usr/sbin/nologin appuser
# USER appuser

# RUN julia ./main.jl

# Xpra launch command
ENTRYPOINT ["xpra", "start", \
    "--start=julia ./main.jl", \
    ":10", \
    "--bind-tcp=0.0.0.0:10000", \
    "--html=on", \
    "--auth=none", \
    "--no-daemon"]

