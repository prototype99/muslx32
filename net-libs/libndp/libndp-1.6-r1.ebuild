# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome2 multilib-minimal

DESCRIPTION="Library for Neighbor Discovery Protocol"
HOMEPAGE="http://libndp.org"
SRC_URI="http://libndp.org/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

KEYWORDS="~alpha amd64 arm ~arm64 ~ia64 ppc ppc64 ~sparc x86"

DEPEND=""
RDEPEND=""

src_prepare() {
	if [[ "${CHOST}" =~ "muslx32" ]] ; then
		epatch "${FILESDIR}"/${PN}-1.6-fd_set-musl.patch
	fi
	default
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" \
	gnome2_src_configure \
		--disable-static \
		--enable-logging
}

multilib_src_install() {
	gnome2_src_install
}
