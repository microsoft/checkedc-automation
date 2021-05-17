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
    self.totalCompileTime = 0.0

  def splitEntry(self, entry):
    return entry.split(':')

  def getValue(self, arr, i):
    return arr[i].strip() \
                 .replace('"', '') \
                 .replace("'", '')

  def getNameValue(self, entry):
    arr = self.splitEntry(entry)
    if len(arr) < 2:
      return (False, None, None)
    return (True, self.getValue(arr, 0), self.getValue(arr, 1))

  def prettyPrint(self, data):
    print json.dumps(data, sort_keys=True, indent=4)

  def getRunData(self, configData):
    runData = {}

    runData['partitionkey'] = os.environ['RUNPARTITIONKEY']
    runData['rowkey'] = os.environ['RUNROWKEY']
    runData['date'] = date.today().strftime('%Y-%m-%d')

    runData['config'] = {}
    for option, value in configData.items():
      runData['config'][option] = value
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

          (res, name, value) = self.getNameValue(line)
          if not res:
            continue
          # New test record begins.
          if name == 'TEST':
            testName = value
            testData[testName] = {}
            testData[testName]['exec_time'] = {}
            testData[testName]['section_sizes'] = {}
          microTestName = value

        elif line.startswith('compile_time:') or \
             line.startswith('link_time:') or \
             line.startswith('exec_time:') or \
             line.startswith('size:') or \
             line.startswith('size.'):
          (res, name, value) = self.getNameValue(line)
          if not res:
            continue
          if testName not in testData:
            continue

          if line.startswith('exec_time:'):
            testData[testName][name][microTestName] = value
          elif line.startswith('size.'):
            testData[testName]['section_sizes'][name] = value
          else:
            testData[testName][name] = value

          # Sum the compile times.
          if line.startswith('compile_time:'):
            self.totalCompileTime += float(value)

        elif 'INFO: Configuring with' in line:
          beginConfig = True

        elif 'INFO: }' in line:
          beginConfig = False

        if beginConfig:
          line = re.sub('^.*INFO:', '', line)
          line = line.replace('FILEPATH:', '')
          (res, name, value) = self.getNameValue(line)
          if not res:
            continue
          configData[name] = value

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
totalCompileTime = logFile.totalCompileTime

if shouldPrint:
  logFile.prettyPrint(runData)
  logFile.prettyPrint(testData)
  print ('Total compile time: {0} s'.format(totalCompileTime))

if storeToDB:
  azure_table.put(runData, testData)
