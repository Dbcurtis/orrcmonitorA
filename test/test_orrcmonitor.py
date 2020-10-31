#!/usr/bin/env python3
"""
Test file for need
"""


import unittest
import orrcmonitor
from orrcmonitor import ProcessLine, FindDataFile, PsudoMain, main
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
        a = 0


if __name__ == '__main__':
    unittest.main()
