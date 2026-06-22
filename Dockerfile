FROM debian:bookworm-slim

# Combining all system changes into one single layer to minimize image size
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    netcat-openbsd \
    cowsay \
    fortune \
    fortunes-min \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /usr/share/doc/* /usr/share/man/*

ENV PATH="$PATH:/usr/games"

RUN groupadd -r appuser && useradd -r -g appuser appuser
WORKDIR /app
RUN chown -R appuser:appuser /app

COPY --chown=appuser:appuser wisecow.sh .
RUN chmod +x wisecow.sh

USER appuser
EXPOSE 4499
CMD ["bash", "./wisecow.sh"]