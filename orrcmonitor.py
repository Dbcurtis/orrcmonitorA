#!/usr/bin/env python3
"""[summary]

    Raises:
        _: [description]
        _: [description]
        TypeError: [description]
        TypeError: [description]
        ex: [description]
        Exception: [description]

    Returns:
        [type]: [description]
    """
import sys
import os
# from typing import Any, Union, Tuple, Callable, TypeVar, Generic, Sequence, Mapping, List, Dict, Set, Deque
from typing import Any, Tuple, List, Dict, Set
from pathlib import Path
import re
from collections import namedtuple
from glob import iglob
import logging
import logging.handlers
from datetime import datetime as Dtc

LOGGER = logging.getLogger(__name__)
LOG_DIR = os.path.dirname(os.path.abspath(__file__)) + '/logs'
LOG_FILE = '/orrcmonitor'

EXITING = False

KeyTup = namedtuple('KeyTup', 'ac, ar, ccs, hldrcs, \
                    city, r, rcs, rx, scs, tx')
"""
    Each record in the extracted file has the following format and the KeyTup value:
    tx:     <td class="grid-cell Center" data-name="TxFreq">444.4500</td>  
    rx:     <td class="grid-cell Center" data-name="RxFreq">449.4500</td>
    city:   <td class="grid-cell"        data-name="NearestCity">Medford</td>
    rcs:    <td class="grid-cell Center" data-name="RepeaterCallSign">K7RVM</td>
    hldrcs: <td class="grid-cell Center" data-name="CoordinationHolder">K7RVM</td>
    ccs:    <td class="grid-cell Center" data-name="Contact">N6WN</td>
    scs:    <td class="grid-cell Center" data-name="Sponsor">K7RVM</td>
    r:      <td class="grid-cell Center" data-name="Region">5</td>
    ar:     <td class="grid-cell Center" data-name="ARRL_Region">South West Oregon</td>
    ac:     <td class="grid-cell"        data-name="ARRL_Code">oset(100.0)</td>    </tr>
"""


def process_dic_result(arg: List[Dict[str, str]], *args, **kwargs) -> List[str]:
    """[summary]

    Args:
        arg (List[Dict[str, str]]): a list of Dicts with html <td></td> per <tr>
        args and kwargs not used.

    Returns:
        List[str]: a list of str with the key row first and the data rows after
        tab seperated values.
    """

    result: List[str] = []

    def _setup_keys() -> List[str]:
        """returns a sorted list of keys in all of the dics in arg

        Returns:
            List[str]: [description]
        """

        _headers: Set[str] = set()
        for _ in arg:
            _ks = set(_.keys())
            _headers.update(_ks)

        _header_lst: List[str] = list(_headers)
        _header_lst.sort()
        return _header_lst

    keys: KeyTup = KeyTup._make(_setup_keys())
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

    dict=kwargs.get('prams',None)
    
    result.append('Information\n')  # title
    result.append('\t'.join(keyseq) + '\n')  # column titles
    for _ in arg:
        myvals: List[str] = [_.get(_k) for _k in keyseq]
        _lna = '\t'.join(myvals)
        result.append(f'{_lna}\n')
    return result


def process_line(line: str) -> Dict[str, str]:
    """Process_Line(string) -> Dict[str,str]

    Args:
        line (str): A line for a <td...> data </td> </tr>
        such as:(all one line)
        <td class="grid-cell Center" data-name="TxFreq">147.0000</td>
        <td class="grid-cell Center" data-name="RxFreq">147.6000</td>
        <td class="grid-cell"        data-name="NearestCity">Medford</td>
        <td class="grid-cell Center" data-name="RepeaterCallSign">K7RVM</td>
        <td class="grid-cell Center" data-name="CoordinationHolder">K7RVM</td>
        <td class="grid-cell Center" data-name="Contact">N6WN</td>
        <td class="grid-cell Center" data-name="Sponsor">K7RVM</td>
        <td class="grid-cell Center" data-name="Region">5</td>
        <td class="grid-cell Center" data-name="ARRL_Region">South Central Oregon</td>
        <td class="grid-cell" data-name="ARRL_Code">oewxt(123.0)</td>    
        </tr>

    Returns:
        Dict[str, str]: where the key is the data-name value
        (...data-name="TxFreq"> => a key of 'TxFreq' with a value of '1470000'

    """

    # find the data fields in the line <td> ... </td>
    _tds: List[str] = re.findall('(<td.+?>.*?</td>)', line)
    result: Dict[str, str] = {}
    for _ in _tds:
        # for each data field, get the field name as 0
        match: List[str] = re.findall(
            '<td.+?data-name=["](.+?)["]>([0-9A-Za-z)(._ ]*?)</td>', _)
        # result[key]=value
        # match[0][0] is the key and [0][1] is the value
        result[match[0][0]] = match[0][1]

    return result


class PsudoMain:
    """

    """

    def _getConfiguration(self) -> Dict[str, Any]:
        configP: Path = Path.home() / '.config' / 'orrccheck.d' / 'orrcprams.txt'
        dataP: Path = Path.home() / '.local' / 'share' / 'orrccheck' / \
            'www.orrc.org' / 'Coordinations'
        if not (configP.exists() and configP.is_file()):
            raise ValueError(
                'orrcprams.txt not in ~/.config/orrccheck.d/orrcprams.txt')
        if not (dataP.exists() and dataP.is_dir()):
            raise ValueError(
                '~.local/share/orrccheck/www.orrc.org/Coordinations directory does not exist')

        cleanlines: List[str] = []
        result: Dict[str, str] = {}
        try:
            rawlines: List[str] = []
            with open(configP, 'r') as infile:
                rawlines = infile.readlines()

            cleanlines: List[str] = [
                l for l in rawlines if not l.startswith('#') and len(l.strip()) > 0]
        except IOError as ioe:
            raise ioe

        for ln in cleanlines:
            aa = ln.split('\n')
            bb = aa[0].split('\n')
            code: List[str, str] = bb[0].split(':')
            result[code[0]] = code[1]

        #dataP:Path = Path.home() / '.local' / 'share' / 'orrccheck ' / 'www.orrc.org' / 'Coordinations'
        result['datap'] = dataP
        return result
    
    def _settimestamp(self):
        filename:str = self.fdfin.name
        match = re.search(r"_([0-9]{8})([0-9]{6})",filename)
        date=match.group(1)
        time=match.group(2)
        #looking for the numbers in k7rvmraw_20201229231119.txt
        year=date[0:4]
        mo = date[4:5]
        dy = date[6:7]
        hr = time[0:1]
        mn = time[2:3]
        sc = time[4:4]
        

    def _genoutPath(self):
        """[summary]
        """
        parent = self.fdfin.parent
        stem = f'{self.fdfin.stem}{self.ext}'
        self.fdfout = parent / stem

    def __init__(self, ext: str = '.tab'):
        self.prams: Dict[str, Any] = self._getConfiguration()
        self.fdfin: Path = self.prams['datap']
        self.fdfout: Path = Path('.')
        self.ext: str = ext
        self.prams['dataversion']=None

    def __str__(self) -> str:
        return 'not implemented'

    def __repr__(self) -> str:
        return 'not implemented'

    def doit(self, arg, *args, **kwargs) -> Path:
        """[summary]

        Args:
            arg ([type]): [description]

        Raises:
            _: [description]
            _: [description]

        Returns:
            Path: the path to the just created tab delimited file
        """
        self.fdfin = FindDataFile(
            self.fdfin, sfn=self.prams['deffilepre']).doit()

        self._settimestamp()
        dic_result: List[Dict[str, str]] = []
        lines: List[str] = []
        try:
            with open(self.fdfin, 'r') as df:
                lines = df.readlines()

            _: List[str] = lines[0].split('<tr>\n') # extract version from first line
            self.prams['dataversion']=_[0]
            lines[0] = '<tr>\n'    # replace line 0
            coordinations: List[List[str]] = []
            row:List[str] = []
            l:str=''
            #
            # generate a list of shortlines sans \n 
            #
            for l in lines:
                _ = l.split('\n') # lose the new line
                _shortline:str = _[0]

                if '<tr>' in _shortline: # start new row
                    row = []
                    row.append(_shortline)
                elif '</tr>' in _shortline: # end row
                    row.append(_shortline)
                    coordinations.append(row) 
                else:
                    row.append(_shortline) # add to row

            longlines:List[str] = []
            _longline:str=''
            for _ in coordinations:  # generate long line from the shorlines
                _longline = " ".join(_)
                longlines.append(_longline)

            for _longline in longlines: # generate the dics from the longline
                dic_result.append(process_line(_longline))

        except Exception as _:
            raise _
        # 
        # result is the tab delimited data suitable for a .txt file
        #
        result: List[str] = process_dic_result(dic_result, prams=self.prams)
        self._genoutPath()                 # generates the path for the linix storage
        cwdp: Path = Path.cwd() / self.fdfout.name # generate path for windows access

        try:
            with open(self.fdfout, 'w') as df:
                df.writelines(result)
            
            with open(cwdp, 'w') as cwdf:
                cwdf.writelines(result)

        except Exception as _:
            raise _
        return self.fdfout


class FindDataFile:
    """
    """

    def __init__(self, arg: Path, sfn='k7rvmraw.txt'):
        """Instantiates FindDataFile class

        Args:
            arg (Path): [description]
            sfn (str, optional): [filename and extension you are trying to find]. Defaults to 'k7rvmraw.txt'.

        Raises:
            TypeError: [If the arg is not a path]
            TypeError: [If the path does not exist or if it is not a directory]
        """
        if not isinstance(arg, Path):
            raise TypeError(f'{arg} must be a Path')
        self.dirpath: Path = arg

        if not (self.dirpath.exists() and self.dirpath.is_dir()):
            raise TypeError(f'{self.dirpath} must be a directory')

        self.sfn: str = sfn+'_[0-9]*.txt'

    def __str__(self) -> str:
        return f'searching for {self.sfn} under {self.dirpath}'

    def __repr__(self) -> str:
        return '%s(%r)' % (self.__class__, self.__dict__)

    def doit(self) -> Path:
        """[summary]

        Returns:
            Path: [description]
        """
        # result = (chain.from_iterable(
        # glob(os.path.join(x[0], FILE_NAME)) for x in os.walk('.')))

        _r: str = ''
        paths: List[Path] = []
        for _r in iglob(f'{self.dirpath}/{self.sfn}', recursive=False):
            paths.append(_r)

        paths.sort(reverse=True)
        return Path(paths[0])


def main():
    """[summary]

    Raises:
        ex: [description]
    """
    THE_LOGGER.info('main executed')
    try:
        _pm = PsudoMain()
        _pm.doit(Path.cwd())

    except Exception as ex:
        raise ex
    finally:
        pass


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
        main()

    except IOError as ioe:
        print(ioe)
        sys.exit(str(ioe))

    except ValueError as ve:
        print(ve)
        sys.exit(str(ve))

    except SystemError as se:
        print(se)
        sys.exit(str(se))

    except(Exception, KeyboardInterrupt) as exc:
        print(exc)
        sys.exit(str(exc))

    sys.exit('normal exit')
