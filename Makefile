_REPODIR != cd "$(shell dirname $(firstword $(MAKEFILE_LIST)))/" && pwd

doc-site:
	lua $(_REPODIR)/ldoc.lua .