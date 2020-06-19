#!/usr/bin/python

import azure_table
import json
import os

metrics = ['compile_time', 'size', 'link_time', 'exec_times', 'section_sizes']

def formatData(data):
  result = {}

  for metric in metrics:
    result[metric] = {}

  curr = []
  for d in data:
    test_name = d.test_name

    result[metrics[0]][test_name] = d.compile_time
    result[metrics[1]][test_name] = d.size
    result[metrics[2]][test_name] = d.link_time

    exec_time = d.exec_time.replace("'", '"')
    exec_times = json.loads(exec_time)
    result[metrics[3]][test_name] = {}
    for k in exec_times.keys():
      result[metrics[3]][test_name][k] = exec_times[k]

    section_size = d.section_sizes.replace("'", '"')
    section_sizes = json.loads(section_size)
    result[metrics[4]][test_name] = {}
    for k in section_sizes.keys():
      result[metrics[4]][test_name][k] = section_sizes[k]

  return result

def prettyPrint(k, b, r):
  b = round(float(b), 2)
  r = round(float(r), 2)

  diff = 0
  if b > 0:
    diff = round((b - r) * 100 / b, 2)

  print '{0}\t{1}\t{2}\t{3}'.format(k, b, r, diff)

def compareData(baselineData, runData):
  b = formatData(baselineData)
  r = formatData(runData)

  for metric in metrics:
    if metric not in r.keys():
      continue

    print '======================================================================'
    print '{0}:'.format(metric)
    print '======================================================================'

    for test_name in sorted(b[metric].keys()):
      if test_name not in r[metric].keys():
        continue

      b_data = b[metric][test_name]
      r_data = r[metric][test_name]

      if metric == 'exec_times':
        print '\n{0}:'.format(test_name)

        for exe_name in sorted(b_data.keys()):
          if exe_name not in r_data.keys():
            continue

          b_val = b_data[exe_name]
          r_val = r_data[exe_name]
          prettyPrint(exe_name, b_val, r_val)

      elif metric == 'section_sizes':
        print '\n{0}:'.format(test_name)

        for section_name in sorted(b_data.keys()):
          if section_name not in r_data.keys():
            continue

          b_val = b_data[section_name]
          r_val = r_data[section_name]
          test_name += '/' + section_name
          prettyPrint(section_name, b_val, r_val)

      else:
        prettyPrint(test_name, b_data, r_data)

    print '\n'


baselinePartitionKey = os.environ['BASELINEPARTITIONKEY']
baselineRowKey = os.environ['BASELINEROWKEY']
baselineData = azure_table.get(baselinePartitionKey, baselineRowKey)

runPartitionKey = os.environ['RUNPARTITIONKEY']
runRowKey = os.environ['RUNROWKEY']
runData = azure_table.get(runPartitionKey, runRowKey)

print '======================================================================'
print 'Comparing benchmark results to baseline'
print '======================================================================'
print 'Baseline Partition Key: {0}'.format(baselinePartitionKey)
print 'Baseline Row Key: {0}'.format(baselineRowKey)
print 'Run Partition Key: {0}'.format(runPartitionKey)
print 'Run Row Key: {0}'.format(runRowKey)

compareData(baselineData, runData)
