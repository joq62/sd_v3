all:
	rm -rf  *~ */*~ apps/sd/src/*.beam apps/sd/src/*~ test/*.beam erl_cra*;
	rm -rf  logs *.service_dir rebar.lock;
	rm -rf _build test_ebin ebin *_info_specs;
	mkdir ebin;		
	rebar3 compile;	
	cp _build/default/lib/*/ebin/* ebin;
	rm -rf _build test_ebin logs log;
	git add -f *;
	git commit -m $(m);
	git push;
	echo Ok there you go!
eunit:
	rm -rf  *~ */*~ apps/sd/src/*.beam test/*.beam test_ebin erl_cra*;
	rm -rf _build logs log *.service_dir *_info_specs;
	rm -rf rebar.lock;
	rm -rf ebin test_ebin;
	rebar3 compile;
	mkdir test_ebin;
	mkdir ebin;
	cp _build/default/lib/*/ebin/* ebin;
	erlc -o test_ebin test/*.erl;
	cp /home/joq62/erlang/applications/ordinary/test_add/ebin/* test_ebin;
	cp /home/joq62/erlang/applications/ordinary/test_divi/ebin/* test_ebin;
	erl -pa ebin -pa test_ebin\
	    -sname sd -run basic_eunit start -setcookie cookie_test
