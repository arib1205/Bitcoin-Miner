defmodule Arib do
  def main(args) do

    {:ok, ifs} = :inet.getif()
    ips = Enum.map(ifs, fn {ip, _broadaddr, _mask} -> ip end)
    myip = Enum.join(Tuple.to_list(Enum.at(ips,0)) , ".")

    input = Enum.at(args,0) |> String.trim
    if String.contains?(input,".") do
      random = genRand(5)
      myip =  String.to_atom(random <> myip)
      Node.start(myip)
      client(input)
    else
      k = input |> String.to_integer
      myip =  String.to_atom("foo@" <> myip)
      Node.start(myip)
      server(k)
    end
  end

  def server(args) do
    Node.set_cookie(Node.self(),:Arib)

    pid = Node.spawn(Node.self(), Arib, :sending, [args])

    pid1 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid1, {pid1,args})
    pid2 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid2, {pid2,args})
    pid3 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid3, {pid3,args})
    pid4 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid4, {pid4,args})
    pid5 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid5, {pid5,args})
    pid6 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid6, {pid6,args})
    pid7 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid7, {pid7,args})
    pid8 = Node.spawn(Node.self(), Arib, :loop, [])
    send(pid8, {pid8,args})

    loop()
  end

  def client(ip) do
      Node.set_cookie(Node.self(),:Arib)
      server_ip = String.to_atom("foo@" <> ip)
      IO.puts Node.self()
      IO.puts Node.get_cookie()
      IO.puts Node.connect(server_ip)
      loop2()
  end

  def loop do
    receive do
      {pid,k} -> coinGen(k)
    end
  end

  def loop2 do
    receive do
      {k,:str} -> coinGen(k)
    end
  end

  def sending(k) do
    addr = List.last(Node.list())
    unless addr==nil do
      pid2 = Node.spawn(addr,Arib, :loop2, [])
      send(pid2,{k,:str})
    end
    sending(k)
  end

  def genRand(l) do
    :crypto.strong_rand_bytes(l) |> Base.url_encode64 |> binary_part(0, l)
  end

  def coinGen(k) do
    str=""
    str = mkstr k,str
    rand = genRand(50)
    input = "arib1993;" <> rand
    i=1
    test=input
    callSha256 k,input,test,i,str
    coinGen(k)
  end

  def callSha256(k,input,test,i,str) do
     sha=:crypto.hash_init(:sha256)
     sha = :crypto.hash_update(sha, test)
     sha_binary = :crypto.hash_final(sha)
     sha_hex = sha_binary |> Base.encode16 |> String.downcase
     #sha_hex = :crypto.hash(:sha256, input) |> Base.encode16
    if(String.slice(sha_hex,0,k)==str) do
        IO.puts "#{test}\t#{sha_hex}"
    else
        test=input <> Integer.to_string(i)
        callSha256(k,input,test,i+1,str)
    end
  end

  def mkstr(k,str) do
    if(k>0) do
      str=str <> "0"
      mkstr(k-1,str)
    else
      str
    end
  end
end
