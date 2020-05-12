#!/usr/bin/python

from azure.cosmosdb.table import (
  TableBatch,
  TableService
)


class AzureTableConnection:
  def __init__(self, tableName, credentials):
    self.tableName = tableName
    self.tableService = TableService(
      account_name=credentials['account_name'],
      account_key=credentials['account_key']
    )

  def insertEntity(self, entity):
    self.tableService.insert_entity(self.tableName, entity)

  def commitBatch(self, batch):
    self.tableService.commit_batch(self.tableName, batch)

  def getEntity(self, PartitionKey, RowKey):
    return self.tableService.get_entity(self.tableName, PartitionKey, RowKey)


def getTableConnection(accountName, accountKey):
  assert accountName, "account name needed to store to DB"
  assert accountKey, "account key needed to store to DB"

  tableName = 'bmark'
  credentials = {}
  credentials['account_name'] = accountName
  credentials['account_key'] = accountKey
  return AzureTableConnection(tableName, credentials)

def get(accountName, accountKey, entity):
  azureTable = getTableConnection(accountName, accountKey)
  return azureTable.getEntity(entity['PartitionKey'], entity['RowKey'])

def put(accountName, accountKey, runData, testData):
  azureTable = getTableConnection(accountName, accountKey)

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
