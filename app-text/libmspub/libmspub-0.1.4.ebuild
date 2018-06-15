# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic \
	multilib multilib-minimal

EGIT_REPO_URI="https://anongit.freedesktop.org/git/libreoffice/libmspub.git"
[[ ${PV} == 9999 ]] && inherit autotools git-r3

DESCRIPTION="Library parsing Microsoft Publisher documents"
HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libmspub"
[[ ${PV} == 9999 ]] || SRC_URI="https://dev-www.libreoffice.org/src/libmspub/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"

# Don't move KEYWORDS on the previous line or ekeyword won't work # 399061
[[ ${PV} == 9999 ]] || \
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~x86"

IUSE="doc static-libs"

RDEPEND="
	dev-libs/icu:=[${MULTILIB_USEDEP}]
	dev-libs/librevenge[${MULTILIB_USEDEP}]
	sys-libs/zlib[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}
	dev-libs/boost[${MULTILIB_USEDEP}]
	sys-devel/libtool[${MULTILIB_USEDEP}]
	virtual/pkgconfig[${MULTILIB_USEDEP}]
	doc? ( app-doc/doxygen )
"

src_prepare() {
	default
	[[ -d m4 ]] || mkdir "m4"
	[[ ${PV} == 9999 ]] && eautoreconf
}

multilib_src_configure() {
	# bug 619044
	append-cxxflags -std=c++14

	econf \
		--disable-werror \
		$(use_with doc docs) \
		$(use_enable static-libs static)
}

multilib_src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}
