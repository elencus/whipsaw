FROM python:3.8

# install dependencies
RUN  apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y wget unzip xvfb libxtst6 libxrender1 python3.7-dev build-essential net-tools x11-utils socat


ENV twsPath=/root/Jts \
    ibcPath=/root/IBC \
    TWS_INSTALL_LOG=/root/Jts/tws_install.log

# make dirs
RUN mkdir -p /tmp && mkdir -p ${ibcPath} && mkdir -p ${twsPath}

# make dirs
RUN mkdir -p /tmp && mkdir -p ${ibcPath} && mkdir -p ${twsPath}

# download IB TWS
RUN wget -q -O /tmp/ibgw.sh https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod +x /tmp/ibgw.sh

# download IBC
RUN wget -q -O /tmp/IBC.zip https://github.com/IbcAlpha/IBC/releases/download/3.8.2/IBCLinux-3.8.2.zip
RUN unzip /tmp/IBC.zip -d ${ibcPath}
RUN chmod +x ${ibcPath}/*.sh ${ibcPath}/*/*.sh

# install TWS, write output to file so that we can parse the TWS version number later
RUN yes n | /tmp/ibgw.sh > ${TWS_INSTALL_LOG}

# remove downloaded files
RUN rm /tmp/ibgw.sh /tmp/IBC.zip

# copy IBC/Jts configs
COPY /config.ini ${ibcIni}
COPY /jts.ini ${twsPath}/jts.ini

# copy cmd script
WORKDIR /root
COPY cmd.sh /root/cmd.sh
RUN chmod +x /root/cmd.sh

COPY algotrader.py /root
RUN chmod +x /root/algotrader.py
COPY bootstrap.py /root
RUN chmod +x /root/bootstrap.py
COPY .env /root

RUN pip install ib_insync ibapi pytz python-dotenv numpy pandas pandas_ta asyncio regex

# set display environment variable (must be set after TWS installation)
ENV DISPLAY=:0
ENV GCP_SECRET=False

ENV IBGW_PORT 4002

EXPOSE $IBGW_PORT

ENTRYPOINT [ "sh", "/root/cmd.sh" ] 