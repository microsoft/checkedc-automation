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


def getTableConnection():
  tableName = 'benchmark'
  azureTable = AzureTableConnection(tableName)
  assert azureTable, "Connection to Azure Table failed"
  return azureTable


def put(runData, testData):
  azureTable = getTableConnection()
  batch = TableBatch()
  entity = {}

  # Add the run data to the batch.
  for key, value in runData.items():
    if key == 'user':
      user = value
      entity['PartitionKey'] = user

    elif key == 'timestamp':
      timestamp = value
      entity['RowKey'] = '{0}_{1}'.format(timestamp, 0)

    else:
      entity[key] = str(value)

  batch.insert_entity(entity)

  # Add the test data to the batch.
  rowNo = 1
  for testName, testResults in testData.items():
    entity = {}
    entity['PartitionKey'] = user
    entity['RowKey'] = '{0}_{1}'.format(timestamp, rowNo)

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
