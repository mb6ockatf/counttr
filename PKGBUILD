# Maintainer: mb6ockatf mdddmmmm@ya.ru
pkgname=counttr
pkgver=1.0
pkgrel=1
pkgdesc="mathematics count trainer"
arch=('any')
url="https://github.com/mb6ockatf/counttr"
license=('AGPL-3.0')
depends=("lua>=5.4.6-1" "luarocks>=3.9.2-1")
install=
source=("main.lua" "LICENSE")
cksums=("3911755826" "1403875556")

prepare(){
	cp main.lua counttr.lua
	mv counttr.lua counttr
	luarocks install mfr --local
	luarocks install argparse --local
}

package() {
	install -Dm755 counttr "$pkgdir/usr/bin/counttr"
	install -d "$pkgdir/usr/share/doc/counttr"
	install -d "$pkgdir/usr/share/licenses/counttr"
	install -Dm644 LICENSE "$pkgdir/usr/share/licenses/counttr/"
}