# Makefile for Borland C++ 5.5

# Will build a Win32 static library libpq.lib
#        and a Win32 dynamic library libpq.dll with import library libpqdll.lib

# Borland C++ base install directory goes here
# BCB=d:\Borland\Bcc55

!MESSAGE Building the Win32 DLL and Static Library...
!MESSAGE
!IF "$(CFG)" == ""
CFG=Release
!MESSAGE No configuration specified. Defaulting to Release.
!MESSAGE
!ELSE
!MESSAGE Configuration "$(CFG)"
!MESSAGE
!ENDIF

!IF "$(CFG)" != "Release" && "$(CFG)" != "Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running MAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE
!MESSAGE make  -DCFG=[Release | Debug] /f bcc32.mak
!MESSAGE
!MESSAGE Possible choices for configuration are:
!MESSAGE
!MESSAGE "Release" (Win32 Release DLL and Static Library)
!MESSAGE "Debug" (Win32 Debug DLL and Static Library)
!MESSAGE
!ERROR An invalid configuration was specified.
!ENDIF

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

!IF "$(CFG)" == "Debug"
DEBUG=1
OUTDIR=.\Debug
INTDIR=.\Debug
!ELSE
OUTDIR=.\Release
INTDIR=.\Release
!ENDIF

OUTFILENAME=blibpq

USERDEFINES=FRONTEND;NDEBUG;WIN32;_WINDOWS;HAVE_VSNPRINTF;HAVE_STRDUP;

CPP=bcc32.exe
CPP_PROJ = -I$(BCB)\include;..\..\include -WD -c -D$(USERDEFINES) -tWM \
		-a8 -X -w-use -w-par -w-pia -w-csu -w-aus -w-ccc

!IFDEF DEBUG
CPP_PROJ	= $(CPP_PROJ) -Od -r- -k -v -y -vi- -D_DEBUG
!else
CPP_PROJ	= $(CPP_PROJ) -O -Oi -OS -DNDEBUG
!endif

CLEAN :
	-@erase "$(INTDIR)\getaddrinfo.obj"
	-@erase "$(INTDIR)\pgstrcasecmp.obj"
	-@erase "$(INTDIR)\thread.obj"
	-@erase "$(INTDIR)\inet_aton.obj"
	-@erase "$(INTDIR)\crypt.obj"
	-@erase "$(INTDIR)\noblock.obj"
	-@erase "$(INTDIR)\md5.obj"
	-@erase "$(INTDIR)\ip.obj"
	-@erase "$(INTDIR)\fe-auth.obj"
	-@erase "$(INTDIR)\fe-protocol2.obj"
	-@erase "$(INTDIR)\fe-protocol3.obj"
	-@erase "$(INTDIR)\fe-connect.obj"
	-@erase "$(INTDIR)\fe-exec.obj"
	-@erase "$(INTDIR)\fe-lobj.obj"
	-@erase "$(INTDIR)\fe-misc.obj"
	-@erase "$(INTDIR)\fe-print.obj"
	-@erase "$(INTDIR)\fe-secure.obj"
	-@erase "$(INTDIR)\pqexpbuffer.obj"
	-@erase "$(INTDIR)\pqsignal.obj"
	-@erase "$(OUTDIR)\libpqdll.obj"
	-@erase "$(OUTDIR)\win32.obj"
	-@erase "$(INTDIR)\wchar.obj"
	-@erase "$(INTDIR)\encnames.obj"
	-@erase "$(INTDIR)\pthread-win32.obj"
	-@erase "$(OUTDIR)\$(OUTFILENAME).lib"
	-@erase "$(OUTDIR)\$(OUTFILENAME)dll.lib"
	-@erase "$(OUTDIR)\libpq.res"
	-@erase "$(OUTDIR)\$(OUTFILENAME).dll"
	-@erase "$(OUTDIR)\$(OUTFILENAME).tds"
	-@erase "$(INTDIR)\pg_config_paths.h"

LIB32=tlib.exe
LIB32_FLAGS= 
LIB32_OBJS= \
	"$(INTDIR)\win32.obj" \
	"$(INTDIR)\getaddrinfo.obj" \
	"$(INTDIR)\pgstrcasecmp.obj" \
	"$(INTDIR)\thread.obj" \
	"$(INTDIR)\inet_aton.obj" \
	"$(INTDIR)\crypt.obj" \
	"$(INTDIR)\noblock.obj" \
	"$(INTDIR)\md5.obj" \
	"$(INTDIR)\ip.obj" \
	"$(INTDIR)\fe-auth.obj" \
	"$(INTDIR)\fe-protocol2.obj" \
	"$(INTDIR)\fe-protocol3.obj" \
	"$(INTDIR)\fe-connect.obj" \
	"$(INTDIR)\fe-exec.obj" \
	"$(INTDIR)\fe-lobj.obj" \
	"$(INTDIR)\fe-misc.obj" \
	"$(INTDIR)\fe-print.obj" \
	"$(INTDIR)\fe-secure.obj" \
	"$(INTDIR)\pqexpbuffer.obj" \
	"$(INTDIR)\pqsignal.obj" \
	"$(INTDIR)\wchar.obj" \
	"$(INTDIR)\encnames.obj" \
	"$(INTDIR)\pthread-win32.obj"


RSC=brcc32.exe
RSC_PROJ=-l 0x409 -i$(BCB)\include -fo"$(INTDIR)\libpq.res"

LINK32=ilink32.exe
LINK32_FLAGS = -Gn -L$(BCB)\lib;$(INTDIR); -x -Tpd -v
LINK32_OBJS= "$(INTDIR)\libpqdll.obj"

ALL: config "$(OUTDIR)" "$(OUTDIR)\blibpq.dll" "$(OUTDIR)\blibpq.lib"

config: ..\..\include\pg_config.h pthread.h pg_config_paths.h

..\..\include\pg_config.h: ..\..\include\pg_config.h.win32
	copy ..\..\include\pg_config.h.win32 ..\..\include\pg_config.h

pthread.h: pthread.h.win32
	copy pthread.h.win32 pthread.h

pg_config_paths.h: win32.mak
	echo #define SYSCONFDIR "" >pg_config_paths.h

"$(OUTDIR)" :
	@if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(OUTDIR)\blibpq.dll": "$(OUTDIR)\blibpq.lib" $(LINK32_OBJS) "$(INTDIR)\libpq.res" blibpqdll.def 
	$(LINK32) @&&!
	$(LINK32_FLAGS) +
	c0d32.obj $(LINK32_OBJS), +
	$@,, +
	"$(OUTDIR)\blibpq.lib" import32.lib cw32mti.lib, +
	blibpqdll.def,"$(INTDIR)\libpq.res"
!
	implib -w "$(OUTDIR)\blibpqdll.lib" blibpqdll.def $@

"$(INTDIR)\libpq.res" : "$(INTDIR)" libpq.rc
    $(RSC) $(RSC_PROJ) libpq.rc

"$(OUTDIR)\blibpq.lib": $(LIB32_OBJS)
	$(LIB32) $@ @&&!
+-"$(**: =" &^
+-")"
!


.c.obj:
	$(CPP) -o"$(INTDIR)\$&" $(CPP_PROJ) $<

