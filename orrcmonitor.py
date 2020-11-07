#!/usr/bin/env python3
import sys
import os


# from typing import Any, Union, Tuple, Callable, TypeVar, Generic, Sequence, Mapping, List, Dict, Set, Deque
from typing import Any, Tuple, List, Dict, Set, Callable, Deque

from pathlib import Path
import re

from collections import namedtuple
from glob import iglob

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

KeyTup = namedtuple('KeyTup', 'ac, ar, ccs, hldrcs, \
                               city, r, rcs, rx, scs, tx')


def process_dic_result(arg: List[Dict[str, str]], *args, **kwargs) -> List[str]:
    result: List[str] = []
    headers: Set[str] = set()
    for d in arg:
        ks = set(d.keys())
        headers.update(ks)

    aa: List[str] = list(headers)
    aa.sort()
    keys: KeyTup = KeyTup._make(aa)
    keyseq: KeyTup = [
        keys.rcs,
        keys.hldrcs,
        keys.ccs,
        keys.scs,
        keys.tx,
        keys.rx,
        keys.city,
        keys.r,
        keys.ar,
        keys.ac,
    ]

    result.append('Information\n')

    result.append('\t'.join(keyseq) + '\n')
    for d in arg:
        myvals: List[str] = []
        for k in keyseq:
            myvals.append(d.get(k))
        lna = '\t'.join(myvals)
        #ln = f'{lna}\n'
        result.append(f'{lna}\n')

    return result


class PsudoMain:
    """

    """

    def _genoutPath(self):
        parent = self.fdfin.parent
        stem = f'{self.fdfin.stem}.tab'
        self.fdfout = parent / stem

    def __init__(self):
        self.fdfin: Path = Path('.')
        self.fdfout: Path = Path('.')
        self.pl = ProcessLine()

    def __str__(self) -> str:
        return 'not implemented'

    def __repr__(self) -> str:
        return 'not implemented'

    def doit(self, arg, *args, **kwargs) -> List[Dict[str, str]]:
        self.fdfin = FindDataFile(arg).doit()

        dic_result: List[Dict[str, str]] = []
        try:
            with open(self.fdfin, 'r') as df:
                line: str = df.readline()
                while line:
                    dic_result.append(self.pl.doit(line))
                    line = df.readline()

        except Exception as ex:
            raise
        result = process_dic_result(dic_result)
        self._genoutPath()
        try:
            with open(self.fdfout, 'w') as df:
                for ln in result:
                    df.write(ln)

        except Exception as ex:
            raise
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
        tds: List[str] = re.findall('(<td.+?>.*?</td>)', line)
        info: Dict[str, str] = {}
        for td in tds:
            stuff = re.findall(
                '<td.+?data-name=["](.+?)["]>([0-9A-Za-z)(._ ]*?)</td>', td)
            #assert 1 == len(stuff)
            info[stuff[0][0]] = stuff[0][1]  # if stuff[0][1] is empty

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

        _r: str = ''
        for _r in iglob(f'{self.dirpath}/**/{self.sfn}', recursive=True):
            break

        return Path(_r)


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
