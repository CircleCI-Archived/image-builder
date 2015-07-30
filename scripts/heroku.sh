#!/bin/bash

set -ex

echo '>>> Installing heroku'

wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh

# Heroku installer doesn't add to path in non-login shells
echo 'export PATH=$PATH:/usr/local/heroku/bin' >> ${CIRCLECI_HOME}/.circlerc

## Workaround heroku not reporting exit codes properly
function patch_heroku_bin() {
	HEROKU_BIN=${1:-$(which heroku)}

	if [ ! -f "$HEROKU_BIN" ]
	then
	    echo "Heroku file not found: $HEROKU_BIN"
	    exit 127
	fi

	HEROKU_PATH=$(readlink -m "$HEROKU_BIN")

	if ( grep -q "Circle Monkey" "$HEROKU_PATH" )
	then
	  echo "Heroku file has been patched already"
	  exit 0
	fi

	TMP_FILE=`mktemp /tmp/heroku.XXXXXXXX` || exit 1

	head -n-1 "$HEROKU_PATH" > "$TMP_FILE"

	cat <<EOF >> $TMP_FILE
#########################################
# Circle Monkey-patching starts here
# https://github.com/heroku/heroku/issues/186

begin
    require 'heroku-api'

    class Heroku::API
        def ps_options_modified(params)
            if params['command']
                # * Parens are needed so that command runs in a subshell
                #   allowing for "exit" command.
                # * Spaces within parens are needs to avoid creating
                #   Double-Parentheses Construct accidentally
                params['command'] = "( #{params['command']} ); echo heroku-command-exit-status: \$?"
            end
            ps_options_unmodified(params)
        end

        alias ps_options_unmodified ps_options
        alias ps_options ps_options_modified
    end

    require 'heroku/client/rendezvous.rb'

    class Heroku::Client::Rendezvous
        def fixup_modified(data)
            data = fixup_unmodified(data)
            if data =~ /heroku-command-exit-status: (\d+)/
                code = \$1.to_i
                output.write(data)
                Process.exit code
            end
	                data
        end

        alias fixup_unmodified fixup
        alias fixup fixup_modified
    end
rescue
    # Could not monkey-patch heroku so running as-is now
    open(ENV['HOME'] + '/.circle_errors', 'a') do |f|
        f.puts 'CircleCI Heroku monkey-patching failed...'
    end
end
#
# CIRCLE Monkey-patching ends here
##########################################

EOF

	tail -n1 "$HEROKU_PATH" >> "$TMP_FILE"

	# Preseve heroku attributes
	cat "$TMP_FILE" > "$HEROKU_PATH"
	rm "$TMP_FILE"

	echo "Heroku file has been patched"
}

patch_heroku_bin /usr/bin/heroku
