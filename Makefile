CC=g++
#CC=/usr/lib/gcc-astra/bin/g++

.DEFAULT_GOAL := all

CPP_VER= -std=c++17
OBJDIR=./tmp/obj

SRCDIR1=./
SRCDIR2=include
SRCDIR3=sources
##SRCDIR1=./

LIBS= -lrt -lpthread
LIBCONFIG=$(shell pkg-config libconfig++ --libs)
LIBMODBUS=$(shell pkg-config --libs --cflags libmodbus)
#LIBNCURSES=$(shell pkg-config ncurses --libs)

LIBS+= $(LIBCONFIG) $(LIBMODBUS) 
# $(LIBNCURSES)


#LIBS= -lconfig -lmodbus
#INCLUDES = -I/usr/include/modbus
#SOURCES=plc32.cpp plc_read.cpp
#OBJECTS=$(SOURCES:.cpp=.o)
#EXECUTABLE=hello

RED='\033[0;91m'
GRE="\033[0;32m"
YEL="\033[0;93m"
YEB="\033[1;33m"
BLU='\033[0;94m'
WHI='\033[0;97m'
NC='\033[0m' # No Color

# === C/CPP flags configuretion ===

LDFLAGS= -Wall
CFLAGS= -c -Wall
DEPFLAGS= -MD -MF
ASFLAGS= -k1 -W3 -xg -xb -xj -xp -c -O -H

WARN_FLAGS=  -Wextra -Wfatal-errors -pedantic -O2 -Wformat=2
CHECK_FLAGS= -Wshadow -Wfloat-equal -Wconversion -Wduplicated-cond -Wlogical-op
TYPES_FLAGS= -Wshift-overflow=2 -Wcast-qual -Wcast-align -fstack-protector
GLIBC_FLAGS= -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2
DEBUG_FLAGS= -g -fsanitize=address -fsanitize=undefined -fno-sanitize-recover

CFLAGS+= $(CPP_VER)
CFLAGS+= $(WARN_FLAGS)
CFLAGS+= $(CHECK_FLAGS)
CFLAGS+= $(TYPES_FLAGS)
CFLAGS+= $(GLIBC_FLAGS)
#CFLAGS+= -fanalyzer

# === Check for DEBUG build ===

$(info === The GOALS is: $(MAKECMDGOALS))

ifeq ("debug","$(filter debug,$(MAKECMDGOALS))")
CFLAGS+= $(DEBUG_FLAGS)
LDFLAGS+= $(DEBUG_FLAGS)
DO_DEBUG=YES
$(info === Debug options activated! ===)
endif

# =====================================================================

FULL_FLAGS= -Wall -Wextra -pedantic -O2 -Wshadow -Wformat=2 \
 -Wfloat-equal -Wconversion -Wlogical-op -Wshift-overflow=2 \
 -Wduplicated-cond -Wcast-qual -Wcast-align -D_GLIBCXX_DEBUG \
 -D_GLIBCXX_DEBUG_PEDANTIC -D_FORTIFY_SOURCE=2 \
 -fsanitize=address -fsanitize=undefined -fno-sanitize-recover \
 -fstack-protector

#======================================================================

SRCFORMAT1="./*.cpp,*.h"
SRCFORMAT2="$(SRCDIR2)/*.cpp,*.h"
SRCFORMAT3="$(SRCDIR3)/*.cpp,*.h"

SRCLIST1= $(patsubst %.cpp,$(OBJDIR)/%.o,$(wildcard $(SRCDIR1)/*.cpp))
SRCLIST2= $(patsubst %.cpp,$(OBJDIR)/%.o,$(wildcard $(SRCDIR2)/*.cpp)) 
SRCLIST3= $(patsubst %.cpp,$(OBJDIR)/%.o,$(wildcard $(SRCDIR3)/*.cpp)) 
SOURCELIST= $(SRCLIST1) $(SRCLIST2) $(SRCLIST3)

DEPLIST1= $(wildcard $(OBJDIR)/$(SRCDIR1)/*.cpp.d)
DEPLIST2= $(wildcard $(OBJDIR)/$(SRCDIR2)/*.cpp.d)
DEPLIST3= $(wildcard $(OBJDIR)/$(SRCDIR3)/*.cpp.d)
DEPLIST= $(DEPLIST1) $(DEPLIST2) $(DEPLIST3)

include $(DEPLIST)

#include $(wildcard $(OBJDIR)/*.cpp.d)

# =============================================
all: a.out

debug: clean a.out

libtest: a.out

# ================ Linking ================================
#a.out: #$(patsubst %.cpp,$(OBJDIR)/%.o,$(wildcard *.cpp)) $(patsubst %.cpp,$(OBJDIR)/%.o,$(wildcard include/*.cpp))

a.out: $(SOURCELIST)
ifdef DO_DEBUG
	@echo -e $(GRE)"=== Linking with DEBUG: $@"$(NC)
else
	@echo -e $(GRE)"=== Linking: $@"$(NC)
endif
	$(CC) $(LDFLAGS) $^ -o $@ $(LIBS)
ifdef DO_DEBUG
	@echo "==="
	@echo "=== Finished with DEBUG! ==="
	@echo "=== The size of executable file will be REALLY BIG. ==="
	@echo "==="
	sleep 3
else
	@echo -e $(GRE)"=== Ready. ==="$(NC)
	@ls -Fog --color $@
	@echo -e $(GRE)"=== Done. ==="$(NC)
	sleep 2
endif

#================== Compiling ==============================
$(OBJDIR)/%.o: %.cpp
ifeq ("YES","$(DO_DEBUG)")
	@echo -e $(YEB)"=== Compiling with DEBUG: $<"$(NC)
else
	@echo -e $(YEL)"=== Compiling: $<"$(NC)
endif
	$(CC) $(CFLAGS) $(DEPFLAGS) $(OBJDIR)/$<.d -o $@ $<
#	$(CC) -dumpdir obj/ $(CFLAGS) $(DEPFLAGS) ./obj/$<.d $<
#       gcc -c -MD $<

# ================== Cleaning =============================
clean: format-linux
	@echo -e $(BLU)"=== Cleaning UP..."$(NC)
	rm -rfv $(OBJDIR)/*.o $(OBJDIR)/*.d
	rm -rfv $(OBJDIR)/$(SRCDIR2)/*.o $(OBJDIR)/$(SRCDIR2)/*.d
	rm -rfv $(OBJDIR)/$(SRCDIR3)/*.o $(OBJDIR)/$(SRCDIR3)/*.d
	rm -rfv a.out

# ================== Formatting ===========================
# Simple format current directory only
clang:
	clang-format -i --verbose *.cpp *.h

google:
	clang-format -i -style=google --verbose *.cpp *.h

# ================ ALL FILE recursively! ==================
# Reindent *.cpp to K&R code-style
format-kr:
	astyle $(ASFLAGS) -n --style=kr $(SRCFORMAT1), $(SRCFORMAT2), $(SRCFORMAT3)
#"./*.cpp,*.h", "include/*.cpp,*.h"

# Reindent *.cpp to Linux code-style
format-linux:
	astyle $(ASFLAGS) -n -s2 --style=linux $(SRCFORMAT1), $(SRCFORMAT2), $(SRCFORMAT3)

# Reindent *.cpp to Allman code-style
format-allman:
	astyle $(ASFLAGS) -n --style=allman $(SRCFORMAT1), $(SRCFORMAT2), $(SRCFORMAT3)

# Reindent *.cpp to Google code-style
format-google2:
	astyle $(ASFLAGS) -n -s2 --style=google $(SRCFORMAT1), $(SRCFORMAT2), $(SRCFORMAT3)

# Reindent *.cpp to LLVM code-style
format-clang:
	clang-format -i --verbose *.cpp *.h $(SRCDIR2)/*.cpp $(SRCDIR2)/*.h $(SRCDIR3)/*.cpp $(SRCDIR3)/*.h

# Reindent *.cpp to Google code-style
format-google:
	clang-format -i -style=google --verbose *.cpp *.h $(SRCDIR2)/*.cpp $(SRCDIR2)/*.h $(SRCDIR3)/*.cpp $(SRCDIR3)/*.h


# =======================================
#$(EXECUTABLE): $(OBJECTS)
#	$(CC) $(LDFLAGS) $(OBJECTS) -o $@
