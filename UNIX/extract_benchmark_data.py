#!/usr/bin/python

import argparse
import azure_table_functions
import getpass
import json
import os
import sys
import time

parser = argparse.ArgumentParser(
           description='Extract benchmark testData from log file and store to DB'
         )
parser.add_argument('--logfile',
                    type=str,
                    required=True,
                    help='path to log file containing benchmark testData')
parser.add_argument('--store-to-db',
                    default=False,
                    action='store_true',
                    help='store the benchmark testData to an azure table storage')
parser.add_argument('--output-type',
                    type=str,
                    choices=['text', 'json'],
                    help='output type to print the benchmark testData')
args = parser.parse_args()


class LogFile:
  def __init__(self, logFile, outputType):
    self.logFile = logFile
    self.outputType = outputType

  def splitEntry(self, entry):
    return entry.split(':')

  def getVal(self, arr, i):
    return arr[i].strip() \
                 .replace('"', '')

  def getEntryTypeVal(self, entry):
    arr = self.splitEntry(entry)
    if len(arr) < 2:
      return (False, None, None)
    return (True, self.getVal(arr, 0), self.getVal(arr, 1))

  def getEntryVal(self, entry):
    arr = self.splitEntry(entry)
    if len(arr) < 2:
      return (False, None)
    return (True, self.getVal(arr, 1))

  def printData(self, name, val):
    print '{0}:{1}'.format(name, val)

  def getRunData(self):
    runData = {}
    runData['user'] = getpass.getuser()
    runData['timestamp'] = time.time()
    return runData

  def getTestData(self):
    testData = {}
    with open(self.logFile) as lines:
      for line in lines:
        line = line.strip()

        if line.startswith('***'):
          line = line.replace('*', '') \
                     .replace('::', ':') \
                     .replace("TEST 'test-suite", 'TEST') \
                     .replace("' RESULTS", '') \
                     .replace('.test', '')

          (res, testType, name) = self.getEntryTypeVal(line)
          if not res:
            continue
          if testType == 'TEST':
            testName = name
            testData[testName] = {}
            testData[testName]['exec_times'] = {}
            testData[testName]['section_sizes'] = {}
          microTestName = name

          if outputType == 'text':
            self.printData(testType, testName)

        elif line.startswith('compile_time:'):
          (res, compileTime) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['compile_time'] = compileTime

          if outputType == 'text':
            self.printData('compile_time', compileTime)

        elif line.startswith('link_time:'):
          (res, linkTime) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['link_time'] = linkTime

          if outputType == 'text':
            self.printData('link_time', linkTime)

        elif line.startswith('exec_time:'):
          (res, execTime) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['exec_times'][microTestName] = execTime

          if outputType == 'text':
            self.printData('exec_times', execTime)

        elif line.startswith('size:'):
          (res, totalSize) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['total_size'] = totalSize

          if outputType == 'text':
            self.printData('total_size', totalSize)

        elif line.startswith('size.'):
          (res, sectionName, size) = self.getEntryTypeVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['section_sizes'][sectionName] = size

          if outputType == 'text':
            self.printData(sectionName, size)

    return testData


logFilePath = args.logfile
outputType = args.output_type
storeToDB = args.store_to_db

logFile = LogFile(logFilePath, outputType)
runData = logFile.getRunData()
testData = logFile.getTestData()

if outputType == 'json':
  print json.dumps(testData)

if storeToDB:
  # azureTable is defined in azure_table_functions.py
  azureTable.put(runData, testData)
