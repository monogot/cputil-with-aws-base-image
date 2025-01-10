# FROM amazonlinux:latest

# RUN dnf update -y && \
#     dnf install -y \
#     dotnet-sdk-8.0 \
#     git \
#     nodejs \
#     npm \
#     cmake \
#     tar \
#     autoconf \
#     automake \
#     libtool \
#     make \
#     gcc \
#     gcc-c++ \
#     # openssl \
#     # openssl-devel \
#     && dnf clean all

# # RUN echo "OpenSSL Version Check:" && LD_LIBRARY_PATH="" openssl version -> OpenSSL 3.0.8 7 Feb 2023

# # Copy package.json and install dependencies
# COPY package.json ${LAMBDA_TASK_ROOT}
# WORKDIR ${LAMBDA_TASK_ROOT}
# RUN npm install
  
# # Clone the repository and build cputil
# RUN git clone https://github.com/star-micronics/cloudprnt-sdk.git /cloudprnt-sdk
# WORKDIR /cloudprnt-sdk/CloudPRNTSDKSamples/cputil

# # ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
# RUN dotnet add package StarMicronics.CloudPRNT-Utility --version 1.1.2
# RUN dotnet publish -o ${LAMBDA_TASK_ROOT}/cputil-linux-x64 -c Release -r linux-x64 --self-contained true
# RUN rm -rf /cloudprnt-sdk /cputil

# WORKDIR ${LAMBDA_TASK_ROOT}

# # Copy function code
# COPY index.js ${LAMBDA_TASK_ROOT}

# # Install runtime interface client
# RUN npm install aws-lambda-ric

# ENTRYPOINT ["/usr/local/bin/npx", "aws-lambda-ric"]

# # Set the CMD to your handler
# CMD [ "index.handler" ]

# docker build --platform linux/amd64 -t aws-base-image-gg --no-cache .

FROM amazonlinux:latest

RUN dnf update -y && \
    dnf install -y \
    dotnet-sdk-8.0 \
    git \
    nodejs \
    npm \
    cmake \
    tar \
    autoconf \
    automake \
    libtool \
    make \
    gcc \
    gcc-c++ \
    # openssl \
    # openssl-devel \
    && dnf clean all

ENV LAMBDA_TASK_ROOT='/'

WORKDIR ${LAMBDA_TASK_ROOT}
  
# Clone the repository and build cputil
RUN git clone https://github.com/star-micronics/cloudprnt-sdk.git /cloudprnt-sdk
WORKDIR /cloudprnt-sdk/CloudPRNTSDKSamples/cputil

# ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true
RUN dotnet add package StarMicronics.CloudPRNT-Utility --version 1.1.2
RUN dotnet publish -o ${LAMBDA_TASK_ROOT}/cputil-linux-x64 -c Release -r linux-x64 --self-contained true
RUN rm -rf /cloudprnt-sdk /cputil

RUN echo "OpenSSL Version Check:" && openssl version

# Specify a volume for the compiled output
VOLUME ${LAMBDA_TASK_ROOT}/cputil-linux-x64

# docker build --progress=plain -t aws-base-image-gg --no-cache .
# docker run -v /dev/compile:/var/task/cputil-linux-x64 aws-base-image-gg:latest

# Required ENVs in AWS Lambda
# DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
# LD_LIBRARY_PATH=
