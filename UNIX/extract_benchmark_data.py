#!/usr/bin/python

import argparse
import azure_table
import getpass
import json
import os
import re
import time
from datetime import date

parser = argparse.ArgumentParser(
           description='Extract benchmark data from a log file and store to database'
         )
parser.add_argument('--logfile',
                    type=str,
                    required=True,
                    help='path to log file containing benchmark data')
parser.add_argument('--pretty-print',
                    default=False,
                    action='store_true',
                    help='print the benchmark config and test data to stdout')
parser.add_argument('--store-to-db',
                    default=False,
                    action='store_true',
                    help='store the benchmark data to an azure table storage')
args = parser.parse_args()


class LogFile:
  def __init__(self, logFile):
    self.logFile = logFile

  def splitEntry(self, entry):
    return entry.split(':')

  def getVal(self, arr, i):
    val = arr[i].strip() \
                .replace('"', '') \
                .replace("'", '')
    # If the string value contains a space, add quotes around it.
    if ' ' in val:
      val = '{0}{1}{0}'.format("'", val)
    return val

  def getEntryNameVal(self, entry):
    arr = self.splitEntry(entry)
    if len(arr) < 2:
      return (False, None, None)
    return (True, self.getVal(arr, 0), self.getVal(arr, 1))

  def getEntryVal(self, entry):
    arr = self.splitEntry(entry)
    if len(arr) < 2:
      return (False, None)
    return (True, self.getVal(arr, 1))

  def prettyPrint(self, data):
    print json.dumps(data, sort_keys=True, indent=4)

  def getRunData(self, configData):
    runData = {}

    runData['user'] = getpass.getuser()
    runData['timestamp'] = time.time()
    runData['date'] = date.today().strftime('%Y-%m-%d')

    runData['config'] = {}
    for option, value in configData.items():
      runData['config'][option] = value
      print runData['config'][option]
    runData['config']['TEST_TARGET'] = os.getenv('TEST_TARGET')

    return runData

  def getTestConfigData(self):
    testData = {}
    configData = {}
    beginConfig = False

    with open(self.logFile) as lines:
      for line in lines:
        line = line.strip()

        if line.startswith('***'):
          line = line.replace('*', '') \
                     .replace('::', ':') \
                     .replace("TEST 'test-suite", 'TEST') \
                     .replace("' RESULTS", '') \
                     .replace('.test', '')

          (res, testType, name) = self.getEntryNameVal(line)
          if not res:
            continue
          if testType == 'TEST':
            testName = name
            testData[testName] = {}
            testData[testName]['exec_times'] = {}
            testData[testName]['section_sizes'] = {}
          microTestName = name

        elif line.startswith('compile_time:'):
          (res, compileTime) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['compile_time'] = compileTime

        elif line.startswith('link_time:'):
          (res, linkTime) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['link_time'] = linkTime

        elif line.startswith('exec_time:'):
          (res, execTime) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['exec_times'][microTestName] = execTime

        elif line.startswith('size:'):
          (res, totalSize) = self.getEntryVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['total_size'] = totalSize

        elif line.startswith('size.'):
          (res, sectionName, size) = self.getEntryNameVal(line)
          if not res:
            continue
          if testName in testData:
            testData[testName]['section_sizes'][sectionName] = size

        elif 'INFO: Configuring with' in line:
          beginConfig = True

        elif 'INFO: }' in line:
          beginConfig = False

        if beginConfig:
          line = re.sub('^.*INFO:', '', line)
          line = line.replace('FILEPATH:', '')
          (res, option, value) = self.getEntryNameVal(line)
          if not res:
            continue
          configData[option] = value

    return (testData, configData)


# Read user options.
logFilePath = args.logfile
shouldPrint = args.pretty_print
storeToDB = args.store_to_db

# Test data are the results of the benchmarks like test name, compile time, code
# size, etc.
# Config data are the compiler flags and other options like test target.
# Run data is the config data plus timestamp, username, etc.
logFile = LogFile(logFilePath)
(testData, configData) = logFile.getTestConfigData()
runData = logFile.getRunData(configData)

if shouldPrint:
  logFile.prettyPrint(runData)
  logFile.prettyPrint(testData)

if storeToDB:
  azure_table.put(runData, testData)
