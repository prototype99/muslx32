# muslx32
This is an unofficial muslx32 (musl libc and x32 ABI) overlay for Gentoo Linux

This profile uses a 64-bit linux kernel with x32 abi compatibility.  All of the userland libraries and programs are built as native x32 ABI without duplicate 64-bit and 32-bit versions (a.k.a. multilib).

Current goals:  get popular packages and necessary developer tools working on the platform/profile for widespread adoption.

Why musl and x32 and Gentoo?  Musl because it is lightweight.  X32 because it reduces memory usage.  Alpine Linux, an embedded mini distro, had Firefox tagging my USB for many tabs resulting in a big slow down.  I was really disappointed about Alpine and the shortcomings of the other previously tested distros.  It was many times slower than the RAM based distros such as Linux Mint and Slax, so there was a motivation to work on muslx32 for Gentoo.  Tiny Linux and Slax packages were pretty much outdated.  blueness said that he wouldn't make muslx32 as top priority or it wasn't his job to do or after the hardened gcc patches for the platform were ready, so I decided to just do it myself without the hardened part.

What is x32?  x32 ABI is 32-bit (4-bytes) per integer, long, pointer using all of the x86_64 general purpose registers identified as (rax,rbx,rcx,r11-r15,rsi,rdi) and using sse registers.  Long-long integers are 8 bytes.  C/C++ programs will use __ILP32__ preprocessor checks to distinguish between 32/64 bit systems.  The build system may also compare sizeof(void*) to see if it has 4 bytes for 32-bit for 8 bytes and 64-bit for LP64 (longs are 8 bytes as well as pointers) and __x86_64__ defined.  

x32 is better than x86 because the compiler can utilize the x86_64 calling convention by dumping arguments to the registers first before dumping additional arguments on the stack.  The compiler can futher optimize the code by reducing the number of instructions executed and utilize the full register and 64 bit instructions.

x32 is better than x86_64 because of reduced pointer size and reduced virtual space.  Reduced virtual space is better safeguard against memory hogs and better memory/cache locality to reduce cache/page miss in theory.

Disadvantages of this platform:  No binary packages work (e.g. spotify, genymotion, virtualbox, etc.) since no major distro currently completely supports it so no incentive to offer a x32 ABI version.  Some SIMD assembly optimizations are not enabled.  Some assembly based packages don't work because they need to be hand edited.  It is not multilib meaning that there may be problems with packages that only offer x86 or x86_64 like wine [which has no x32 support].

Other recommendations?  Use -Os and use kernel zswap+zbud to significantly reduce swapping.  Use cache to ram for Firefox if using Gentoo from a usbstick.

You need use crossdev to build this.  Crossdev is used to build the cross-compile toolchain.  Use the cross-compile toolchain to build system.  Use the system to build world.  The result is a stage 3/4 image like the tarball you download from Gentoo.  It sounds easy but there are a lot of broken ebuilds and packages that need patches.  It took me several weeks to get it right.  I give you the overlay this time, so it will only take you a few days.

Some patches for musl libc and x32 came from Alpine Linux (Natanael Copa), Void Linux, debian x32 port (Adam Borowski), musl overlay (Anthony G. Basile/blueness), musl-extras (Aric Belsito/lluixhi)) .... (will update this list)

What you can do to help?:  
-Clean the ebuilds with proper x32 ABI and musl CHOST checks and submit them to Gentoo.
-Write/Fix assembly code for the jit based packages and assembly based packages.
-Test and patch new ebuilds for these use cases or stakeholders: server, web, gaming, etc, entertainment, developer, science, business, graphic artists.
-Fix the build system to get rid of the bashrc script and odd quirks.
-Check and fix packages that use elf_x86_64 when it should link using elf32_x86_64.
-Check and fix packages that use constant numbers for syscalls.  The syscall needs to added/or'ed by __X32_SYSCALL_BIT or 0x40000000.
-Check all sizeof(void*) and similar to be sure they are in the 4G address range if porting from 64 bit code.
-Replace all important longs that assume 64-bit as long long.  In x32, long is actual 4 bytes.

Where can we meet on IRC?
#gentoo-muslx32 on freenode

## Works

package | notes
--- | ---
firefox 45.x only | except when using pulseaudio and jit.  javascript works but through interpreter. YouTube works with alsa audio.  firefox 47+ and 49+ is broken on x32 with 45.x patches applied.
strace | for debugging from this overlay.  It depends on musl from this overlay since bits/user.h is broken in musl.
gdb | for debugging from this overlay.  It depends on musl from this overlay since bits/user.h is broken in musl.
X | for windowing system
wpa_supplicant | for wifi
xf86-video-nouveau |
xf86-video-ati |
mplayer | 
mpd |
geany |
dwm |
xfce4 |
aterm | from this overlay
xfce4-terminal |
gimp |
xscreensaver |
glxgears from mesa-progs |
chrony and ntpd work | chrony needs musl struct timex patched with musl from this overlay.

## Broken

(do not use the ebuild and associated patches from this overlay if broken.  my personal patches may add more complications so do it from scratch again): 

package | notes
--- | ---
Makefile.in or make system | use my bashrc scripts to fix it see below.
Chromium | v8 javascript engine is broken for x32.  Intel V8 X32 team (Chih-Ping Chen, Dale Schouten, Haitao Feng, Peter Jensen and Weiliang Lin) were working on it in May 2013-Jun 2014, but it has been neglected and doesn't work since the testing of >=52.0.2743.116 of Chromium.  I can confirm that the older standalone v8 works from https://github.com/fenghaitao/v8/ on x32. I decided to stop working on this.  As of 20170507 there is some chance if someone other than me that will be able to get Chromium on x32.  The strategy to fix this is undo some changesets that cause the breakage and it has been working up to 5.4.200.  We need 5.4.500.31 which exactly matches chromium-54.0.2840.59 stable from the portage tree because the wrappers depend on a particular version of v8.  Progress can be found at https://github.com/orsonteodoro/muslx32/issues/2.  I stopped working on this because I cannot find the bug.  I had a working v8 but there are problems on the browser side not v8 JavaScript engine which did pass unit tests up to 5.3.201 and did have a working mksnapshot as of 5.4.259.  The browser interface does work, but it is not showing content from the web.
wayland | dunno if it is just weston causing the problem
weston | segfaults
pulseaudio | cannot connect pavucontrol or pulseaudio apps
webkit-gtk | just gives a blank screen.  jit is broken or something else related not relevant to the patches.  JavaScriptCore works for 2.0.4 on x32 works on standalone but it doesn't work when applied to 2.12.3.  2.0.4. is unstable and crashes out a lot.  Also, it seems that the LLint won't work alone until you enable the jit.  Yuqiang Xian of Intel was working on it but stopped in Apr 2013.
evdev | semi broken and quirky; dev permissions need to be manually set or devices reloaded. init script fixes are in these instructions
grub2-install | doesn't work natively in x32 use lilo.  you can still install grub from amd64 profile.
xterm | works in root but not as user
mono | C# (incomplete patch from PLD Linux... was testing) details (https://www.mail-archive.com/pld-cvs-commit@lists.pld-linux.org/msg361561.html) on what needs to be done.  From previous attempt, the fix is not trivial which PLD would suggest.
nodejs | depends on v8.  v8 doesn't support x32.
import (from imagematick) | cannot take a screenshot use imlib2 
wine | it's broken and never supported x32.  x86 (win32/win16) may never be supported but x86_64 based windows apps may be supported.  Problems and immaturity of musl may prevent it be ported to muslx32.  win32 uses x86 calling conventions which make it possibly impossible to support.  x32 uses x86_64 assembly instructions and same registers which makes it easier to port but porting may not go well and limit to programs compiled with the wine toolchain than those produced with the microsoft toolchain.
libreoffice | the one from musl overlay is broken and can't be compiled on this toolchain or configuration.
clang | clang 3.7 does work with compiling a hello world program, but it still broken when used as system-wide compiler.  It failed with a simple program like gnome-calculator.  https://llvm.org/bugs/show_bug.cgi?id=13666 at comment 3 needs to be fixed first.  This ebuild will compile clang to the end even though the bug report says otherwise because we can skip over compiling atomic.c and gcc_personality_v0.c.

Instructions for creating the muslx32 toolchain:
You need the muslx32toolkit below.  It has convenience scripts to build stage3 and stage4 images.  You can build the images using your existing Gentoo installation.


https://github.com/orsonteodoro/muslx32toolkit
