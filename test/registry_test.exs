defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "Cria um bucket, busca e adiciona um item", %{registry: registry} do
    #deve dar erro para quando o bucket não existe
    assert KV.Registry.lookup(registry, "shopping") == :error

    # Cria o bucket no registro
    KV.Registry.create(registry, "shopping")
    #verifica se foi criado
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    #Adiciona um item no bucket: milk => 10
    KV.Bucket.put(bucket, "milk", 10)

    #Verifica se o dado foi inserido e corresponde ao valor esperado da chave
    assert KV.Bucket.get(bucket, "milk") == 10

  end

  test "removes bucket on exit", %{registry: registry} do
    #cria o bucket
    KV.Registry.create(registry, "shopping")

    #pega o bucket
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    #para o bucket.
    Agent.stop(bucket)
    # se o bucket parou, então ele não poderia mais existir no registro
    assert KV.Registry.lookup(registry, "shopping") == :error

    #pega

  end

end
