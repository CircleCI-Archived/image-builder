echo '>>> Installing casperjs'

set -ex
cd "/usr/local"
git clone "git://github.com/n1k0/casperjs.git"
cd casperjs
git checkout "tags/1.0.2"
ln -sf "`pwd`/bin/casperjs" "/usr/local/bin/casperjs"
