FROM public.ecr.aws/lambda/nodejs:20

ARG LIBS=/usr/lib64
ARG OUT=/root/layers
ARG NODE_VERSION=20

# set up container
RUN yum -y update \
&& yum -y groupinstall "Development Tools" \
&& curl --silent --location https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash - \
&& yum install -y gcc-c++ cairo-devel libjpeg-turbo-devel pango-devel giflib-devel
# && yum install -y nodejs cairo cairo-devel cairomm-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel giflib-devel

RUN node --version

# will be created and become working dir
WORKDIR $OUT/nodejs

RUN npm install canvas@2.11.2 \
chartjs-plugin-datalabels@2.2.0 \
chartjs-node-canvas@4.1.6 \
chart.js@3.9.1

# will be created and become working dir
WORKDIR $OUT/lib

# gather missing libraries
RUN cp $LIBS/libblkid.so.1 . \
&& cp $LIBS/libmount.so.1 . \
&& cp $LIBS/libuuid.so.1 . \
&& cp $LIBS/libfontconfig.so.1 . \
&& cp $LIBS/libpixman-1.so.0 .


WORKDIR $OUT

RUN zip -r -9 node${NODE_VERSION}_canvas_layer.zip nodejs \
&& zip -r -9 node${NODE_VERSION}_canvas_lib64_layer.zip lib

ENTRYPOINT ["zip","-r","-9"]
CMD ["/out/layers.zip", $OUT]
