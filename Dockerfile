# FFmpeg Docker Container
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install FFmpeg
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a working directory for media files
WORKDIR /media

# Set FFmpeg as the default command
ENTRYPOINT ["ffmpeg"]

# Default command shows FFmpeg version
CMD ["-version"]
