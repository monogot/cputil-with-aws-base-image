FROM public.ecr.aws/lambda/nodejs:22

RUN dnf update -y && \
    dnf install -y \
    dotnet-sdk-8.0 \
    git \
    # openssl \
    # openssl-devel \
    && dnf clean all

# RUN echo "OpenSSL Version Check:" && LD_LIBRARY_PATH="" openssl version -> OpenSSL 3.0.8 7 Feb 2023

# Copy package.json and install dependencies
COPY package.json ${LAMBDA_TASK_ROOT}
WORKDIR ${LAMBDA_TASK_ROOT}
RUN npm install
  
# Clone the repository and build cputil
RUN git clone https://github.com/star-micronics/cloudprnt-sdk.git /tmp/cloudprnt-sdk
WORKDIR /tmp/cloudprnt-sdk/CloudPRNTSDKSamples/cputil

RUN dotnet add package StarMicronics.CloudPRNT-Utility --version 1.1.2
RUN dotnet publish -o ${LAMBDA_TASK_ROOT}/cputil-linux-x64 -c Release -r linux-x64 --self-contained true
RUN rm -rf /tmp/cloudprnt-sdk /tmp/cputil

# Copy function code
COPY index.js ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler
CMD [ "index.handler" ]
