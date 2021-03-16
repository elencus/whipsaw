FROM python:3.8

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
COPY /root/config.ini ${ibcIni}
COPY /root/jts.ini ${twsPath}/jts.ini

WORKDIR /root
COPY algotrader.py /root
COPY .env /root

RUN pip install ib_insync ibapi pytz python-dotenv numpy pandas pandas_ta asyncio regex

# EXPOSE 4000
EXPOSE 4002
# EXPOSE 7496
# EXPOSE 7947

CMD ["python", "./algotrader.py"]