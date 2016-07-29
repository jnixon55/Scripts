#/bin/bash

if [ ! "$1" ]; then
        echo "Please specify date ie: 20160615"
        exit 1
      else
          for h in `cat ~/rbin/servers_patch`; do
            knife node attribute $h set releasedate $1;

        done
fi
