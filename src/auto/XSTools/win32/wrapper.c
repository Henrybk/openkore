/*
 * This file was generated automatically by ExtUtils::ParseXS version 3.40 from the
 * contents of wrapper.xs. Do not edit this file, edit wrapper.xs instead.
 *
 *    ANY CHANGES MADE HERE WILL BE LOST!
 *
 */

#line 1 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <Tlhelp32.h>
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "locale.c"
#include "utils.h"

#line 21 "src\\auto\\XSTools\\win32\\wrapper.c"
#ifndef PERL_UNUSED_VAR
#  define PERL_UNUSED_VAR(var) if (0) var = var
#endif

#ifndef dVAR
#  define dVAR		dNOOP
#endif


/* This stuff is not part of the API! You have been warned. */
#ifndef PERL_VERSION_DECIMAL
#  define PERL_VERSION_DECIMAL(r,v,s) (r*1000000 + v*1000 + s)
#endif
#ifndef PERL_DECIMAL_VERSION
#  define PERL_DECIMAL_VERSION \
	  PERL_VERSION_DECIMAL(PERL_REVISION,PERL_VERSION,PERL_SUBVERSION)
#endif
#ifndef PERL_VERSION_GE
#  define PERL_VERSION_GE(r,v,s) \
	  (PERL_DECIMAL_VERSION >= PERL_VERSION_DECIMAL(r,v,s))
#endif
#ifndef PERL_VERSION_LE
#  define PERL_VERSION_LE(r,v,s) \
	  (PERL_DECIMAL_VERSION <= PERL_VERSION_DECIMAL(r,v,s))
#endif

/* XS_INTERNAL is the explicit static-linkage variant of the default
 * XS macro.
 *
 * XS_EXTERNAL is the same as XS_INTERNAL except it does not include
 * "STATIC", ie. it exports XSUB symbols. You probably don't want that
 * for anything but the BOOT XSUB.
 *
 * See XSUB.h in core!
 */


/* TODO: This might be compatible further back than 5.10.0. */
#if PERL_VERSION_GE(5, 10, 0) && PERL_VERSION_LE(5, 15, 1)
#  undef XS_EXTERNAL
#  undef XS_INTERNAL
#  if defined(__CYGWIN__) && defined(USE_DYNAMIC_LOADING)
#    define XS_EXTERNAL(name) __declspec(dllexport) XSPROTO(name)
#    define XS_INTERNAL(name) STATIC XSPROTO(name)
#  endif
#  if defined(__SYMBIAN32__)
#    define XS_EXTERNAL(name) EXPORT_C XSPROTO(name)
#    define XS_INTERNAL(name) EXPORT_C STATIC XSPROTO(name)
#  endif
#  ifndef XS_EXTERNAL
#    if defined(HASATTRIBUTE_UNUSED) && !defined(__cplusplus)
#      define XS_EXTERNAL(name) void name(pTHX_ CV* cv __attribute__unused__)
#      define XS_INTERNAL(name) STATIC void name(pTHX_ CV* cv __attribute__unused__)
#    else
#      ifdef __cplusplus
#        define XS_EXTERNAL(name) extern "C" XSPROTO(name)
#        define XS_INTERNAL(name) static XSPROTO(name)
#      else
#        define XS_EXTERNAL(name) XSPROTO(name)
#        define XS_INTERNAL(name) STATIC XSPROTO(name)
#      endif
#    endif
#  endif
#endif

/* perl >= 5.10.0 && perl <= 5.15.1 */


/* The XS_EXTERNAL macro is used for functions that must not be static
 * like the boot XSUB of a module. If perl didn't have an XS_EXTERNAL
 * macro defined, the best we can do is assume XS is the same.
 * Dito for XS_INTERNAL.
 */
#ifndef XS_EXTERNAL
#  define XS_EXTERNAL(name) XS(name)
#endif
#ifndef XS_INTERNAL
#  define XS_INTERNAL(name) XS(name)
#endif

/* Now, finally, after all this mess, we want an ExtUtils::ParseXS
 * internal macro that we're free to redefine for varying linkage due
 * to the EXPORT_XSUB_SYMBOLS XS keyword. This is internal, use
 * XS_EXTERNAL(name) or XS_INTERNAL(name) in your code if you need to!
 */

#undef XS_EUPXS
#if defined(PERL_EUPXS_ALWAYS_EXPORT)
#  define XS_EUPXS(name) XS_EXTERNAL(name)
#else
   /* default to internal */
#  define XS_EUPXS(name) XS_INTERNAL(name)
#endif

#ifndef PERL_ARGS_ASSERT_CROAK_XS_USAGE
#define PERL_ARGS_ASSERT_CROAK_XS_USAGE assert(cv); assert(params)

/* prototype to pass -Wmissing-prototypes */
STATIC void
S_croak_xs_usage(const CV *const cv, const char *const params);

STATIC void
S_croak_xs_usage(const CV *const cv, const char *const params)
{
    const GV *const gv = CvGV(cv);

    PERL_ARGS_ASSERT_CROAK_XS_USAGE;

    if (gv) {
        const char *const gvname = GvNAME(gv);
        const HV *const stash = GvSTASH(gv);
        const char *const hvname = stash ? HvNAME(stash) : NULL;

        if (hvname)
	    Perl_croak_nocontext("Usage: %s::%s(%s)", hvname, gvname, params);
        else
	    Perl_croak_nocontext("Usage: %s(%s)", gvname, params);
    } else {
        /* Pants. I don't think that it should be possible to get here. */
	Perl_croak_nocontext("Usage: CODE(0x%" UVxf ")(%s)", PTR2UV(cv), params);
    }
}
#undef  PERL_ARGS_ASSERT_CROAK_XS_USAGE

#define croak_xs_usage        S_croak_xs_usage

#endif

/* NOTE: the prototype of newXSproto() is different in versions of perls,
 * so we define a portable version of newXSproto()
 */
#ifdef newXS_flags
#define newXSproto_portable(name, c_impl, file, proto) newXS_flags(name, c_impl, file, proto, 0)
#else
#define newXSproto_portable(name, c_impl, file, proto) (PL_Sv=(SV*)newXS(name, c_impl, file), sv_setpv(PL_Sv, proto), (CV*)PL_Sv)
#endif /* !defined(newXS_flags) */

#if PERL_VERSION_LE(5, 21, 5)
#  define newXS_deffile(a,b) Perl_newXS(aTHX_ a,b,file)
#else
#  define newXS_deffile(a,b) Perl_newXS_deffile(aTHX_ a,b)
#endif

#line 165 "src\\auto\\XSTools\\win32\\wrapper.c"

XS_EUPXS(XS_Utils__Win32_GetProcByName); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_GetProcByName)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "name");
    {
	char *	name = (char *)SvPV_nolen(ST(0))
;
	unsigned long	RETVAL;
	dXSTARG;

	RETVAL = GetProcByName(name);
	XSprePUSH; PUSHu((UV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_InjectDLL); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_InjectDLL)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "ProcID, dll");
    {
	unsigned long	ProcID = (unsigned long)SvUV(ST(0))
;
	char *	dll = (char *)SvPV_nolen(ST(1))
;
	bool	RETVAL;

	RETVAL = InjectDLL(ProcID, dll);
	ST(0) = boolSV(RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_ShellExecute); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_ShellExecute)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "handle, operation, file");
    {
	unsigned int	handle = (unsigned int)SvUV(ST(0))
;
	SV *	operation = ST(1)
;
	char *	file = (char *)SvPV_nolen(ST(2))
;
	int	RETVAL;
	dXSTARG;
#line 30 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		char *op = NULL;
#line 223 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 32 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		if (operation && SvOK (operation))
			op = SvPV_nolen (operation);
		RETVAL = ((int) ShellExecute((HWND) handle, op, file, NULL, NULL, SW_NORMAL)) == 42;
#line 228 "src\\auto\\XSTools\\win32\\wrapper.c"
	XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_listProcesses); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_listProcesses)
{
    dVAR; dXSARGS;
    if (items != 0)
       croak_xs_usage(cv,  "");
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
#line 41 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		HANDLE toolhelp;
		PROCESSENTRY32 pe;
#line 247 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 44 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		pe.dwSize = sizeof(PROCESSENTRY32);
		toolhelp = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
		if (Process32First(toolhelp, &pe)) {
			do {
				HV *hash;

				hash = (HV *) sv_2mortal ((SV *) newHV ());
				hv_store (hash, "exe", 3,
					newSVpv (pe.szExeFile, 0),
					0);
				hv_store (hash, "pid", 3,
					newSVuv (pe.th32ProcessID),
					0);
				XPUSHs (newRV ((SV *) hash));
			} while (Process32Next(toolhelp,&pe));
		}
		CloseHandle(toolhelp);
#line 266 "src\\auto\\XSTools\\win32\\wrapper.c"
	PUTBACK;
	return;
    }
}


XS_EUPXS(XS_Utils__Win32_playSound); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_playSound)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "file");
    {
	char *	file = (char *)SvPV_nolen(ST(0))
;
#line 66 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	sndPlaySound(NULL, SND_ASYNC);
	sndPlaySound(file, SND_ASYNC | SND_NODEFAULT);
#line 285 "src\\auto\\XSTools\\win32\\wrapper.c"
    }
    XSRETURN_EMPTY;
}


XS_EUPXS(XS_Utils__Win32_FlashWindow); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_FlashWindow)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "handle");
    {
	IV	handle = (IV)SvIV(ST(0))
;
#line 73 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	if (GetActiveWindow() != (HWND) handle)
		FlashWindow((HWND) handle, TRUE);
#line 303 "src\\auto\\XSTools\\win32\\wrapper.c"
    }
    XSRETURN_EMPTY;
}


XS_EUPXS(XS_Utils__Win32_OpenProcess); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_OpenProcess)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "Access, ProcID");
    {
	unsigned long	Access = (unsigned long)SvUV(ST(0))
;
	unsigned long	ProcID = (unsigned long)SvUV(ST(1))
;
	unsigned long	RETVAL;
	dXSTARG;
#line 81 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		RETVAL = ((DWORD) OpenProcess((DWORD)Access, 0, (DWORD)ProcID));
#line 324 "src\\auto\\XSTools\\win32\\wrapper.c"
	XSprePUSH; PUSHu((UV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_SystemInfo_PageSize); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_SystemInfo_PageSize)
{
    dVAR; dXSARGS;
    if (items != 0)
       croak_xs_usage(cv,  "");
    {
	unsigned long	RETVAL;
	dXSTARG;
#line 88 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		SYSTEM_INFO si;
#line 342 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 90 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		GetSystemInfo((LPSYSTEM_INFO)&si);
		RETVAL = si.dwPageSize;
#line 346 "src\\auto\\XSTools\\win32\\wrapper.c"
	XSprePUSH; PUSHu((UV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_SystemInfo_MinAppAddress); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_SystemInfo_MinAppAddress)
{
    dVAR; dXSARGS;
    if (items != 0)
       croak_xs_usage(cv,  "");
    {
	unsigned long	RETVAL;
	dXSTARG;
#line 98 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		SYSTEM_INFO si;
#line 364 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 100 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		GetSystemInfo((LPSYSTEM_INFO)&si);
		RETVAL = ((DWORD) si.lpMinimumApplicationAddress);
#line 368 "src\\auto\\XSTools\\win32\\wrapper.c"
	XSprePUSH; PUSHu((UV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_SystemInfo_MaxAppAddress); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_SystemInfo_MaxAppAddress)
{
    dVAR; dXSARGS;
    if (items != 0)
       croak_xs_usage(cv,  "");
    {
	unsigned long	RETVAL;
	dXSTARG;
#line 108 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		SYSTEM_INFO si;
#line 386 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 110 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		GetSystemInfo((LPSYSTEM_INFO)&si);
		RETVAL = ((DWORD) si.lpMaximumApplicationAddress);
#line 390 "src\\auto\\XSTools\\win32\\wrapper.c"
	XSprePUSH; PUSHu((UV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_VirtualProtectEx); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_VirtualProtectEx)
{
    dVAR; dXSARGS;
    if (items != 4)
       croak_xs_usage(cv,  "ProcHND, lpAddr, dwSize, dwProtection");
    {
	unsigned long	ProcHND = (unsigned long)SvUV(ST(0))
;
	unsigned long	lpAddr = (unsigned long)SvUV(ST(1))
;
	unsigned long	dwSize = (unsigned long)SvUV(ST(2))
;
	unsigned long	dwProtection = (unsigned long)SvUV(ST(3))
;
	unsigned long	RETVAL;
	dXSTARG;
#line 122 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		DWORD old;
#line 416 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 124 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		if (0 == VirtualProtectEx((HANDLE)ProcHND, (LPVOID)lpAddr, (SIZE_T)dwSize, (DWORD)dwProtection, (PDWORD)&old)) {
			RETVAL = 0;
		} else {
			RETVAL = old;
		}
#line 423 "src\\auto\\XSTools\\win32\\wrapper.c"
	XSprePUSH; PUSHu((UV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_ReadProcessMemory); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_ReadProcessMemory)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "ProcHND, lpAddr, dwSize");
    {
	unsigned long	ProcHND = (unsigned long)SvUV(ST(0))
;
	unsigned long	lpAddr = (unsigned long)SvUV(ST(1))
;
	unsigned long	dwSize = (unsigned long)SvUV(ST(2))
;
	SV *	RETVAL;
#line 138 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		DWORD bytesRead;
		LPVOID buffer;
#line 447 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 141 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		buffer = malloc(dwSize);
		if (0 == ReadProcessMemory((HANDLE)ProcHND, (LPCVOID)lpAddr, buffer, (SIZE_T)dwSize, (SIZE_T*)&bytesRead)) {
			XSRETURN_UNDEF;
		} else {
			RETVAL = newSVpvn((char *)buffer, bytesRead);
		}
		free(buffer);
#line 456 "src\\auto\\XSTools\\win32\\wrapper.c"
	RETVAL = sv_2mortal(RETVAL);
	ST(0) = RETVAL;
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_WriteProcessMemory); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_WriteProcessMemory)
{
    dVAR; dXSARGS;
    if (items != 3)
       croak_xs_usage(cv,  "ProcHND, lpAddr, svData");
    {
	unsigned long	ProcHND = (unsigned long)SvUV(ST(0))
;
	unsigned long	lpAddr = (unsigned long)SvUV(ST(1))
;
	SV *	svData = ST(2)
;
	unsigned long	RETVAL;
	dXSTARG;
#line 157 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		LPCVOID lpBuffer;
		STRLEN dwSize;
		DWORD bytesWritten;
#line 483 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 161 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		if (0 == SvPOK(svData)) {
			RETVAL = 0;
		} else {
			lpBuffer = (LPCVOID) SvPV(svData, dwSize);
			if (0 == WriteProcessMemory((HANDLE)ProcHND, (LPVOID)lpAddr, lpBuffer, (SIZE_T)dwSize, (SIZE_T*)&bytesWritten)) {
				RETVAL = 0;
			} else {
				RETVAL = bytesWritten;
			}
		}
#line 495 "src\\auto\\XSTools\\win32\\wrapper.c"
	XSprePUSH; PUSHu((UV)RETVAL);
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_CloseProcess); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_CloseProcess)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "Handle");
    {
	unsigned long	Handle = (unsigned long)SvUV(ST(0))
;
#line 178 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
		CloseHandle((HANDLE)Handle);
#line 513 "src\\auto\\XSTools\\win32\\wrapper.c"
    }
    XSRETURN_EMPTY;
}


XS_EUPXS(XS_Utils__Win32_getLanguageName); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_getLanguageName)
{
    dVAR; dXSARGS;
    if (items != 0)
       croak_xs_usage(cv,  "");
    {
	char *	RETVAL;
	dXSTARG;

	RETVAL = getLanguageName();
	sv_setpv(TARG, RETVAL); XSprePUSH; PUSHTARG;
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_printConsole); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_printConsole)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "message");
    {
	SV *	message = ST(0)
;
#line 188 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	if (message && SvOK (message)) {
		char *msg;
		STRLEN len;

		msg = SvPV (message, len);
		if (msg != NULL)
			printConsole(msg, len);
	}
#line 554 "src\\auto\\XSTools\\win32\\wrapper.c"
    }
    XSRETURN_EMPTY;
}


XS_EUPXS(XS_Utils__Win32_setConsoleTitle); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_setConsoleTitle)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "title");
    {
	SV *	title = ST(0)
;
#line 201 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	if (title && SvOK (title)) {
		char *str;
		STRLEN len;

		str = SvPV (title, len);
		if (str != NULL)
			setConsoleTitle(str, len);
	}
#line 578 "src\\auto\\XSTools\\win32\\wrapper.c"
    }
    XSRETURN_EMPTY;
}


XS_EUPXS(XS_Utils__Win32_codepageToUTF8); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_codepageToUTF8)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "codepage, str");
    {
	unsigned int	codepage = (unsigned int)SvUV(ST(0))
;
	SV *	str = ST(1)
;
	SV *	RETVAL;
#line 215 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	if (str && SvOK(str)) {
		char *s, *result;
		STRLEN len;
		unsigned int result_len;

		s = SvPV(str, len);
		result = codepageToUTF8(codepage, s, len, &result_len);
		if (result == NULL) {
			XSRETURN_UNDEF;
		}

		RETVAL = newSVpvn(result, result_len);
		SvUTF8_on(RETVAL);
		free(result);
	} else {
		XSRETURN_UNDEF;
	}
#line 614 "src\\auto\\XSTools\\win32\\wrapper.c"
	RETVAL = sv_2mortal(RETVAL);
	ST(0) = RETVAL;
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_utf8ToCodepage); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_utf8ToCodepage)
{
    dVAR; dXSARGS;
    if (items != 2)
       croak_xs_usage(cv,  "codepage, str");
    {
	unsigned int	codepage = (unsigned int)SvUV(ST(0))
;
	SV *	str = ST(1)
;
	SV *	RETVAL;
#line 240 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	if (str && SvOK(str)) {
		char *s, *result;
		STRLEN len;
		unsigned int result_len;

		s = SvPV(str, len);
		result = utf8ToCodepage(codepage, s, len, &result_len);
		if (result == NULL) {
			XSRETURN_UNDEF;
		}

		RETVAL = newSVpvn(result, result_len);
		free(result);
	} else {
		XSRETURN_UNDEF;
	}
#line 651 "src\\auto\\XSTools\\win32\\wrapper.c"
	RETVAL = sv_2mortal(RETVAL);
	ST(0) = RETVAL;
    }
    XSRETURN(1);
}


XS_EUPXS(XS_Utils__Win32_FormatMessage); /* prototype to pass -Wmissing-prototypes */
XS_EUPXS(XS_Utils__Win32_FormatMessage)
{
    dVAR; dXSARGS;
    if (items != 1)
       croak_xs_usage(cv,  "code");
    {
	int	code = (int)SvIV(ST(0))
;
	SV *	RETVAL;
#line 263 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	WCHAR buffer[1024];
	DWORD size;
#line 672 "src\\auto\\XSTools\\win32\\wrapper.c"
#line 266 "src\\\\auto\\\\XSTools\\\\win32\\\\wrapper.xs"
	size = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM, NULL, code,
		0, buffer, sizeof(buffer) - 1, NULL);
	if (size == 0) {
		XSRETURN_UNDEF;
	} else {
		char utf8buffer[1024 * 4];
		buffer[size] = 0;
		size = WideCharToMultiByte(CP_UTF8, MB_USEGLYPHCHARS, buffer, size,
			utf8buffer, sizeof(utf8buffer), NULL, NULL);
		if (size == 0) {
			XSRETURN_UNDEF;
		}
		RETVAL = newSVpvn(utf8buffer, size - 1);
		SvUTF8_on(RETVAL);
	}
#line 689 "src\\auto\\XSTools\\win32\\wrapper.c"
	RETVAL = sv_2mortal(RETVAL);
	ST(0) = RETVAL;
    }
    XSRETURN(1);
}

#ifdef __cplusplus
extern "C"
#endif
XS_EXTERNAL(boot_Utils__Win32); /* prototype to pass -Wmissing-prototypes */
XS_EXTERNAL(boot_Utils__Win32)
{
#if PERL_VERSION_LE(5, 21, 5)
    dVAR; dXSARGS;
#else
    dVAR; dXSBOOTARGSXSAPIVERCHK;
#endif
#if (PERL_REVISION == 5 && PERL_VERSION < 9)
    char* file = __FILE__;
#else
    const char* file = __FILE__;
#endif

    PERL_UNUSED_VAR(file);

    PERL_UNUSED_VAR(cv); /* -W */
    PERL_UNUSED_VAR(items); /* -W */
#if PERL_VERSION_LE(5, 21, 5)
    XS_VERSION_BOOTCHECK;
#  ifdef XS_APIVERSION_BOOTCHECK
    XS_APIVERSION_BOOTCHECK;
#  endif
#endif

        (void)newXSproto_portable("Utils::Win32::GetProcByName", XS_Utils__Win32_GetProcByName, file, "$");
        (void)newXSproto_portable("Utils::Win32::InjectDLL", XS_Utils__Win32_InjectDLL, file, "$$");
        (void)newXSproto_portable("Utils::Win32::ShellExecute", XS_Utils__Win32_ShellExecute, file, "$$$");
        (void)newXSproto_portable("Utils::Win32::listProcesses", XS_Utils__Win32_listProcesses, file, "");
        (void)newXSproto_portable("Utils::Win32::playSound", XS_Utils__Win32_playSound, file, "$");
        (void)newXSproto_portable("Utils::Win32::FlashWindow", XS_Utils__Win32_FlashWindow, file, "$");
        (void)newXSproto_portable("Utils::Win32::OpenProcess", XS_Utils__Win32_OpenProcess, file, "$$");
        (void)newXSproto_portable("Utils::Win32::SystemInfo_PageSize", XS_Utils__Win32_SystemInfo_PageSize, file, "");
        (void)newXSproto_portable("Utils::Win32::SystemInfo_MinAppAddress", XS_Utils__Win32_SystemInfo_MinAppAddress, file, "");
        (void)newXSproto_portable("Utils::Win32::SystemInfo_MaxAppAddress", XS_Utils__Win32_SystemInfo_MaxAppAddress, file, "");
        (void)newXSproto_portable("Utils::Win32::VirtualProtectEx", XS_Utils__Win32_VirtualProtectEx, file, "$$$$");
        (void)newXSproto_portable("Utils::Win32::ReadProcessMemory", XS_Utils__Win32_ReadProcessMemory, file, "$$$");
        (void)newXSproto_portable("Utils::Win32::WriteProcessMemory", XS_Utils__Win32_WriteProcessMemory, file, "$$$");
        (void)newXSproto_portable("Utils::Win32::CloseProcess", XS_Utils__Win32_CloseProcess, file, "$");
        (void)newXSproto_portable("Utils::Win32::getLanguageName", XS_Utils__Win32_getLanguageName, file, "");
        (void)newXSproto_portable("Utils::Win32::printConsole", XS_Utils__Win32_printConsole, file, "$");
        (void)newXSproto_portable("Utils::Win32::setConsoleTitle", XS_Utils__Win32_setConsoleTitle, file, "$");
        (void)newXSproto_portable("Utils::Win32::codepageToUTF8", XS_Utils__Win32_codepageToUTF8, file, "$$");
        (void)newXSproto_portable("Utils::Win32::utf8ToCodepage", XS_Utils__Win32_utf8ToCodepage, file, "$$");
        (void)newXSproto_portable("Utils::Win32::FormatMessage", XS_Utils__Win32_FormatMessage, file, "$");
#if PERL_VERSION_LE(5, 21, 5)
#  if PERL_VERSION_GE(5, 9, 0)
    if (PL_unitcheckav)
        call_list(PL_scopestack_ix, PL_unitcheckav);
#  endif
    XSRETURN_YES;
#else
    Perl_xs_boot_epilog(aTHX_ ax);
#endif
}
