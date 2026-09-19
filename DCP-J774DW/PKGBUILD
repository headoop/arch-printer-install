# Maintainer: headoop <12900332+headoop@users.noreply.github.com>
pkgname=brother-dcpj774dw
PKGEXT='.pkg.tar.gz'
pkgver=1.0.5
pkgrel=1
pkgdesc="Driver for the Brother DCP-J774DW wifi multifuncional printer"
url="http://solutions.brother.com/linux/en_us/index.html"
license=('custom:brother')
depends=('a2ps' 'cups')
makedepends=('rpmextract')
install="brother-dcpj774dw.install"
arch=('i686' 'x86_64')

md5sums=('eea70856dffacfa00bdef3fd98885b2f'
         '6d801459e40568ba8595bd8f6c7eb036')

source=(
	"fix_lp.patch" \
  "http://download.brother.com/welcome/dlf103543/dcpj774dwpdrv-$pkgver-0.i386.rpm"
)

build() {
  cd "$srcdir"
	patch -Np0 < fix_lp.patch
}

package()
{
  install -d $pkgdir/usr/bin
	install -d $pkgdir/var/spool/lpd
  install -Dm755 "$srcdir"/usr/bin/brprintconf_dcpj774dw "$pkgdir"/usr/bin/
	cp -R $srcdir/opt $pkgdir/opt
}
