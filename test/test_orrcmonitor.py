#!/usr/bin/env python3
"""
Test file for need
"""

from typing import Any, Tuple, List, Dict, Set
import unittest
import context
#import orrcmonitor
from orrcmonitor import  FindDataFile, PsudoMain, main, process_line
from pathlib import Path
#import context


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
        a=0

    def test0002_FindDataFile_instat(self):
        """FindDataFile_instat

        Test FindDataFile strings

        """
        _fdf = FindDataFile(Path.cwd())
        estr: str = str(_fdf)  # ''
        erepr: str = repr(_fdf)  # ''
        self.assertEqual(estr, str(_fdf))
        self.assertEqual(erepr, repr(_fdf))
        a=0

    def test0003_FindDataFile_instat(self):    
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

        stuff = process_line(lines[0])
        estuff = "{'TxFreq': '145.2400', 'RxFreq': '144.6400', 'NearestCity': 'Medford', 'RepeaterCallSign': 'KG7FOJ', 'CoordinationHolder': 'K7RVM', 'Contact': 'N6WN', 'Sponsor': 'K7RVM', 'Region': '5', 'ARRL_Region': 'South West Oregon', 'ARRL_Code': 'oe'}"
        assert str(stuff) == estuff

        result: List[Dict[str, str]] = []

        for l in lines:
            stuff = process_line(l)
            result.append(stuff)
        assert len(lines) == len(result)
        a=0
        """FindDataFile_instat

        Test FindDataFile strings

        """



if __name__ == '__main__':
    unittest.main()
