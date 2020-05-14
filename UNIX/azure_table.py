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

  def insertEntity(self, entity):
    self.tableService.insert_entity(self.tableName, entity)

  def commitBatch(self, batch):
    self.tableService.commit_batch(self.tableName, batch)


def getTableConnection():
  tableName = 'bmark'
  azureTable = AzureTableConnection(tableName)
  assert azureTable, "Connection to Azure Table failed"
  return azureTable


def put(runData, testData):
  azureTable = getTableConnection()
  batch = TableBatch()
  entity = {}

  for key, value in runData.items():
    if key == 'user':
      user = value
      entity['PartitionKey'] = user

    elif key == 'timestamp':
      timestamp = value
      entity['RowKey'] = '{0}_{1}'.format(timestamp, 0)

    else:
      entity[key] = value

  batch.insert_entity(entity)

  rowNo = 1
  for testName, testResults in testData.items():
    entity = {}
    entity['PartitionKey'] = user
    entity['RowKey'] = '{0}_{1}'.format(timestamp, rowNo)

    entity['test_name'] = testName
    for metric, value in testResults.items():
      entity[metric] = str(value)

    if rowNo % 100 == 0:
      azureTable.commitBatch(batch)
      batch = TableBatch()

    batch.insert_entity(entity)
    rowNo += 1

  # If there are any leftover entities in batch.
  azureTable.commitBatch(batch)
