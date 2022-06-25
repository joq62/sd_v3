%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is§
%%% -------------------------------------------------------------------
-module(sd_eunit).   
 
-export([start/0]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include_lib("kernel/include/logger.hrl").
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start()->
    {ok,HostName}=net:gethostname(),
    [N0,N1,N2]=setup(),
    ok=sd:appl_start([]),
    pong=sd:ping(),
   

    ok=load_test([N0,N1,N2],HostName),
    ok=start_1_test([N0,N1,N2],HostName),
    ok=start_2_test([N0,N1,N2],HostName),
    
   
 
    init:stop(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
start_2_test([N0,N1,N2],HostName)->
    rpc:call(N0,application,start,[test_add],5000),
    rpc:call(N1,application,start,[test_divi],5000),
    rpc:call(N2,application,start,[test_add],5000),
    rpc:call(N2,application,start,[test_divi],5000),

    [{'n0@c100',"c100"},{'n2@c100',"c100"}]=sd:get(test_add),
    [{'n1@c100',"c100"},{'n2@c100',"c100"}]=sd:get(test_divi),  
    []=sd:get(glurk), 
    [{'n0@c100',"c100"},{'n2@c100',"c100"}]=sd:get_host(test_add,HostName),
    [{'n1@c100',"c100"},{'n2@c100',"c100"}]=sd:get_host(test_divi,HostName),
    []=sd:get_host(test_divi,"glurk_hostname"),
    []=sd:get_host(glurk,HostName),
    []=sd:get_host(glurk,"glurk_hostname"),
    M=test_add,
    F=add,
    A=[20,22],
    T=5000,
    42=sd:call(test_add,M,F,A,T),
    []=sd:call(glurk,M,F,A,T),
    {badrpc,_}=sd:call(test_add,glurk,F,A,T),
    {badrpc,_}=sd:call(test_add,M,glurk,A,T),
    {badrpc,_}=sd:call(test_add,M,F,[a,34],T),
    
    true=sd:cast(test_add,M,F,A),

    io:format(" sd:all ~p~n",[sd:all()]),
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
start_1_test([N0,N1,N2],HostName)->
    rpc:call(N0,application,start,[test_add],5000),
    rpc:call(N1,application,start,[test_divi],5000),
    rpc:call(N2,application,load,[test_add],5000),
    rpc:call(N2,application,load,[test_divi],5000),

    [{'n0@c100',"c100"}]=sd:get(test_add),
    [{'n1@c100',"c100"}]=sd:get(test_divi),  
    []=sd:get(glurk), 
    [{'n0@c100',"c100"}]=sd:get_host(test_add,HostName),
    [{'n1@c100',"c100"}]=sd:get_host(test_divi,HostName),
    []=sd:get_host(test_divi,"glurk_hostname"),
    []=sd:get_host(glurk,HostName),
    []=sd:get_host(glurk,"glurk_hostname"),
    M=test_add,
    F=add,
    A=[20,22],
    T=5000,
    42=sd:call(test_add,M,F,A,T),
    []=sd:call(glurk,M,F,A,T),
    {badrpc,_}=sd:call(test_add,glurk,F,A,T),
    {badrpc,_}=sd:call(test_add,M,glurk,A,T),
    {badrpc,_}=sd:call(test_add,M,F,[a,34],T),
    
    true=sd:cast(test_add,M,F,A),
    io:format(" sd:all ~p~n",[sd:all()]),
  
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
load_test([N0,N1,N2],HostName)->
    rpc:call(N0,application,load,[test_add],5000),
    rpc:call(N1,application,load,[test_divi],5000),
    rpc:call(N2,application,load,[test_add],5000),
    rpc:call(N2,application,load,[test_divi],5000),

    []=sd:get(test_add),
    []=sd:get(test_divi),  
    []=sd:get(glurk), 
    []=sd:get_host(test_add,HostName),
    []=sd:get_host(test_divi,HostName),
    []=sd:get_host(test_divi,"glurk_hostname"),
    []=sd:get_host(glurk,HostName),
    []=sd:get_host(glurk,"glurk_hostname"),
    M=test_add,
    F=add,
    A=[20,22],
    T=5000,
    []=sd:call(test_add,M,F,A,T),
    []=sd:call(glurk,M,F,A,T),
    []=sd:call(test_add,glurk,F,A,T),
    []=sd:call(test_add,M,glurk,A,T),
    []=sd:call(test_add,M,F,[a,34],T),
    
    {error,[eexists,test_add,cast,sd,205]}=sd:cast(test_add,M,F,A),

    io:format(" sd:all ~p~n",[sd:all()]),    
    ok.


%call(App,M,F,A,T)
%cast(App,M,F,A)
%all(),
%get(WantedApp)
%get_host(WantedApp,WantedHost)

%get(WantedApp,WantedNode)
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
call_cast_test()->
    
    ok.



setup()->
    ok=rpc:call(node(),test_nodes,start_nodes,[],5000),
    [N0,N1,N2]=test_nodes:get_nodes(),
    rpc:call(N0,code,add_patha,["test_ebin"],5000),
    rpc:call(N1,code,add_patha,["test_ebin"],5000),
    rpc:call(N2,code,add_patha,["test_ebin"],5000),
    [N0,N1,N2].
