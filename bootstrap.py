from ib_insync import IBC, IB, Watchdog
import os
import logging
from dotenv import load_dotenv
import sys
import regex
import algotrader

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        stream=sys.stdout,
                        format="[%(asctime)s]%(levelname)s:%(message)s")
    logging.info('start ib gateway...')
    with open(os.getenv('TWS_INSTALL_LOG'), 'r') as fp:
        install_log = fp.read()
    twsVersion = regex.search('IB Gateway ([0-9]{3})',
                              install_log).group(1)

    load_dotenv()
    userid = os.getenv('USERID')
    password = os.getenv('PASSWORD')
    dirname = os.path.dirname(os.path.abspath(__file__))
    twsPath = os.path.join(dirname, "Jts")
    ibcPath = os.path.join(dirname, "IBC")
    ibcIni = os.path.join(dirname, "IBC", "config.ini")
    ibc = IBC(
        # WINDOWS:
        # twsVersion=978,
        # LINUX:
        twsVersion=twsVersion,
        gateway=True,
        tradingMode='paper',
        twsPath=twsPath,
        twsSettingsPath="",
        ibcPath=ibcPath,
        ibcIni=ibcIni,
        userid=userid,
        password=password
    )
    ib = IB()

    def onConnected():
        logging.info('IB gateway connected')
        logging.info(ib.accountValues())

    def onDisconnected():
        logging.info('IB gateway disconnected')
    watchdog = Watchdog(ibc, ib, port=4002,
                        connectTimeout=30,
                        appStartupTime=120,
                        appTimeout=30)
    watchdog.startedEvent += onConnected
    watchdog.stoppedEvent += onDisconnected
    watchdog.start()
    logging.info("Watchdog Started.")
    ib.run()
    logging.info('IB gateway is ready.')
