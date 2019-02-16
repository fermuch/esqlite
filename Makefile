PROJECT = esqlite
DIALYZER = dialyzer

REBAR := $(shell which rebar 2>/dev/null || echo ./rebar)
REBAR_URL := https://github.com/downloads/basho/rebar/rebar


LDFLAGS ?= -fPIC -shared -pedantic

CFLAGS ?= -fPIC -O2
SQLITE_CFLAGS = -DSQLITE_THREADSAFE=1 -DSQLITE_USE_URI -DSQLITE_ENABLE_FTS3 \
	-DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 \
	-DSQLITE_ENABLE_RTREE

CFLAGS += $(SQLITE_CFLAGS) -fPIC -Ic_src/sqlite3

all: compile

./rebar:
	erl -noshell -s inets start -s ssl start \
        -eval '{ok, saved_to_file} = httpc:request(get, {"$(REBAR_URL)", []}, [], [{stream, "./rebar"}])' \
        -s inets stop -s init stop
	chmod +x ./rebar

compile: rebar
	$(REBAR) compile

test: compile
	$(REBAR) eunit

clean: rebar
	$(REBAR) clean

distclean: 
	rm $(REBAR)

# dializer 

build-plt:
	@$(DIALYZER) --build_plt --output_plt .$(PROJECT).plt \
		--apps kernel stdlib 

dialyze:
	@$(DIALYZER) --src src --plt .$(PROJECT).plt --no_native \
		-Werror_handling -Wrace_conditions -Wunmatched_returns -Wunderspecs

