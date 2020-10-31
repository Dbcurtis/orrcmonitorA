#!/usr/bin/env python3
import sys
import os


# from typing import Any, Union, Tuple, Callable, TypeVar, Generic, Sequence, Mapping, List, Dict, Set, Deque
from typing import Any, Tuple, List, Dict, Set, Callable, Deque

from pathlib import Path
import re

from collections import namedtuple
from glob import glob, iglob

import logging
import logging.handlers


from time import sleep as Sleep
from time import monotonic
from datetime import datetime as Dtc
from datetime import timezone
from collections import deque, namedtuple

LOGGER = logging.getLogger(__name__)

LOG_DIR = os.path.dirname(os.path.abspath(__file__)) + '/logs'
LOG_FILE = '/orrcmonitor'

EXITING = False


class PsudoMain:
    """
    (<td.+?>.+?</td>)
    (<td.+?data-name=["](.+?)["]>([0-9A-Za-z._]+?)</td>)
    """

    def __init__(self):
        pass

    def __str__(self) -> str:
        return 'not implemented'

    def __repr__(self) -> str:
        return 'not implemented'

    def doit(self, arg, *args, **kwargs) -> List[Dict[str, str]]:
        fdf: Path = FindDataFile(arg).doit()
        pl = ProcessLine()
        dic_result: List[Dict[str, str]] = []
        try:
            with open(fdf, 'r') as df:
                line: str = df.readline()
                while line:
                    dic_result.append(pl.doit(line))
                    line = df.readline()

        except Exception as ex:
            raise
        result = process_dic_result(dic_result)
        return result


class ProcessLine:
    """
    """

    def __init__(self):
        pass

    def __str__(self) -> str:
        return 'not implemented'

    def __repr__(self) -> str:
        return '%s(%r)' % (self.__class__, self.__dict__)

    def doit(self, line: str) -> Dict[str, str]:
        tds: List[str] = re.findall('(<td.+?>.+?</td>)', line)
        info: Dict[str, str] = {}
        for td in tds:
            stuff = re.findall(
                '<td.+?data-name=["](.+?)["]>([0-9A-Za-z)(._ ]+?)</td>', td)
            assert 1 == len(stuff)
            info[stuff[0][0]] = stuff[0][1]

        a = 0
        return info


class FindDataFile:
    """
    """

    def __init__(self, arg: Path, sfn='k7rvmraw.txt'):
        if not isinstance(arg, Path):
            raise TypeError(f'{arg} must be a Path')
        self.dirpath: Path = arg

        if not (self.dirpath.exists() and self.dirpath.is_dir()):
            raise TypeError(f'{dirpath} must be a directory')

        self.sfn: str = sfn

    def __str__(self) -> str:
        return f'searching for {self.sfn} under {self.dirpath}'

    def __repr__(self) -> str:
        return '%s(%r)' % (self.__class__, self.__dict__)

    def doit(self) -> Path:
        # result = (chain.from_iterable(
        # glob(os.path.join(x[0], FILE_NAME)) for x in os.walk('.')))

        result: Path = None
        for result in iglob(f'{self.dirpath}/**/{self.sfn}', recursive=True):
            a = 0
            break
        return result


def main():
    THE_LOGGER.info('main executed')
    try:
        _pm = PsudoMain()
        info = _pm.doit(Path.cwd())

    except Exception as ex:
        raise ex
    finally:
        pass


def test1():
    """FindDataFile_instat

    Test FindDataFile instantiation

    """
    try:
        _fdf = FindDataFile('junk')
        #self.fail('took string as path')
        a = 0
    except:
        pass
    try:
        _fdf = FindDataFile(Path.home() / 'gobblygook')
        #self.fail('took junk path as directory')
        a = 0
    except:
        pass
    print(Path.cwd())
    try:
        _fdf = FindDataFile(Path.cwd())
        pass
    except:
        a = 0


def test2():
    """FindDataFile_instat

    Test FindDataFile strings

    """
    _fdf = FindDataFile(Path.cwd())
    estr: str = 'searching for k7rvmraw.txt under m:\Python\Python3_packages\orrcmonitor'
    erepr: str = "<class '__main__.FindDataFile'>({'dirpath': WindowsPath('m:/Python/Python3_packages/orrcmonitor'), 'sfn': 'k7rvmraw.txt'})"
    assert estr == str(_fdf)
    assert erepr == repr(_fdf)


def test3():
    """FindDataFile_instat

    Test FindDataFile strings

    """
    _fdf = FindDataFile(Path.cwd())
    pth2file: Path = _fdf.doit()
    lines: List[str]
    with open(pth2file, 'r') as fl:
        lines = fl.readlines()
    assert len(lines) == 6

    a = 0
    pl = ProcessLine()
    stuff = pl.doit(lines[0])
    estuff = "{'TxFreq': '145.2400', 'RxFreq': '144.6400', 'NearestCity': 'Medford', 'RepeaterCallSign': 'KG7FOJ', 'CoordinationHolder': 'K7RVM', 'Contact': 'N6WN', 'Sponsor': 'K7RVM', 'Region': '5', 'ARRL_Region': 'South West Oregon', 'ARRL_Code': 'oe'}"
    assert str(stuff) == estuff

    result: List[Dict[str, str]] = []

    for l in lines:
        stuff = pl.doit(l)
        result.append(stuff)
    assert len(lines) == len(result)


if __name__ == '__main__':

    if not os.path.isdir(LOG_DIR):
        os.mkdir(LOG_DIR)

    LF_HANDLER = logging.handlers.RotatingFileHandler(
        ''.join([LOG_DIR, LOG_FILE, ]),
        maxBytes=10000,
        backupCount=5,
    )
    LF_HANDLER.setLevel(logging.DEBUG)
    LC_HANDLER = logging.StreamHandler()
    LC_HANDLER.setLevel(logging.DEBUG)  # (logging.ERROR)
    LF_FORMATTER = logging.Formatter(
        '%(asctime)s - %(name)s - %(funcName)s - %(levelname)s - %(message)s')
    LC_FORMATTER = logging.Formatter('%(name)s: %(levelname)s - %(message)s')
    LC_HANDLER.setFormatter(LC_FORMATTER)
    LF_HANDLER.setFormatter(LF_FORMATTER)
    THE_LOGGER = logging.getLogger()
    THE_LOGGER.setLevel(logging.DEBUG)
    THE_LOGGER.addHandler(LF_HANDLER)
    THE_LOGGER.addHandler(LC_HANDLER)
    THE_LOGGER.info('orrcmonitor executed as main')

    from platform import python_version
    print(python_version())

    try:
        val = 0
        if val == 0:
            main()

        elif val == 1:
            test1()
        elif val == 2:
            test2()
        elif val == 3:
            test3()
        elif val == 4:
            dataval1()

        else:
            raise Exception("wrong val")

    except(Exception, KeyboardInterrupt) as exc:
        print(exc)
        sys.exit(str(exc))

    except SystemError as se:
        print(se)
        sys.exit(str(se))

    finally:
        sys.exit('normal exit')
