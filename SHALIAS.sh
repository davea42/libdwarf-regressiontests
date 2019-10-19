# For situations where one must use gmake
# it's impossible to easily and safely
# to sub-shells (sh or bash) without
# using ENV or BASH_ENV and that is itself
# a nuisance to set up.
# So  this file is source (with .) in every shell here.
# (we use sh or bash, not csh/tcsh)
# uncomment the following line:

# alias make=gmake

# For freebsd 'pkg install gmake'
# then uncomment:
# alias make=/usr/local/bin/gmake

# Once the correct aliases set up
# either leave it in regression tests
# or copy the modified version to ~/SHALIAS.sh
# scripts/run-all-tests.sh uses this
# convention. 
