# Use an official Python runtime as a parent image
FROM python:3.13-slim

RUN apt-get update && apt-get install -y libaio1 wget unzip

WORKDIR /opt/oracle

RUN wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip && \
    unzip instantclient-basiclite-linuxx64.zip && rm -f instantclient-basiclite-linuxx64.zip && \
    cd /opt/oracle/instantclient* && rm -f *jdbc* *occi* *mysql* *mql1* *ipc1* *jar uidrvci genezi adrci && \
    echo /opt/oracle/instantclient* > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

# Set the working directory in the container
WORKDIR /app

ADD runner/runner.py /app
ADD runner/requirements.txt /app
#COPY . /app

# Install any needed dependencies specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


# Define environment variable
#ENV NAME World

CMD ["python", "runner.py"]