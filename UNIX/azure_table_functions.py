#!/usr/bin/python

import os
import subprocess
from azure.cosmosdb.table import (
  TableBatch,
  TableService
)


class AzureTableConnection:
  def __init__(self, tableName):
    name=subprocess.check_output(['echo', '$(Storage.Account.Name)']),
    key=subprocess.check_output(['echo', "'$(Storage.Account.Key)'"])
    print name, key

    self.tableName = tableName
    self.tableService = TableService(account_name=name, account_key=key)

  def insertEntity(self, entity):
    self.tableService.insert_entity(self.tableName, entity)

  def commitBatch(self, batch):
    self.tableService.commit_batch(self.tableName, batch)

  def getEntity(self, PartitionKey, RowKey):
    return self.tableService.get_entity(self.tableName, PartitionKey, RowKey)


tableName = 'bmark'
azureTable = AzureTableConnection(tableName)


def get(accountName, accountKey, entity):
  return azureTable.getEntity(entity['PartitionKey'], entity['RowKey'])


def put(accountName, accountKey, runData, testData):
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
