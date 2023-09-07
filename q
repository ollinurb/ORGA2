syscall(2)                    System Calls Manual                   syscall(2)

NAME
       syscall - indirect system call

LIBRARY
       Standard C library (libc, -lc)

SYNOPSIS
       #include <sys/syscall.h>      /* Definition of SYS_* constants */
       #include <unistd.h>

       long syscall(long number, ...);

   Feature Test Macro Requirements for glibc (see feature_test_macros(7)):

       syscall():
           Since glibc 2.19:
               _DEFAULT_SOURCE
           Before glibc 2.19:
               _BSD_SOURCE || _SVID_SOURCE

DESCRIPTION
       syscall() is a small library function that invokes the system call
       whose assembly language interface has the specified number with the
       specified arguments.  Employing syscall() is useful, for example, when
       invoking a system call that has no wrapper function in the C library.

       syscall() saves CPU registers before making the system call, restores
       the registers upon return from the system call, and stores any error
       returned by the system call in errno(3).

       Symbolic constants for system call numbers can be found in the header
       file <sys/syscall.h>.

RETURN VALUE
       The return value is defined by the system call being invoked.  In
       general, a 0 return value indicates success.  A -1 return value
       indicates an error, and an error number is stored in errno.

NOTES
       syscall() first appeared in 4BSD.

   Architecture-specific requirements
       Each architecture ABI has its own requirements on how system call
       arguments are passed to the kernel.  For system calls that have a glibc
       wrapper (e.g., most system calls), glibc handles the details of copying
       arguments to the right registers in a manner suitable for the
       architecture.  However, when using syscall() to make a system call, the
       caller might need to handle architecture-dependent details; this
       requirement is most commonly encountered on certain 32-bit
       architectures.

       For example, on the ARM architecture Embedded ABI (EABI), a 64-bit
       value (e.g., long long) must be aligned to an even register pair.
       Thus, using syscall() instead of the wrapper provided by glibc, the
       readahead(2) system call would be invoked as follows on the ARM
       architecture with the EABI in little endian mode:

           syscall(SYS_readahead, fd, 0,
                   (unsigned int) (offset & 0xFFFFFFFF),
