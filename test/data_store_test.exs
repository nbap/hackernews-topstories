defmodule DataStoreTest do
  use ExUnit.Case

  alias Toolkit.DataStore

  setup do
    datastore = start_supervised!(DataStore)
    name = Faker.Name.first_name()
    [datastore: datastore, name: name]
  end

  test "insert and find", context do
    DataStore.insert(:name, context[:name])
    {:name, {name, _timestamp}} = hd(DataStore.find(:name))
    assert name == context[:name]
  end

  test "find_topstories", context do
    DataStore.insert(:topstories_ordered, context[:name])
    {:topstories_ordered, {name, _timestamp}} = hd(DataStore.find_topstories())
    assert name == context[:name]
  end

  test "clear_table", context do
    DataStore.insert(:name, context[:name])
    DataStore.clear_table()
    assert [] = DataStore.find(:name)
  end
end
