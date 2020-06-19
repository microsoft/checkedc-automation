#!/usr/bin/python

import os
from azure.cosmosdb.table import (
  TableBatch,
  TableService
)


class AzureTableConnection:
  def __init__(self, tableName):
    self.tableName = tableName
    self.tableService = TableService(
      account_name=os.environ['STORAGEACCOUNTNAME'],
      account_key=os.environ['STORAGEACCOUNTKEY']
    )

  def commitBatch(self, batch):
    self.tableService.commit_batch(self.tableName, batch)

  def getData(self, partitionKey, rowKey):
    startRowKey = '{0}_0'.format(rowKey)
    endRowKey = '{0}_9999'.format(rowKey)
    filterExpression = "PartitionKey eq '{0}' and \
                        RowKey gt '{1}' and \
                        RowKey lt '{2}'" \
                        .format(partitionKey, startRowKey, endRowKey)
    return self.tableService.query_entities(self.tableName, filter=filterExpression)


def getTableConnection():
  tableName = 'benchmark'
  azureTable = AzureTableConnection(tableName)
  assert azureTable, 'Connection to Azure Table failed'
  return azureTable

def get(partitionKey, rowKey):
  azureTable = getTableConnection()
  return azureTable.getData(partitionKey, rowKey)

def put(runData, testData):
  azureTable = getTableConnection()
  batch = TableBatch()
  entity = {}

  # Add the run data to the batch.
  for key, value in runData.items():
    if key == 'partitionkey':
      entity['PartitionKey'] = value

    elif key == 'rowkey':
      entity['RowKey'] = '{0}_{1}'.format(value, 0)

    else:
      entity[key] = str(value)

  batch.insert_entity(entity)

  # Add the test data to the batch.
  rowNo = 1
  for testName, testResults in testData.items():
    entity = {}
    entity['PartitionKey'] = runData['partitionkey']
    entity['RowKey'] = '{0}_{1}'.format(runData['rowkey'], rowNo)

    entity['test_name'] = testName
    for metric, value in testResults.items():
      entity[metric] = str(value)

    # Azure Table only allows batches of 100 entities.
    if rowNo % 100 == 0:
      azureTable.commitBatch(batch)
      batch = TableBatch()

    batch.insert_entity(entity)
    rowNo += 1

  # Commit any leftovers in the batch.
  azureTable.commitBatch(batch)

  print '======================================================================'
  print 'Benchmark data successfully saved to Azure Table Storage'
  print '======================================================================'
  print 'PartitionKey: {0}'.format(runData['partitionkey'])
  print 'RowKey: {0}'.format(runData['rowkey'])
  print '# of records inserted: {0}'.format(rowNo)
