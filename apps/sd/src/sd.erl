%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(sd). 

-behaviour(gen_server). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
-define(SERVER,?MODULE).


%% External exports
-export([
	 get_node/1,
	 get_node_on_node/2,
	 get_node_on_host/2,
	 get_node_host/1,
	 get_node_host_on_node/2,
	 get_node_host_on_host/2,
	 call/5,
	 cast/4,
	 all/0,

	 appl_start/1,
	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
	
	       }).

%% ====================================================================
%% External functions
%% ====================================================================
appl_start([])->
    application:start(?MODULE).

%% ====================================================================
%% Server functions
%% ====================================================================
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).

%% ====================================================================
%% Application handling
%% ====================================================================

%% ====================================================================
%% Support functions
%% ====================================================================
%%---------------------------------------------------------------
%% Function:all_specs()
%% @doc: all service specs infromation       
%% @param: non 
%% @returns:State#state.service_specs_info
%%
%%---------------------------------------------------------------

%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).

%% ====================================================================
%% Gen Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    case code:is_loaded(nodelog) of
	false->
	    be_silent;
	_->
	    rpc:cast(node(),nodelog,log,[notice,?MODULE_STRING,?LINE,
						{"OK, started server at node  ",?MODULE," ",node()}])
    end,
    {ok, #state{}
    }.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stopped},_From, State) ->
    Reply=ok,
    {reply, Reply, State};


handle_call({not_implemented},_From, State) ->
    Reply=not_implemented,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    %rpc:cast(node(),log,log,[?Log_ticket("unmatched call",[Request, From])]),
    Reply = {ticket,"unmatched call",Request, From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast(_Msg, State) ->
  %  rpc:cast(node(),log,log,[?Log_ticket("unmatched cast",[Msg])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
    %rpc:cast(node(),log,log,[?Log_ticket("unmatched info",[Info])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
call(App,M,F,A,T)->
    Result=case rpc:call(node(),sd,get_node_host,[App],T) of
	       {badrpc,Reason}->
		   {error,[{badrpc,Reason}]};
	       []->
		   [];
	       [{Node,_}|_]->
		   rpc:call(Node,M,F,A,T)
	   end,
    Result.

	%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
cast(App,M,F,A)->
    Result=case rpc:call(node(),sd,get_node_host,[App],5*1000) of
	       {badrpc,Reason}->
		   {badrpc,Reason};
	       []->
		   {error,[eexists,App,?FUNCTION_NAME,?MODULE,?LINE]};
	       [{Node,_}|_]->
		   rpc:cast(Node,M,F,A)
	   end,
    Result.			   

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
all()->
    Apps=[{Node,rpc:call(Node,net,gethostname,[],5*1000),rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    AvailableNodes=[{Node,HostName,AppList}||{Node,{ok,HostName},AppList}<-Apps,
				    AppList/={badrpc,nodedown}],
    AvailableNodes.
    


get_node(WantedApp)->
    Apps=[{Node,rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    AvailableNodes=[Node||{Node,AppList}<-Apps,
				     AppList/={badrpc,nodedown},
				     AppList/={badrpc,timeout},
				     true==lists:keymember(WantedApp,1,AppList)],
    AvailableNodes.

get_node_on_node(WantedApp,WantedNode)->

    Apps=[{Node,rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    AvailableNodes=[Node||{Node,AppList}<-Apps,
			  AppList/={badrpc,nodedown},
			  AppList/={badrpc,timeout},
			  true==lists:keymember(WantedApp,1,AppList),
			  Node==WantedNode],
    AvailableNodes.

get_node_on_host(WantedApp,WantedHost)->
    Apps=[{Node,rpc:call(Node,net,gethostname,[],5*1000),
	   rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    AvailableNodes=[Node||{Node,{ok,HostName},AppList}<-Apps,
				     AppList/={badrpc,nodedown},
				     AppList/={badrpc,timeout},
				     true=:=lists:keymember(WantedApp,1,AppList),
				     HostName=:=WantedHost],
    AvailableNodes.
	  

get_node_host(WantedApp)->
    Apps=[{Node,rpc:call(Node,net,gethostname,[],5*1000),
	   rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    AvailableNodes=[{Node,HostName}||{Node,{ok,HostName},AppList}<-Apps,
				     AppList/={badrpc,nodedown},
				     AppList/={badrpc,timeout},
				     true==lists:keymember(WantedApp,1,AppList)],
    AvailableNodes.

get_node_host_on_node(WantedApp,WantedNode)->

    Apps=[{Node,rpc:call(Node,net,gethostname,[],5*1000),
	   rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    AvailableNodes=[{Node,HostName}||{Node,{ok,HostName},AppList}<-Apps,
				     AppList/={badrpc,nodedown},
				     AppList/={badrpc,timeout},
				     true==lists:keymember(WantedApp,1,AppList),
				     Node==WantedNode],
    AvailableNodes.

get_node_host_on_host(WantedApp,WantedHost)->
    Apps=[{Node,rpc:call(Node,net,gethostname,[],5*1000),
	   rpc:call(Node,application,which_applications,[],5*1000)}||Node<-[node()|nodes()]],
    AvailableNodes=[{Node,HostName}||{Node,{ok,HostName},AppList}<-Apps,
				     AppList/={badrpc,nodedown},
				     AppList/={badrpc,timeout},
				     true=:=lists:keymember(WantedApp,1,AppList),
				     HostName=:=WantedHost],
    AvailableNodes.
	  
%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
