# Usage: docker run --restart=always -v /var/data/blockchain-xmr:/root/.bitmonero -p 18080:18080 -p 18081:18081 --name=monerod -td kannix/monero-full-node
FROM ubuntu:18.04 AS build

ENV LOKI_VERSION=7.1.9 LOKI_SHA512=3c52512d51e710553b5601dbbe15a0123bc7e924f997334f6e57e181b457ff84
ENV LOKI_TAR=loki-linux-x64-v$LOKI_VERSION.tar.xz


RUN apt-get update && apt-get install -y curl xz-utils lib32readline7

WORKDIR /root

RUN curl -L https://github.com/loki-project/loki-core/releases/download/v$LOKI_VERSION/$LOKI_TAR -O &&\
#  echo "$LOKI_SHA512  $LOKI_TAR" | sha512sum -c  &&\
  tar -xvf loki-linux-x64-v$LOKI_VERSION.tar.xz &&\
  rm loki-linux-x64-v$LOKI_VERSION.tar.xz &&\
  cp ./loki-linux-x64-v$LOKI_VERSION/loki* . &&\
  rm -r loki-linux-*

FROM ubuntu:18.04

RUN useradd -ms /bin/bash loki && mkdir -p /home/loki/.loki && chown -R loki:loki /home/loki/.loki
USER loki
WORKDIR /home/loki

COPY --chown=loki:loki --from=build /root/lokid /home/loki/lokid
COPY --chown=loki:loki --from=build /root/loki-blockchain-ancestry /home/loki/loki-blockchain-ancestry
COPY --chown=loki:loki --from=build /root/loki-blockchain-depth /home/loki/loki-blockchain-depth
COPY --chown=loki:loki --from=build /root/loki-blockchain-export /home/loki/loki-blockchain-export
COPY --chown=loki:loki --from=build /root/loki-blockchain-import /home/loki/loki-blockchain-import
COPY --chown=loki:loki --from=build /root/loki-blockchain-mark-spent-outputs /home/loki/loki-blockchain-mark-spent-outputs
COPY --chown=loki:loki --from=build /root/loki-blockchain-stats /home/loki/loki-blockchain-stats
COPY --chown=loki:loki --from=build /root/loki-blockchain-usage /home/loki/loki-blockchain-usage
COPY --chown=loki:loki --from=build /root/loki-gen-trusted-multisig /home/loki/loki-gen-trusted-multisig
COPY --chown=loki:loki --from=build /root/loki-wallet-cli /home/loki/loki-wallet-cli
COPY --chown=loki:loki --from=build /root/loki-wallet-rpc /home/loki/loki-wallet-rpc

# blockchain loaction
VOLUME /home/loki/.loki

EXPOSE 22023

ENTRYPOINT ["./lokid"]
CMD ["--non-interactive", "--restricted-rpc", "--rpc-bind-ip=0.0.0.0", "--confirm-external-bind"]
