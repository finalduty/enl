### finalduty@github.com [rev: 902897d]
## Bootstrap Script for templates to pull latest firstrun.sh
#!/bin/bash

[ -e /usr/bin/curl ] && bash <(curl https://raw.githubusercontent.com/finalduty/enl/master/install/firstrun.sh) && exit
[ -f /usr/bin/wget ] && bash <(wget -q https://raw.githubusercontent.com/finalduty/enl/master/install/firstrun.sh) && exit

echo "Can not find a curl or wget install and I'm not programmed to install either of them."
echo "Failed"
exit 1
