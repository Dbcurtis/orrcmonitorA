#!/usr/bin/env python3
"""
Test file for need
"""


import os
import sys
from typing import Any, Tuple, List, Dict, Set
from pathlib import Path
import unittest
#import context
#import orrcmonitor


#import context

ppath = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(ppath)
from orrcmonitor import PsudoMain, FindDataFile, KeyTup, process_dic_result, main, process_line


class TestOrrcMonitor(unittest.TestCase):
    """

    """

    def setUp(self):
        """

        """
        pass

    def tearDown(self):
        """

        """
        pass

    @classmethod
    def setUpClass(cls):
        """

        """
        pass

    @classmethod
    def tearDownClass(cls):
        """

        """
        pass

    def test0000a_process_line(self):
        """

        """
        dic_result: Dict[str, str] = {}
        try:
            pth: Path = Path.cwd() / Path('tests') / Path('k7rvmraw.txt')
            with open(pth, 'r') as df:
                line: str = df.readline()
                dic_result = process_line(line)

        except Exception as e:
            self.fail(str(e))

        keys: Set[str] = set(dic_result.keys())
        keyol: List[str] = list(keys)
        keyol.sort()
        ans: str = "['ARRL_Code', 'ARRL_Region', 'Contact', 'CoordinationHolder', 'NearestCity', 'Region', 'RepeaterCallSign', 'RxFreq', 'Sponsor', 'TxFreq']"
        self.assertEqual(ans, str(keyol))
        sortedvals: List[str] = [dic_result[k] for k in keyol]
        ans = "['oe', 'South West Oregon', 'N6WN', 'K7RVM', 'Medford', '5', 'KG7FOJ', '144.6400', 'K7RVM', '145.2400']"
        self.assertEqual(ans, str(sortedvals))

    def test0000b_process_line(self):
        """

        """

        dic_result: List[Dict[str, str]] = []
        pth: Path = Path.cwd() / Path('tests') / Path('k7rvmraw.txt')
        ptht: Path = Path.cwd() / Path('tests') / Path('k7rvmraw.tab')
        tabedexp: List[str] = []
        try:
            with open(pth, 'r') as df:
                line: str = df.readline()
                while line:
                    dic_result.append(process_line(line))
                    line = df.readline()
            with open(ptht, 'r') as df1:
                tabedexp = df1.readlines()

        except Exception as _:
            self.fail('exception making dic_result')
        self.assertEqual(6, len(dic_result))
        result = process_dic_result(dic_result)
        self.assertEqual(8, len(result))
        self.assertEqual(8, len(tabedexp))
        for x, y in zip(result, tabedexp):
            self.assertEqual(x, y)

    def test0001_FindDataFile_instat(self):
        """FindDataFile_instat

        Test FindDataFile instantiation

        """
        try:
            _fdf = FindDataFile('junk')
            self.fail('took string as path')
        except:
            pass
        try:
            _fdf = FindDataFile(Path.home() / 'gobblygook')
            self.fail('took junk path as directory')
        except:
            pass
        print(Path.cwd())
        try:
            _fdf = FindDataFile(Path.cwd())
            pass
        except:
            self.fail('rejected a directory')
        a = 0

    def test0002_FindDataFile_instat(self):
        """FindDataFile_instat

        Test FindDataFile strings

        """
        _fdf = FindDataFile(Path.cwd())
        estr: str = str(_fdf)  # ''
        erepr: str = repr(_fdf)  # ''
        self.assertEqual(estr, str(_fdf))
        self.assertEqual(erepr, repr(_fdf))

    def test0003_FindDataFile_instat(self):
        """FindDataFile_instat

        Test FindDataFile strings

        """
        _fdf = FindDataFile(Path.cwd())
        pth2file: Path = _fdf.doit()
        self.assertEqual('k7rvmraw.txt', pth2file.name)
        lines: List[str] = []
        with open(pth2file, 'r') as fl:
            lines = fl.readlines()
        self.assertEqual(6, len(lines))

        estuff = "{'TxFreq': '145.2400', 'RxFreq': '144.6400', 'NearestCity': 'Medford', 'RepeaterCallSign': 'KG7FOJ', 'CoordinationHolder': 'K7RVM', 'Contact': 'N6WN', 'Sponsor': 'K7RVM', 'Region': '5', 'ARRL_Region': 'South West Oregon', 'ARRL_Code': 'oe'}"
        self.assertEqual(estuff, str(process_line(lines[0])))

        result: List[Dict[str, str]] = [
            process_line(_) for _ in lines
        ]
        self.assertEqual(len(lines), len(result))
        
    def test0003_PsudoMain(self):
        pm:PsudoMain = PsudoMain(ext='.dbg')
        astr:str=str(pm)
        arepr:str=repr(pm)
        self.assertEqual(astr,str(pm))
        self.assertEqual(arepr,repr(pm))
        
        dbgpth:Path = pm.doit(Path.cwd())
        ptht: Path = Path.cwd() / Path('tests') / Path('k7rvmraw.tab')
        chklines:List[str]=[]
        dbglines:List[str]=[]
        with open(ptht,'r') as tf:
            chklines=tf.readlines()
            
        with open(dbgpth,'r') as dbf:
            dbglines=dbf.readlines()

        for x, y in zip(chklines, dbglines):
            self.assertEqual(x, y)



if __name__ == '__main__':
    unittest.main()
