import sys
sys.path.append('../')
import os
from config.settings import config
from services.loggerService import loggerService
if __name__ == '__main__':
    try:
        env = sys.argv[1]
        if env in config['BUILDING']:
            result = config['BUILDING'][env]
            print(result)
        else:
            loggerService.warning('env not found!')
    except Exception as e:
        loggerService.error('Parameter missing!')